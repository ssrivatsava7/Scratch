import 'package:get_storage/get_storage.dart';

class StorageService {
  static final box = GetStorage();

  // --------------------
  // PLAYLISTS
  // --------------------
  static List<Map<String, dynamic>> getPlaylists() {
    return List<Map<String, dynamic>>.from(
      box.read('playlists') ?? [],
    );
  }

  static void savePlaylists(List playlists) {
    box.write('playlists', playlists);
  }

  // --------------------
  // FAVORITES
  // --------------------
  static List<Map<String, dynamic>> getFavorites() {
    return List<Map<String, dynamic>>.from(
      box.read('favorites') ?? [],
    );
  }

  static void saveFavorites(List favorites) {
    box.write('favorites', favorites);
  }

  // --------------------
  // HISTORY
  // --------------------
  static List<Map<String, dynamic>> getHistory() {
    return List<Map<String, dynamic>>.from(
      box.read('history') ?? [],
    );
  }

  static void saveHistory(List history) {
    box.write('history', history);
  }

  // --------------------
  // DOWNLOADS
  // --------------------
  static List<Map<String, dynamic>> getDownloads() {
    return List<Map<String, dynamic>>.from(
      box.read('downloads') ?? [],
    );
  }

  static void saveDownloads(List downloads) {
    box.write('downloads', downloads);
  }
}
