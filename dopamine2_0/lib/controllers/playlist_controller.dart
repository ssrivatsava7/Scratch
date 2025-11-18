import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class PlaylistController extends GetxController {
  /// Structure:
  /// playlists = [
  ///   {
  ///     "name": "My Lofi Mix",
  ///     "tracks": [ MediaItem, MediaItem, ... ]
  ///   }
  /// ]
  final playlists = RxList<Map<String, dynamic>>([]);

  @override
  void onInit() {
    super.onInit();
    try {
      final data = StorageService.getPlaylists();
      playlists.value = RxList<Map<String, dynamic>>.from(
        data.map((e) {
          if (e is Map) {
            final playlist = Map<String, dynamic>.from(e);
            if (playlist["items"] != null && playlist["items"] is List) {
              playlist["items"] = RxList<Map<String, dynamic>>.from(
                (playlist["items"] as List).map((item) => 
                  item is Map ? Map<String, dynamic>.from(item) : <String, dynamic>{}
                ),
              );
            } else {
              playlist["items"] = RxList<Map<String, dynamic>>([]);
            }
            return playlist;
          }
          return <String, dynamic>{
            "name": "Unknown",
            "items": RxList<Map<String, dynamic>>([]),
          };
        }),
      );

      if (playlists.isEmpty) {
        createPlaylist("My Playlist");
      }
    } catch (e) {
      print('Error loading playlists: $e');
      playlists.value = RxList<Map<String, dynamic>>([]);
      createPlaylist("My Playlist");
    }
  }

  /// --------------------------------------------------------
  /// CREATE PLAYLIST
  /// --------------------------------------------------------
  void createPlaylist(String name) {
    playlists.add({
      "name": name,
      "tracks": [],
    });
  }

  /// --------------------------------------------------------
  /// ADD TRACK (UI calls this for modal)
  /// --------------------------------------------------------
  void addTrack(String playlistName, Map<String, dynamic> item) {
    final index = playlists.indexWhere((p) => p["name"] == playlistName);
    if (index != -1) {
      playlists[index]["tracks"].add(item);
      playlists.refresh();
    }
  }

  /// --------------------------------------------------------
  /// ADD TO PLAYLIST (Used by AudioPlayerScreen)
  /// --------------------------------------------------------
  void addToPlaylist(String playlistName, Map<String, dynamic> item) {
    final playlist =
        playlists.firstWhere((p) => p["name"] == playlistName, orElse: () => {});

    if (playlist.isEmpty) return;

    final RxList list = playlist["items"];

    // No duplicates
    if (!list.any((e) => e["id"] == item["id"])) {
      list.insert(0, item);
    }

    StorageService.savePlaylists(playlists);
    playlists.refresh();
  }

  void removeTrackFromPlaylist(String playlistName, Map<String, dynamic> item) {
    final index = playlists.indexWhere((p) => p["name"] == playlistName);
    if (index != -1) {
      playlists[index]["tracks"].remove(item);
      playlists.refresh();
    }
  }

  void removeFromPlaylist(String playlistName, Map<String, dynamic> item) {
    final index = playlists.indexWhere((p) => p['name'] == playlistName);
    if (index == -1) {
      Get.snackbar('Error', 'Playlist not found');
      return;
    }

    final playlist = playlists[index];
    final items = List<Map<String, dynamic>>.from(playlist['items'] ?? []);
    
    // Remove item by id or videoId
    final itemId = item['id'] ?? item['videoId'];
    items.removeWhere((i) => (i['id'] == itemId || i['videoId'] == itemId));
    
    playlist['items'] = items;
    playlists[index] = playlist;
    
    StorageService.savePlaylists(playlists);
    playlists.refresh();
    
    Get.snackbar(
      'Removed',
      'Removed from $playlistName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// --------------------------------------------------------
  /// DELETE ENTIRE PLAYLIST
  /// --------------------------------------------------------
  void deletePlaylist(String playlistName) {
    playlists.removeWhere((e) => e["name"] == playlistName);
    StorageService.savePlaylists(playlists);
    playlists.refresh();
  }
}
