import 'package:flutter/material.dart';

class CustomPageTransitionAnimation extends PageRouteBuilder {
  final Widget enterWidget;
  final Alignment alignment;
  CustomPageTransitionAnimation(this.enterWidget, this.alignment)
      : super(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) => enterWidget,
          transitionDuration: const Duration(milliseconds: 500),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            animation = CurvedAnimation(
              parent: animation,
              curve: Curves.fastLinearToSlowEaseIn,
              reverseCurve: Curves.fastOutSlowIn,
            );

            return ScaleTransition(
              scale: animation,
              alignment: alignment,
              child: child,
            );
          },
        );
}
