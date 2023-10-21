import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/screens/topic_page.dart';
import 'package:vocabulary_trainer/widgets/EditableTextWidget.dart';
// import 'package:reorderables/reorderables.dart';

class SubjectPage extends StatefulWidget {
  Subject subject;
  SubjectPage({super.key, required this.subject});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  static const columnCount = 3;

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
      body: SafeArea(
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
      ),
    );
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
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => TopicPage(
                  parentSubject: widget.subject,
                  topic: topic,
                ),
              ));
            },
            onLongPress: () {
              _editSubject(index);
            },
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
    );
  }

  Widget oldContextBuilder(BuildContext context, int index) => ListTile(
        title: Text(widget.subject.topics[index].name),
        tileColor: widget.subject.topics[index].color,
        onTap: () {
          print("TODO -> openSubjectScreen..");
        },
        onLongPress: () {
          print("TODO -> AskToDeleteSubject");
        },
      );

  void _addNewTopic() async {
    String? newSubjectName = await _showAddItemDialog();

    if (newSubjectName == null) return;

    widget.subject.topics.add(Topic(name: newSubjectName));

    setState(() {});
  }

  Future _editSubject(int index) async {
    Topic subject = widget.subject.topics[index];

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
                      widget.subject.topics.removeAt(index);
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
}
