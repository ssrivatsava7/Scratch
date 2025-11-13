import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class StorageService {
  static final box = GetStorage();

  // -------- FAVORITES --------
  static List<Map<String, dynamic>> getFavorites() {
    final raw = box.read("favorites");
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(raw);
  }

  static void saveFavorites(List<Map<String, dynamic>> favorites) {
    box.write("favorites", favorites);
  }

  // -------- HISTORY --------
  static List<Map<String, dynamic>> getHistory() {
    final raw = box.read("history");
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(raw);
  }

  static void saveHistory(List<Map<String, dynamic>> history) {
    box.write("history", history);
  }

  // -------- PLAYLISTS --------
  static List<Map<String, dynamic>> getPlaylists() {
    final raw = box.read("playlists");
    if (raw == null) return [];
    return List<Map<String, dynamic>>.from(raw);
  }

  static void savePlaylists(List<Map<String, dynamic>> playlists) {
    box.write("playlists", playlists);
  }
}
