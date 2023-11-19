import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:vocabulary_trainer/code_behind/study_card.dart';

abstract class LearningObject {
  // ignore: constant_identifier_names
  static const TYPE_KEY = "type_key";
  // ignore: constant_identifier_names
  static const ALIGNMENT_KEY = "alignment_key";
  // ignore: constant_identifier_names
  static const SCALE_KEY = "scale_key";

  StudyCard parent;
  rx.BehaviorSubject get editingWidgetChangedStream =>
      parent.editingChangedStream;

  Alignment alignment;
  double scale = 1;

  LearningObject(this.alignment, this.parent);

  Widget createAlignmentWidget({Widget? child}) {
    return AnimatedAlign(
      alignment: alignment,
      duration: const Duration(milliseconds: 25),
      child: child,
    );
  }

  Widget creatLearningWidget();

  Widget creatEditingWidget();

  Map<String, dynamic> toJson() {
    return {
      ALIGNMENT_KEY: "${alignment.x}_${alignment.y}",
      SCALE_KEY: scale.toString(),
    };
  }

  //sets the alignment
  void setParamsFromJson(Map<String, dynamic> json) {
    alignment = _alignmentFromString(json[ALIGNMENT_KEY]);
    scale = double.parse(json[SCALE_KEY]);
  }

  Alignment _alignmentFromString(String string) {
    return Alignment(
      double.parse(string.split("_")[0]),
      double.parse(string.split("_")[1]),
    );
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
