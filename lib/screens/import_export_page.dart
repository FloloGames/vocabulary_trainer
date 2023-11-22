import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/android_count_unlocks_manager.dart';
import 'package:vocabulary_trainer/code_behind/pair.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/study_card_provider.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/subject_manager.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/screens/settings_page.dart';
import 'package:path_provider/path_provider.dart';

enum Mode {
  none,
  import,
  export,
}

class ImportExportPage extends StatefulWidget {
  const ImportExportPage({super.key});

  @override
  State<ImportExportPage> createState() => _ImportExportPageState();
}

class _ImportExportPageState extends State<ImportExportPage> {
  final ExpansionTileController _expansionTileController =
      ExpansionTileController();

  final AndroidCountUnlocksManager _androidCountUnlocksManager =
      AndroidCountUnlocksManager.instance;

  final PageController _pageController = PageController();

  final Curve _stepTransitionCurve = Curves.easeOut;
  final Duration _stepTransitionDuration = const Duration(milliseconds: 500);

  Directory? _selectedImportDir;

  Mode _currentMode = Mode.none; //egal welcher mode

  //id = subject.name + "/" + topic.name
  final List<String> _selectedTopics = [];

  @override
  void initState() {
    super.initState();
    SubjectManager.loadSubjects(loadTopics_: true, loadStudyCards_: true);
    _asyncInit();
  }

  Future<void> _asyncInit() async {
    //TODO save and load shit
    // _androidCountUnlocksManager.setUnlockCountToOpenApp(
    //     _androidCountUnlocksManager.unlockCountToOpenApp);
    // bool? isForegroundServiceRunning =
    //     await _androidCountUnlocksManager.isForegroundServiceRunning();
    // isForegroundServiceRunning ??= false;
  }

