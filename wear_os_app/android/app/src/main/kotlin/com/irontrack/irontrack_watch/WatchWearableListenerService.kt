package com.irontrack.irontrack_watch

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.VibrationEffect
import android.os.Vibrator
import androidx.core.app.NotificationCompat
import com.google.android.gms.wearable.MessageEvent
import com.google.android.gms.wearable.WearableListenerService
import org.json.JSONObject

class WatchWearableListenerService : WearableListenerService() {

    companion object {
        const val NOTIFICATION_CHANNEL_ID = "wear_workout_channel"
        const val NOTIFICATION_ID = 5001
        var activeInstance: WatchWearableListenerService? = null
    }

    override fun onCreate() {
        super.onCreate()
        activeInstance = this
        createNotificationChannel()
    }

    override fun onDestroy() {
        if (activeInstance == this) activeInstance = null
        super.onDestroy()
    }

    override fun onMessageReceived(messageEvent: MessageEvent) {
        val path = messageEvent.path
        val dataStr = String(messageEvent.data, Charsets.UTF_8)
        android.util.Log.d("AVWatchListener", "onMessageReceived path: $path, data: $dataStr")

        when (path) {
            "/workout/start", "/workout/state" -> {
                handleWorkoutStateReceived(dataStr)
            }
            "/workout/stop" -> {
                handleWorkoutStopReceived()
            }
            "/watch/ping" -> {
                triggerHaptic(longArrayOf(0, 150, 80, 150))
            }
        }

        // Forward to MainActivity if active
        MainActivity.activeInstance?.runOnUiThread {
            MainActivity.activeInstance?.handleIncomingMessage(path, dataStr)
        }
    }

    private fun handleWorkoutStateReceived(dataStr: String) {
        var workoutName = "Active Workout"
        var currentExercise = ""
        try {
            val json = JSONObject(dataStr)
            workoutName = json.optString("workoutName", "Active Workout")
            currentExercise = json.optString("currentExercise", "")
        } catch (_: Exception) {}

        // 1. Alert with haptic pulse
        triggerHaptic(longArrayOf(0, 200, 100, 300))

        // 2. Launch / Bring MainActivity to front
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
            putExtra("workout_state", dataStr)
            putExtra("auto_started", true)
        }
        val pendingIntent = PendingIntent.getActivity(
            this,
            NOTIFICATION_ID,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        try {
            startActivity(openIntent)
        } catch (e: Exception) {
            android.util.Log.e("AVWatchListener", "Failed direct startActivity", e)
        }

        // 3. Post / Update Ongoing Workout Notification with full-screen intent so Wear OS wakes up the display!
        val subText = if (currentExercise.isNotEmpty()) "🏋️ $currentExercise" else "Workout in progress"
        val notification = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("🏋️ $workoutName")
            .setContentText(subText)
            .setContentIntent(pendingIntent)
            .setFullScreenIntent(pendingIntent, true) // Wakes screen & shows activity
            .setOngoing(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_WORKOUT)
            .setAutoCancel(false)
            .build()

        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.notify(NOTIFICATION_ID, notification)
    }

    private fun handleWorkoutStopReceived() {
        triggerHaptic(longArrayOf(0, 250))
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        nm.cancel(NOTIFICATION_ID)
    }

    private fun triggerHaptic(pattern: LongArray) {
        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as? Vibrator ?: return
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            vibrator.vibrate(VibrationEffect.createWaveform(pattern, -1))
        } else {
            vibrator.vibrate(pattern, -1)
        }
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Workout Companion",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Shows live workout status on watch and auto-starts companion tracking"
                enableVibration(true)
                setShowBadge(true)
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }
}

