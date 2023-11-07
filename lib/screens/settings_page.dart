import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/android_count_unlocks_manager.dart';
import 'package:vocabulary_trainer/code_behind/pair.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/screens/study_card_learning_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final ExpansionTileController _expansionTileController =
      ExpansionTileController();

  final AndroidCountUnlocksManager _androidCountUnlocksManager =
      AndroidCountUnlocksManager.instance;

  bool _openAppAfterUnlocks = false;

  // ignore: prefer_final_fields

  @override
  void initState() {
    super.initState();
    SubjectManager.loadSubjects(loadTopics_: true);
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    //TODO save and load shit
    _androidCountUnlocksManager.setUnlockCountToOpenApp(
        _androidCountUnlocksManager.unlockCountToOpenApp);
    bool? isForegroundServiceRunning =
        await _androidCountUnlocksManager.isForegroundServiceRunning();
    isForegroundServiceRunning ??= false;
    _openAppAfterUnlocks = isForegroundServiceRunning;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: StreamBuilder(
          stream: SubjectManager.topicStream,
          builder: (context, snapshot) {
            return ListView(
              children: [
                ListTile(
                  onTap: () {
                    //set unlock count
                  },
                  title: Text(
                    "Open app after ${_androidCountUnlocksManager.unlockCountToOpenApp} unlocks",
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  trailing: Switch(
                    value: _openAppAfterUnlocks,
                    onChanged: (value) async {
                      if (value) {
                        bool? startedForegroundService =
                            await _androidCountUnlocksManager
                                .startForegroundService();
                        startedForegroundService ??= false;
                        _openAppAfterUnlocks = startedForegroundService;
                      } else {
                        await _androidCountUnlocksManager
                            .endForegroundService();
                        _openAppAfterUnlocks = false;
                      }
                      if (!_openAppAfterUnlocks) {
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
                        color:
                            _openAppAfterUnlocks ? Colors.white : Colors.grey,
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
                    onPressed: () async {
                      List<Pair3<Subject, Topic, StudyCard>> studyCardList = [];

                      List<Pair<Subject, int>> learningTopics =
                          SubjectManager.getLearningTopics();

                      for (int i = 0; i < learningTopics.length; i++) {
                        Topic topic = learningTopics[i]
                            .first
                            .topics[learningTopics[i].second];

                        await SubjectManager.loadStudyCards(
                            learningTopics[i].first, topic);

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
                        (a, b) => a.third.learningScore
                            .compareTo(b.third.learningScore),
                      );
                      if (studyCardList.isEmpty) {
                        //display msg
                        return;
                      }
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => StudyCardLearningPage(
                            studyCardList: studyCardList,
                          ),
                        ),
                      );
                      setState(() {});
                    },
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
            );
          }),
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
  AndroidCountUnlocksManager androidCountUnlocksManager =
      AndroidCountUnlocksManager();
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
