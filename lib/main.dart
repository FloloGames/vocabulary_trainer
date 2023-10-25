import 'package:flutter/material.dart';

import 'screens/home_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocabulary Trainer',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}



// import 'package:flutter/material.dart';

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Draggable Custom Painter',
//       home: Scaffold(
//         body: CustomPainterDraggable(),
//       ),
//     );
//   }
// }

// class CustomPainterDraggable extends StatefulWidget {
//   @override
//   _CustomPainterDraggableState createState() => _CustomPainterDraggableState();
// }

// class _CustomPainterDraggableState extends State<CustomPainterDraggable> {
//   var xPos = 0.0;
//   var yPos = 0.0;
//   final width = 100.0;
//   final height = 100.0;
//   bool _dragging = false;

//   /// Is the point (x, y) inside the rect?
//   bool _insideRect(double x, double y) =>
//       x >= xPos && x <= xPos + width && y >= yPos && y <= yPos + height;

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onPanStart: (details) => _dragging = _insideRect(
//         details.globalPosition.dx,
//         details.globalPosition.dy,
//       ),
//       onPanEnd: (details) {
//         _dragging = false;
//       },
//       onPanUpdate: (details) {
//         if (_dragging) {
//           setState(() {
//             xPos += details.delta.dx;
//             yPos += details.delta.dy;
//           });
//         }
//       },
//       child: Container(
//         color: Colors.white,
//         child: CustomPaint(
//           painter: RectanglePainter(Rect.fromLTWH(xPos, yPos, width, height)),
//           child: Container(),
//         ),
//       ),
//     );
//   }
// }

// class RectanglePainter extends CustomPainter {
//   RectanglePainter(this.rect);
//   final Rect rect;

//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.drawRect(rect, Paint());
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) => true;
// }
