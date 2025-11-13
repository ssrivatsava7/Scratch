import 'package:flutter/material.dart';

class ParallaxThumbnail extends StatelessWidget {
  final String url;

  const ParallaxThumbnail({
    super.key,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.03, end: 1.0),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 70,
          height: 55,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
