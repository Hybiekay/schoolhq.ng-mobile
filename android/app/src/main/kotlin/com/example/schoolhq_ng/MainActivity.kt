package com.example.schoolhq_ng

import android.content.res.Configuration
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var securityEvents: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            METHOD_CHANNEL,
        ).setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            when (call.method) {
                "setSecureScreen" -> {
                    val enabled = call.argument<Boolean>("enabled") ?: false
                    if (enabled) {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    } else {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }

                "isInMultiWindow" -> result.success(isInMultiWindowMode)
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            EVENT_CHANNEL,
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?,
                ) {
                    securityEvents = events
                    emitMultiWindowState(isInMultiWindowMode)
                }

                override fun onCancel(arguments: Any?) {
                    securityEvents = null
                }
            },
        )
    }

    override fun onMultiWindowModeChanged(
        isInMultiWindowMode: Boolean,
        newConfig: Configuration,
    ) {
        super.onMultiWindowModeChanged(isInMultiWindowMode, newConfig)
        emitMultiWindowState(isInMultiWindowMode)
    }

    private fun emitMultiWindowState(active: Boolean) {
        securityEvents?.success(
            mapOf(
                "type" to "multi_window",
                "active" to active,
            ),
        )
    }

    companion object {
        private const val METHOD_CHANNEL = "schoolhq_ng/exam_security"
        private const val EVENT_CHANNEL = "schoolhq_ng/exam_security/events"
    }
}
