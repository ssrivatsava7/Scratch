import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/storage_service.dart';

class FavoritesController extends GetxController {
  final favorites = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    try {
      final data = StorageService.getFavorites();
      favorites.value = List<Map<String, dynamic>>.from(
        data.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}),
      );
    } catch (e) {
      print('Error loading favorites: $e');
      favorites.value = [];
    }
  }

  void toggleFavorite(Map<String, dynamic> item) {
    final index = favorites.indexWhere((e) => e["id"] == item["id"]);

    if (index != -1) {
      favorites.removeAt(index);
      Get.snackbar(
        "Removed from Favorites",
        item["title"] ?? "Track removed",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } else {
      favorites.insert(0, item);
      Get.snackbar(
        "Added to Favorites",
        item["title"] ?? "Track added",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.7),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }

    StorageService.saveFavorites(favorites);
    favorites.refresh();
  }

  void removeFavorite(Map<String, dynamic> item) {
    favorites.removeWhere((e) => e["id"] == item["id"]);
    StorageService.saveFavorites(favorites);
    favorites.refresh();
    Get.snackbar(
      "Removed from Favorites",
      item["title"] ?? "Track removed",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.orange.withOpacity(0.7),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  bool isFavorite(String id) {
    return favorites.any((e) => e["id"] == id);
  }
}
