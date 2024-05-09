import 'package:flutter/material.dart';

/// Transparent AppBar.
class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TransparentAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(
          color: Colors.grey), // Use iconTheme for icon color
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
