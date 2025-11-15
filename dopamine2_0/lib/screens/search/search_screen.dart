import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/search_controller.dart' as local_search;
import 'search_results_screen.dart';

import '../../widgets/aurora_navbar.dart';
import '../../controllers/nav_controller.dart';
import '../../theme/midnight_aurora_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textController = TextEditingController();
  final controller = Get.find<local_search.SearchController>();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_textController.text.trim().isNotEmpty) {
      controller.search(_textController.text.trim());
      Get.to(() => const SearchResultsScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final nav = Get.find<NavController>();

    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Search'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Get.back(),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search Bar
              TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search for any song or YouTube video...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  suffixIcon: Obx(() {
                    return controller.query.value.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.white70),
                            onPressed: () {
                              _textController.clear();
                              controller.clearSearch();
                            },
                          )
                        : const SizedBox();
                  }),
                ),
                onChanged: (value) => controller.updateQuery(value),
                onSubmitted: (value) => _performSearch(),
              ),

              const SizedBox(height: 16),

              // Search Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purpleAccent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Search',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Recent Searches or Suggestions
              Expanded(
                child: Obx(() {
                  if (controller.hasSearched.value && controller.results.isEmpty) {
                    return const Center(
                      child: Text(
                        'No results found',
                        style: TextStyle(color: Colors.white54),
                      ),
                    );
                  }

                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search,
                          size: 64,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Search for songs, artists, or videos',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AuroraNavbar(
          currentIndex: 1,
          onTap: (index) {
            final nav = Get.find<NavController>();
            nav.changePage(index);
          },
        ),
      ),
    );
  }
}
