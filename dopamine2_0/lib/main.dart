import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_libs_audio/media_kit_libs_audio.dart';
import 'package:media_kit_libs_windows_audio/media_kit_libs_windows_audio.dart';
import 'screens/home_screen.dart';
import 'controllers/history_controller.dart';
import 'controllers/youtube_media_controller.dart';

void main() {
  // Ensure Flutter engine and MediaKit are initialized
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(); // ✅ Removed 'await'
  print('✅ MediaKit initialized successfully. Audio backend ready.');

  // Register controllers globally using GetX
  Get.put(HistoryController());
  Get.put(YouTubeMediaController());

  // Launch the app
  runApp(const DopamineApp());
}

class DopamineApp extends StatelessWidget {
  const DopamineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dopamine 2.0',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}
