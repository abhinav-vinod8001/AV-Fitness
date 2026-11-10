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
        val weeklyVolume = prefs.getString("weekly_volume", "0") ?: "0"
        val weeklyWorkouts = prefs.getString("weekly_workouts", "0") ?: "0"
        val weeklySets = prefs.getString("weekly_sets", "0") ?: "0"
        val lastWorkoutName = prefs.getString("last_workout_name", "No workouts yet") ?: "No workouts yet"
        val lastWorkoutDate = prefs.getString("last_workout_date", "") ?: ""

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, layoutId)

            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                putExtra("quick_action", "quick_workout")
            }

            val pendingIntent = PendingIntent.getActivity(
                context,
                appWidgetId,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            views.setOnClickPendingIntent(R.id.widget_container, pendingIntent)

            // Safely bind data — use try/catch for views that may not exist in all layouts
            try { views.setTextViewText(R.id.streak_count, streak) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.weekly_volume, formatVolume(weeklyVolume)) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.weekly_workouts, weeklyWorkouts) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.weekly_sets, weeklySets) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.last_workout_name, lastWorkoutName) } catch (_: Exception) {}
            try { views.setTextViewText(R.id.last_workout_date, lastWorkoutDate) } catch (_: Exception) {}

            // For 2x2 widget: build the label text
            try {
                val daysAgo = prefs.getString("days_since_last", "") ?: ""
                val label = if (daysAgo.isNotEmpty() && daysAgo != "0") {
                    if (daysAgo == "1") "Last workout: yesterday"
                    else "Last workout: $daysAgo days ago"
                } else if (daysAgo == "0") {
                    "Trained today ✓"
                } else {
                    "Tap to start training"
                }
                views.setTextViewText(R.id.last_workout_label, label)
            } catch (_: Exception) {}

            // For 3x3: streak badge text
            try {
                views.setTextViewText(R.id.streak_count, "$streak day streak")
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

class Widget2x1 : QuickWorkoutWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_2x1)
    }
}

class Widget3x3 : QuickWorkoutWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        updateWidgets(context, appWidgetManager, appWidgetIds, R.layout.widget_3x3)
    }
}
