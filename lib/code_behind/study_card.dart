import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects.dart';
import 'package:vocabulary_trainer/code_behind/study_card_provider.dart';

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
  //TODO: typo in answer.. but if I change the current learnobjects wont get loaded..
  static const ANSWER_LEARN_OBJECTS_KEY = "awnser_learn_objects_key";
  // ignore: constant_identifier_names
  static const SCORE_KEY = "score_key";
  // ignore: constant_identifier_names
  static const LAST_ANSWER_KEY = "last_answer_key";

  List<LearningObject> questionLearnObjects = [
    TextObject("Question", Offset.zero, Paint()),
  ];
  List<LearningObject> answerLearnObjects = [
    TextObject("Answer", Offset.zero, Paint()),
  ];

  //da muss ich mir noch was schlaues überlegen
  int learningScore = 0;
  int index = -1; //needed to save StudyCard
  StudyCardStatus lastAnswer = StudyCardStatus.none;

  StudyCard(this.index);

  void setParamsFromJson(Map<String, dynamic> json) {
    _setQuestionLearnObjectsFromJson(json[QUESTION_LEARN_OBJECTS_KEY]);
    _setAnswerLearnObjectsFromJson(json[ANSWER_LEARN_OBJECTS_KEY]);
    learningScore = int.parse(json[SCORE_KEY]);
    lastAnswer = _parseLastAnswer(json[LAST_ANSWER_KEY]);
  }

  StudyCardStatus _parseLastAnswer(String value) {
    switch (value) {
      case "ezKnown":
        return StudyCardStatus.ezKnown;
      case "known":
        return StudyCardStatus.known;
      case "unknown":
        return StudyCardStatus.unknown;
      case "notSure":
        return StudyCardStatus.notSure;
      case "none":
        return StudyCardStatus.none;
      default:
        return StudyCardStatus.none;
    }
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

    Map<String, dynamic> answerObjects = {};
    for (int i = 0; i < answerLearnObjects.length; i++) {
      LearningObject obj = answerLearnObjects[i];
      Map<String, dynamic> objJson = obj.toJson();

      answerObjects.addAll({
        "index:$i": objJson, //TODO: man kann index: vielleicht weglassen
      });
    }

    return {
      QUESTION_LEARN_OBJECTS_KEY: questionLearnObjects,
      ANSWER_LEARN_OBJECTS_KEY: answerLearnObjects,
      SCORE_KEY: learningScore.toString(),
      LAST_ANSWER_KEY: lastAnswer.toString(),
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

  void _setAnswerLearnObjectsFromJson(List<dynamic> listOfJson) {
    answerLearnObjects.clear();
    for (int i = 0; i < listOfJson.length; i++) {
      Map<String, dynamic> objJson = listOfJson[i];
      switch (objJson[LearningObject.TYPE_KEY]) {
        case TextObject.TYPE_KEY:
          TextObject textObject = TextObject("text", Offset.zero, Paint());
          textObject.setParamsFromJson(objJson);
          answerLearnObjects.add(textObject);
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
