import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:grpc/grpc.dart';

import 'chart_painter.dart';
import 'data_controller.dart';
import 'src/generated/message.pbgrpc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter + gRPC + Chart',
      theme: ThemeData.dark(),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  final screens = [const GrpcScreen(), ChartScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'gRPC'),
          BottomNavigationBarItem(icon: Icon(Icons.show_chart), label: 'Chart'),
        ],
        onTap: (value) {
          setState(() {
            _index = value;
          });
        },
      ),
    );
  }
}

class GrpcScreen extends StatefulWidget {
  const GrpcScreen({super.key});

  @override
  State<GrpcScreen> createState() => _GrpcScreenState();
}

class _GrpcScreenState extends State<GrpcScreen> {
  String message = "Press button to get greeting";

  Future<void> fetchHelloMessage() async {
    final channel = ClientChannel(
      '10.0.2.2', // For Android Emulator
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
      appBar: AppBar(title: const Text("gRPC Greeting")),
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

class ChartScreen extends StatelessWidget {
  final DataController controller = Get.put(DataController());

  ChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Real-Time Chart")),
      body: Obx(() {
        return CustomPaint(
          painter: ChartPainter(List.from(controller.data)),
          size: Size.infinite,
        );
      }),
    );
  }
}