  bool _canPop = true;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _canPop,
      onPopInvoked: (value) {
        if (_canPop) {
          return;
        }
        _currentMode = Mode.none;
        _pageController.animateToPage(
          0,
          duration: _stepTransitionDuration,
          curve: _stepTransitionCurve,
        );
        _canPop = true;
        setState(() {});
      },
      child: Scaffold(
        appBar: AppBar(
          title: _getTitleText(),
          actions: const [
            // IconButton(
            //   onPressed: () async {},
            //   icon: const Icon(Icons.system_update_alt_rounded),
            // ),
          ],
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: [
            _firstStep(),
            _secondStep(),
          ],
        ),
        // StreamBuilder(
        //   stream: SubjectManager.topicStream,
        //   builder: (context, snapshot) {
        //     return ListView(
        //       children: [
        //         ExpansionTile(
        //           controller: _expansionTileController,
        //           title: const Text(
        //             "Selected Topics to learn:",
        //             style: TextStyle(
        //               fontSize: 18,
        //               color: Colors.white,
        //             ),
        //           ),
        //           children: List.generate(
        //             SubjectManager.subjects.length,
        //             (index) => _listSubjectExpansionTileBuilder(index),
        //           ),
        //         ),
        //       ],
        //     );
        //   },
        // ),
      ),
    );
  }

  Widget _firstStep() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ["zip"],
            );

            if (result == null) {
              return;
            }
            final selectedFile = File(result.files.single.path!);

            if (!selectedFile.existsSync()) return;

            // _selectedImportFile = selectedFile;

            _currentMode = Mode.import;

            final tempDir = await getTemporaryDirectory();

            // if (tempDir.existsSync()) {
            //   tempDir.deleteSync();
            // }
            tempDir.createSync();

            final bytes = selectedFile.readAsBytesSync();

            // Decode the Zip file
            final archive = ZipDecoder().decodeBytes(bytes);

            // Extract the contents of the Zip archive to disk.
            for (final file in archive) {
              final filename = file.name;
              if (file.isFile) {
                final data = file.content as List<int>;
                File(
                    '${tempDir.path}${SubjectManager.SUBJECTS_SAVE_DIR_NAME}$filename')
                  ..createSync(recursive: true)
                  ..writeAsBytesSync(data);
              } else {
                Directory(
                        '${tempDir.path}${SubjectManager.SUBJECTS_SAVE_DIR_NAME}$filename')
                    .create(recursive: true);
              }
            }

            _selectedImportDir =
                Directory(tempDir.path + SubjectManager.SUBJECTS_SAVE_DIR_NAME);
            _selectedTopics.clear();

            _pageController.nextPage(
              duration: _stepTransitionDuration,
              curve: _stepTransitionCurve,
            );
            _canPop = false;
            setState(() {});
          },
          child: const Text("Import"),
        ),
        const SizedBox(
          width: 20,
        ),
        ElevatedButton(
          onPressed: () {
            _currentMode = Mode.export;
            _pageController.nextPage(
              duration: _stepTransitionDuration,
              curve: _stepTransitionCurve,
            );
            _canPop = false;
            setState(() {});
          },
          child: const Text("Export"),
        ),
      ],
    );
  }

  Widget _secondStep() {
    if (_currentMode == Mode.import) {
      return _importStep();
    } else {
      return _exportStep();
    }
  }

  Widget _importStep() {
    if (_selectedImportDir == null) Navigator.of(context).pop();

    return FutureBuilder(
      future: SubjectManager.loadSubjectsFromDirectory(
        _selectedImportDir!,
        (p0) => null,
        true,
        true,
      ),
      builder: (context, data) {
        final loadedSubjects = data.data;

        if (loadedSubjects == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: loadedSubjects.length,
                itemBuilder: (context, subjectIndex) {
                  Subject subject = loadedSubjects[subjectIndex];

                  return ExpansionTile(
                    leading: Icon(
                      Icons.circle,
                      color: subject.color,
                    ),
                    tilePadding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 16),
                    // collapsedBackgroundColor: subject.color,
                    title: Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    children: List.generate(
                      subject.topics.length,
                      (topicIndex) {
                        Topic topic = subject.topics[topicIndex];
                        //_selectedTopics
                        return ExportTopicListItem(
                          subject: subject,
                          topic: topic,
                          index: topicIndex,
                          selectedTopics: _selectedTopics,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
            // const Text("StudyCards will get overriten!"),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _onImportButtonPressed(loadedSubjects),
                  child: const Text("Import"),
                ),
              ],
            ),
            const Spacer(),
          ],
        );
      },
    );
  }

  void _onImportButtonPressed(List<Subject> loadedSubjects) async {
    if (_selectedTopics.isEmpty) {
      return;
    }
    // print("import: $_selectedTopics");
    // for(sub)
    // SubjectManager.subjects.

    for (String topicStr in _selectedTopics) {
      String subjectName = topicStr.split("/")[0];
      String topicName = topicStr.split("/")[1];

      Subject importSubject =
          loadedSubjects.firstWhere((element) => element.name == subjectName);
      Topic importTopic = importSubject.topics
          .firstWhere((element) => element.name == topicName);

      Subject? localSubject;

      try {
        localSubject = SubjectManager.subjects.firstWhere(
          (element) => element.name == subjectName,
        );
      } catch (e) {
        localSubject = null;
      }

      if (localSubject == null) {
        localSubject = Subject(name: subjectName);
        localSubject.setColor(importSubject.color);
        localSubject.topics.add(importTopic);
        SubjectManager.addSubject(
          localSubject,
          saveStudyCards_: true,
          saveTopics_: true,
        );
      } else {
        Topic? localTopic;
        try {
          localTopic = localSubject.topics.firstWhere(
            (element) => element.name == topicName,
          );
        } catch (e) {
          localTopic = null;
        }

        if (localTopic == null) {
          localTopic = importTopic;
          for (int i = 0; i < localTopic.studyCards.length; i++) {
            StudyCard studyCard = localTopic.studyCards[i];
            studyCard.index = i;
            studyCard.lastAnswer = StudyCardStatus.none;
            studyCard.learningScore = -3;
          }
          localSubject.topics.add(localTopic);
        } else {
          int len = localTopic.studyCards.length;
          for (int i = 0; i < importTopic.studyCards.length; i++) {
            StudyCard studyCard = importTopic.studyCards[i];
            studyCard.index = len + i;
            studyCard.lastAnswer = StudyCardStatus.none;
            studyCard.learningScore = -3;
            localTopic.studyCards.add(studyCard);
          }
        }
        SubjectManager.saveSubject(
          localSubject,
          saveTopics_: true,
          saveStudyCards_: true,
        );
      }
    }
    await Future.delayed(const Duration(seconds: 1));
    SubjectManager.loadSubjects();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Widget _exportStep() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: SubjectManager.subjects.length,
            itemBuilder: (context, subjectIndex) {
              Subject subject = SubjectManager.subjects[subjectIndex];

              return ExpansionTile(
                leading: Icon(
                  Icons.circle,
                  color: subject.color,
                ),
                tilePadding:
                    const EdgeInsetsDirectional.symmetric(horizontal: 16),
                // collapsedBackgroundColor: subject.color,
                title: Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 18,
                  ),
                ),
                children: List.generate(
                  subject.topics.length,
                  (topicIndex) {
                    Topic topic = subject.topics[topicIndex];
                    //_selectedTopics
                    return ExportTopicListItem(
                      subject: subject,
                      topic: topic,
                      index: topicIndex,
                      selectedTopics: _selectedTopics,
                    );
                  },
                ),
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () async {
                if (_selectedTopics.isEmpty) {
                  return;
                }

                // Write the file
                // await File(filePath).writeAsBytes(bytes);
              },
              child: const Text("Export to other Device"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_selectedTopics.isEmpty) {
                  return;
                }

                DateTime now = DateTime.now();

                final fileName =
                    "VocabularyExport ${now.day}.${now.month}.${now.year}";

                final downloadDir = await getDownloadsDirectory();

                if (downloadDir == null) return;

                final savePath = '${downloadDir.path}/$fileName.zip';
                final loadDir = await SubjectManager.getSubjectsSaveDir();
                // final loadFile = File(loadDir.path);
                if (!loadDir.existsSync()) return;

                var encoder = ZipFileEncoder();
                encoder.zipDirectory(loadDir, filename: savePath,
                    onProgress: (value) {
                  print(value);
                });

                File out = File(savePath);
                if (!out.existsSync()) return;
                final result = await Share.shareXFiles([XFile(out.path)],
                    text: "Share you StudyCards!");
                if (result.status == ShareResultStatus.success && mounted) {
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Export and Share"),
            ),
          ],
        ),
        const Spacer(),
      ],
    );
  }

  // Future<void> _createZipFile(String zipFilePath, List<File> files) async {
  //   final archive = Archive();

  //   // Add each file to the archive
  //   for (final file in files) {
  //     final fileData = await file.readAsBytes();
  //     archive.addFile(ArchiveFile(file.path, fileData.length, fileData));
  //   }

  //   final encodedArchive = ZipEncoder().encode(archive);

  //   if (encodedArchive == null) {
  //     return;
  //   }
  //   // Open the zip file for writing
  //   final zipFile = File(zipFilePath).openWrite();

  //   // Write the archive to the zip file
  //   zipFile.add(Uint8List.fromList(encodedArchive));

  //   await zipFile.flush();

  //   // Close the zip file
  //   await zipFile.close();
  // }

  Widget _listTopicExpansionTileBuilder(Subject subject, int index) {
    Topic topic = subject.topics[index];

    return ExpansionTile(
      leading: Icon(
        Icons.circle,
        color: topic.color,
      ),
      tilePadding: const EdgeInsetsDirectional.symmetric(horizontal: 16),
      // collapsedBackgroundColor: subject.color,
      title: Text(
        topic.name,
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
    );
  }

  Text _getTitleText() {
    switch (_currentMode) {
      case Mode.import:
        return const Text("Select topics to Import");
      case Mode.export:
        return const Text("Select topics to Export");
      case Mode.none:
        return const Text("Import / Export");
    }
  }
}

