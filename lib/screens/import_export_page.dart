import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';
import 'package:archive/archive_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/android_count_unlocks_manager.dart';
import 'package:vocabulary_trainer/code_behind/pair.dart';
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

  File? _selectedImportFile;

  Mode _currentMode = Mode.none; //egal welcher mode

  //id = subject.name + "/" + topic.name
  final List<String> _selectedTopics = [];

  @override
  void initState() {
    super.initState();
    SubjectManager.loadSubjects(loadTopics_: true);
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

            _selectedImportFile = selectedFile;
            print(_selectedImportFile!.path);

            _currentMode = Mode.import;
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
    return const Center(child: Text("Import Todo"));
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
                Share.shareXFiles([XFile(out.path)],
                    text: "Share you StudyCards!");
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
        return const Text("Import");
      case Mode.export:
        return const Text("Export");
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
