import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'screens/audio_player_screen.dart';

void main() {
  // Must call this before any other media_kit usage
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized(); // remove 'await' here

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
      home: AudioPlayerScreen(),
    );
  }
}
