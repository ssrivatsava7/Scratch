import 'package:get/get.dart';
import '../services/storage_service.dart';

class PlaylistController extends GetxController {
  RxList<Map<String, dynamic>> playlists = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadPlaylists();
  }

  void loadPlaylists() {
    // Load from StorageService
    playlists.value = StorageService.getPlaylists();
  }

  void addPlaylist(String name) {
    final playlist = {
      "id": DateTime.now().millisecondsSinceEpoch.toString(),
      "name": name,
      "tracks": <Map<String, dynamic>>[],
    };

    playlists.add(playlist);
    StorageService.savePlaylists(playlists);
  }

  void deletePlaylist(String id) {
    playlists.removeWhere((p) => p["id"] == id);
    StorageService.savePlaylists(playlists);
  }

  void addTrackToPlaylist(String playlistId, Map<String, dynamic> track) {
    final index = playlists.indexWhere((p) => p["id"] == playlistId);
    if (index == -1) return;

    final tracks = List<Map<String, dynamic>>.from(playlists[index]["tracks"]);
    tracks.add(track);

    playlists[index]["tracks"] = tracks;

    // Update storage
    StorageService.savePlaylists(playlists);
    playlists.refresh();
  }

  void removeTrackFromPlaylist(String playlistId, String trackId) {
    final index = playlists.indexWhere((p) => p["id"] == playlistId);
    if (index == -1) return;

    final tracks = List<Map<String, dynamic>>.from(playlists[index]["tracks"]);
    tracks.removeWhere((t) => t["id"] == trackId);

    playlists[index]["tracks"] = tracks;
    StorageService.savePlaylists(playlists);
    playlists.refresh();
  }
}
