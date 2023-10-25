import 'dart:io';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rxdart/rxdart.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/widgets/editable_text_widget.dart';

import 'dart:ui';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

//FlipCard dimensions: 400 * 600

class StudyCardEditor extends StatefulWidget {
  StudyCard studyCard;
  Topic parentTopic;
  StudyCardEditor(
      {super.key, required this.studyCard, required this.parentTopic});

  @override
  State<StudyCardEditor> createState() => _StudyCardEditorState();
}

enum SelectedMode {
  StrokeWidth,
  Opacity,
  Color,
}

class _StudyCardEditorState extends State<StudyCardEditor> {
  Color selectedColor = Colors.black;
  Color pickerColor = Colors.black;
  double strokeWidth = 3.0;
  List<DrawingPoints> points = [];
  bool showBottomList = false;
  double opacity = 1.0;
  StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];

  late PictureRecorder recorder;
  Canvas? canvas;

  final GlobalKey _globalKey = GlobalKey();
  List<LearningObject> _learningObjects = [];
  final _learningObjectStream = BehaviorSubject<List<LearningObject>>();

  LearningObject? _currentLearningObject = null;

  @override
  void initState() {
    super.initState();
    recorder = PictureRecorder();
  }

  @override
  void dispose() {
    _learningObjectStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    canvas ??= Canvas(
      recorder,
      Rect.fromPoints(
          const Offset(0, 0), Offset(width * 0.8, width * 0.8 * 6 / 4)),
    );
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Prevents automatic resizing when the keyboard appears.
      appBar: AppBar(
        shadowColor: const Color.fromARGB(127, 127, 127, 127),
        backgroundColor: const Color.fromARGB(127, 127, 127, 127),
        title: EditableTextWidget(
          preText: "${widget.parentTopic.name} / ",
          initialText: widget.studyCard.name,
          onTextSaved: (text) {
            widget.studyCard.setName(text);
            setState(() {});
          },
        ),
        actions: const [
          // IconButton(
          //   onPressed: _addNewStudyCard,
          //   icon: const Icon(Icons.add),
          // ),
        ],
      ),
      bottomNavigationBar: _bottomNavigationBar(context),
      body: _body(context),
    );
  }

  Column _body(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;

    final containerMargin = EdgeInsets.only(
      top: (width - width * 0.8) / 2,
      bottom: width - width * 0.8,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InteractiveViewer(
              panEnabled: false, // Set it to false to prevent panning.
              boundaryMargin: const EdgeInsets.all(80),
              minScale: 0.5,
              maxScale: 4,
              child: GestureDetector(
                onPanStart: (details) {
                  RenderBox? renderBox = _globalKey.currentContext
                      ?.findRenderObject() as RenderBox;

                  Offset point =
                      renderBox.globalToLocal(details.globalPosition);

                  final Paint paint = Paint()
                    ..color = selectedColor.withAlpha((opacity * 255).toInt())
                    ..strokeCap = StrokeCap.round
                    ..strokeWidth = strokeWidth;

                  _currentLearningObject =
                      LineObject([point], const Offset(0, 0), paint);

                  _learningObjects.add(_currentLearningObject!);

                  _learningObjectStream.add(_learningObjects);
                },
                onPanUpdate: (details) {
                  RenderBox? renderBox = _globalKey.currentContext
                      ?.findRenderObject() as RenderBox;

                  Offset point =
                      renderBox.globalToLocal(details.globalPosition);

                  if (_currentLearningObject == null) return;

                  (_currentLearningObject as LineObject).points.add(point);

                  _learningObjectStream.add(_learningObjects);
                },
                onPanEnd: (details) {
                  _currentLearningObject = null;
                },
                child: Container(
                  margin: containerMargin,
                  color: const Color.fromARGB(255, 255, 255, 255),
                  width: width * 0.8,
                  height: width * 0.8 * 6 / 4,
                  child: StreamBuilder<List<LearningObject>>(
                      key: _globalKey,
                      stream: _learningObjectStream,
                      builder: (context, snapshot) {
                        return CustomPaint(
                          foregroundPainter: StudyCardPainter(
                              snapshot.data == null
                                  ? []
                                  : snapshot.data as List<LearningObject>),
                        );
                      }),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Padding _bottomNavigationBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50.0),
            color: Theme.of(context).primaryColor),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  IconButton(
                    onPressed: () {
                      if (_learningObjects.isEmpty) {
                        return;
                      }
                      _learningObjects.removeLast();
                      _learningObjectStream.add(_learningObjects);
                    },
                    icon: const Icon(Icons.arrow_back),
                  ),
                  IconButton(
                    onPressed: () {
                      print("TODO");
                    },
                    icon: const Icon(Icons.text_fields),
                  ),
                  IconButton(
                      icon: const Icon(Icons.album),
                      onPressed: () {
                        setState(() {
                          if (selectedMode == SelectedMode.StrokeWidth) {
                            showBottomList = !showBottomList;
                          }
                          selectedMode = SelectedMode.StrokeWidth;
                        });
                      }),
                  IconButton(
                      icon: const Icon(Icons.opacity),
                      onPressed: () {
                        setState(() {
                          if (selectedMode == SelectedMode.Opacity) {
                            showBottomList = !showBottomList;
                          }
                          selectedMode = SelectedMode.Opacity;
                        });
                      }),
                  IconButton(
                      icon: const Icon(Icons.color_lens),
                      onPressed: () {
                        setState(() {
                          if (selectedMode == SelectedMode.Color) {
                            showBottomList = !showBottomList;
                          }
                          selectedMode = SelectedMode.Color;
                        });
                      }),
                  IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          showBottomList = false;
                          points.clear();
                        });
                      }),
                ],
              ),
              Visibility(
                visible: showBottomList,
                child: (selectedMode == SelectedMode.Color)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: getColorList(),
                      )
                    : Slider(
                        value: (selectedMode == SelectedMode.StrokeWidth)
                            ? strokeWidth
                            : opacity,
                        max: (selectedMode == SelectedMode.StrokeWidth)
                            ? 50.0
                            : 1.0,
                        min: 0.0,
                        onChanged: (val) {
                          setState(
                            () {
                              if (selectedMode == SelectedMode.StrokeWidth) {
                                strokeWidth = val;
                              } else {
                                opacity = val;
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> getColorList() {
    List<Widget> listWidget = [];
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                //enableLabel: true,
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  setState(() => selectedColor = pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.red, Colors.green, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }
  // Card _cardExample(BuildContext context) {
  //   return Card(
  //     elevation: 0.0,
  //     margin: const EdgeInsets.all(16.0),
  //     color: const Color(0x00000000),
  //     child: FlipCard(
  //       direction: FlipDirection.HORIZONTAL,
  //       side: CardSide.FRONT,
  //       flipOnTouch: true,
  //       speed: 1000,
  //       onFlipDone: (status) async {
  //         print("Status:");
  //         print(status);
  //       },
  //       front: Expanded(
  //         child: Container(
  //           decoration: const BoxDecoration(
  //             color: Color(0xFF006666),
  //             borderRadius: BorderRadius.all(Radius.circular(8.0)),
  //           ),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: <Widget>[
  //               Text('Front', style: Theme.of(context).textTheme.displayLarge),
  //               Text('Click here to flip back',
  //                   style: Theme.of(context).textTheme.bodyLarge),
  //             ],
  //           ),
  //         ),
  //       ),
  //       back: Expanded(
  //         child: Container(
  //           decoration: const BoxDecoration(
  //             color: Color(0xFF006666),
  //             borderRadius: BorderRadius.all(Radius.circular(8.0)),
  //           ),
  //           child: Column(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: <Widget>[
  //               Text('Back', style: Theme.of(context).textTheme.displayLarge),
  //               Text('Click here to flip front',
  //                   style: Theme.of(context).textTheme.bodyLarge),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
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
