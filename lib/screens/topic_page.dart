import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/screens/study_card_editor_page.dart';
import 'package:vocabulary_trainer/widgets/editable_text_widget.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: widget.topic.color,
        backgroundColor: widget.topic.color,
        title: Text("${widget.parentSubject.name} / ${widget.topic.name}"),
        actions: [
          IconButton(
            onPressed: _addNewStudyCard,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SafeArea(
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
      ),
    );
  }

  Widget contextBuilder(BuildContext context, int index) {
    final subject = widget.topic.studyCards[index];
    return AnimationConfiguration.staggeredGrid(
      columnCount: columnCount,
      position: index,
      duration: const Duration(milliseconds: 375),
      child: ScaleAnimation(
        scale: 0.5,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: () {
              print("TODO -> openSubjectScreen..");
            },
            onLongPress: () {
              _editSubject(index);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 375),
              padding: const EdgeInsets.all(8.0), // Add padding
              margin: const EdgeInsets.all(08.0),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(127, 127, 127, 127),
                  borderRadius:
                      BorderRadius.circular(16.0), // Add rounded corners
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(127, 127, 127, 127),
                      blurRadius: 8.0,
                    ),
                  ]),
              child: const Center(
                child: Text(
                  "Image of question",
                  style: TextStyle(
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
    String? newStudyCardName = await _showAddItemDialog();

    if (newStudyCardName == null) return;
    StudyCard? newStudyCard =
        await Navigator.of(context).push<StudyCard>(MaterialPageRoute(
            builder: (context) => StudyCardEditor(
                  parentTopic: widget.topic,
                  studyCard: StudyCard(name: newStudyCardName),
                )));

    if (newStudyCard == null) return;

    widget.topic.studyCards.add(newStudyCard);

    setState(() {});
  }

  Future _editSubject(int index) async {
    StudyCard studyCard = widget.topic.studyCards[index];

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
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    initialText: studyCard.name,
                    onTextSaved: (name) {
                      studyCard.setName(name);
                      setState(() {});
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextButton(
                    onPressed: () {
                      widget.topic.studyCards.removeAt(index);
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
          title: const Text('Add Study Card'),
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
}
