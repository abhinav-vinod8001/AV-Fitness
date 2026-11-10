package com.irontrack.irontrack

import android.content.Intent
import android.os.Build
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.irontrack/live_activity"
    private var methodChannel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        
        // Delegate for receiver to call Flutter MethodChannel
        WorkoutActionReceiver.methodChannelDelegate = { method, args ->
            methodChannel?.invokeMethod(method, args)
        }

        methodChannel?.setMethodCallHandler { call, result ->
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
                        android.util.Log.e("LiveActivity", "Failed to start foreground service from background", e)
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
    }
}
