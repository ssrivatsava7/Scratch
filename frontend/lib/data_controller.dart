import 'dart:async';

import 'package:get/get.dart';

class DataController extends GetxController {
  var data = <double>[].obs;
  var fps = 0.0.obs;

  int _frameCount = 0;
  late DateTime _lastTime;
  late Timer _dataTimer;

  @override
  void onInit() {
    super.onInit();
    _lastTime = DateTime.now();

    // Start timer to update data every 8 ms (~120 FPS)
    _dataTimer = Timer.periodic(Duration(milliseconds: 8), (_) {
      updateData(); // public method called here
    });
  }

  @override
  void onClose() {
    _dataTimer.cancel();
    super.onClose();
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

  // public method now
  void updateData() {
    final now = DateTime.now();

    // Example: generate random data between 0 and 100
    double newValue = (100 * (now.millisecond / 1000));

    if (data.length > 200) {
      data.removeAt(0);
    }
    data.add(newValue);

    frameRendered();
  }
}
