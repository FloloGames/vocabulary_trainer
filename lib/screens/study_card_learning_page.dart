// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'dart:math';

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects.dart';
import 'package:vocabulary_trainer/code_behind/pair.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/study_card_provider.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/widgets/editable_text_widget.dart';

import 'dart:ui';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

//FlipCard dimensions: 400 * 600

class StudyCardLearningPage extends StatefulWidget {
  List<Pair<Topic, StudyCard>> studyCardList = [];

  StudyCardLearningPage({super.key, required this.studyCardList});

  @override
  State<StudyCardLearningPage> createState() => _StudyCardLearningPageState();
}

class _StudyCardLearningPageState extends State<StudyCardLearningPage> {
  int currCardIndex = 0;

  final StudyCardProvider _studyCardProvider = StudyCardProvider();
  final FlipCardController _flipCardController = FlipCardController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _studyCardProvider.setScreenSize(MediaQuery.of(context).size);
    });
    _studyCardProvider.addListener(onStudyCardProviderChanged);
  }

  @override
  void dispose() {
    _studyCardProvider.removeListener(onStudyCardProviderChanged);
    super.dispose();
  }

  void onStudyCardProviderChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // final width = MediaQuery.of(context).size.width;
    // canvas ??= Canvas(
    //   recorder,
    //   Rect.fromPoints(
    //       const Offset(0, 0), Offset(width * 0.8, width * 0.8 * 6 / 4)),
    // );
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents automatic resizing when the keyboard appears.
      appBar: AppBar(
        shadowColor: const Color.fromARGB(127, 127, 127, 127),
        backgroundColor: const Color.fromARGB(127, 127, 127, 127),
        title: Text(
          widget.studyCardList[currCardIndex].first.name,
        ),
        actions: const [
          //TODO: zurück oder so
          // IconButton(
          //   onPressed: _addNewStudyCard,
          //   icon: const Icon(Icons.add),
          // ),
        ],
      ),
      // bottomNavigationBar: _bottomNavigationBar(context),
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: Stack(children: [
        _nextCardPrev(width),
        LayoutBuilder(builder: (context, constraints) {
          final duration = Duration(
            milliseconds: _studyCardProvider.isDragging ? 0 : 400,
          );

          final center = constraints.smallest.center(Offset.zero);

          final angle = _studyCardProvider.angle * pi / 180;
          final rotatedMatrix = Matrix4.identity()
            ..translate(center.dx, center.dy)
            ..rotateZ(angle)
            ..translate(-center.dx, -center.dy);

          if (_studyCardProvider.status != StudyCardStatus.none &&
              !_studyCardProvider.isDragging) {
            _studyCardProvider.resetStatus();
            _nextCard(const Duration(milliseconds: 200));
          }

          Color studyCardColor = Colors.white;

          switch (_studyCardProvider.status) {
            case StudyCardStatus.known:
              studyCardColor = Colors.green;
              break;
            case StudyCardStatus.unknown:
              studyCardColor = Colors.red;
              break;
            case StudyCardStatus.notSure:
              studyCardColor = Colors.yellow;
              break;
            case StudyCardStatus.ezKnown:
              studyCardColor = Colors.blue;
              break;
            default:
              break;
          }

          return AnimatedContainer(
            curve: Curves.easeInOut,
            duration: duration,
            transform: rotatedMatrix
              ..translate(
                _studyCardProvider.position.dx * 1.2,
                _studyCardProvider.position.dy * 1.2,
              ),
            child: GestureDetector(
              onPanStart: (details) {
                _studyCardProvider.startPosition(details);
              },
              onPanUpdate: (details) {
                _studyCardProvider.updatePosition(details);
              },
              onPanEnd: (details) {
                _studyCardProvider.endPosition();
              },
              child: FlipCard(
                controller: _flipCardController,
                flipOnTouch: true,
                front: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  //margin: containerMargin,
                  // color: const Color.fromARGB(255, 255, 255, 255),
                  width: width * 0.8,
                  height: width * 0.8 * 6 / 4,
                  decoration: ShapeDecoration(
                    color: studyCardColor,
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
                  child: Center(
                    child: Text(
                      (widget.studyCardList[currCardIndex].second
                              .questionLearnObjects[0] as TextObject)
                          .text,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
                back: Container(
                  width: width * 0.8,
                  height: width * 0.8 * 6 / 4,
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
                  child: Center(
                    child: Text(
                      (widget.studyCardList[currCardIndex].second
                              .awnserLearnObjects[0] as TextObject)
                          .text,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ]),
    );
  }

  Widget _nextCardPrev(double width) {
    if (currCardIndex + 1 >= widget.studyCardList.length) {
      return Container(
        //margin: containerMargin,
        // color: const Color.fromARGB(255, 255, 255, 255),
        width: width * 0.8,
        height: width * 0.8 * 6 / 4,
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
        child: const Center(
          child: Column(
            children: [
              // const Text(
              //   "Du bist durch!\nNochmal?",
              //   style: TextStyle(
              //     color: Colors.black,
              //     fontSize: 22,
              //   ),
              // ),
              // TextButton(
              //   child: const Text('Nochmal!'),
              //   onPressed: () {
              //     currCardIndex = 0;
              //     setState(() {});
              //   },
              // ),
            ],
          ),
        ),
      );
    } //else..
    return Container(
      //margin: containerMargin,
      // color: const Color.fromARGB(255, 255, 255, 255),
      width: width * 0.8,
      height: width * 0.8 * 6 / 4,
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
      child: Center(
        child: Text(
          (widget.studyCardList[currCardIndex + 1].second
                  .questionLearnObjects[0] as TextObject)
              .text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Future<void> _nextCard(Duration delayDuration) async {
    await Future.delayed(delayDuration);

    currCardIndex++;

    if (currCardIndex >= widget.studyCardList.length) currCardIndex = 0;

    _studyCardProvider.resetPositionAndAngle();
    FlipCardState? cardState = _flipCardController.state;

    if (cardState != null && !cardState.isFront) {
      _flipCardController.toggleCardWithoutAnimation();
    }
    setState(() {});
  }
}

class StudyCardPainter extends CustomPainter {
  final List<LearningObject> _learningObjects;

  StudyCardPainter(this._learningObjects);

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _learningObjects.length; i++) {
      LearningObject obj = _learningObjects[i];
      obj.drawObject(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawingPoints {
  Paint paint;
  Offset points;
  DrawingPoints({required this.points, required this.paint});
}
