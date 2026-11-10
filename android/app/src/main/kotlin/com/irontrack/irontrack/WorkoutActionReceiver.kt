package com.irontrack.irontrack

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class WorkoutActionReceiver : BroadcastReceiver() {
    companion object {
        const val ACTION_ADD_REST = "com.irontrack.ACTION_ADD_REST"
        const val ACTION_SKIP_REST = "com.irontrack.ACTION_SKIP_REST"
        const val ACTION_COMPLETE_SET = "com.irontrack.ACTION_COMPLETE_SET"
        
        var methodChannelDelegate: ((String, Any?) -> Unit)? = null
    }

    override fun onReceive(context: Context?, intent: Intent?) {
        when (intent?.action) {
            ACTION_ADD_REST -> {
                methodChannelDelegate?.invoke("onAddRestTime", 30)
            }
            ACTION_SKIP_REST -> {
                methodChannelDelegate?.invoke("onSkipRest", null)
            }
            ACTION_COMPLETE_SET -> {
                val exerciseId = intent.getStringExtra("exerciseId")
                val setId = intent.getStringExtra("setId")
                if (exerciseId != null && setId != null) {
                    methodChannelDelegate?.invoke("onCompleteSet", mapOf(
                        "exerciseId" to exerciseId,
                        "setId" to setId
                    ))
                }
            }
        }
    }
}
