import 'package:flutter/material.dart';

class AuroraPageTransition extends PageTransitionsBuilder {
  const AuroraPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeOutCubic;

    final fade = CurvedAnimation(parent: animation, curve: curve);

    final slide = Tween<Offset>(
      begin: const Offset(0.03, 0.015),    // tiny diagonal slide
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }
}
