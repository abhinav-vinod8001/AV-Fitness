package com.irontrack.irontrack_watch

import android.Manifest
import android.content.pm.PackageManager
import android.os.BatteryManager
import android.os.PowerManager
import android.os.VibrationEffect
import android.os.Vibrator
import android.view.WindowManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.health.services.client.HealthServices
import androidx.health.services.client.MeasureCallback
import androidx.health.services.client.data.Availability
import androidx.health.services.client.data.DataPointContainer
import androidx.health.services.client.data.DataType
import androidx.health.services.client.data.DeltaDataType
import com.google.android.gms.tasks.Tasks
import com.google.android.gms.wearable.*
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import kotlinx.coroutines.*
import kotlinx.coroutines.guava.await
import org.json.JSONObject

class MainActivity : FlutterActivity(), MessageClient.OnMessageReceivedListener, CapabilityClient.OnCapabilityChangedListener {
    private val HEALTH_CHANNEL = "com.irontrack.watch/health"
    private val HEALTH_EVENTS = "com.irontrack.watch/health_events"
    private val HAPTIC_CHANNEL = "com.irontrack.watch/haptics"
    private val executor = Executors.newSingleThreadExecutor()
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    private var heartRateCallback: MeasureCallback? = null
    private var eventSink: EventChannel.EventSink? = null
    private var wakeLock: PowerManager.WakeLock? = null

    private lateinit var messageClient: MessageClient
    private lateinit var nodeClient: NodeClient
    private lateinit var capabilityClient: CapabilityClient

    // Cache of connected phone nodes
    private val connectedPhoneNodes = mutableSetOf<Node>()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        messageClient = Wearable.getMessageClient(this)
        nodeClient = Wearable.getNodeClient(this)
        capabilityClient = Wearable.getCapabilityClient(this)

        messageClient.addListener(this)
        capabilityClient.addListener(this, "av_fitness_phone")

