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
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Container(
              height: 300,
              width: double.infinity,
              color: Colors.black,
              child: Obx(() {
                return CustomPaint(
                  painter: ChartPainter(List.from(controller.data)),
                  size: Size.infinite,
                );
              }),
            ),
          ),
          Positioned(
            top: 16,
            left: 16,
            child: Obx(() {
              return Text(
                'FPS: ${controller.fps.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  shadows: [
                    Shadow(
                      offset: Offset(1, 1),
                      blurRadius: 2,
                      color: Colors.black54,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
