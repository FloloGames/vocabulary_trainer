import 'dart:ui';

import 'package:vocabulary_trainer/code_behind/study_card.dart';

class Topic {
  String _name = "Subject";
  Color? _color;

  List<StudyCard> studyCards = [];

  Topic({required String name, Color? color})
      : _color = color,
        _name = name;

  String get name => _name;
  Color get color =>
      _color == null ? const Color.fromARGB(127, 127, 127, 127) : _color!;

  void setColor(Color color) {
    _color = color;
  }

  void setName(String name) {
    _name = name;
  }
}
