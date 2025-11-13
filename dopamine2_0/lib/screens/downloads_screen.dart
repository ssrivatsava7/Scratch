import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/download_controller.dart';
import '../theme/midnight_aurora_theme.dart';

class DownloadsScreen extends StatelessWidget {
  DownloadsScreen({super.key});

  final ctrl = Get.find<DownloadController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("Downloads"),
        ),
        body: Obx(() {
          if (ctrl.downloads.isEmpty) {
            return const Center(
              child: Text(
                "No downloads yet",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            itemCount: ctrl.downloads.length,
            itemBuilder: (_, i) {
              final item = ctrl.downloads[i];

              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(14),
                decoration: MidnightAuroraTheme.glass.copyWith(
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item["title"],
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 10),

                    LinearProgressIndicator(
                      value: item["progress"],
                      minHeight: 6,
                      color: const Color(0xFF4FD1C5),
                      backgroundColor: Colors.white12,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      item["status"],
                      style: const TextStyle(color: Colors.white54),
                    )
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
