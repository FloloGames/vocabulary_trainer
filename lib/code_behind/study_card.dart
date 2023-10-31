import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects.dart';

class StudyCard {
  // ignore: constant_identifier_names
  static const int KNOWN_VALUE = 1;
  // ignore: constant_identifier_names
  static const int NOT_SURE_VALUE = 0;
  // ignore: constant_identifier_names
  static const int UNKNOWN_VALUE = -1;
  // ignore: constant_identifier_names
  static const int EZKNOWN_VALUE = 2; //oder 3 oder so

  // ignore: constant_identifier_names
  static const QUESTION_LEARN_OBJECTS_KEY = "question_learn_objects_key";
  // ignore: constant_identifier_names
  static const AWNSER_LEARN_OBJECTS_KEY = "awnser_learn_objects_key";
  // ignore: constant_identifier_names
  static const SCORE_KEY = "score_key";

  List<LearningObject> questionLearnObjects = [
    TextObject("Question", Offset.zero, Paint()),
  ];
  List<LearningObject> awnserLearnObjects = [
    TextObject("Awnser", Offset.zero, Paint()),
  ];

  //da muss ich mir noch was schlaues überlegen
  int learningScore = 0;
  int index = -1; //needed to save StudyCard

  StudyCard(this.index);

  void setParamsFromJson(Map<String, dynamic> json) {
    _setQuestionLearnObjectsFromJson(json[QUESTION_LEARN_OBJECTS_KEY]);
    _setAwnserLearnObjectsFromJson(json[AWNSER_LEARN_OBJECTS_KEY]);
    learningScore = int.parse(json[SCORE_KEY]);
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> questionObjects = {};
    for (int i = 0; i < questionLearnObjects.length; i++) {
      LearningObject obj = questionLearnObjects[i];
      Map<String, dynamic> objJson = obj.toJson();

      questionObjects.addAll({
        "index:$i": objJson, //TODO: man kann index: vielleicht weglassen
      });
    }

    Map<String, dynamic> awnserObjects = {};
    for (int i = 0; i < awnserLearnObjects.length; i++) {
      LearningObject obj = awnserLearnObjects[i];
      Map<String, dynamic> objJson = obj.toJson();

      awnserObjects.addAll({
        "index:$i": objJson, //TODO: man kann index: vielleicht weglassen
      });
    }

    return {
      QUESTION_LEARN_OBJECTS_KEY: questionLearnObjects,
      AWNSER_LEARN_OBJECTS_KEY: awnserLearnObjects,
      SCORE_KEY: learningScore.toString(),
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

  void addKnownScore() {
    learningScore += KNOWN_VALUE;
  }

  void addUnknownScore() {
    learningScore += UNKNOWN_VALUE;
  }

  void addNotSureScore() {
    learningScore += NOT_SURE_VALUE;
  }

  void addEzknownScore() {
    learningScore += EZKNOWN_VALUE;
  }
}
