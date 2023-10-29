import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vocabulary_trainer/code_behind/pair.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/screens/custom_page_transition_animation.dart';
import 'package:vocabulary_trainer/screens/topic_page.dart';
import 'package:vocabulary_trainer/widgets/editable_text_widget.dart';
// import 'package:reorderables/reorderables.dart';

class SubjectPage extends StatefulWidget {
  Subject subject;
  SubjectPage({
    super.key,
    required this.subject,
  });

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  static const columnCount = 3;

  @override
  void initState() {
    super.initState();
    SubjectManager.loadTopics(widget.subject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: widget.subject.color,
        backgroundColor: widget.subject.color,
        title: Text(widget.subject.name),
        actions: [
          IconButton(
            onPressed: _addNewTopic,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: StreamBuilder<Pair<Subject, Topic>>(
          stream: SubjectManager.topicStream,
          builder: (context, snapshot) {
            return SafeArea(
              child: GridView.count(
                childAspectRatio: 1.0,
                padding: const EdgeInsets.all(8.0),
                crossAxisCount: columnCount,
                children: List.generate(
                  widget.subject.topics.length,
                  (int index) {
                    return contextBuilder(context, index);
                  },
                ),
              ),
            );
          }),
    );
  }

  // Widget oldContextBuilder(BuildContext context, int index) => ListTile(
  //       title: Text(widget.subject.topics[index].name),
  //       tileColor: widget.subject.topics[index].color,
  //       onTap: () {
  //         print("TODO -> openSubjectScreen..");
  //       },
  //       onLongPress: () {
  //         print("TODO -> AskToDeleteSubject");
  //       },
  //     );

  void _addNewTopic() async {
    String? newTopicName = await _showAddItemDialog();

    if (newTopicName == null) return;

    if (widget.subject.topics.any((element) => element.name == newTopicName)) {
      //TODO: Show pop up..
      return;
    }

    SubjectManager.addTopic(widget.subject, Topic(name: newTopicName));

    setState(() {});
  }

  Future _editSubject(int index) async {
    Topic topic = widget.subject.topics[index];
    String newTopicName = topic.name;
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
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    initialText: topic.name,
                    onTextSaved: (name) {
                      newTopicName = name;
                    },
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  HueRingPicker(
                    pickerColor: topic.color,
                    onColorChanged: (value) {
                      topic.setColor(value);
                      setState(() {});
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      SubjectManager.removeTopicAt(widget.subject, index);
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

    if (newTopicName == topic.name) {
      SubjectManager.saveTopicAt(widget.subject, index);
    } else {
      if (widget.subject.topics
          .any((element) => element.name == newTopicName)) {
        //TODO: Show pop up..
        return;
      }
      SubjectManager.renameTopicAt(widget.subject, index, newTopicName);
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
          title: const Text('Add Topic'),
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

  Widget contextBuilder(BuildContext context, int index) {
    final topic = widget.subject.topics[index];
    return AnimationConfiguration.staggeredGrid(
      columnCount: columnCount,
      position: index,
      duration: const Duration(milliseconds: 375),
      child: ScaleAnimation(
        scale: 0.5,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CustomPageTransitionAnimation(
                  TopicPage(
                    parentSubject: widget.subject,
                    topic: topic,
                  ),
                  const Alignment(0, 0),
                ),
              );
            },
            onLongPress: () {
              _editSubject(index);
            },
            child: Hero(
              tag: "topicContainerHero:$index",
              child: AnimatedContainer(
                height: 100,
                duration: const Duration(milliseconds: 375),
                padding: const EdgeInsets.all(8.0), // Add padding
                margin: const EdgeInsets.all(08.0),
                decoration: BoxDecoration(
                    color: topic.color,
                    borderRadius:
                        BorderRadius.circular(16.0), // Add rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: topic.color,
                        blurRadius: 8.0,
                      ),
                    ]),
                child: Center(
                  child: Text(
                    topic.name,
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
      ),
    );
  }
}
