// ignore_for_file: constant_identifier_names

import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects/text_object.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';

//FlipCard dimensions: 400 * 600

class StudyCardEditorPage extends StatefulWidget {
  StudyCard studyCard;
  Topic parentTopic;
  StudyCardEditorPage(
      {super.key, required this.studyCard, required this.parentTopic});

  @override
  State<StudyCardEditorPage> createState() => _StudyCardEditorPageState();
}

enum SelectedMode {
  StrokeWidth,
  Opacity,
  Color,
}

class _StudyCardEditorPageState extends State<StudyCardEditorPage> {
  // Color selectedColor = Colors.black;
  // Color pickerColor = Colors.black;
  // double strokeWidth = 3.0;
  // // List<DrawingPoints> points = [];
  // bool showBottomList = false;
  // double opacity = 1.0;
  // StrokeCap strokeCap = (Platform.isAndroid) ? StrokeCap.butt : StrokeCap.round;
  // SelectedMode selectedMode = SelectedMode.StrokeWidth;
  // List<Color> colors = [
  //   Colors.red,
  //   Colors.green,
  //   Colors.blue,
  //   Colors.amber,
  //   Colors.black
  // ];

  // late PictureRecorder recorder;
  // Canvas? canvas;

  // List<LearningObject> _learningObjects = [];
  // final _learningObjectStream = BehaviorSubject<List<LearningObject>>();

  // LearningObject? _currentLearningObject = null;

  final FlipCardController _flipCardController = FlipCardController();

  @override
  void initState() {
    super.initState();
    // recorder = PictureRecorder();
  }

