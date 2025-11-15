import 'package:get_storage/get_storage.dart';

class StorageService {
  static final _box = GetStorage();

  // Favorites
  static List<dynamic> getFavorites() {
    final data = _box.read('favorites');
    if (data == null) return [];
    if (data is List) return data;
    return [];
  }

  static void saveFavorites(List<dynamic> favorites) {
    _box.write('favorites', favorites);
  }

  // History
  static List<dynamic> getHistory() {
    final data = _box.read('history');
    if (data == null) return [];
    if (data is List) return data;
    return [];
  }

  static void saveHistory(List<dynamic> history) {
    _box.write('history', history);
  }

  // Playlists
  static List<dynamic> getPlaylists() {
    final data = _box.read('playlists');
    if (data == null) return [];
    if (data is List) return data;
    return [];
  }

  static void savePlaylists(List<dynamic> playlists) {
    _box.write('playlists', playlists);
  }

  // Downloads
  static List<dynamic> getDownloads() {
    final data = _box.read('downloads');
    if (data == null) return [];
    if (data is List) return data;
    return [];
  }

  static void saveDownloads(List<dynamic> downloads) {
    _box.write('downloads', downloads);
  }

  // Clear all data
  static void clearAll() {
    _box.erase();
  }
}
