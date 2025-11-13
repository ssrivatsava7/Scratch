import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../theme/midnight_aurora_theme.dart';

class AuroraDrawer extends StatelessWidget {
  const AuroraDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        decoration: MidnightAuroraTheme.glass.copyWith(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Dopamine Player",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Midnight Aurora Theme",
                    style: TextStyle(color: Colors.white54, fontSize: 14),
                  ),
                ],
              ),
            ),
            _item("Home", Routes.HOME),
            _item("Favorites", Routes.FAVORITES),
            _item("History", Routes.HISTORY),
            _item("Downloads", Routes.DOWNLOADS),
            _item("Settings", Routes.SETTINGS),
          ],
        ),
      ),
    );
  }

  Widget _item(String label, String route) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => Get.offNamed(route),
      hoverColor: Colors.white.withOpacity(0.05),
    );
  }
}
