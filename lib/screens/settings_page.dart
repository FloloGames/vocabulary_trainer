import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ExpansionTileController _expansionTileController =
      ExpansionTileController();
  bool _openAppAfterUnlocks = false;

  @override
  void initState() {
    super.initState();
    SubjectManager.loadSubjects(loadTopics_: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            onTap: () {
              //set unlock count
            },
            title: const Text(
              "Open app after {n} unlocks",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
            trailing: Switch(
              value: _openAppAfterUnlocks,
              onChanged: (value) {
                _openAppAfterUnlocks = value;
                if (!value) {
                  _expansionTileController.collapse();
                }
                setState(() {});
              },
            ),
          ),
          IgnorePointer(
            ignoring: !_openAppAfterUnlocks,
            child: ExpansionTile(
              controller: _expansionTileController,
              title: Text(
                "Selected Topics to learn:",
                style: TextStyle(
                  fontSize: 18,
                  color: _openAppAfterUnlocks ? Colors.white : Colors.grey,
                ),
              ),
              children: List.generate(
                SubjectManager.subjects.length,
                (index) => _listSubjectExpansionTileBuilder(index),
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !_openAppAfterUnlocks,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Example Screen",
                style: TextStyle(
                  fontSize: 18,
                  color: _openAppAfterUnlocks ? Colors.blue : Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _listSubjectExpansionTileBuilder(int index) {
    Subject subject = SubjectManager.subjects[index];

    return Container(
      decoration: BoxDecoration(
        // color: subject.color,
        borderRadius: BorderRadius.circular(16),
      ),
      // padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        leading: Icon(
          Icons.circle,
          color: subject.color,
        ),
        tilePadding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
        // collapsedBackgroundColor: subject.color,
        title: Text(
          subject.name,
          style: const TextStyle(
            fontSize: 18,
          ),
        ),
        children: List.generate(
          subject.topics.length,
          (i) => ListTopicExpansionTile(
            subject: subject,
            index: i,
          ),
        ),
      ),
    );
  }
}

class ListTopicExpansionTile extends StatefulWidget {
  Subject subject;
  int index;

  ListTopicExpansionTile(
      {super.key, required this.subject, required this.index});

  @override
  State<ListTopicExpansionTile> createState() => _ListTopicExpansionTileState();
}

class _ListTopicExpansionTileState extends State<ListTopicExpansionTile> {
  bool _switchValue = false;

  @override
  void initState() {
    super.initState();
    _switchValue = widget.subject.topics[widget.index].isLearningTopic;
  }

  @override
  Widget build(BuildContext context) {
    Topic topic = widget.subject.topics[widget.index];

    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        // color: subject.color,
        // color: topic.color.withAlpha(255),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        // contentPadding: const EdgeInsets.symmetric(horizontal: 24),
        leading: Icon(
          Icons.circle,
          color: topic.color,
        ),
        title: Text(topic.name),
        // tileColor: const Color.fromARGB(255, 127, 127, 127),
        trailing: Switch(
          value: _switchValue,
          onChanged: (value) {
            _switchValue = value;
            setState(() {});
            topic.isLearningTopic = value;
            SubjectManager.saveTopicAt(
              widget.subject,
              widget.index,
              saveStudyCards: false,
            );
          },
        ),
      ),
    );
  }
}
