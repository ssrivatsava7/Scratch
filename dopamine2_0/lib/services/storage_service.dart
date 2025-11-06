import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/video_item.dart';
import '../models/playlist.dart';
import '../models/download_item.dart';

class StorageService {
  static const String _favoritesKey = 'favorites';
  static const String _historyKey = 'history';
  static const String _playlistsKey = 'playlists';
  static const String _downloadsKey = 'downloads';
  static const String _cacheKey = 'url_cache';
  static const String _qualityPreferenceKey = 'quality_preference';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Favorites
  Future<List<VideoItem>> getFavorites() async {
    final String? favoritesJson = _prefs.getString(_favoritesKey);
    if (favoritesJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(favoritesJson);
    return decoded.map((item) => VideoItem.fromJson(item)).toList();
  }

  Future<bool> saveFavorites(List<VideoItem> favorites) async {
    final String encoded = jsonEncode(favorites.map((f) => f.toJson()).toList());
    return await _prefs.setString(_favoritesKey, encoded);
  }

  Future<bool> addFavorite(VideoItem video) async {
    final favorites = await getFavorites();
    if (!favorites.any((v) => v.id == video.id)) {
      favorites.insert(0, video);
      return await saveFavorites(favorites);
    }
    return false;
  }

  Future<bool> removeFavorite(String videoId) async {
    final favorites = await getFavorites();
    favorites.removeWhere((v) => v.id == videoId);
    return await saveFavorites(favorites);
  }

  Future<bool> isFavorite(String videoId) async {
    final favorites = await getFavorites();
    return favorites.any((v) => v.id == videoId);
  }

  // History
  Future<List<VideoItem>> getHistory() async {
    final String? historyJson = _prefs.getString(_historyKey);
    if (historyJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(historyJson);
    return decoded.map((item) => VideoItem.fromJson(item)).toList();
  }

  Future<bool> saveHistory(List<VideoItem> history) async {
    final String encoded = jsonEncode(history.map((h) => h.toJson()).toList());
    return await _prefs.setString(_historyKey, encoded);
  }

  Future<bool> addToHistory(VideoItem video) async {
    final history = await getHistory();
    // Remove if exists to add to top
    history.removeWhere((v) => v.id == video.id);
    history.insert(0, video);
    
    // Keep only last 100 items
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    
    return await saveHistory(history);
  }

  Future<bool> clearHistory() async {
    return await _prefs.remove(_historyKey);
  }

  // Playlists
  Future<List<Playlist>> getPlaylists() async {
    final String? playlistsJson = _prefs.getString(_playlistsKey);
    if (playlistsJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(playlistsJson);
    return decoded.map((item) => Playlist.fromJson(item)).toList();
  }

  Future<bool> savePlaylists(List<Playlist> playlists) async {
    final String encoded = jsonEncode(playlists.map((p) => p.toJson()).toList());
    return await _prefs.setString(_playlistsKey, encoded);
  }

  Future<bool> addPlaylist(Playlist playlist) async {
    final playlists = await getPlaylists();
    if (!playlists.any((p) => p.id == playlist.id)) {
      playlists.add(playlist);
      return await savePlaylists(playlists);
    }
    return false;
  }

  Future<bool> updatePlaylist(Playlist playlist) async {
    final playlists = await getPlaylists();
    final index = playlists.indexWhere((p) => p.id == playlist.id);
    if (index != -1) {
      playlists[index] = playlist;
      return await savePlaylists(playlists);
    }
    return false;
  }

  Future<bool> deletePlaylist(String playlistId) async {
    final playlists = await getPlaylists();
    playlists.removeWhere((p) => p.id == playlistId);
    return await savePlaylists(playlists);
  }

  // Downloads
  Future<List<DownloadItem>> getDownloads() async {
    final String? downloadsJson = _prefs.getString(_downloadsKey);
    if (downloadsJson == null) return [];
    
    final List<dynamic> decoded = jsonDecode(downloadsJson);
    return decoded.map((item) => DownloadItem.fromJson(item)).toList();
  }

  Future<bool> saveDownloads(List<DownloadItem> downloads) async {
    final String encoded = jsonEncode(downloads.map((d) => d.toJson()).toList());
    return await _prefs.setString(_downloadsKey, encoded);
  }

  Future<bool> addDownload(DownloadItem download) async {
    final downloads = await getDownloads();
    if (!downloads.any((d) => d.id == download.id)) {
      downloads.add(download);
      return await saveDownloads(downloads);
    }
    return false;
  }

  Future<bool> updateDownload(DownloadItem download) async {
    final downloads = await getDownloads();
    final index = downloads.indexWhere((d) => d.id == download.id);
    if (index != -1) {
      downloads[index] = download;
      return await saveDownloads(downloads);
    }
    return false;
  }

  Future<bool> removeDownload(String downloadId) async {
    final downloads = await getDownloads();
    downloads.removeWhere((d) => d.id == downloadId);
    return await saveDownloads(downloads);
  }

  // URL Cache
  Future<Map<String, dynamic>?> getCachedUrl(String videoId) async {
    final String? cacheJson = _prefs.getString(_cacheKey);
    if (cacheJson == null) return null;
    
    final Map<String, dynamic> cache = jsonDecode(cacheJson);
    final videoCache = cache[videoId];
    
    if (videoCache != null) {
      final cachedAt = DateTime.parse(videoCache['cachedAt']);
      // Cache expires after 1 hour
      if (DateTime.now().difference(cachedAt).inHours < 1) {
        return videoCache;
      }
    }
    return null;
  }

  Future<bool> cacheUrl(String videoId, String url, Map<String, String> headers) async {
    final String? cacheJson = _prefs.getString(_cacheKey);
    final Map<String, dynamic> cache = cacheJson != null 
        ? jsonDecode(cacheJson) 
        : {};
    
    cache[videoId] = {
      'url': url,
      'headers': headers,
      'cachedAt': DateTime.now().toIso8601String(),
    };
    
    // Keep only last 50 cached URLs
    if (cache.length > 50) {
      final sortedKeys = cache.keys.toList()
        ..sort((a, b) {
          final aTime = DateTime.parse(cache[a]['cachedAt']);
          final bTime = DateTime.parse(cache[b]['cachedAt']);
          return aTime.compareTo(bTime);
        });
      
      for (var i = 0; i < cache.length - 50; i++) {
        cache.remove(sortedKeys[i]);
      }
    }
    
    return await _prefs.setString(_cacheKey, jsonEncode(cache));
  }

  // Quality Preference
  Future<String> getQualityPreference() async {
    return _prefs.getString(_qualityPreferenceKey) ?? '720p';
  }

  Future<bool> setQualityPreference(String quality) async {
    return await _prefs.setString(_qualityPreferenceKey, quality);
  }
}
