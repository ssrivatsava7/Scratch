import 'dart:math';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class DataController extends GetxController with GetTickerProviderStateMixin {
  final RxList<double> data = <double>[].obs;
  final int maxPoints = 300;
  final _random = Random();
  late Ticker _ticker;

  @override
  void onInit() {
    super.onInit();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (data.length >= maxPoints) {
      data.removeAt(0);
    }
    data.add(_random.nextDouble() * 100);
  }

  @override
  void onClose() {
    _ticker.dispose();
    super.onClose();
  }
}
