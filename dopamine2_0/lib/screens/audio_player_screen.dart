import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/audio_controller.dart';
import '../theme/midnight_aurora_theme.dart';
import '../widgets/aurora_navbar.dart';
import '../widgets/aurora_drawer.dart';
import '../widgets/aurora_waveform.dart';

class AudioPlayerScreen extends StatelessWidget {
  AudioPlayerScreen({super.key});

  final audio = Get.find<AudioController>();

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final title = args['title'] ?? audio.currentTitle;

    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        drawer: const AuroraDrawer(),
        bottomNavigationBar: const AuroraNavbar(currentIndex: 0),

        appBar: AppBar(title: Text(title, overflow: TextOverflow.ellipsis)),

        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.35),
                    blurRadius: 40,
                    spreadRadius: 5,
                  ),
                ],
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B233A), Color(0xFF0F1628)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.music_note_rounded,
                  color: Colors.white54, size: 80),
            ),

            const SizedBox(height: 30),
            const AuroraWaveform(),
            const SizedBox(height: 40),

            Obx(() {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _button(
                    icon: Icons.pause_circle_filled_rounded,
                    altIcon: Icons.play_circle_fill_rounded,
                    active: audio.isPlaying.value,
                    onTap: audio.togglePlayback,
                  ),
                  const SizedBox(width: 40),
                  _button(
                    icon: Icons.stop_circle_rounded,
                    active: false,
                    onTap: audio.stop,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _button({
    required IconData icon,
    IconData? altIcon,
    required bool active,
    required VoidCallback onTap,
  }) {
    final ic = active && altIcon != null ? icon : altIcon ?? icon;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: MidnightAuroraTheme.glass.copyWith(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Icon(ic, size: 55, color: const Color(0xFF4FD1C5)),
      ),
    );
  }
}
