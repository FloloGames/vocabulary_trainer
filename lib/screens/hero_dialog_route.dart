// import 'package:flutter/material.dart';

// class HeroDialogRoute extends PageRoute {
//   HeroDialogRoute({required this.builder}) : super();

//   final WidgetBuilder builder;

//   @override
//   bool get opaque => false;

//   @override
//   bool get barrierDismissible => true;

//   @override
//   Duration get transitionDuration => const Duration(milliseconds: 300);

//   @override
//   bool get maintainState => true;

//   @override
//   Color get barrierColor => Colors.black54;

//   @override
//   Widget buildTransitions(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation, Widget child) {
//     return FadeTransition(
//         opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
//         child: child);
//   }

//   @override
//   Widget buildPage(BuildContext context, Animation<double> animation,
//       Animation<double> secondaryAnimation) {
//     return builder(context);
//   }

//   @override
//   // TODO: implement barrierLabel
//   String? get barrierLabel => "throw UnimplementedError()";
// }
// //Example:

// // await Navigator.push(
// //       context,
// //       HeroDialogRoute(
// //         builder: (BuildContext context) {
// //           return Center(
// //             child: Hero(
// //               tag: getSubjectHeroString(index),
// //               child: AlertDialog(
// //                 title: const Text('You are my hero.'),
// //                 content: const SizedBox(
// //                   height: 200.0,
// //                   width: 200.0,
// //                   child: FlutterLogo(),
// //                 ),
// //                 actions: <Widget>[
// //                   TextButton(
// //                     onPressed: Navigator.of(context).pop,
// //                     child: const Text('RAD!'),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );