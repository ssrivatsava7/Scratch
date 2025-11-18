import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/dopamine_app_bar.dart';
import '../utils/controller_helper.dart';

/// Example: How to use DopamineAppBar and access controllers in any screen
/// You can copy this pattern to all your existing screens

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Use DopamineAppBar instead of regular AppBar
      appBar: DopamineAppBar(
        title: 'Example Screen',
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Access search controller from anywhere
              // Controllers.search.performSearch('query');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Example: Access favorites controller
            ElevatedButton(
              onPressed: () {
                final favController = Controllers.favorites;
                // Use the controller
              },
              child: const Text('Access Favorites'),
            ),
            const SizedBox(height: 16),
            // Example: Access playlist controller
            ElevatedButton(
              onPressed: () {
                final playlistController = Controllers.playlist;
                // Use the controller
              },
              child: const Text('Access Playlist'),
            ),
            const SizedBox(height: 16),
            // Example: Access mini player controller
            ElevatedButton(
              onPressed: () {
                final miniPlayer = Controllers.miniPlayer;
                // Use the controller
              },
              child: const Text('Access Mini Player'),
            ),
          ],
        ),
      ),
    );
  }
}
