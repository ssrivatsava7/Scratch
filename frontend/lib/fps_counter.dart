import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FpsCounter extends StatefulWidget {
  final Color textColor;

  const FpsCounter({this.textColor = Colors.red, Key? key}) : super(key: key);

  @override
  _FpsCounterState createState() => _FpsCounterState();
}

class _FpsCounterState extends State<FpsCounter> {
  int _frames = 0;
  double _fps = 0.0;
  late final Ticker _ticker;
  late DateTime _lastTime;

  @override
  void initState() {
    super.initState();
    _lastTime = DateTime.now();
    _ticker = Ticker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    _frames++;
    final now = DateTime.now();
    final diff = now.difference(_lastTime);
    if (diff.inMilliseconds >= 1000) {
      setState(() {
        _fps = _frames * 1000 / diff.inMilliseconds;
      });
      _frames = 0;
      _lastTime = now;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${_fps.toStringAsFixed(1)} FPS',
      style: TextStyle(
        color: widget.textColor,
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}
