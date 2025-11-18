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
      "items": [],
    });
    StorageService.savePlaylists(playlists);
    playlists.refresh();
  }

  /// --------------------------------------------------------
  /// ADD TRACK (UI calls this for modal)
  /// --------------------------------------------------------
  void addTrack(String playlistName, Map<String, dynamic> item) {
    final index = playlists.indexWhere((p) => p["name"] == playlistName);
    if (index != -1) {
      // Handle both 'items' and 'tracks' keys
      final itemsKey = playlists[index].containsKey('items') ? 'items' : 'tracks';
      
      if (playlists[index][itemsKey] == null) {
        playlists[index][itemsKey] = [];
      }
      
      playlists[index][itemsKey].add(item);
      StorageService.savePlaylists(playlists);
      playlists.refresh();
    }
  }

  /// --------------------------------------------------------
  /// ADD TO PLAYLIST (Used by AudioPlayerScreen)
  /// --------------------------------------------------------
  void addToPlaylist(String playlistName, Map<String, dynamic> item) {
    final playlist =
        playlists.firstWhere((p) => p["name"] == playlistName, orElse: () => {});

    if (playlist.isEmpty) {
      print('Playlist "$playlistName" not found');
      return;
    }

    // Handle both 'items' and 'tracks' keys
    final itemsKey = playlist.containsKey('items') ? 'items' : 'tracks';
    
    if (playlist[itemsKey] == null) {
      playlist[itemsKey] = RxList<Map<String, dynamic>>([]);
    }
    
    final RxList list = playlist[itemsKey];

    // No duplicates - check both id and videoId
    final itemId = item['id'] ?? item['videoId'];
    if (!list.any((e) => (e["id"] == itemId || e["videoId"] == itemId))) {
      list.insert(0, item);
      print('Added "${item["title"]}" to "$playlistName"');
    } else {
      print('Item already exists in "$playlistName"');
    }

    StorageService.savePlaylists(playlists);
    playlists.refresh();
  }

  void removeTrackFromPlaylist(String playlistName, Map<String, dynamic> item) {
    final index = playlists.indexWhere((p) => p["name"] == playlistName);
    if (index != -1) {
      // Handle both 'items' and 'tracks' keys
      final itemsKey = playlists[index].containsKey('items') ? 'items' : 'tracks';
      playlists[index][itemsKey].remove(item);
      StorageService.savePlaylists(playlists);
      playlists.refresh();
    }
  }

  void removeFromPlaylist(String playlistName, Map<String, dynamic> item) {
    print('=== REMOVE FROM PLAYLIST DEBUG ===');
    print('Playlist name: "$playlistName"');
    print('Item to remove: ${item["title"]} (id: ${item["id"]}, videoId: ${item["videoId"]})');
    print('Available playlists: ${playlists.map((p) => p["name"]).toList()}');
    
    final index = playlists.indexWhere((p) => p['name'] == playlistName);
    if (index == -1) {
      print('ERROR: Playlist "$playlistName" not found!');
      Get.snackbar(
        'Error', 
        'Playlist "$playlistName" not found',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    print('Playlist found at index: $index');
    final playlist = playlists[index];
    
    // Handle both 'items' and 'tracks' keys
    final itemsKey = playlist.containsKey('items') ? 'items' : 'tracks';
    print('Using key: "$itemsKey"');
    
    // Get items as RxList to modify directly
    if (playlist[itemsKey] is RxList) {
      final RxList rxList = playlist[itemsKey];
      print('Current items count: ${rxList.length}');
      
      // Remove item by id or videoId
      final itemId = item['id'] ?? item['videoId'];
      final originalLength = rxList.length;
      
      rxList.removeWhere((i) {
        final matches = (i['id'] == itemId || i['videoId'] == itemId);
        if (matches) {
          print('Found matching item: ${i["title"]}');
        }
        return matches;
      });
      
      if (rxList.length == originalLength) {
        print('ERROR: Item not found in playlist');
        print('Looking for id: $itemId');
        print('Playlist items: ${rxList.map((i) => "id:${i['id']}, videoId:${i['videoId']}").toList()}');
        Get.snackbar(
          'Not Found', 
          'Item not found in playlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }
      
      print('Successfully removed! New count: ${rxList.length}');
    } else {
      // Fallback for non-RxList
      final items = List<Map<String, dynamic>>.from(playlist[itemsKey] ?? []);
      final itemId = item['id'] ?? item['videoId'];
      final originalLength = items.length;
      items.removeWhere((i) => (i['id'] == itemId || i['videoId'] == itemId));
      
      if (items.length == originalLength) {
        print('ERROR: Item not found in playlist (fallback)');
        return;
      }
      
      playlist[itemsKey] = items;
      playlists[index] = playlist;
    }
    
    StorageService.savePlaylists(playlists);
    playlists.refresh();
    
    Get.snackbar(
      'Removed',
      'Removed from $playlistName',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    
    print('=== END DEBUG ===');
  }

  /// --------------------------------------------------------
  /// DELETE ENTIRE PLAYLIST
  /// --------------------------------------------------------
  void deletePlaylist(String playlistName) {
    playlists.removeWhere((e) => e["name"] == playlistName);
    StorageService.savePlaylists(playlists);
    playlists.refresh();
  }

  /// Get all tracks in a specific playlist (returns List<Map<String, dynamic>>)
  List<Map<String, dynamic>> getPlaylistTracks(String playlistName) {
    final playlist = playlists.firstWhereOrNull((p) => p['name'] == playlistName);
    if (playlist == null) return [];
    
    // Use 'items' key which is the standard in this controller
    final itemsKey = playlist.containsKey('items') ? 'items' : 'tracks';
    final List<dynamic> tracksList = playlist[itemsKey] ?? [];
    
    return tracksList.map((trackData) {
      if (trackData is Map<String, dynamic>) {
        return trackData;
      } else if (trackData is Map) {
        return Map<String, dynamic>.from(trackData);
      }
      return <String, dynamic>{};
    }).toList();
  }
}
