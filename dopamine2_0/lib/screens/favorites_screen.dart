import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorites_controller.dart';
import '../controllers/audio_controller.dart';
import '../widgets/aurora_glass_card.dart';

class FavoritesScreen extends StatelessWidget {
  FavoritesScreen({super.key});

  final FavoritesController controller = Get.find();
  final AudioController audio = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.favorites;

      if (items.isEmpty) {
        return const Center(
          child: Text(
            "No favorites yet",
            style: TextStyle(color: Colors.white70),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (_, i) {
          final item = items[i];

          return AuroraGlassCard(
            onTap: () {
              audio.playAudio(
                item["url"],
                title: item["title"] ?? "",
              );
            },
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.redAccent),
              title: Text(item["title"] ?? "",
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(item["channel"] ?? "",
                  style: const TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.play_arrow,
                  color: Colors.white, size: 28),
            ),
          );
        },
      );
    });
  }
}
