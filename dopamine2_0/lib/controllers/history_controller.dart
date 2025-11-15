import 'package:get/get.dart';
import '../services/storage_service.dart';

class HistoryController extends GetxController {
  final history = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    try {
      final data = StorageService.getHistory();
      history.value = List<Map<String, dynamic>>.from(
        data.map((e) => e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}),
      );
    } catch (e) {
      print('Error loading history: $e');
      history.value = [];
    }
  }

  void addToHistory(Map<String, dynamic> item) {
    history.removeWhere((e) => e["videoUrl"] == item["videoUrl"]);
    history.insert(0, item);

    StorageService.saveHistory(history);
    history.refresh();
  }

  void removeEntry(Map item) {
    history.remove(item);
    StorageService.saveHistory(history);
    history.refresh();
  }

  void clearHistory() {
    history.clear();
    StorageService.saveHistory(history);
    history.refresh();
  }
}
