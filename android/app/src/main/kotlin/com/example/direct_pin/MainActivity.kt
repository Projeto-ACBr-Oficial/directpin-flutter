package com.example.direct_pin

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.directpin/intent"
    private var pendingResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendDirectPinIntent" -> {
                    pendingResult = result
                    val action = call.argument<String>("action") ?: ""
                    val requestJson = call.argument<String>("request") ?: ""
                    
                    val intent = Intent(action).apply {
                        putExtra("request", requestJson)
                    }
                    
                    try {
                        startActivityForResult(intent, REQUEST_CODE_DIRECT_PIN)
                    } catch (e: Exception) {
                        result.error("INTENT_ERROR", "Erro ao iniciar intent: ${e.message}", null)
                        pendingResult = null
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == REQUEST_CODE_DIRECT_PIN) {
            pendingResult?.let { result ->
                if (resultCode == Activity.RESULT_OK) {
                    val response = data?.getStringExtra("response")
                    result.success(mapOf("response" to (response ?: "")))
                } else {
                    result.error("CANCELLED", "Operação cancelada", null)
                }
                pendingResult = null
            }
        }
    }

    companion object {
        private const val REQUEST_CODE_DIRECT_PIN = 1001
    }
}
