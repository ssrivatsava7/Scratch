import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

class AuroraNavbar extends StatelessWidget {
  final int currentIndex;

  const AuroraNavbar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0x660A0E1A),
            Color(0x990A0E1A),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.08)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item(icon: Icons.home_rounded, label: "Home", route: Routes.HOME, index: 0),
          _item(icon: Icons.favorite_rounded, label: "Favs", route: Routes.FAVORITES, index: 1),
          _item(icon: Icons.history_rounded, label: "History", route: Routes.HISTORY, index: 2),
          _item(icon: Icons.download_rounded, label: "Downloads", route: Routes.DOWNLOADS, index: 3),
          _item(icon: Icons.settings_rounded, label: "Settings", route: Routes.SETTINGS, index: 4),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String label,
    required String route,
    required int index,
  }) {
    final selected = index == currentIndex;

    return GestureDetector(
      onTap: () => Get.offNamed(route),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: selected
            ? BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: selected ? 28 : 24,
                color: selected ? const Color(0xFF4FD1C5) : Colors.white70),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : Colors.white70,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
