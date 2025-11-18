import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_pages.dart';

class DopamineAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showHomeButton;
  final PreferredSizeWidget? bottom;

  const DopamineAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.showHomeButton = true,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      leading: showHomeButton && Get.currentRoute != AppPages.initial
          ? IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                // Navigate to home screen
                Get.offAllNamed(AppPages.initial);
              },
              tooltip: 'Home',
            )
          : null,
      actions: actions,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}
