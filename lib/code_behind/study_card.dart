import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects/learning_object.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects/text_object.dart';
import 'package:vocabulary_trainer/code_behind/study_card_provider.dart';
import 'package:rxdart/rxdart.dart' as rx;

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
  // ignore: constant_identifier_names
  static const THUMBNAIL_BYTES_KEY = "thumbnail_bytes_key";
  // ignore: constant_identifier_names
  static const THUMBNAIL_WIDTH_KEY = "thumbnail_width_key";
  // ignore: constant_identifier_names
  static const THUMBNAIL_HEIGHT_KEY = "thumbnail_heigth_key";

  final rx.BehaviorSubject editingChangedStream = rx.BehaviorSubject();

  List<LearningObject> questionLearnObjects = [];
  List<LearningObject> answerLearnObjects = [];

  //da muss ich mir noch was schlaues überlegen
  int learningScore = 0;
  int index = -1; //needed to save StudyCard
  StudyCardStatus lastAnswer = StudyCardStatus.none;

  //thumbnail gets shown on the topic_page
  Uint8List? thumbnailBytes; //pngBytes
  int thumbnailWidth = -1;
  int thumbnailHeight = -1;

  StudyCard(this.index);

  Widget createThumbnailWidget() {
    if (thumbnailBytes == null) {
      if (questionLearnObjects.isEmpty) {
        return const Text(
          "no question object",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        );
      }
      return questionLearnObjects.first.creatLearningWidget();
    }

    return Image.memory(
      thumbnailBytes!,
      width: thumbnailWidth.toDouble(),
      height: thumbnailHeight.toDouble(),
    );
  }

  Widget createLearningWidget({
    required double containerHeight,
    required double containerWidth,
    required FlipCardController flipCardController,
    required Color studyCardColor,
  }) {
    return StudyCardLearningWidget(
      studyCard: this,
      containerWidth: containerWidth,
      containerHeight: containerHeight,
      flipCardController: flipCardController,
      studyCardColor: studyCardColor,
    );
  }

  Widget createEditingWidget({
    required double containerHeight,
    required double containerWidth,
    required FlipCardController flipCardController,
  }) {
    return StudyCardEditingWidget(
      studyCard: this,
      flipCardController: flipCardController,
      containerHeight: containerHeight,
      containerWidth: containerWidth,
    );
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
      THUMBNAIL_WIDTH_KEY: thumbnailWidth,
      THUMBNAIL_HEIGHT_KEY: thumbnailHeight,
      THUMBNAIL_BYTES_KEY:
          thumbnailBytes == null ? "null" : base64.encode(thumbnailBytes!),
    };
  }

  void setParamsFromJson(Map<String, dynamic> json) {
    _setQuestionLearnObjectsFromJson(json[QUESTION_LEARN_OBJECTS_KEY]);
    _setAnswerLearnObjectsFromJson(json[ANSWER_LEARN_OBJECTS_KEY]);
    learningScore = int.parse(json[SCORE_KEY]);
    lastAnswer = _parseLastAnswer(json[LAST_ANSWER_KEY]);
    thumbnailWidth = json[THUMBNAIL_WIDTH_KEY];
    thumbnailHeight = json[THUMBNAIL_HEIGHT_KEY];
    if (json[THUMBNAIL_BYTES_KEY] == "null") {
      thumbnailBytes = null;
    } else {
      thumbnailBytes = base64Decode(json[THUMBNAIL_BYTES_KEY]);
    }
  }

  StudyCardStatus _parseLastAnswer(String value) {
    switch (value) {
      case "StudyCardStatus.ezKnown":
        return StudyCardStatus.ezKnown;
      case "StudyCardStatus.known":
        return StudyCardStatus.known;
      case "StudyCardStatus.unknown":
        return StudyCardStatus.unknown;
      case "StudyCardStatus.notSure":
        return StudyCardStatus.notSure;
      case "StudyCardStatus.none":
        return StudyCardStatus.none;
      default:
        return StudyCardStatus.none;
    }
  }

  void _setQuestionLearnObjectsFromJson(List<dynamic> listOfJson) {
    questionLearnObjects.clear();
    for (int i = 0; i < listOfJson.length; i++) {
      Map<String, dynamic> objJson = listOfJson[i];
      switch (objJson[LearningObject.TYPE_KEY]) {
        case TextObject.TYPE_KEY:
          TextObject textObject = TextObject(
            "Tap to edit text.",
            Alignment.center,
            this,
          );
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
          TextObject textObject = TextObject(
            "Tap to edit text.",
            Alignment.center,
            this,
          );
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

class StudyCardLearningWidget extends StatefulWidget {
  double containerWidth;
  double containerHeight;
  Color studyCardColor;
  StudyCard studyCard;
  FlipCardController flipCardController;

  StudyCardLearningWidget({
    super.key,
    required this.studyCard,
    required this.containerWidth,
    required this.containerHeight,
    required this.studyCardColor,
    required this.flipCardController,
  });

  @override
  State<StudyCardLearningWidget> createState() =>
      _StudyCardLearningWidgetState();
}

class _StudyCardLearningWidgetState extends State<StudyCardLearningWidget> {
  @override
  Widget build(BuildContext context) {
    return FlipCard(
      controller: widget.flipCardController,
      flipOnTouch: true,
      front: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        //margin: containerMargin,
        // color: const Color.fromARGB(255, 255, 255, 255),
        width: widget.containerWidth,
        height: widget.containerHeight,
        decoration: ShapeDecoration(
          color: widget.studyCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: [
            BoxShadow(
              color: widget.studyCardColor,
              blurRadius: 18,
            ),
          ],
        ),
        child: Stack(
          children: List.generate(
            widget.studyCard.questionLearnObjects.length,
            (index) {
              LearningObject learningObject =
                  widget.studyCard.questionLearnObjects[index];
              return learningObject.creatLearningWidget();
            },
          ),
        ),
      ),
      back: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        //margin: containerMargin,
        // color: const Color.fromARGB(255, 255, 255, 255),
        width: widget.containerWidth,
        height: widget.containerHeight,
        decoration: ShapeDecoration(
          color: widget.studyCardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          shadows: [
            BoxShadow(
              color: widget.studyCardColor,
              blurRadius: 18,
            ),
          ],
        ),
        child: Stack(
          children: List.generate(
            widget.studyCard.answerLearnObjects.length,
            (index) {
              LearningObject learningObject =
                  widget.studyCard.answerLearnObjects[index];
              return learningObject.creatLearningWidget();
            },
          ),
        ),
      ),
    );
  }
}

class StudyCardEditingWidget extends StatefulWidget {
  double containerWidth;
  double containerHeight;
  StudyCard studyCard;

  FlipCardController flipCardController;

  StudyCardEditingWidget({
    super.key,
    required this.flipCardController,
    required this.studyCard,
    required this.containerWidth,
    required this.containerHeight,
  });

  @override
  State<StudyCardEditingWidget> createState() => _StudyCardEditingWidgetState();
}

class _StudyCardEditingWidgetState extends State<StudyCardEditingWidget> {
  // ignore: constant_identifier_names
  static const double MAX_SCALE = 10;
  // ignore: constant_identifier_names
  static const double MIN_SCALE = 1;

  final GlobalKey _questionStackKey = GlobalKey();

  Future<void> setStudyCardThumbnail() async {
    if (widget.studyCard.questionLearnObjects.length == 1) {
      //wenn nur 1 frage vorhanden ist, dann zeig nur LearnObject an also nicht das thumbnail speichern..

      widget.studyCard.thumbnailBytes = null;
      widget.studyCard.thumbnailWidth = -1;
      widget.studyCard.thumbnailHeight = -1;
      return;
    }

    RenderRepaintBoundary boundary = _questionStackKey.currentContext!
        .findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    widget.studyCard.thumbnailBytes = pngBytes;
    widget.studyCard.thumbnailWidth = image.width;
    widget.studyCard.thumbnailHeight = image.height;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await setStudyCardThumbnail();
        return true;
      },
      child: StreamBuilder(
        stream: widget.studyCard.editingChangedStream,
        builder: (context, snapshot) {
          return GestureDetector(
            onTap: () {
              widget.flipCardController.toggleCard();
            },
            child: FlipCard(
              controller: widget.flipCardController,
              flipOnTouch: false,
              front: Container(
                width: widget.containerWidth,
                height: widget.containerHeight,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: RepaintBoundary(
                  key: _questionStackKey,
                  child: Stack(
                    children: List.generate(
                      widget.studyCard.questionLearnObjects.length,
                      (index) {
                        LearningObject learningObject =
                            widget.studyCard.questionLearnObjects[index];
                        return _learningObjectGestureDetector(
                          onLongPress: () {
                            widget.studyCard.questionLearnObjects
                                .remove(learningObject);
                            setState(() {});
                          },
                          learningObject: learningObject,
                          child: learningObject.creatEditingWidget(),
                        );
                      },
                    ),
                  ),
                ),
              ),
              back: Container(
                // margin: containerMargin,
                // color: const Color.fromARGB(255, 255, 255, 255),
                width: widget.containerWidth,
                height: widget.containerHeight,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  shadows: const [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Stack(
                  children: List.generate(
                    widget.studyCard.answerLearnObjects.length,
                    (index) {
                      LearningObject learningObject =
                          widget.studyCard.answerLearnObjects[index];
                      return _learningObjectGestureDetector(
                        onLongPress: () {
                          widget.studyCard.answerLearnObjects.removeAt(index);
                          setState(() {});
                        },
                        learningObject: learningObject,
                        child: learningObject.creatEditingWidget(),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _learningObjectGestureDetector({
    required LearningObject learningObject,
    void Function()? onLongPress,
    Widget? child,
  }) {
    return GestureDetector(
      onLongPress: onLongPress,
      onScaleUpdate: (details) {
        Alignment touchedPosAlignment = Alignment(
          details.localFocalPoint.dx * 2 / widget.containerWidth - 1,
          details.localFocalPoint.dy * 2 / widget.containerHeight - 1,
        );

        if (touchedPosAlignment.x < -1) {
          touchedPosAlignment = Alignment(-1, touchedPosAlignment.y);
        }
        if (touchedPosAlignment.y < -1) {
          touchedPosAlignment = Alignment(touchedPosAlignment.x, -1);
        }

        if (touchedPosAlignment.x > 1) {
          touchedPosAlignment = Alignment(1, touchedPosAlignment.y);
        }
        if (touchedPosAlignment.y > 1) {
          touchedPosAlignment = Alignment(touchedPosAlignment.x, 1);
        }

        learningObject.alignment = touchedPosAlignment;
        // learningObject.alignment = Alignment(
        //   learningObject.alignment.x +
        //       details.focalPointDelta.dx * 2 / widget.containerWidth,
        //   learningObject.alignment.y +
        //       details.focalPointDelta.dy * 2 / widget.containerHeight,
        // );

        //print("${touchedPosAlignment.x} : ${touchedPosAlignment.y}");

        learningObject.alignment = _snapToPoints(touchedPosAlignment);

        learningObject.scale += (details.scale - 1) / 100;
        if (learningObject.scale < MIN_SCALE) {
          learningObject.scale = MIN_SCALE;
        }
        if (learningObject.scale > MAX_SCALE) {
          learningObject.scale = MAX_SCALE;
        }

        //TODO: fixen und rotation hinzufügen
        setState(() {});
      },
      child: child,
    );
  }

  Alignment _snapToPoints(Alignment alignment) {
    Alignment snapedAlignment = Alignment(alignment.x, alignment.y);

    snapedAlignment = _snapToOtherAlignments(alignment, [
      const Alignment(0.5, 0.5),
      const Alignment(-0.5, -0.5),
    ]);
    snapedAlignment = _snapToCenter(snapedAlignment);

    return snapedAlignment;
  }

  Alignment _snapToCenter(Alignment alignment) {
    const minDistToSnap = 0.1;

    Alignment snapedAlignment = Alignment(alignment.x, alignment.y);

    double distToCenterX = alignment.x.abs();
    double distToCenterY = alignment.y.abs();

    if (distToCenterX < minDistToSnap) {
      snapedAlignment = Alignment(0, snapedAlignment.y);
    }

    if (distToCenterY < minDistToSnap) {
      snapedAlignment = Alignment(snapedAlignment.x, 0);
    }

    return snapedAlignment;
  }

  Alignment _snapToOtherAlignments(
    Alignment alignment,
    List<Alignment> otherAlignments,
  ) {
    const minDistToSnap = 0.1;
    Alignment snapedAlignment = Alignment(alignment.x, alignment.y);

    int nearestXindex = -1;
    double nearestX = double.infinity;
    int nearestYindex = -1;
    double nearestY = double.infinity;

    for (int i = 0; i < otherAlignments.length; i++) {
      Alignment otherAlignment = otherAlignments[i];

      double distToOtherX = (snapedAlignment.x - otherAlignment.x).abs();
      double distToOtherY = (snapedAlignment.y - otherAlignment.y).abs();

      if (distToOtherX < nearestX) {
        nearestX = distToOtherX;
        nearestXindex = i;
      }
      if (distToOtherY < nearestY) {
        nearestY = distToOtherY;
        nearestYindex = i;
      }
    }

    //gibt kein anderes alignment
    // if(nearestX == -1 || nearestY == -1){
    //   return snapedAlignment;
    // }

    if (nearestX < minDistToSnap) {
      snapedAlignment = Alignment(
        otherAlignments[nearestXindex].x,
        snapedAlignment.y,
      );
    }

    if (nearestY < minDistToSnap) {
      snapedAlignment = Alignment(
        snapedAlignment.x,
        otherAlignments[nearestYindex].y,
      );
    }

    return snapedAlignment;
  }

  // Alignment _snapToOtherAlignment(
  //   Alignment alignment,
  //   Alignment otherAlignment,
  // ) {
  //   const minDistToSnap = 0.1;

  //   Alignment snapedAlignment = Alignment(alignment.x, alignment.y);

  //   double distToOtherX = (alignment.x - otherAlignment.x).abs();
  //   double distToOtherY = (alignment.y - otherAlignment.y).abs();

  //   double distToOtherAlignment = sqrt(
  //     pow(alignment.x - otherAlignment.x, 2) +
  //         pow(alignment.y - otherAlignment.y, 2),
  //   );

  //   //wenn zu nah aneinander dann nichts machen
  //   if (distToOtherAlignment < minDistToSnap) {
  //     return snapedAlignment;
  //   }

  //   if (distToOtherX < minDistToSnap) {
  //     snapedAlignment = Alignment(otherAlignment.x, snapedAlignment.y);
  //   }

  //   if (distToOtherY < minDistToSnap) {
  //     snapedAlignment = Alignment(snapedAlignment.x, otherAlignment.y);
  //   }

  //   return snapedAlignment;
  // }
}
