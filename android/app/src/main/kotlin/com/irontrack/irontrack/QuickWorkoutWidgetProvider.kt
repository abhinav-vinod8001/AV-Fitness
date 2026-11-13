package com.irontrack.irontrack

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

open class QuickWorkoutWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_2x2)
    }

    protected fun updateWidgets(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, layoutId: Int) {
        // Read stats from SharedPreferences (written by Flutter via home_widget)
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val streak = prefs.getString("streak", "0") ?: "0"
        val streakText = prefs.getString("streak_text", "$streak day streak") ?: "$streak day streak"
        val weeklyVolume = prefs.getString("weekly_volume", "0") ?: "0"
        val weeklyWorkouts = prefs.getString("weekly_workouts", "0") ?: "0"
        val weeklySets = prefs.getString("weekly_sets", "0") ?: "0"
        val lastWorkoutName = prefs.getString("last_workout_name", "No workouts yet") ?: "No workouts yet"
        val lastWorkoutDate = prefs.getString("last_workout_date", "") ?: ""
        val lastWorkoutVolume = prefs.getString("last_workout_volume", "") ?: ""
        val daysAgo = prefs.getString("days_since_last", "") ?: ""
        val trainedToday = prefs.getString("trained_today", "false") == "true"
        val activeWorkout = prefs.getString("active_workout", "false") == "true"
        val activeWorkoutName = prefs.getString("active_workout_name", "") ?: ""

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, layoutId)

            // 1. Container tap -> Open Main Activity
            val mainIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("quick_action", "open")
            }
            val mainPendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId * 10,
                mainIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_container, mainPendingIntent)

            // 2. Start Workout button tap -> Open Quick Workout / Starter
            val startIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("quick_action", "quick_workout")
            }
            val startPendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId * 10 + 1,
                startIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            try {
                views.setOnClickPendingIntent(R.id.btn_start_workout, startPendingIntent)
            } catch (_: Exception) {}

            // 3. History button tap -> Open History screen
            val historyIntent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
                putExtra("quick_action", "history")
            }
            val historyPendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId * 10 + 2,
                historyIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            try {
                views.setOnClickPendingIntent(R.id.btn_history, historyPendingIntent)
            } catch (_: Exception) {}

            // Streak bindings
            try { views.setTextViewText(R.id.streak_count, streak) } catch (_: Exception) {}
            try {
                val label = if (trainedToday) {
                    "Trained today ✓"
                } else if (streak != "0") {
                    "$streak day streak"
                } else {
                    "Start your streak"
                }
                views.setTextViewText(R.id.streak_label, label)
            } catch (_: Exception) {}

            // Weekly stats bindings
            try { views.setTextViewText(R.id.weekly_workouts, weeklyWorkouts) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.weekly_volume, formatVolume(weeklyVolume)) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.weekly_sets, weeklySets) } catch (_: Exception) {}

            // Last workout bindings
            try { views.setTextViewText(R.id.last_workout_name, lastWorkoutName) } catch (_: Exception) {}
            try {
                val dateString = if (lastWorkoutVolume.isNotEmpty() && lastWorkoutDate.isNotEmpty()) {
                    "$lastWorkoutDate • $lastWorkoutVolume"
                } else if (lastWorkoutDate.isNotEmpty()) {
                    lastWorkoutDate
                } else {
                    "Tap to start training"
                }
                views.setTextViewText(R.id.last_workout_date, dateString)
            } catch (_: Exception) {}

            // Summary label for 2x2 and 4x2
            try {
                val summary = if (activeWorkout && activeWorkoutName.isNotEmpty()) {
                    "⚡ In Progress: $activeWorkoutName"
                } else if (trainedToday) {
                    "Trained today ✓ • $lastWorkoutName"
                } else if (daysAgo.isNotEmpty() && daysAgo != "0") {
                    if (daysAgo == "1") "Yesterday: $lastWorkoutName"
                    else "$daysAgo days ago: $lastWorkoutName"
                } else {
                    "Tap to start training"
                }
                views.setTextViewText(R.id.last_workout_label, summary)
            } catch (_: Exception) {}

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }

    private fun formatVolume(raw: String): String {
        return try {
            val vol = raw.toDouble()
            if (vol >= 1000) {
                String.format("%.1fk", vol / 1000.0)
            } else {
                String.format("%.0f", vol)
            }
        } catch (_: Exception) {
            raw
        }
    }
}

class Widget1x1 : QuickWorkoutWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_1x1)
    }
}

class Widget2x1 : QuickWorkoutWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_2x1)
    }
}

class Widget4x1 : QuickWorkoutWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_4x1)
    }
}

class Widget2x2 : QuickWorkoutWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_2x2)
    }
}

class Widget4x2 : QuickWorkoutWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_4x2)
    }
}

class Widget3x3 : QuickWorkoutWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_3x3)
    }
}
