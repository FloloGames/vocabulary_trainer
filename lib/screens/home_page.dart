import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/screens/custom_page_transition_animation.dart';
import 'package:vocabulary_trainer/screens/subject_page.dart';
import 'package:vocabulary_trainer/widgets/editable_text_widget.dart';
// import 'package:reorderables/reorderables.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const columnCount = 2;

  List<Subject> subjects = [
    Subject(name: "Deutsch"),
    Subject(name: "Mathe"),
    Subject(name: "Englisch")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
        actions: [
          IconButton(
            onPressed: _addNewSubject,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      // body: SingleChildScrollView(
      //   child: ReorderableWrap(
      //       spacing: 8.0,
      //       runSpacing: 4.0,
      //       padding: const EdgeInsets.all(8),
      //       onReorder: (int oldIndex, int newIndex) {
      //         setState(() {
      //           Subject row = subjects.removeAt(oldIndex);
      //           subjects.insert(newIndex, row);
      //         });
      //       },
      //       onNoReorder: (int index) {
      //         //this callback is optional
      //         debugPrint(
      //             '${DateTime.now().toString().substring(5, 22)} reorder cancelled. index:$index');
      //       },
      //       onReorderStarted: (int index) {
      //         //this callback is optional
      //         debugPrint(
      //             '${DateTime.now().toString().substring(5, 22)} reorder started: index:$index');
      //       },
      //       children: List.generate(
      //         subjects.length,
      //         (index) => contextBuilder(context, index),
      //       )),
      // ),
      body: SafeArea(
        child: GridView.count(
          childAspectRatio: 1.0,
          padding: const EdgeInsets.all(8.0),
          crossAxisCount: columnCount,
          children: List.generate(
            subjects.length,
            (int index) {
              return contextBuilder(context, index);
            },
          ),
        ),
      ),
    );
  }

  Widget contextBuilder(BuildContext context, int index) {
    final subject = subjects[index];
    // final globalKey = subject.globalKey;
    return AnimationConfiguration.staggeredGrid(
      columnCount: columnCount,
      position: index,
      duration: const Duration(milliseconds: 375),
      child: ScaleAnimation(
        scale: 0.5,
        child: FadeInAnimation(
          child: GestureDetector(
            // onTapDown: (details) {
            //   final RenderBox renderBox =
            //       context.findRenderObject() as RenderBox;
            //   final localPos = renderBox.globalToLocal(details.globalPosition);

            //   final alignment = Alignment(
            //     (localPos.dx / renderBox.size.width) * 2 - 1,
            //     (localPos.dy / renderBox.size.height) * 2 - 1,
            //   );

            //   Navigator.of(context).push(
            //     CustomPageTransitionAnimation(
            //       SubjectPage(
            //         subject: subject,
            //       ),
            //       alignment,
            //     ),
            //   );
            // },
            onTap: () {
              Navigator.of(context).push(
                CustomPageTransitionAnimation(
                  SubjectPage(
                    subject: subject,
                  ),
                  const Alignment(0, 0),
                ),
              );
            },
            onLongPress: () {
              _editSubject(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 375),
              padding: const EdgeInsets.all(8.0), // Add padding
              margin: const EdgeInsets.all(08.0),
              decoration: BoxDecoration(
                  color: subject.color,
                  borderRadius:
                      BorderRadius.circular(16.0), // Add rounded corners
                  boxShadow: [
                    BoxShadow(
                      color: subject.color,
                      blurRadius: 8.0,
                    ),
                  ]),
              child: Center(
                child: Text(
                  subject.name,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addNewSubject() async {
    String? newSubjectName = await _showAddItemDialog();

    if (newSubjectName == null) return;

    subjects.add(Subject(name: newSubjectName));

    setState(() {});
  }

  Future _editSubject(int index) async {
    Subject subject = subjects[index];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SizedBox(
            width: double.maxFinite, // Make the dialog content full width
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EditableTextWidget(
                    initialText: subject.name,
                    onTextSaved: (name) {
                      subject.setName(name);
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  HueRingPicker(
                    pickerColor: subject.color,
                    onColorChanged: (value) {
                      subject.setColor(value);
                      setState(() {});
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      subjects.removeAt(index);
                      setState(() {});
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 26,
                        color: Color.fromARGB(255, 255, 0, 0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<String?> _showAddItemDialog() async {
    String? subjectName;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String newItem = '';
        return AlertDialog(
          title: const Text('Add Subject'),
          content: TextField(
            autofocus: true,
            onChanged: (value) {
              newItem = value;
            },
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                subjectName = newItem;
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
    return subjectName;
  }

  PageRouteBuilder _createRoute(Widget nextScreen) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}