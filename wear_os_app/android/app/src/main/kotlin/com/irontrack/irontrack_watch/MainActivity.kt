package com.irontrack.irontrack_watch

import android.Manifest
import android.content.pm.PackageManager
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import androidx.health.services.client.HealthServices
import androidx.health.services.client.MeasureCallback
import androidx.health.services.client.data.Availability
import androidx.health.services.client.data.DataPointContainer
import androidx.health.services.client.data.DataType
import androidx.health.services.client.data.DeltaDataType
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors
import kotlinx.coroutines.*
import kotlinx.coroutines.guava.await

class MainActivity : FlutterActivity() {
    private val HEALTH_CHANNEL = "com.irontrack.watch/health"
    private val HEALTH_EVENTS = "com.irontrack.watch/health_events"
    private val HAPTIC_CHANNEL = "com.irontrack.watch/haptics"
    private val executor = Executors.newSingleThreadExecutor()
    private val scope = CoroutineScope(Dispatchers.IO + SupervisorJob())

    private var heartRateCallback: MeasureCallback? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Health data event stream
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, HEALTH_EVENTS).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }
                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        // Health control methods
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HEALTH_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "requestPermissions" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.BODY_SENSORS) != PackageManager.PERMISSION_GRANTED) {
                        ActivityCompat.requestPermissions(this, arrayOf(
                            Manifest.permission.BODY_SENSORS,
                            Manifest.permission.ACTIVITY_RECOGNITION
                        ), 100)
                    }
                    result.success(true)
                }
                "startHeartRate" -> {
                    startHeartRateMonitoring()
                    result.success(true)
                }
                "stopHeartRate" -> {
                    stopHeartRateMonitoring()
                    result.success(true)
                }
                "checkCapabilities" -> {
                    checkCapabilities(result)
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
                else -> result.notImplemented()
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
                    result.success(mapOf<String, Boolean>(
                        "heartRate" to supportsHR
                    ))
                }
            } catch (e: Exception) {
                withContext(Dispatchers.Main) {
                    result.success(mapOf<String, Boolean>("heartRate" to false))
                }
            }
        }
    }

    private fun startHeartRateMonitoring() {
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

    private fun triggerVibration(pattern: LongArray) {
        val vibrator = getSystemService(VIBRATOR_SERVICE) as? Vibrator ?: return
        val amplitudes = IntArray(pattern.size) { if (it % 2 == 0) 0 else 255 }
        vibrator.vibrate(VibrationEffect.createWaveform(pattern, amplitudes, -1))
    }

    override fun onDestroy() {
        stopHeartRateMonitoring()
        scope.cancel()
        super.onDestroy()
    }
}
