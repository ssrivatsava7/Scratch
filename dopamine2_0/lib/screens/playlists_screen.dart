import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/aurora_glass_card.dart';
import '../widgets/aurora_button.dart';
import '../routes/app_routes.dart';
import '../theme/midnight_aurora_theme.dart';

class PlaylistsScreen extends StatelessWidget {
  PlaylistsScreen({super.key});

  // Dummy playlists — later connect to real data
  final playlists = [
    {"name": "Chill Vibes", "count": 34},
    {"name": "Workout Mix", "count": 18},
    {"name": "Coding Beats", "count": 52},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        appBar: AppBar(
          title: const Text("Playlists"),
        ),

        body: Column(
          children: [
            const SizedBox(height: 12),

            AuroraButton(
              text: "Create New Playlist",
              icon: Icons.add,
              onTap: () {
                Get.snackbar(
                  "Coming Soon",
                  "Playlist creation UI will be added in next batch!",
                  colorText: Colors.white,
                );
              },
            ),

            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: playlists.length,
                itemBuilder: (_, i) {
                  final p = playlists[i];

                  return AuroraGlassCard(
                    onTap: () => Get.toNamed(
                      Routes.PLAYLIST_DETAIL,
                      arguments: {
                        "name": p["name"].toString(),
                        "count": p["count"],
                      },
                    ),
                    child: ListTile(
                      title: Text(
                        p["name"].toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        "${p["count"]} tracks",
                        style: const TextStyle(color: Colors.white54),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white60,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
