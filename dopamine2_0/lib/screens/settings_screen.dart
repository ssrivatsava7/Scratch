import 'package:flutter/material.dart';
import '../widgets/aurora_glass_card.dart';
import '../widgets/aurora_navbar.dart';
import '../widgets/aurora_drawer.dart';
import '../theme/midnight_aurora_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: MidnightAuroraTheme.backgroundGradient,
      child: Scaffold(
        backgroundColor: Colors.transparent,

        drawer: const AuroraDrawer(),
        bottomNavigationBar: const AuroraNavbar(currentIndex: 4),

        appBar: AppBar(title: const Text("Settings")),

        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AuroraGlassCard(
              child: SwitchListTile(
                title: const Text("Enable Notifications",
                    style: TextStyle(color: Colors.white)),
                value: true,
                activeColor: const Color(0xFF4FD1C5),
                onChanged: (_) {},
              ),
            ),
            AuroraGlassCard(
              child: SwitchListTile(
                title: const Text("Autoplay Next Song",
                    style: TextStyle(color: Colors.white)),
                value: true,
                activeColor: const Color(0xFF6C63FF),
                onChanged: (_) {},
              ),
            ),
            AuroraGlassCard(
              child: const ListTile(
                title: Text("About Dopamine Player",
                    style: TextStyle(color: Colors.white)),
                subtitle:
                    Text("Version 1.0.0", style: TextStyle(color: Colors.white54)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
