import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
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
      "tracks": <MediaItem>[],
    });
  }

  /// --------------------------------------------------------
  /// ADD TRACK (UI calls this for modal)
  /// --------------------------------------------------------
  void addTrack(String playlistName, MediaItem item) {
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

  void removeFromPlaylist(String playlistName, MediaItem item) {
    final index = playlists.indexWhere((p) => p["name"] == playlistName);
    if (index != -1) {
      playlists[index]["tracks"].remove(item);
      playlists.refresh();
    }
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
