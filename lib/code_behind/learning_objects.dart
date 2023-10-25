import 'dart:ui';

import 'package:flutter/material.dart';

abstract class LearningObject {
  Offset offset;
  Paint paint;
  LearningObject(this.offset, this.paint);

  void drawObject(Canvas canvas);
}

// class TextObject extends LearningObject {
//   String text = "text";

//   TextObject(this.text, Offset offset) : super(offset);

//   @override
//   void drawObject(Canvas canvas, Paint paint) {}
// }

class LineObject extends LearningObject {
  List<Offset> points;

  LineObject(this.points, super.offset, super.paint);

  @override
  void drawObject(Canvas canvas) {
    canvas.drawPoints(PointMode.points, points, paint);
    // for (int i = 0; i < points.length - 1; i++) {
    //   canvas.drawLine(points[i], points[i + 1], paint);
    // }
  }
}
