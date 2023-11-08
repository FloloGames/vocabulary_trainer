// import 'package:flip_card/flip_card.dart';
// import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
// import 'package:vocabulary_trainer/code_behind/android_count_unlocks_manager.dart';
// import 'package:vocabulary_trainer/code_behind/pair.dart';
// import 'package:vocabulary_trainer/code_behind/study_card.dart';
// import 'package:vocabulary_trainer/code_behind/subject.dart';
// import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
// import 'package:vocabulary_trainer/code_behind/topic.dart';
// import 'package:vocabulary_trainer/code_behind/update_manager.dart';
// import 'package:rxdart/rxdart.dart';
// import 'package:vocabulary_trainer/code_behind/learning_objects.dart';
// import 'package:vocabulary_trainer/code_behind/study_card.dart';
// import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/screens/home_page.dart';
// import 'package:vocabulary_trainer/screens/study_card_learning_page.dart';
// import 'package:vocabulary_trainer/widgets/editable_text_widget.dart';

// AspectRatio() für Container.. aber vorher noch documentation checken weil vielleicht doch nicht das richtige lol

void main() {
  runApp(const MyApp());
  // _searchForNewUpdate();
}

// Future<void> _searchForNewUpdate() async {
//   if (await UpdateManager.instance.isUpdateAvaiable()) {
//     print("Update Avaiable");
//   }
// }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vocabulary Trainer',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

// class TestDrawingHomePage extends StatefulWidget {
//   StudyCard studyCard = StudyCard();
//   TestDrawingHomePage({super.key});

//   @override
//   State<TestDrawingHomePage> createState() => _TestDrawingHomePageState();
// }

// class _TestDrawingHomePageState extends State<TestDrawingHomePage> {
//   final TransformationController _transformationController =
//       TransformationController();
//   final FlipCardController _flipCardController = FlipCardController();

//   final _learningObjectStream = BehaviorSubject<List<LearningObject>>();
//   // List<LearningObject> _learningObjects = [];

//   // Offset currentOffset = const Offset(0, 0);
//   // double currentScale = 1;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       resizeToAvoidBottomInset:
//           false, // Prevents automatic resizing when the keyboard appears.
//       appBar: AppBar(
//         shadowColor: const Color.fromARGB(127, 127, 127, 127),
//         backgroundColor: const Color.fromARGB(127, 127, 127, 127),
//         title: const Text("TestTopic / create Study Card"),
//         actions: const [
//           // IconButton(
//           //   onPressed: _addNewStudyCard,
//           //   icon: const Icon(Icons.add),
//           // ),
//         ],
//       ),
//       // bottomNavigationBar: _bottomNavigationBar(context),
//       body: _body(context),
//     );
//   }

//   Widget _body(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     // final height = MediaQuery.of(context).size.height;

//     final containerMargin = EdgeInsets.only(
//       top: (width - width * 0.8) / 2,
//       bottom: width - width * 0.8,
//     );

//     return Center(
//       child: InteractiveViewer(
//         scaleEnabled: true,
//         transformationController: _transformationController,
//         panEnabled: false, // Set it to false to prevent panning.
//         boundaryMargin: const EdgeInsets.all(80),
//         minScale: 0.5,
//         maxScale: 4,
//         child: GestureDetector(
//           onScaleStart: (details) {
//             // print("ScaleStart");
//           },
//           onScaleUpdate: (details) {
//             print("ScaleUpdate ${details.focalPointDelta}");
//             if (details.pointerCount == 1) {
//               return;
//             }
//           },
//           onScaleEnd: (details) {},
//           onDoubleTap: () {
//             print("add text");
//           },
//           onLongPress: () {
//             _flipCardController.toggleCard();
//           },
//           child: FlipCard(
//             controller: _flipCardController,
//             flipOnTouch: false,
//             front: Container(
//               margin: containerMargin,
//               color: const Color.fromARGB(255, 255, 255, 255),
//               width: width * 0.8,
//               height: width * 0.8 * 6 / 4,
//               child: const Center(
//                 child: Text(
//                   "FRONT",
//                   style: TextStyle(color: Colors.black),
//                 ),
//               ),
//             ),
//             back: Container(
//               margin: containerMargin,
//               color: const Color.fromARGB(255, 255, 255, 255),
//               width: width * 0.8,
//               height: width * 0.8 * 6 / 4,
//               child: const Center(
//                 child: Text(
//                   "BACK",
//                   style: TextStyle(color: Colors.black),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Widget _bottomNavigationBar(BuildContext context) {
//   //   return Row(
//   //     IconButton(
//   //       onPressed: () {
//   //         _flipCardController.
//   //       },
//   //     ),
//   //   );
//   // }
// }
