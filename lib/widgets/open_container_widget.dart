import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class OpenContainerWidget extends StatelessWidget {
  Widget Function(BuildContext, void Function({Object? returnValue}))
      openBuilder;
  Widget Function(BuildContext, void Function()) closedBuilder;
  void Function(Object?)? onClosed;
  void Function() onLongPress;

  OpenContainerWidget({
    super.key,
    required this.openBuilder,
    required this.closedBuilder,
    required this.onLongPress,
    this.onClosed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: OpenContainer(
        onClosed: onClosed,
        transitionDuration: const Duration(milliseconds: 550),
        closedElevation: 0,
        openElevation: 0,
        closedColor: Colors.transparent,
        openColor: Colors.transparent,
        middleColor: Colors.transparent,
        openBuilder: openBuilder,
        closedBuilder: closedBuilder,
      ),
    );
  }
}
