import 'package:flutter/material.dart';

class ChartPainter extends CustomPainter {
  final List<double> data;

  ChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final Paint linePaint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    final double dx = size.width / data.length;
    final double maxY = 100;

    for (int i = 0; i < data.length; i++) {
      double x = i * dx;
      double y = size.height * (1 - (data[i] / maxY));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant ChartPainter oldDelegate) =>
      oldDelegate.data != data;
}
