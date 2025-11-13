import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widgets/aurora_glass_card.dart';
import '../widgets/aurora_navbar.dart';
import '../widgets/aurora_drawer.dart';
import '../widgets/parallax_thumbnail.dart';
import '../theme/midnight_aurora_theme.dart';

class PlaylistDetailScreen extends StatelessWidget {
  PlaylistDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments;
    final name = args["name"];
    final count = args["count"];

    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        drawer: const AuroraDrawer(),
        bottomNavigationBar: const AuroraNavbar(currentIndex: 0),

        appBar: AppBar(
          title: Text(name),
        ),

        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "$count tracks",
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: count,
                itemBuilder: (_, index) {
                  return AuroraGlassCard(
                    child: ListTile(
                      // -------------------------------
                      // NEW Parallax Thumbnail
                      // -------------------------------
                      leading: ParallaxThumbnail(
                        url:
                            "https://i.pinimg.com/564x/5b/42/82/5b4282ad39c22e6d9f1e2b42d9f9d2d7.jpg",
                      ),

                      title: Text(
                        "Track ${index + 1}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      subtitle: const Text(
                        "Artist Name",
                        style: TextStyle(color: Colors.white54),
                      ),

                      trailing: const Icon(
                        Icons.play_circle_fill,
                        color: Color(0xFF4FD1C5),
                        size: 30,
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
