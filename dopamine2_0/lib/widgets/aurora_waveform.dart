import 'dart:math';
import 'package:flutter/material.dart';

class AuroraWaveform extends StatefulWidget {
  const AuroraWaveform({super.key});

  @override
  State<AuroraWaveform> createState() => _AuroraWaveformState();
}

class _AuroraWaveformState extends State<AuroraWaveform>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(8, (i) {
            final height = random.nextInt(30) + 10;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: height * controller.value,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF4FD1C5)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
