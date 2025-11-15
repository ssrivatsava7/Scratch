import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/playlist_picker_sheet.dart';

void showAddToPlaylistModal(Map<String, dynamic> item) {
  Get.bottomSheet(
    PlaylistPickerSheet(item: item),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: true,
    isDismissible: true,
  );
}
