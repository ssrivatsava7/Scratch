import 'package:flutter/material.dart';
import '../theme/midnight_aurora_theme.dart';

class AuroraGlassCard extends StatefulWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final VoidCallback? onTap;

  const AuroraGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin = const EdgeInsets.only(bottom: 12),
    this.borderRadius = 18,
    this.onTap,
  });

  @override
  State<AuroraGlassCard> createState() => _AuroraGlassCardState();
}

class _AuroraGlassCardState extends State<AuroraGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  bool hovering = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        hovering = true;
        _hoverController.forward();
      },
      onExit: (_) {
        hovering = false;
        _hoverController.reverse();
      },
      child: AnimatedBuilder(
        animation: _hoverController,
        builder: (context, _) {
          final glow = _hoverController.value * 15;

          return GestureDetector(
            onTapDown: (_) => _hoverController.reverse(),
            onTapUp: (_) => _hoverController.forward(),
            onTapCancel: () => _hoverController.forward(),
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: widget.margin,
              padding: widget.padding,
              decoration: MidnightAuroraTheme.glass.copyWith(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.05),
                    blurRadius: 4 + glow,
                    spreadRadius: glow / 5,
                  )
                ],
              ),
              transform: Matrix4.identity()
                ..translate(0.0, -glow / 8)
                ..scale(1.0 + glow * 0.002),
              child: widget.child,
            ),
          );
        },
      ),
    );
  }
}
