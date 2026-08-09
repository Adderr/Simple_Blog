import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BaceFook extends StatelessWidget implements PreferredSizeWidget {
  const BaceFook({super.key, this.actions, this.onLogoPress});
  final List<Widget>? actions;
  final VoidCallback? onLogoPress;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => context.go('/'),
            style: TextButton.styleFrom(backgroundColor: Colors.transparent),
            child: const Text(
              'BaceFook',
              style: TextStyle(
                color: Color.fromARGB(255, 90, 181, 250),
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (actions != null) Row(children: actions!),
        ],
      ),
      backgroundColor: const Color.fromARGB(255, 1, 66, 119),
    );
  }
}
