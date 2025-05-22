import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoFiber Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String message = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchHelloMessage();
  }

  Future<void> fetchHelloMessage() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8080/hello'));
      if (response.statusCode == 200) {
        setState(() {
          message = response.body;
        });
      } else {
        setState(() {
          message = "Error: ${response.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        message = "Failed to connect to backend: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GoFiber Flutter Client")),
      body: Center(child: Text(message)),
    );
  }
}