class ExportTopicListItem extends StatefulWidget {
  List<String> selectedTopics = [];
  Subject subject;
  Topic topic;
  int index;

  ExportTopicListItem({
    super.key,
    required this.subject,
    required this.topic,
    required this.index,
    required this.selectedTopics,
  });

  @override
  State<ExportTopicListItem> createState() => ExportTopicStateListItem();
}

class ExportTopicStateListItem extends State<ExportTopicListItem> {
  bool switchValue = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        leading: Icon(
          Icons.circle,
          color: widget.topic.color,
        ),
        title: Text(widget.topic.name),
        trailing: Switch(
          value: switchValue,
          onChanged: (value) {
            switchValue = value;
            setState(() {});
            if (value) {
              widget.selectedTopics
                  .add("${widget.subject.name}/${widget.topic.name}");
            } else {
              widget.selectedTopics
                  .remove("${widget.subject.name}/${widget.topic.name}");
            }
          },
        ),
      ),
    );
  }
}
 // //if it does not exists then create a new Subject

                      // if (importSubject == null) {
                      //   importSubject = loadedSubjects.firstWhere(
                      //       (element) => element.name == subjectName);

                      //   for (Topic topic in importSubject.topics) {
                      //     for (int i = 0; i < topic.studyCards.length; i++) {
                      //       StudyCard studyCard = topic.studyCards[i];
                      //       studyCard.learningScore = -3;
                      //       studyCard.lastAnswer = StudyCardStatus.none;
                      //       studyCard.index = i;
                      //     }
                      //   }
                      //   SubjectManager.addSubject(
                      //     importSubject,
                      //     saveTopics_: true,
                      //     saveStudyCards_: true,
                      //   );

                      //   continue;
                      // } else {
                      //   Subject loadedSubject = loadedSubjects.firstWhere(
                      //       (element) => element.name == subjectName);

                      //   for (Topic topic in loadedSubject.topics) {
                      //     if(importSubject.topics.any((element) => element.name==topicName)){
                      //       //test if topic already exists
                      //     } else {
                      //       //if not set from loaded
                      //       importSubject.
                      //     }
                      //   }
                      //loadedSubjects
                      // .firstWhere((element) => element.name == subjectName);

                      //test if the topic already exists
                      // for (int i = 0; i < importSubject.topics.length; i++) {
                      //   Topic currTopic = importSubject.topics[i];
                      //   if (topicName == currTopic.name) {
                      //     importTopic = currTopic;
                      //     break;
                      //   }
                      // }

                      // try {
                      //   importTopic ??= loadedSubjects
                      //       .firstWhere(
                      //           (element) => element.name == subjectName)
                      //       .topics
                      //       .firstWhere((element) => element.name == topicName);

                      //   int len = importTopic.studyCards.length;
                      //   for (int i = 0;
                      //       i < importTopic.studyCards.length;
                      //       i++) {
                      //     StudyCard studyCard = importTopic.studyCards[i];
                      //     studyCard.index = len + i;
                      //     studyCard.lastAnswer = StudyCardStatus.none;
                      //     studyCard.learningScore = -3; //TODO
                      //     importTopic.studyCards.add(studyCard);
                      //   }

                      //   SubjectManager.addSubject(
                      //     Subject(name: subjectName),
                      //     saveTopics_: true,
                      //     saveStudyCards_: true,
                      //   );
                      // } catch (e) {
                      //   print(e);
                      // }