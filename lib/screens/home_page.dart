import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vocabulary_trainer/code_behind/android_count_unlocks_manager.dart';
import 'package:vocabulary_trainer/code_behind/pair.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/screens/custom_bottom_app_bar.dart';
import 'package:vocabulary_trainer/screens/custom_page_transition_animation.dart';
import 'package:vocabulary_trainer/screens/hero_dialog_route.dart';
import 'package:vocabulary_trainer/screens/settings_page.dart';
import 'package:vocabulary_trainer/screens/study_card_learning_page.dart';
import 'package:vocabulary_trainer/screens/subject_page.dart';
import 'package:vocabulary_trainer/widgets/editable_text_widget.dart';
// import 'package:reorderables/reorderables.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  static const columnCount = 2;

  Future<void> _appStarted() async {
    int vocabularyCount = 4;

    print("App Started");
    // ignore: unused_local_variable
    final AndroidCountUnlocksManager androidCountUnlocksManager =
        AndroidCountUnlocksManager.instance;

    int? count = await androidCountUnlocksManager.getUnlockCount();

    count ??= -1;

    if (count < androidCountUnlocksManager.unlockCountToOpenApp) {
      return;
    }

    List<Pair3<Subject, Topic, StudyCard>> studyCardList = [];

    await SubjectManager.loadSubjects(loadTopics_: true);

    List<Pair<Subject, int>> learningTopics =
        SubjectManager.getLearningTopics();

    for (int i = 0; i < learningTopics.length; i++) {
      Topic topic = learningTopics[i].first.topics[learningTopics[i].second];

      await SubjectManager.loadStudyCards(learningTopics[i].first, topic);

      for (StudyCard studyCard in topic.studyCards) {
        Pair3<Subject, Topic, StudyCard> pair = Pair3(
          learningTopics[i].first,
          topic,
          studyCard,
        );
        studyCardList.add(pair);
      }
    }

    studyCardList.sort(
      (a, b) => a.third.learningScore.compareTo(b.third.learningScore),
    );

    while (studyCardList.length > vocabularyCount * 2) {
      studyCardList.removeLast();
    }

    //scamble
    studyCardList.shuffle();

    while (studyCardList.length > vocabularyCount) {
      studyCardList.removeLast();
    }

    if (studyCardList.isEmpty) {
      //display msg
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StudyCardLearningPage(
          studyCardList: studyCardList,
          repeat: false,
        ),
      ),
    );

    androidCountUnlocksManager.vocabularyDone();

    SystemNavigator.pop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // This code will run when the app is brought to the foreground.
      _appStarted();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appStarted();
    SubjectManager.loadSubjects(loadTopics_: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subjects'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
      bottomNavigationBar: _bottomNavigationBar(context),
      floatingActionButton: _floatingActionButton(context),
      body: StreamBuilder(
        stream: SubjectManager.subjectStream,
        builder: (context, snapshot) {
          return SafeArea(
            child: GridView.count(
              childAspectRatio: 1.0,
              padding: const EdgeInsets.all(8.0),
              crossAxisCount: columnCount,
              children: List.generate(
                SubjectManager.subjects.length,
                (int index) {
                  return contextBuilder(context, index);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget contextBuilder(BuildContext context, int index) {
    final subject = SubjectManager.subjects[index];

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

    if (newSubjectName.isEmpty) return;
    newSubjectName.trim();

    if (SubjectManager.subjects
        .any((element) => element.name == newSubjectName)) {
      //TODO: Show pop up..
      return;
    }

    SubjectManager.addSubject(Subject(name: newSubjectName));
    setState(() {});
  }

  Future _editSubject(int index) async {
    Subject subject = SubjectManager.subjects[index];
    String newSubjectName = subject.name;
    bool deleted = false;

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
                      newSubjectName = name;
                    },
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
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
                      SubjectManager.removeSubjectAt(index);
                      setState(() {});
                      deleted = true;
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

    if (deleted) {
      setState(() {});
      return;
    }

    if (newSubjectName.isEmpty) {
      return;
    }

    newSubjectName.trim();

    if (newSubjectName == subject.name) {
      SubjectManager.saveSubjectAt(index);
    } else {
      //if subject.name changed

      if (SubjectManager.subjects
          .any((element) => element.name == newSubjectName)) {
        //TODO: Show pop up..
        return;
      }

      SubjectManager.renameSubjectAt(index, newSubjectName);
    }
    setState(() {});
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

  Widget _bottomNavigationBar(BuildContext context) {
    return CustomBottomAppBar(
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.library_books),
        ),
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              CustomPageTransitionAnimation(
                const SettingsPage(),
                const Alignment(1, 1),
              ),
            );
          },
          icon: const Icon(Icons.settings),
        ),
      ],
    );
  }

  Widget _floatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: _addNewSubject,
      elevation: 5,
      child: const Icon(Icons.add),
    );
  }

  // String getSubjectHeroString(int index) {
  //   return "subjectContainer:$index";
  // }
}