  @override
  void dispose() {
    // _learningObjectStream.close();
    super.dispose();
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
        shadowColor: widget
            .parentTopic.color, //const Color.fromARGB(127, 127, 127, 127),
        backgroundColor: widget
            .parentTopic.color, //const Color.fromARGB(127, 127, 127, 127),
        title: Text(
          "${widget.parentTopic.name} / edit Study Card",
        ),
        actions: [
          IconButton(
            onPressed: _addNewText,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      // bottomNavigationBar: _bottomNavigationBar(context),
      body: _body(context),
    );
  }

  void _addNewText() {
    TextObject textObject =
        TextObject("Tap to Edit", Alignment.center, widget.studyCard);
    FlipCardState? state = _flipCardController.state;
    if (state == null) return;
    if (state.isFront) {
      widget.studyCard.questionLearnObjects.add(textObject);
    } else {
      widget.studyCard.answerLearnObjects.add(textObject);
    }
    setState(() {});
  }

  Widget _body(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // final height = MediaQuery.of(context).size.height;

    double containerWidth = width * 0.8;
    double containerHeight = width * 0.8 * 6 / 4;

    double animContainerW = 100;
    double animContainerH = 100;

    return Center(
      child: widget.studyCard.createEditingWidget(
        flipCardController: _flipCardController,
        containerWidth: containerWidth,
        containerHeight: containerHeight,
      ),
    );
  }

  // Padding _bottomNavigationBar(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: AnimatedContainer(
  //       duration: const Duration(seconds: 1),
  //       padding: const EdgeInsets.only(left: 8.0, right: 8.0),
  //       decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(50.0),
  //           color: Theme.of(context).primaryColor),
  //       child: Padding(
  //         padding: const EdgeInsets.all(8.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: <Widget>[
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: <Widget>[
  //                 IconButton(
  //                   onPressed: () {
  //                     // if (_learningObjects.isEmpty) {
  //                     //   return;
  //                     // }
  //                     // _learningObjects.removeLast();
  //                     // _learningObjectStream.add(_learningObjects);
  //                   },
  //                   icon: const Icon(Icons.arrow_back),
  //                 ),
  //                 IconButton(
  //                   onPressed: () {
  //                     print("TODO");
  //                   },
  //                   icon: const Icon(Icons.text_fields),
  //                 ),
  //                 IconButton(
  //                     icon: const Icon(Icons.album),
  //                     onPressed: () {
  //                       setState(() {
  //                         if (selectedMode == SelectedMode.StrokeWidth) {
  //                           showBottomList = !showBottomList;
  //                         }
  //                         selectedMode = SelectedMode.StrokeWidth;
  //                       });
  //                     }),
  //                 IconButton(
  //                     icon: const Icon(Icons.opacity),
  //                     onPressed: () {
  //                       setState(() {
  //                         if (selectedMode == SelectedMode.Opacity) {
  //                           showBottomList = !showBottomList;
  //                         }
  //                         selectedMode = SelectedMode.Opacity;
  //                       });
  //                     }),
  //                 IconButton(
  //                     icon: const Icon(Icons.color_lens),
  //                     onPressed: () {
  //                       setState(() {
  //                         if (selectedMode == SelectedMode.Color) {
  //                           showBottomList = !showBottomList;
  //                         }
  //                         selectedMode = SelectedMode.Color;
  //                       });
  //                     }),
  //                 IconButton(
  //                     icon: const Icon(Icons.clear),
  //                     onPressed: () {
  //                       setState(() {
  //                         showBottomList = false;
  //                         points.clear();
  //                       });
  //                     }),
  //               ],
  //             ),
  //             Visibility(
  //               visible: showBottomList,
  //               child: (selectedMode == SelectedMode.Color)
  //                   ? Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //                       children: getColorList(),
  //                     )
  //                   : Slider(
  //                       value: (selectedMode == SelectedMode.StrokeWidth)
  //                           ? strokeWidth
  //                           : opacity,
  //                       max: (selectedMode == SelectedMode.StrokeWidth)
  //                           ? 50.0
  //                           : 1.0,
  //                       min: 0.0,
  //                       onChanged: (val) {
  //                         setState(
  //                           () {
  //                             if (selectedMode == SelectedMode.StrokeWidth) {
  //                               strokeWidth = val;
  //                             } else {
  //                               opacity = val;
  //                             }
  //                           },
  //                         );
  //                       },
  //                     ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

//   List<Widget> getColorList() {
//     List<Widget> listWidget = [];
//     for (Color color in colors) {
//       listWidget.add(colorCircle(color));
//     }
//     Widget colorPicker = GestureDetector(
//       onTap: () {
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             title: const Text('Pick a color!'),
//             content: SingleChildScrollView(
//               child: ColorPicker(
//                 pickerColor: pickerColor,
//                 onColorChanged: (color) {
//                   pickerColor = color;
//                 },
//                 //enableLabel: true,
//                 pickerAreaHeightPercent: 0.8,
//               ),
//             ),
//             actions: <Widget>[
//               TextButton(
//                 child: const Text('Save'),
//                 onPressed: () {
//                   setState(() => selectedColor = pickerColor);
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//       child: ClipOval(
//         child: Container(
//           padding: const EdgeInsets.only(bottom: 16.0),
//           height: 36,
//           width: 36,
//           decoration: const BoxDecoration(
//               gradient: LinearGradient(
//             colors: [Colors.red, Colors.green, Colors.blue],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           )),
//         ),
//       ),
//     );
//     listWidget.add(colorPicker);
//     return listWidget;
//   }

//   Widget colorCircle(Color color) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           selectedColor = color;
//         });
//       },
//       child: ClipOval(
//         child: Container(
//           padding: const EdgeInsets.only(bottom: 16.0),
//           height: 36,
//           width: 36,
//           color: color,
//         ),
//       ),
//     );
//   }
}

// class StudyCardPainter extends CustomPainter {
//   final List<LearningObject> _learningObjects;

//   StudyCardPainter(this._learningObjects);

//   @override
//   void paint(Canvas canvas, Size size) {
//     for (int i = 0; i < _learningObjects.length; i++) {
//       LearningObject obj = _learningObjects[i];
//       obj.drawObject(canvas);
//     }
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) {
//     return true;
//   }
// }

// class DrawingPoints {
//   Paint paint;
//   Offset points;
//   DrawingPoints({required this.points, required this.paint});
// }
