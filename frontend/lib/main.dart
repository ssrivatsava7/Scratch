import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart';

import 'src/generated/message.pbgrpc.dart'; // Make sure this path matches your generated Dart files

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
  String message = "Press button to get greeting";

  Future<void> fetchHelloMessage() async {
    final channel = ClientChannel(
      '10.0.2.2', // Use 10.0.2.2 if running on Android emulator; 'localhost' for iOS simulator
      port: 50051,
      options: const ChannelOptions(credentials: ChannelCredentials.insecure()),
    );

    final stub = GreeterClient(channel);

    try {
      final response = await stub.sayHello(
        HelloRequest()..name = 'Flutter User',
      );
      setState(() {
        message = response.message;
      });
    } catch (e) {
      setState(() {
        message = "Error calling gRPC server: $e";
      });
    }

    await channel.shutdown();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("GoFiber Flutter Client")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(message),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchHelloMessage,
              child: const Text('Say Hello via gRPC'),
            ),
          ],
        ),
      ),
    );
  }
}
