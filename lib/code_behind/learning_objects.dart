import 'dart:ui';

import 'package:flutter/material.dart';

abstract class LearningObject {
  // ignore: constant_identifier_names
  static const TYPE_KEY = "type_key";
  // ignore: constant_identifier_names
  static const OFFSET_KEY = "offset_key";
  // ignore: constant_identifier_names
  static const PAINT_KEY = "paint_key";

  Offset offset;
  Paint paint;
  LearningObject(this.offset, this.paint);

  void drawObject(Canvas canvas);

  Map<String, dynamic> toJson() {
    return {
      OFFSET_KEY: "${offset.dx}_${offset.dy}",
      PAINT_KEY: "",
    };
  }

  void setParamsFromJson(Map<String, dynamic> json) {
    offset = _offsetFromString(json[OFFSET_KEY]);
    paint = _paintFromString(json[PAINT_KEY]);
  }

  Offset _offsetFromString(String string) {
    return Offset(
        double.parse(string.split("_")[0]), double.parse(string.split("_")[1]));
  }

  Paint _paintFromString(json) {
    //TODO
    return Paint();
  }
}

class TextObject extends LearningObject {
  // ignore: constant_identifier_names
  static const TYPE_KEY = "TextObject";
  // ignore: constant_identifier_names
  static const TEXT_KEY = "text_key";

  String text = "text";

  TextObject(this.text, super.offset, super.paint);

  @override
  void drawObject(Canvas canvas) {}

  @override
  void setParamsFromJson(Map<String, dynamic> json) {
    super.setParamsFromJson(json);
    text = json[TEXT_KEY];
  }

  @override
  Map<String, dynamic> toJson() {
    final superMap = super.toJson();
    superMap.addAll({
      TEXT_KEY: text,
      LearningObject.TYPE_KEY: TYPE_KEY,
    });

    return superMap;
  }
}

// class LineObject extends LearningObject {
//   List<Offset> points;

//   LineObject(this.points, super.offset, super.paint);

//   @override
//   void drawObject(Canvas canvas) {
//     canvas.drawPoints(PointMode.points, points, paint);
//     // for (int i = 0; i < points.length - 1; i++) {
//     //   canvas.drawLine(points[i], points[i + 1], paint);
//     // }
//   }
// }
