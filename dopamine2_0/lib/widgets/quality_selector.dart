import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QualitySelector extends StatelessWidget {
  final String currentQuality;
  final List<String> availableQualities;
  final Function(String) onQualitySelected;

  const QualitySelector({
    super.key,
    required this.currentQuality,
    required this.availableQualities,
    required this.onQualitySelected,
  });

  static Future<String?> show({
    required String currentQuality,
    required List<String> availableQualities,
  }) {
    return Get.dialog<String>(
      AlertDialog(
        title: const Text('Select Quality'),
        content: SizedBox(
          width: double.minPositive,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: availableQualities.length,
            itemBuilder: (context, index) {
              final quality = availableQualities[index];
              final isSelected = quality == currentQuality;
              
              return RadioListTile<String>(
                value: quality,
                groupValue: currentQuality,
                title: Text(quality),
                subtitle: Text(_getQualityDescription(quality)),
                activeColor: Colors.blue,
                selected: isSelected,
                onChanged: (value) {
                  Get.back(result: value);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  static String _getQualityDescription(String quality) {
    switch (quality) {
      case '360p':
        return 'Low quality • Saves data';
      case '480p':
        return 'Medium quality • Balanced';
      case '720p':
        return 'HD quality • Recommended';
      case '1080p':
        return 'Full HD • High quality';
      default:
        return 'Standard quality';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Quality'),
      content: SizedBox(
        width: double.minPositive,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: availableQualities.length,
          itemBuilder: (context, index) {
            final quality = availableQualities[index];
            final isSelected = quality == currentQuality;
            
            return RadioListTile<String>(
              value: quality,
              groupValue: currentQuality,
              title: Text(quality),
              subtitle: Text(_getQualityDescription(quality)),
              activeColor: Colors.blue,
              selected: isSelected,
              onChanged: (value) {
                if (value != null) {
                  onQualitySelected(value);
                  Get.back();
                }
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
