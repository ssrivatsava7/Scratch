import 'dart:io';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:path_provider/path_provider.dart';

class DownloadService {
  final yt = YoutubeExplode();

  Future<Directory> _getDownloadDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final downloadDir = Directory("${dir.path}/DopamineDownloads");

    if (!await downloadDir.exists()) {
      await downloadDir.create(recursive: true);
    }
    return downloadDir;
  }

  Stream<double> downloadAudio(String videoUrl, String title) async* {
    final downloadDir = await _getDownloadDir();

    final videoId = VideoId(videoUrl);
    final manifest = await yt.videos.streamsClient.getManifest(videoId);
    final audio = manifest.audioOnly.withHighestBitrate();

    final filePath = "${downloadDir.path}/$title.webm";
    final file = File(filePath);
    final output = file.openWrite();

    final stream = yt.videos.streamsClient.get(audio);

    final total = audio.size.totalBytes;
    int downloaded = 0;

    await for (final data in stream) {
      output.add(data);
      downloaded += data.length;

      yield downloaded / total;
    }

    await output.close();
  }
}
