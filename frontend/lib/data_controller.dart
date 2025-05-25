import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class DataController extends GetxController {
  var data = <double>[].obs;
  var fps = 0.0.obs;

  int _frameCount = 0;
  late DateTime _lastTime;
  late Ticker _ticker;

  @override
  void onInit() {
    super.onInit();
    _lastTime = DateTime.now();

    _ticker = Ticker(_onTick)..start(); // Start the ticker
  }

  void _onTick(Duration elapsed) {
    frameRendered(); // Call your frame tracking logic

    if (data.length >= 500) {
      data.removeAt(0);
    }

    // Simulate a sine wave point (range: 0–100)
    double t = (elapsed.inMilliseconds % 1000) / 1000 * 2 * pi;
    data.add(sin(t) * 50 + 50); // value from 0 to 100
  }

  void frameRendered() {
    _frameCount++;
    final now = DateTime.now();
    final diff = now.difference(_lastTime).inMilliseconds;

    if (diff >= 1000) {
      fps.value = _frameCount * 1000 / diff;
      _frameCount = 0;
      _lastTime = now;
    }
  }

  @override
  void onClose() {
    _ticker.dispose();
    super.onClose();
  }
}
