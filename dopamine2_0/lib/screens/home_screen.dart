import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/parallax_thumbnail.dart';
import '../controllers/youtube_media_controller.dart';
import '../routes/app_routes.dart';
import '../theme/midnight_aurora_theme.dart';
import '../widgets/aurora_navbar.dart';
import '../widgets/aurora_drawer.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final yt = Get.find<YouTubeMediaController>();
  final TextEditingController searchField = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        drawer: const AuroraDrawer(),
        bottomNavigationBar: const AuroraNavbar(currentIndex: 0),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            "Dopamine Player",
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),

        body: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 10),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      child: Container(
        decoration: MidnightAuroraTheme.glass.copyWith(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            const Icon(Icons.search, color: Colors.white70),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: searchField,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search YouTube videos...",
                  hintStyle: TextStyle(color: Colors.white54),
                ),
                onSubmitted: (v) => _handleSearch(),
              ),
            ),
            GestureDetector(
              onTap: _handleSearch,
              child: Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (yt.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
        );
      }

      if (yt.searchResults.isEmpty) {
        return const Center(
          child: Text("Search for something!",
              style: TextStyle(color: Colors.white54)),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: yt.searchResults.length,
        itemBuilder: (_, index) {
          final video = yt.searchResults[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: MidnightAuroraTheme.glass.copyWith(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              leading: ParallaxThumbnail(url: video.thumbnails.mediumResUrl),
              title: Text(
                video.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(video.author,
                  style: const TextStyle(color: Colors.white54)),
              trailing: const Icon(Icons.play_circle_fill,
                  color: Color(0xFF4FD1C5), size: 30),
              onTap: () async {
                final url = await yt.getBestVideoUrl(video.id.value);
                if (url != null) {
                  Get.toNamed(
                    Routes.VIDEO_PLAYER,
                    arguments: {"url": url, "title": video.title},
                  );
                }
              },
            ),
          );
        },
      );
    });
  }

  void _handleSearch() {
    final query = searchField.text.trim();
    if (query.isNotEmpty) yt.searchVideos(query);
  }
}
