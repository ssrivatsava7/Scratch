package com.example.frontend

import android.os.Build
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import java.lang.reflect.Method

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val method: Method = window.javaClass.getMethod("setFrameRate", Float::class.java, Int::class.java)
                method.invoke(window, 120f, 0 /* FrameRateCompatibility.DEFAULT */)
                Log.d("MainActivity", "120Hz frame rate set.")
            } catch (e: Exception) {
                Log.e("MainActivity", "Failed to set frame rate: ${e.message}")
            }
        }
    }
}