        // Health data event stream
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, HEALTH_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    refreshConnectedNodes()
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        // Health & Communication control methods
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEALTH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermissions" -> {
                    val permissions = mutableListOf(
                        Manifest.permission.BODY_SENSORS,
                        Manifest.permission.ACTIVITY_RECOGNITION
                    )
                    if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
                        permissions.add(Manifest.permission.BODY_SENSORS_BACKGROUND)
                    }
                    val missing = permissions.filter {
                        ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
                    }
                    if (missing.isNotEmpty()) {
                        ActivityCompat.requestPermissions(this, missing.toTypedArray(), 100)
                    }
                    result.success(true)
                }
                "startHeartRate" -> {
                    acquireWakeLock()
                    startHeartRateMonitoring()
                    result.success(true)
                }
                "stopHeartRate" -> {
                    releaseWakeLock()
                    stopHeartRateMonitoring()
                    result.success(true)
                }
                "checkCapabilities" -> {
                    checkCapabilities(result)
                }
                "sendWorkoutCommand" -> {
                    val command = call.argument<String>("command") ?: ""
                    val extra = call.argument<Map<String, Any>>("extra") ?: emptyMap()
                    sendWorkoutCommandToPhone(command, extra)
                    result.success(true)
                }
                "getPhoneConnectionStatus" -> {
                    scope.launch {
                        try {
                            val nodes: List<Node> = Tasks.await(nodeClient.connectedNodes)
                            val isConnected = nodes.isNotEmpty()
                            val phoneName = nodes.firstOrNull()?.displayName ?: ""
                            withContext(Dispatchers.Main) {
                                result.success(mapOf(
                                    "connected" to isConnected,
                                    "phoneName" to phoneName,
                                    "nodeCount" to nodes.size
                                ))
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.success(mapOf(
                                    "connected" to false,
                                    "phoneName" to "",
                                    "nodeCount" to 0
                                ))
                            }
                        }
                    }
                }
                "setKeepScreenOn" -> {
                    val enable = call.argument<Boolean>("enable") ?: false
                    if (enable) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        // Haptic feedback methods
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HAPTIC_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "vibrate" -> {
                    val patternList = call.argument<List<Int>>("pattern") ?: listOf(0, 200, 100, 200)
                    val pattern = patternList.map { it.toLong() }.toLongArray()
                    triggerVibration(pattern)
                    result.success(true)
                }
                "vibrateOnce" -> {
                    triggerVibration(longArrayOf(0, 300))
                    result.success(true)
                }
                "vibrateDouble" -> {
                    triggerVibration(longArrayOf(0, 150, 100, 150))
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        refreshConnectedNodes()
    }

    private fun refreshConnectedNodes() {
        scope.launch {
            try {
                val nodes: List<Node> = Tasks.await(nodeClient.connectedNodes)
                connectedPhoneNodes.clear()
                connectedPhoneNodes.addAll(nodes)
                val isConnected = nodes.isNotEmpty()
                val phoneName = nodes.firstOrNull()?.displayName ?: ""
                withContext(Dispatchers.Main) {
                    eventSink?.success(mapOf(
                        "type" to "connection_changed",
                        "connected" to isConnected,
                        "phoneName" to phoneName
                    ))
                }
            } catch (e: Exception) {
                android.util.Log.e("AVWatch", "Error querying connected nodes", e)
            }
        }
    }

    private fun checkCapabilities(result: MethodChannel.Result) {
        scope.launch {
            try {
                val healthClient = HealthServices.getClient(this@MainActivity)
                val capabilities = healthClient.measureClient.getCapabilitiesAsync().await()
                val supportsHR = DataType.HEART_RATE_BPM in capabilities.supportedDataTypesMeasure
                withContext(Dispatchers.Main) {
                    result.success(mapOf(
                        "heartRate" to supportsHR
                    ))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.success(mapOf("heartRate" to false))
                }
            }
        }
    }

    private fun startHeartRateMonitoring() {
        if (heartRateCallback != null) return // Already monitoring
        val healthClient = HealthServices.getClient(this)
        val measureClient = healthClient.measureClient

        heartRateCallback = object : MeasureCallback {
            override fun onAvailabilityChanged(dataType: DeltaDataType<*, *>, availability: Availability) {
                runOnUiThread {
                    eventSink?.success(mapOf("type" to "availability", "value" to availability.toString()))
                }
            }

            override fun onDataReceived(data: DataPointContainer) {
                val heartRatePoints = data.getData(DataType.HEART_RATE_BPM)
                for (point in heartRatePoints) {
                    val bpm = point.value
                    runOnUiThread {
                        eventSink?.success(mapOf("type" to "heart_rate", "value" to bpm))
                    }
                    // Stream real-time heart rate to connected phone!
                    sendHeartRateToPhone(bpm)
                }
            }
        }

        scope.launch {
            try {
                measureClient.registerMeasureCallback(DataType.HEART_RATE_BPM, heartRateCallback!!)
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    eventSink?.success(mapOf("type" to "error", "value" to "HR: ${e.message}"))
                }
            }
        }
    }

    private fun stopHeartRateMonitoring() {
        heartRateCallback?.let { callback ->
            val healthClient = HealthServices.getClient(this)
            scope.launch {
                try {
                    healthClient.measureClient.unregisterMeasureCallbackAsync(DataType.HEART_RATE_BPM, callback)
                } catch (_: Exception) {}
            }
            heartRateCallback = null
        }
    }

    private fun sendHeartRateToPhone(bpm: Double) {
        scope.launch {
            try {
                val payload = JSONObject().apply {
                    put("bpm", bpm.toInt())
                    put("timestamp", System.currentTimeMillis())
                }.toString().toByteArray(Charsets.UTF_8)

                val nodes: Collection<Node> = if (connectedPhoneNodes.isNotEmpty()) connectedPhoneNodes else Tasks.await(nodeClient.connectedNodes)
                for (node in nodes) {
                    messageClient.sendMessage(node.id, "/health/heart_rate", payload)
                }
            } catch (e: Exception) {
                android.util.Log.e("AVWatch", "Error sending HR to phone", e)
            }
        }
    }

    private fun sendWorkoutCommandToPhone(command: String, extra: Map<String, Any>) {
        scope.launch {
            try {
                val json = JSONObject().apply {
                    put("command", command)
                    put("timestamp", System.currentTimeMillis())
                    for ((k, v) in extra) {
                        put(k, v)
                    }
                }
                val payload = json.toString().toByteArray(Charsets.UTF_8)
                val nodes: Collection<Node> = if (connectedPhoneNodes.isNotEmpty()) connectedPhoneNodes else Tasks.await(nodeClient.connectedNodes)
                for (node in nodes) {
                    messageClient.sendMessage(node.id, "/workout/command", payload)
                }
            } catch (e: Exception) {
                android.util.Log.e("AVWatch", "Error sending workout command to phone", e)
            }
        }
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        val path = messageEvent.path
        val dataStr = String(messageEvent.data, Charsets.UTF_8)

        when (path) {
            "/workout/state" -> {
                runOnUiThread {
                    eventSink?.success(mapOf(
                        "type" to "workout_state",
                        "data" to dataStr
                    ))
                }
            }
            "/workout/stop" -> {
                runOnUiThread {
                    eventSink?.success(mapOf(
                        "type" to "workout_stop"
                    ))
                }
            }
            "/watch/ping" -> {
                triggerVibration(longArrayOf(0, 200, 100, 200))
                runOnUiThread {
                    eventSink?.success(mapOf(
                        "type" to "ping",
                        "timestamp" to System.currentTimeMillis()
                    ))
                }
                // Send pong back with battery level
                sendPong(messageEvent.sourceNodeId)
            }
        }
    }

    private fun sendPong(sourceNodeId: String) {
        scope.launch {
            try {
                val bm = getSystemService(BATTERY_SERVICE) as? BatteryManager
                val batteryPct = bm?.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY) ?: -1
                val pongPayload = JSONObject().apply {
                    put("status", "ok")
                    put("battery", batteryPct)
                    put("timestamp", System.currentTimeMillis())
                    put("device", android.os.Build.MODEL)
                }.toString().toByteArray(Charsets.UTF_8)

                messageClient.sendMessage(sourceNodeId, "/watch/pong", pongPayload)
            } catch (e: Exception) {
                android.util.Log.e("AVWatch", "Error sending pong", e)
            }
        }
    }

    override fun onCapabilityChanged(capabilityInfo: CapabilityInfo) {
        val nodes = capabilityInfo.nodes
        connectedPhoneNodes.clear()
        connectedPhoneNodes.addAll(nodes)
        val isConnected = nodes.isNotEmpty()
        val phoneName = nodes.firstOrNull()?.displayName ?: ""
        runOnUiThread {
            eventSink?.success(mapOf(
                "type" to "connection_changed",
                "connected" to isConnected,
                "phoneName" to phoneName
            ))
        }
    }

    private fun acquireWakeLock() {
        if (wakeLock == null) {
            val powerManager = getSystemService(POWER_SERVICE) as? PowerManager
            wakeLock = powerManager?.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "AVFitness::WatchHRLock")?.apply {
                acquire(120 * 60 * 1000L) // 2 hours max
            }
        }
    }

    private fun releaseWakeLock() {
        try {
            if (wakeLock?.isHeld == true) {
                wakeLock?.release()
            }
        } catch (_: Exception) {}
        wakeLock = null
    }

    private fun triggerVibration(pattern: LongArray) {
        val vibrator = getSystemService(VIBRATOR_SERVICE) as? Vibrator ?: return
        val amplitudes = IntArray(pattern.size) { if (it % 2 == 0) 0 else 255 }
        vibrator.vibrate(VibrationEffect.createWaveform(pattern, amplitudes, -1))
    }

    override fun onResume() {
        super.onResume()
        refreshConnectedNodes()
    }

    override fun onDestroy() {
        messageClient.removeListener(this)
        capabilityClient.removeListener(this)
        stopHeartRateMonitoring()
        releaseWakeLock()
        scope.cancel()
        super.onDestroy()
    }
}
