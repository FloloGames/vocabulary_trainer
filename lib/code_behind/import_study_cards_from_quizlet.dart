import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects/text_object.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';

class ImportStudyCardsFromQuizlet {
  static ImportStudyCardsFromQuizlet instance = ImportStudyCardsFromQuizlet();

  // final Dio _dio = Dio();

  void addStudyCardsFromString(
      String studyCardsString, Subject subject, Topic topic) {
    List<String> studyCardStrings = studyCardsString.split("\n");
    int studyCardLength = topic.studyCards.length;

    int failedCount = 0;

    for (int i = 0; i < studyCardStrings.length; i++) {
      String studyCardString = studyCardStrings[i];
      List<String> questionAndAnswer = studyCardString.split("\t");

      if (questionAndAnswer.length != 2) {
        failedCount++;
        continue;
      }

      StudyCard studyCard = StudyCard(i + studyCardLength - failedCount);

      studyCard.questionLearnObjects.clear();
      studyCard.answerLearnObjects.clear();

      studyCard.questionLearnObjects
          .add(TextObject(questionAndAnswer[0], Alignment.center, studyCard));
      studyCard.answerLearnObjects
          .add(TextObject(questionAndAnswer[1], Alignment.center, studyCard));

      SubjectManager.addStudyCard(subject, topic, studyCard);
    }
  }

  // Future<String> _getHtml(String url) async {
  //   const userAgent =
  //       "Mozilla/5.0 (Linux; Android AndroidVersion; Model) AppleWebKit/WebKitVersion (KHTML, like Gecko) Chrome/ChromeVersion Mobile Safari/SafariVersion";

  //   final response = await _dio.get(
  //     url,
  //     options: Options(
  //       headers: {
  //         'User-Agent': userAgent,
  //       },
  //     ),
  //   );
  //   if (response.statusMessage != "OK") {
  //     return response.statusMessage ?? "";
  //   }
  //   return response.data;
  // }
}
