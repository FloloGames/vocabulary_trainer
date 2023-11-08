import 'package:flutter/material.dart';

class CustomBottomAppBar extends StatelessWidget {
  List<Widget> children = [];

  CustomBottomAppBar({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      padding: const EdgeInsets.all(8),
      notchMargin: 6,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }
}
