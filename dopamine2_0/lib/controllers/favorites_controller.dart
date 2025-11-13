import 'package:get/get.dart';
import '../services/storage_service.dart';

class FavoritesController extends GetxController {
  RxList<Map<String, dynamic>> favorites = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  void loadFavorites() {
    favorites.value = StorageService.getFavorites();
  }

  void addFavorite(Map<String, dynamic> item) {
    favorites.add(item);
    StorageService.saveFavorites(favorites);
  }

  void removeFavorite(String id) {
    favorites.removeWhere((v) => v["id"] == id);
    StorageService.saveFavorites(favorites);
  }
}
