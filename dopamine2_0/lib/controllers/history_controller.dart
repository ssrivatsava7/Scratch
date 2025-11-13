import 'package:get/get.dart';
import '../services/storage_service.dart';

class HistoryController extends GetxController {
  RxList<Map<String, dynamic>> history = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHistory();
  }

  void loadHistory() {
    history.value = StorageService.getHistory();
  }

  void addHistory(Map<String, dynamic> item) {
    history.removeWhere((h) => h["id"] == item["id"]);
    history.insert(0, item);
    StorageService.saveHistory(history);
  }

  void clearHistory() {
    history.clear();
    StorageService.saveHistory(history);
  }
}
