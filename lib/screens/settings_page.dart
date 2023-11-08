import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/android_count_unlocks_manager.dart';
import 'package:vocabulary_trainer/code_behind/pair.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/code_behind/update_manager.dart';
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
  int _currUnlockCount = -1;
  // ignore: prefer_final_fields

  bool _alreadyUpdating = false;

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
    int? count = await AndroidCountUnlocksManager.instance.getUnlockCount();
    count ??= -1;
    _currUnlockCount = count;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IgnorePointer(
            ignoring: _alreadyUpdating,
            child: IconButton(
              onPressed: () async {
                if (_alreadyUpdating) return;
                _alreadyUpdating = true;
                setState(() {});
                bool isUpdateAvaiable =
                    await UpdateManager.instance.isUpdateAvaiable();
                if (isUpdateAvaiable) {
                  bool downloadNewVersion = await _newUpdateAvailable(
                      UpdateManager.instance.whatsNew);
                  if (downloadNewVersion) {
                    bool successful =
                        await UpdateManager.instance.downloadNewestApk();
                    if (successful) {
                      //install
                      UpdateManager.instance.installNewestApk();
                    }
                  }
                } else {
                  _noNewUpdateAvailable();
                }
                _alreadyUpdating = false;
                setState(() {});
              },
              icon: const Icon(Icons.system_update_alt_rounded),
            ),
          ),
        ],
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
                      await _androidCountUnlocksManager.endForegroundService();
                      _openAppAfterUnlocks = false;
                    }
                    if (!_openAppAfterUnlocks) {
                      _expansionTileController.collapse();
                    }
                    setState(() {});
                  },
                ),
              ),
              ListTile(
                onTap: () {},
                title: const Text(
                  "Request 4 Study Cards",
                  style: TextStyle(
                    fontSize: 18,
                  ),
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
              // IgnorePointer(
              //   ignoring: !_openAppAfterUnlocks,
              //   child: TextButton(
              //     onPressed: () async {
              //       List<Pair3<Subject, Topic, StudyCard>> studyCardList = [];

              //       List<Pair<Subject, int>> learningTopics =
              //           SubjectManager.getLearningTopics();

              //       for (int i = 0; i < learningTopics.length; i++) {
              //         Topic topic = learningTopics[i]
              //             .first
              //             .topics[learningTopics[i].second];

              //         await SubjectManager.loadStudyCards(
              //             learningTopics[i].first, topic);

              //         for (StudyCard studyCard in topic.studyCards) {
              //           Pair3<Subject, Topic, StudyCard> pair = Pair3(
              //             learningTopics[i].first,
              //             topic,
              //             studyCard,
              //           );
              //           studyCardList.add(pair);
              //         }
              //       }

              //       studyCardList.sort(
              //         (a, b) => a.third.learningScore
              //             .compareTo(b.third.learningScore),
              //       );
              //       if (studyCardList.isEmpty) {
              //         //display msg
              //         return;
              //       }
              //       await Navigator.of(context).push(
              //         MaterialPageRoute(
              //           builder: (context) => StudyCardLearningPage(
              //             studyCardList: studyCardList,
              //           ),
              //         ),
              //       );
              //       setState(() {});
              //     },
              //     child: Text(
              //       "Example Screen",
              //       style: TextStyle(
              //         fontSize: 18,
              //         color: _openAppAfterUnlocks ? Colors.blue : Colors.grey,
              //       ),
              //     ),
              //   ),
              // ),
              Center(
                child: Text(
                  "Current Unlock Count:\n$_currUnlockCount",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
              ),
              const SizedBox(
                height: 100,
              ),
              Visibility(
                visible: _alreadyUpdating,
                child: StreamBuilder<double>(
                    stream: UpdateManager.instance.downloadPercentStream,
                    builder: (context, snapshot) {
                      double percent = snapshot.data ?? 0;
                      return Center(
                          child: Text("Download ${percent.toInt()}%"));
                    }),
              ),
            ],
          );
        },
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

  Future<bool> _newUpdateAvailable(String whatsNew) async {
    bool downloadNewVersion = false;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("New Version is available"),
          content: Text("Features:\n$whatsNew"),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Download'),
              onPressed: () {
                downloadNewVersion = true;
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
    return downloadNewVersion;
  }

  Future _noNewUpdateAvailable() async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("You are running the newest version!"),
          // content: const Center(
          //   child: Text("Do you want to download it now?"),
          // ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Okay'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
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
  bool switchValue = false;

  @override
  void initState() {
    super.initState();
    switchValue = widget.subject.topics[widget.index].isLearningTopic;
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
          value: switchValue,
          onChanged: (value) {
            switchValue = value;
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
