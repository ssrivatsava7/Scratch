import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'chart_painter.dart';
import 'data_controller.dart';

void main() {
  runApp(GetMaterialApp(debugShowCheckedModeBanner: false, home: ChartPage()));
}

class ChartPage extends StatelessWidget {
  final DataController controller = Get.put(DataController());

  ChartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return CustomPaint(
          painter: ChartPainter(List.from(controller.data)),
          size: Size.infinite,
        );
      }),
    );
  }
}
