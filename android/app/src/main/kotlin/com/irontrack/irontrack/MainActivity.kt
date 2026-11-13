package com.irontrack.irontrack

import android.content.Intent
import android.os.Build
import androidx.core.content.ContextCompat
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.tasks.await
import org.json.JSONObject

class MainActivity : FlutterActivity(), MessageClient.OnMessageReceivedListener, CapabilityClient.OnCapabilityChangedListener {
    private val LIVE_ACTIVITY_CHANNEL = "com.irontrack/live_activity"
    private val WEARABLE_CHANNEL = "com.irontrack/wearable"
    private val WEARABLE_EVENTS = "com.irontrack/wearable_events"

    private var liveActivityMethodChannel: MethodChannel? = null
    private var wearableMethodChannel: MethodChannel? = null
    private var wearableEventSink: EventChannel.EventSink? = null

    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())
    private lateinit var messageClient: MessageClient
    private lateinit var nodeClient: NodeClient
    private lateinit var capabilityClient: CapabilityClient

    private val connectedWatchNodes = mutableSetOf<Node>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Setup Wearable Google Play Services clients
        messageClient = Wearable.getMessageClient(this)
        nodeClient = Wearable.getNodeClient(this)
        capabilityClient = Wearable.getCapabilityClient(this)

        messageClient.addListener(this)
        capabilityClient.addListener(this, "av_fitness_wear")

        // 1. Live Activity Channel (Existing)
        liveActivityMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, LIVE_ACTIVITY_CHANNEL)
        WorkoutActionReceiver.methodChannelDelegate = { method, args ->
            liveActivityMethodChannel?.invokeMethod(method, args)
        }

        liveActivityMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "startLiveActivity", "updateLiveActivity" -> {
                    val intent = Intent(this, WorkoutForegroundService::class.java).apply {
                        action = WorkoutForegroundService.ACTION_START_OR_UPDATE
                        putExtra("workoutName", call.argument<String>("workoutName") ?: "Active Workout")
                        putExtra("currentExercise", call.argument<String>("currentExercise") ?: "")
                        putExtra("completedSets", call.argument<Int>("completedSets") ?: 0)
                        putExtra("totalSets", call.argument<Int>("totalSets") ?: 0)
                        putExtra("startTimeMillis", call.argument<Long>("startTimeMillis") ?: System.currentTimeMillis())
                        putExtra("isResting", call.argument<Boolean>("isResting") ?: false)
                        putExtra("restTimeRemaining", call.argument<Int>("restTimeRemaining") ?: 0)
                        putExtra("currentSetNumber", call.argument<Int>("currentSetNumber") ?: -1)
                        putExtra("currentSetWeight", call.argument<Double>("currentSetWeight") ?: -1.0)
                        putExtra("currentSetReps", call.argument<Int>("currentSetReps") ?: -1)
                        putExtra("nextSetExerciseId", call.argument<String>("nextSetExerciseId"))
                        putExtra("nextSetId", call.argument<String>("nextSetId"))
                    }
                    try {
                        ContextCompat.startForegroundService(this, intent)
                    } catch (e: Exception) {
                        android.util.Log.e("LiveActivity", "Failed to start foreground service", e)
                    }
                    result.success(true)
                }
                "stopLiveActivity" -> {
                    val intent = Intent(this, WorkoutForegroundService::class.java).apply {
                        action = WorkoutForegroundService.ACTION_STOP
                    }
                    startService(intent)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // 2. Wearable Events Stream
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, WEARABLE_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    wearableEventSink = events
                    refreshConnectedWatchNodes()
                }
                override fun onCancel(arguments: Any?) {
                    wearableEventSink = null
                }
            }
        )

        // 3. Wearable Control Channel
        wearableMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, WEARABLE_CHANNEL)
        wearableMethodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getConnectedWatch" -> {
                    scope.launch {
                        try {
                            val nodes: List<Node> = Tasks.await(nodeClient.connectedNodes)
                            val isConnected = nodes.isNotEmpty()
                            val watchName = nodes.firstOrNull()?.displayName ?: ""
                            val watchId = nodes.firstOrNull()?.id ?: ""
                            withContext(Dispatchers.Main) {
                                result.success(mapOf(
                                    "connected" to isConnected,
                                    "name" to watchName,
                                    "id" to watchId,
                                    "count" to nodes.size
                                ))
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.success(mapOf(
                                    "connected" to false,
                                    "name" to "",
                                    "id" to "",
                                    "count" to 0
                                ))
                            }
                        }
                    }
                }
                "sendWorkoutState" -> {
                    val stateJson = call.argument<String>("state") ?: "{}"
                    sendToConnectedWatches("/workout/state", stateJson.toByteArray(Charsets.UTF_8))
                    result.success(true)
                }
                "sendWorkoutStop" -> {
                    sendToConnectedWatches("/workout/stop", ByteArray(0))
                    result.success(true)
                }
                "pingWatch" -> {
                    sendToConnectedWatches("/watch/ping", ByteArray(0))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        refreshConnectedWatchNodes()
    }

    private fun refreshConnectedWatchNodes() {
        scope.launch {
            try {
                val nodes: List<Node> = Tasks.await(nodeClient.connectedNodes)
                connectedWatchNodes.clear()
                connectedWatchNodes.addAll(nodes)
                val isConnected = nodes.isNotEmpty()
                val watchName = nodes.firstOrNull()?.displayName ?: ""
                withContext(Dispatchers.Main) {
                    wearableEventSink?.success(mapOf(
                        "type" to "connection",
                        "connected" to isConnected,
                        "name" to watchName
                    ))
                }
            } catch (e: Exception) {
                android.util.Log.e("AVPhoneWearable", "Failed querying connected nodes", e)
            }
        }
    }

    private fun sendToConnectedWatches(path: String, data: ByteArray) {
        scope.launch {
            try {
                val nodes: Collection<Node> = if (connectedWatchNodes.isNotEmpty()) connectedWatchNodes else Tasks.await(nodeClient.connectedNodes)
                for (node in nodes) {
                    messageClient.sendMessage(node.id, path, data)
                }
            } catch (e: Exception) {
                android.util.Log.e("AVPhoneWearable", "Error sending message $path to watch", e)
            }
        }
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        val path = messageEvent.path
        val dataStr = String(messageEvent.data, Charsets.UTF_8)

        when (path) {
            "/health/heart_rate" -> {
                try {
                    val json = JSONObject(dataStr)
                    val bpm = json.optInt("bpm", 0)
                    val timestamp = json.optLong("timestamp", System.currentTimeMillis())
                    runOnUiThread {
                        wearableEventSink?.success(mapOf(
                            "type" to "heart_rate",
                            "bpm" to bpm,
                            "timestamp" to timestamp
                        ))
                    }
                } catch (e: Exception) {
                    android.util.Log.e("AVPhoneWearable", "Failed parsing HR payload", e)
                }
            }
            "/workout/command" -> {
                try {
                    val json = JSONObject(dataStr)
                    val command = json.optString("command", "")
                    runOnUiThread {
                        wearableEventSink?.success(mapOf(
                            "type" to "command",
                            "command" to command
                        ))
                    }
                } catch (e: Exception) {
                    android.util.Log.e("AVPhoneWearable", "Failed parsing command", e)
                }
            }
            "/watch/pong" -> {
                try {
                    val json = JSONObject(dataStr)
                    val battery = json.optInt("battery", -1)
                    val device = json.optString("device", "")
                    val timestamp = json.optLong("timestamp", System.currentTimeMillis())
                    runOnUiThread {
                        wearableEventSink?.success(mapOf(
                            "type" to "pong",
                            "battery" to battery,
                            "device" to device,
                            "timestamp" to timestamp
                        ))
                    }
                } catch (e: Exception) {
                    android.util.Log.e("AVPhoneWearable", "Failed parsing pong", e)
                }
            }
        }
    }

    override fun onCapabilityChanged(capabilityInfo: CapabilityInfo) {
        val nodes = capabilityInfo.nodes
        connectedWatchNodes.clear()
        connectedWatchNodes.addAll(nodes)
        val isConnected = nodes.isNotEmpty()
        val watchName = nodes.firstOrNull()?.displayName ?: ""
        runOnUiThread {
            wearableEventSink?.success(mapOf(
                "type" to "connection",
                "connected" to isConnected,
                "name" to watchName
            ))
        }
    }

    override fun onResume() {
        super.onResume()
        refreshConnectedWatchNodes()
    }

    override fun onDestroy() {
        messageClient.removeListener(this)
        capabilityClient.removeListener(this)
        scope.cancel()
        super.onDestroy()
    }
}
