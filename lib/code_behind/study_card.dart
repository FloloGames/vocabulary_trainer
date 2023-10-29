import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects.dart';

class StudyCard {
  // ignore: constant_identifier_names
  static const QUESTION_LEARN_OBJECTS_KEY = "question_learn_objects_key";
  // ignore: constant_identifier_names
  static const AWNSER_LEARN_OBJECTS_KEY = "awnser_learn_objects_key";

  List<LearningObject> questionLearnObjects = [
    TextObject("Question", Offset.zero, Paint()),
  ];
  List<LearningObject> awnserLearnObjects = [
    TextObject("Awnser", Offset.zero, Paint()),
  ];

  StudyCard();

  void setParamsFromJson(Map<String, dynamic> json) {
    _setQuestionLearnObjectsFromJson(json[QUESTION_LEARN_OBJECTS_KEY]);
    _setAwnserLearnObjectsFromJson(json[AWNSER_LEARN_OBJECTS_KEY]);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> questionObjects = {};
    for (int i = 0; i < questionLearnObjects.length; i++) {
      LearningObject obj = questionLearnObjects[i];
      Map<String, dynamic> objJson = obj.toJson();

      questionObjects.addAll({
        "index:$i": objJson,
      });
    }

    Map<String, dynamic> awnserObjects = {};
    for (int i = 0; i < awnserLearnObjects.length; i++) {
      LearningObject obj = awnserLearnObjects[i];
      Map<String, dynamic> objJson = obj.toJson();

      awnserObjects.addAll({
        "index:$i": objJson,
      });
    }

    return {
      QUESTION_LEARN_OBJECTS_KEY: questionLearnObjects,
      AWNSER_LEARN_OBJECTS_KEY: awnserLearnObjects,
    };
  }

  void _setQuestionLearnObjectsFromJson(List<dynamic> listOfJson) {
    questionLearnObjects.clear();
    for (int i = 0; i < listOfJson.length; i++) {
      Map<String, dynamic> objJson = listOfJson[i];
      switch (objJson[LearningObject.TYPE_KEY]) {
        case TextObject.TYPE_KEY:
          TextObject textObject = TextObject("text", Offset.zero, Paint());
          textObject.setParamsFromJson(objJson);
          questionLearnObjects.add(textObject);
          break;
      }
      // LearningObject obj = questionLearnObjects[i];
      // obj.setParamsFromJson(objJson);
    }
  }

  void _setAwnserLearnObjectsFromJson(List<dynamic> listOfJson) {
    awnserLearnObjects.clear();
    for (int i = 0; i < listOfJson.length; i++) {
      Map<String, dynamic> objJson = listOfJson[i];
      switch (objJson[LearningObject.TYPE_KEY]) {
        case TextObject.TYPE_KEY:
          TextObject textObject = TextObject("text", Offset.zero, Paint());
          textObject.setParamsFromJson(objJson);
          awnserLearnObjects.add(textObject);
          break;
      }
    }
  }
}
