import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';

class Subject {
  // ignore: constant_identifier_names
  static const COLOR_KEY = "colorKey";

  String _name = "Subject";
  Color? _color;

  List<Topic> topics = [];

  Subject({required String name, Color? color})
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

  void setParamsFromJson(Map<String, dynamic> json) {
    _color = json[COLOR_KEY] == null ? null : Color(json[COLOR_KEY]);
  }

  Map<String, dynamic> toJson() {
    return {
      COLOR_KEY: _color?.value,
    };
  }
}
