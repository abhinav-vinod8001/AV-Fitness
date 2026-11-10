package com.irontrack.irontrack

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat

class WorkoutForegroundService : Service() {

    companion object {
        const val NOTIFICATION_CHANNEL_ID = "live_workout_channel"
        const val NOTIFICATION_ID = 1001

        const val ACTION_START_OR_UPDATE = "com.irontrack.ACTION_START_OR_UPDATE"
        const val ACTION_STOP = "com.irontrack.ACTION_STOP"
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START_OR_UPDATE -> {
                val workoutName = intent.getStringExtra("workoutName") ?: "Active Workout"
                val currentExercise = intent.getStringExtra("currentExercise") ?: ""
                val completedSets = intent.getIntExtra("completedSets", 0)
                val totalSets = intent.getIntExtra("totalSets", 0)
                val startTimeMillis = intent.getLongExtra("startTimeMillis", System.currentTimeMillis())
                val isResting = intent.getBooleanExtra("isResting", false)
                val restTimeRemaining = intent.getIntExtra("restTimeRemaining", 0)
                
                // New args
                val currentSetNumber = intent.getIntExtra("currentSetNumber", -1)
                val currentSetWeight = intent.getDoubleExtra("currentSetWeight", -1.0)
                val currentSetReps = intent.getIntExtra("currentSetReps", -1)
                val nextSetExerciseId = intent.getStringExtra("nextSetExerciseId")
                val nextSetId = intent.getStringExtra("nextSetId")

                val notification = buildNotification(
                    workoutName, currentExercise, completedSets, totalSets,
                    startTimeMillis, isResting, restTimeRemaining,
                    currentSetNumber, currentSetWeight, currentSetReps,
                    nextSetExerciseId, nextSetId
                )

                // Start foreground
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    startForeground(NOTIFICATION_ID, notification, android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_SPECIAL_USE)
                } else {
                    startForeground(NOTIFICATION_ID, notification)
                }
            }
            ACTION_STOP -> {
                stopForeground(STOP_FOREGROUND_REMOVE)
                stopSelf()
            }
        }
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                "Live Workout Activity",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Shows live workout progress and rest timer on lockscreen, status bar, and Samsung Now Bar"
                setShowBadge(true)
                lockscreenVisibility = NotificationCompat.VISIBILITY_PUBLIC
            }
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            nm.createNotificationChannel(channel)
        }
    }

    private fun buildNotification(
        workoutName: String,
        currentExercise: String,
        completedSets: Int,
        totalSets: Int,
        startTimeMillis: Long,
        isResting: Boolean,
        restTimeRemaining: Int,
        currentSetNumber: Int,
        currentSetWeight: Double,
        currentSetReps: Int,
        nextSetExerciseId: String?,
        nextSetId: String?
    ): android.app.Notification {
        
        val openIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        val openPendingIntent = PendingIntent.getActivity(
            this, 0, openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val title = if (isResting) {
            val min = restTimeRemaining / 60
            val sec = restTimeRemaining % 60
            val formatted = String.format("%02d:%02d", min, sec)
            "⏱️ Rest Timer: $formatted • $workoutName"
        } else if (currentExercise.isNotEmpty()) {
            "🏋️ $currentExercise • $workoutName"
        } else {
            "🏋️ $workoutName"
        }

        var contentText = if (totalSets > 0) {
            "$completedSets of $totalSets sets completed"
        } else {
            "Workout in progress"
        }
        
        if (!isResting && currentSetNumber != -1) {
            val weightStr = if (currentSetWeight > 0) String.format("%.1f", currentSetWeight) else "0"
            contentText = "Set $currentSetNumber: $weightStr × $currentSetReps  •  $contentText"
        }

        val builder = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(R.mipmap.launcher_icon)
            .setContentTitle(title)
            .setContentText(contentText)
            .setContentIntent(openPendingIntent)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setVisibility(NotificationCompat.VISIBILITY_PUBLIC)
            .setCategory(NotificationCompat.CATEGORY_WORKOUT) // Promotes to Samsung One UI Now Bar
            .setPriority(NotificationCompat.PRIORITY_DEFAULT)

        // Android 16+ Promoted Live Updates
        builder.extras.putBoolean("android.requestPromotedOngoing", true)

        if (!isResting) {
            builder.setUsesChronometer(true)
                .setShowWhen(true)
                .setWhen(startTimeMillis)
                
            if (nextSetExerciseId != null && nextSetId != null) {
                val completeIntent = Intent(this, WorkoutActionReceiver::class.java).apply {
                    action = WorkoutActionReceiver.ACTION_COMPLETE_SET
                    putExtra("exerciseId", nextSetExerciseId)
                    putExtra("setId", nextSetId)
                }
                val completePending = PendingIntent.getBroadcast(
                    this, nextSetId.hashCode(), completeIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
                )
                builder.addAction(android.R.drawable.ic_menu_edit, "✓ Complete Set", completePending)
            }
            
        } else {
            builder.setUsesChronometer(false)
            
            val addRestIntent = Intent(this, WorkoutActionReceiver::class.java).apply { action = WorkoutActionReceiver.ACTION_ADD_REST }
            val addRestPending = PendingIntent.getBroadcast(this, 1, addRestIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            
            val skipRestIntent = Intent(this, WorkoutActionReceiver::class.java).apply { action = WorkoutActionReceiver.ACTION_SKIP_REST }
            val skipRestPending = PendingIntent.getBroadcast(this, 2, skipRestIntent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
            
            builder.addAction(android.R.drawable.ic_input_add, "+30s Rest", addRestPending)
            builder.addAction(android.R.drawable.ic_media_next, "Skip Rest", skipRestPending)
        }

        return builder.build()
    }
}
