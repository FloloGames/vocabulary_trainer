import 'package:flutter/material.dart';

class CustomPageTransitionAnimation extends PageRouteBuilder {
  final Widget enterWidget;
  final Alignment alignment;
  final double startWidth;
  final double startHeight;
  final Color color;
  Offset offset;
  CustomPageTransitionAnimation({
    required this.enterWidget,
    required this.alignment,
    required this.startHeight,
    required this.startWidth,
    required this.color,
    this.offset = Offset.zero,
  }) : super(
          opaque: true,
          pageBuilder: (context, animation, secondaryAnimation) => enterWidget,
          transitionDuration: const Duration(milliseconds: 1500),
          reverseTransitionDuration: const Duration(milliseconds: 1500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const curve = Curves.easeInOut;

            var horizontalTween = Tween(
                    begin: startWidth / MediaQuery.of(context).size.width,
                    end: 1.0)
                .chain(CurveTween(curve: curve));

            var verticalTween = Tween(
                    begin: startHeight / MediaQuery.of(context).size.height,
                    end: 1.0)
                .chain(CurveTween(curve: curve));

            var colorTween = ColorTween(
              begin: color, // Set your initial color
              end: Colors.transparent, // Set your desired transparent end color
            ).chain(CurveTween(curve: Curves.easeInOutCubic));

            var horizontalScale = animation.drive(horizontalTween);
            var verticalScale = animation.drive(verticalTween);
            var colorAnimation = animation.drive(colorTween);

            // double width = MediaQuery.of(context).size.width;
            // double height = MediaQuery.of(context).size.height;

            // double alignmentX = (offset.dx - width / 2) / (width / 2);
            // double alignmentY = (offset.dy - height / 2) / (height / 2);
            // // double alignmentX = (2 * offset.dx / width) - 1;
            // // double alignmentY = (2 * offset.dy / height) - 1;
            // const newAlignment = Alignment(-0.5, 0.36 /*0.435*/);

            // print("$alignmentX : $alignmentY");

            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Transform.scale(
                scaleX: horizontalScale.value,
                scaleY: verticalScale.value,
                alignment: alignment,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    colorAnimation.value!,
                    BlendMode.srcATop, // Choose the blend mode as needed
                  ),
                  child: child,
                ),
              ),
            );
          },
        );
}



// class CustomPageTransitionAnimation extends PageRouteBuilder {
//   final Widget enterWidget;
//   final Alignment alignment;
//   CustomPageTransitionAnimation(this.enterWidget, this.alignment)
//       : super(
//           opaque: true,
//           pageBuilder: (context, animation, secondaryAnimation) => enterWidget,
//           transitionDuration: const Duration(milliseconds: 500),
//           reverseTransitionDuration: const Duration(milliseconds: 500),
//           transitionsBuilder: (context, animation, secondaryAnimation, child) {
//             animation = CurvedAnimation(
//               parent: animation,
//               curve: Curves.fastLinearToSlowEaseIn,
//               reverseCurve: Curves.fastOutSlowIn,
//             );

//             return ScaleTransition(
//               scale: animation,
//               alignment: alignment,
//               child: child,
//             );
//           },
//         );
// }
