import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dopamine',
      theme: ThemeData.dark(),
      home: const SearchPage(),
    );
  }
}

class Config {
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://192.168.1.42:8000'; // Replace with your local IP
    } else {
      return 'http://localhost:8000';
    }
  }
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _controller = TextEditingController();
  final _yt = YoutubeExplode();
  final _player = AudioPlayer();
  List<Video> _results = [];
  bool _loading = false;
  String? _currentPlaying;

  void _search(String query) async {
    setState(() {
      _loading = true;
      _results = [];
    });

    final searchResults = await _yt.search.getVideos(query);
    setState(() {
      _results = searchResults.toList();
      _loading = false;
    });
  }

  Future<void> _playAudio(Video video) async {
    try {
      setState(() {
        _currentPlaying = video.title;
      });

      final response = await http.post(
        Uri.parse('${Config.baseUrl}/get_audio'),

        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'video_url': 'https://www.youtube.com/watch?v=${video.id.value}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioUrl = data['audio_url'];
        await _player.setUrl(audioUrl);
        await _player.play();
      } else {
        print('Failed to fetch audio URL: ${response.body}');
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    _yt.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dopamine")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              onSubmitted: _search,
              decoration: InputDecoration(
                hintText: "Search for YouTube songs",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _search(_controller.text),
                ),
              ),
            ),
          ),
          if (_loading) const CircularProgressIndicator(),
          if (_currentPlaying != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Now playing: $_currentPlaying"),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final video = _results[index];
                return ListTile(
                  title: Text(video.title),
                  subtitle: Text(video.author),
                  trailing: const Icon(Icons.play_arrow),
                  onTap: () => _playAudio(video),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
