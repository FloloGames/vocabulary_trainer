import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vocabulary_trainer/code_behind/import_study_cards_from_quizlet.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects.dart';
import 'package:vocabulary_trainer/code_behind/pair.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/screens/custom_bottom_app_bar.dart';
import 'package:vocabulary_trainer/screens/custom_page_transition_animation.dart';
import 'package:vocabulary_trainer/screens/settings_page.dart';
import 'package:vocabulary_trainer/screens/study_card_editor_page.dart';
import 'package:vocabulary_trainer/screens/study_card_learning_page.dart';
// import 'package:reorderables/reorderables.dart';

class TopicPage extends StatefulWidget {
  Subject parentSubject;
  Topic topic;
  TopicPage({
    super.key,
    required this.topic,
    required this.parentSubject,
  });

  @override
  State<TopicPage> createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  static const columnCount = 2;

  @override
  void initState() {
    super.initState();
    SubjectManager.loadStudyCards(widget.parentSubject, widget.topic);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: widget.topic.color,
        backgroundColor: widget.topic.color,
        title: Text("${widget.parentSubject.name} / ${widget.topic.name}"),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: const Icon(Icons.keyboard_double_arrow_down_sharp),
        //   ),
        //   IconButton(
        //     onPressed: _addNewStudyCard,
        //     icon: const Icon(Icons.add),
        //   ),
        // ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewStudyCard,
        elevation: 5,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomBottomAppBar(
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            onPressed: () async {
              String studyCardsString =
                  await _importStudyCardsFromQuizletDialog();
              // print(studyCardsString);
              if (studyCardsString.isEmpty) return;
              studyCardsString.trim();

              ImportStudyCardsFromQuizlet.instance.addStudyCardsFromString(
                  studyCardsString, widget.parentSubject, widget.topic);
            },
            icon: const Icon(Icons.download_for_offline),
          ),
        ],
      ),
      body: StreamBuilder<Object>(
          stream: SubjectManager.studyCardStream,
          builder: (context, snapshot) {
            return SafeArea(
              child: GridView.count(
                childAspectRatio: 1.0,
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: columnCount,
                children: List.generate(
                  widget.topic.studyCards.length,
                  (int index) {
                    return contextBuilder(context, index);
                  },
                ),
              ),
            );
          }),
    );
  }

  Future<String> _importStudyCardsFromQuizletDialog() async {
    TextEditingController controller = TextEditingController();
    String studyCardsString = "";
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Import StudyCards from Quizlet"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                  "1. In your set in Quizlet (website) click on “...” select “Export”.\n"),
              const Text(
                  "2. Press on “Copy text” and paste it in the field below."),
              TextField(
                maxLength: null,
                maxLines: 5,
                controller: controller,
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Import'),
              onPressed: () {
                studyCardsString = controller.text;
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
    return studyCardsString;
  }

  Widget contextBuilder(BuildContext context, int index) {
    final studyCard = widget.topic.studyCards[index];

    return AnimationConfiguration.staggeredGrid(
      columnCount: columnCount,
      position: index,
      duration: const Duration(milliseconds: 375),
      child: ScaleAnimation(
        scale: 0.5,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: () async {
              List<Pair3<Subject, Topic, StudyCard>> studyCardList = [];

              for (int i = 0; i < widget.topic.studyCards.length; i++) {
                if (i == index) {
                  continue; //sonst ist die currstudycard zweimal drin
                }
                studyCardList.add(Pair3(widget.parentSubject, widget.topic,
                    widget.topic.studyCards[i]));
              }

              studyCardList.sort(
                (a, b) =>
                    a.third.learningScore.compareTo(b.third.learningScore),
              );

              studyCardList.insert(
                  0, Pair3(widget.parentSubject, widget.topic, studyCard));

              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => StudyCardLearningPage(
                    studyCardList: studyCardList,
                  ),
                ),
              );
              setState(() {});
            },
            onDoubleTap: () async {
              await Navigator.of(context).push<StudyCard>(
                MaterialPageRoute(
                  builder: (context) => StudyCardEditorPage(
                    parentTopic: widget.topic,
                    studyCard: studyCard,
                  ),
                ),
              );
              SubjectManager.saveStudyCardAt(
                  widget.parentSubject, widget.topic, index);
              setState(() {});
            },
            onLongPress: () {
              _editStudyCard(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 375),
              padding: const EdgeInsets.all(8.0), // Add padding
              margin: const EdgeInsets.all(08.0),
              decoration: BoxDecoration(
                  color: widget.topic.color,
                  borderRadius:
                      BorderRadius.circular(16.0), // Add rounded corners
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(127, 127, 127, 127),
                      blurRadius: 8.0,
                    ),
                  ]),
              child: Center(
                child: Text(
                  // "i: ${studyCard.index} | ls: ${studyCard.learningScore}\n${(studyCard.questionLearnObjects[0] as TextObject).text}",
                  (studyCard.questionLearnObjects[0] as TextObject).text,
                  textAlign: TextAlign.center,
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

  Future<void> _addNewStudyCard() async {
    StudyCard studyCard = StudyCard(widget.topic.studyCards.length);

    // StudyCard? newStudyCard =
    await Navigator.of(context).push<StudyCard>(
      MaterialPageRoute(
        builder: (context) => StudyCardEditorPage(
          parentTopic: widget.topic,
          studyCard: studyCard,
        ),
      ),
    );

    if (studyCard.answerLearnObjects.isEmpty ||
        studyCard.questionLearnObjects.isEmpty) {
      return;
    }

    SubjectManager.addStudyCard(widget.parentSubject, widget.topic, studyCard);

    setState(() {});
  }

  Future _editStudyCard(int index) async {
    // StudyCard studyCard = widget.topic.studyCards[index];

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
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);

                      await Navigator.of(context).push<StudyCard>(
                        MaterialPageRoute(
                          builder: (context) => StudyCardEditorPage(
                            parentTopic: widget.topic,
                            studyCard: widget.topic.studyCards[index],
                          ),
                        ),
                      );

                      SubjectManager.saveStudyCardAt(
                          widget.parentSubject, widget.topic, index);

                      setState(() {});
                    },
                    child: const Text(
                      "Edit",
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextButton(
                    onPressed: () {
                      SubjectManager.removeStudyCardAt(
                          widget.parentSubject, widget.topic, index);
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
}
