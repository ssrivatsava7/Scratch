import 'package:flutter/material.dart';
import '../transitions/aurora_page_transition.dart';

class MidnightAuroraTheme {
  static ThemeData theme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: Colors.transparent,
    useMaterial3: true,

    // ----------------------------------------
    // GLOBAL PAGE TRANSITIONS (Apple-style)
    // ----------------------------------------
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: AuroraPageTransition(),
        TargetPlatform.iOS: AuroraPageTransition(),
        TargetPlatform.windows: AuroraPageTransition(),
        TargetPlatform.linux: AuroraPageTransition(),
        TargetPlatform.macOS: AuroraPageTransition(),
      },
    ),

    // ----------------------------------------
    // Typography
    // ----------------------------------------
    fontFamily: "Inter",
    textTheme: const TextTheme(
      bodyMedium: TextStyle(color: Colors.white),
      bodyLarge: TextStyle(color: Colors.white),
      titleLarge:
          TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
    ),

    // ----------------------------------------
    // AppBar
    // ----------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),

    // ----------------------------------------
    // Icon theme
    // ----------------------------------------
    iconTheme: const IconThemeData(color: Colors.white70),
  );

  // ----------------------------------------
  // Aurora Gradient Background
  // ----------------------------------------
  static const backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Color(0xFF0F1A2A),
        Color(0xFF0A0E1A),
        Color(0xFF121B33),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  // ----------------------------------------
  // GLASS EFFECT (frosted blur)
  // ----------------------------------------
  static final glass = BoxDecoration(
    color: Colors.white.withOpacity(0.08),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(
      color: Colors.white.withOpacity(0.12),
      width: 1.2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.25),
        blurRadius: 20,
        offset: const Offset(0, 6),
      ),
    ],
  );

  // ----------------------------------------
  // Bottom Sheet Decoration
  // ----------------------------------------
  static final bottomSheetDecoration = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.black.withOpacity(0.9),
        Colors.purple.withOpacity(0.3),
        Colors.black.withOpacity(0.9),
      ],
    ),
    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  );
}
