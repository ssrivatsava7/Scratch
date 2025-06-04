import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'go_fiber_ffi.dart'; // Your Dart FFI wrapper

// Separate function to start the GoFiber server in a new isolate
void startGoFiber(_) {
  GoFiberFFI.startServer();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start GoFiber server in a separate isolate
  await Isolate.spawn(startGoFiber, null);

  // Launch the Flutter app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoFiber + Flutter Demo',
      home: Scaffold(
        appBar: AppBar(
          title: Text('GoFiber + Flutter'),
        ),
        body: Center(
          child: Text(
            'Server running on 127.0.0.1:8080',
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
