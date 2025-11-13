import 'package:get/get.dart';
import '../services/download_service.dart';

class DownloadController extends GetxController {
  final service = DownloadService();

  RxList<Map<String, dynamic>> downloads = <Map<String, dynamic>>[].obs;

  Future<void> downloadAudio(String url, String title) async {
    final item = {
      "title": title,
      "progress": 0.0,
      "status": "downloading",
    };

    downloads.add(item);

    final index = downloads.length - 1;

    service.downloadAudio(url, title).listen(
      (progress) {
        downloads[index]["progress"] = progress;
        downloads.refresh();
      },
      onDone: () {
        downloads[index]["status"] = "completed";
        downloads.refresh();
      },
      onError: (e) {
        downloads[index]["status"] = "failed";
        downloads.refresh();
      },
    );
  }
}
