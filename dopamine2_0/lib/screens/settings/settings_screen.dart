import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Settings', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsSection(
            'About',
            [
              _buildSettingsTile(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
              _buildSettingsTile(
                icon: Icons.description,
                title: 'About Dopamine Player',
                subtitle: 'A powerful YouTube music and video player',
                onTap: () => _showAboutDialog(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSettingsSection(
            'Storage',
            [
              _buildSettingsTile(
                icon: Icons.folder,
                title: 'Download Location',
                subtitle: 'Manage download folder',
                onTap: () {
                  Get.snackbar(
                    'Download Location',
                    'Downloads are saved in the app directory',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                },
              ),
              _buildSettingsTile(
                icon: Icons.delete_sweep,
                title: 'Clear Cache',
                subtitle: 'Free up storage space',
                onTap: () => _showClearCacheDialog(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.purpleAccent,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.purpleAccent),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      onTap: onTap,
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('About Dopamine Player', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Dopamine Player v1.0.0\n\n'
          'A powerful music and video player that streams content from YouTube.\n\n'
          'Features:\n'
          '• Audio and video playback\n'
          '• Create and manage playlists\n'
          '• Download for offline playback\n'
          '• Favorites and history tracking\n\n'
          '© 2024 Dopamine Player',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Close', style: TextStyle(color: Colors.purpleAccent)),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will clear temporary files and free up storage space. Continue?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Cache Cleared',
                'Temporary files have been removed',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
