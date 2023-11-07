import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path/path.dart' as path;
import 'package:rxdart/rxdart.dart' as rx;
import 'package:vocabulary_trainer/code_behind/pair.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/subject.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';

class SubjectManager {
  // ignore: constant_identifier_names
  static const SUBJECTS_SAVE_DIR_NAME = "/subjects/";
  // ignore: constant_identifier_names
  static const LEARNING_TOPICS_SAVE_DIR_NAME = "/learningTopics/";
  // ignore: constant_identifier_names
  static const LEARNING_TOPICS_SAVE_FILE_NAME = "learningTopics.LNT";
  // ignore: constant_identifier_names
  static const STUDY_CARDS_SAVE_DIR_NAME =
      "studyCardsToLearn/"; //die StudyCards die man lernen muss
  // ignore: constant_identifier_names
  static const SUBJECT_EXTENSION = ".SUB";
  // ignore: constant_identifier_names
  static const TOPIC_EXTENSION = ".TOP";
  // ignore: constant_identifier_names
  static const STUDY_CARD_EXTENSION = ".STC";

  //nicht schön aber selten sollte ich nochmal überarbeiten z.B. als eine List<String> oder List<Pair<String, String>>
  // static Map<String, Pair<Subject, Topic>> learningTopics = {};

  static List<Subject> subjects = [];
  // static Directory? _appDataDir = null;
  // static get Directory appDataDir;

  static final rx.BehaviorSubject<Subject> subjectStream =
      rx.BehaviorSubject<Subject>();

  static final rx.BehaviorSubject<Pair<Subject, Topic>> topicStream =
      rx.BehaviorSubject<Pair<Subject, Topic>>();

  static final rx.BehaviorSubject<Pair<Topic, StudyCard>> studyCardStream =
      rx.BehaviorSubject<Pair<Topic, StudyCard>>();

  // static String _getLearningTopicsKey(Subject subject, Topic topic) {
  //   return "${subject.name}/${topic.name}";
  // }

  // static void addLearningTopic(
  //   Subject subject,
  //   Topic topic,
  // ) {
  //   Pair<Subject, Topic> pair = Pair(subject, topic);
  //   learningTopics[_getLearningTopicsKey(subject, topic)] = pair;
  //   saveLearningTopics();
  // }

  // static void removeLearningTopicAt(Subject subject, Topic topic) {
  //   // Pair<Subject, Topic>? pair =
  //   learningTopics.remove(_getLearningTopicsKey(subject, topic));

  //   saveLearningTopics();
  // }

  // static Map<String, dynamic> _getLearningTopicsMapAsJson() {
  //   Map<String, dynamic> json = {};

  //   for (String key in learningTopics.keys) {
  //     Pair<Subject, Topic>? pair = learningTopics[key];
  //     if (pair == null) continue;

  //     json.addAll(
  //       {
  //         key: {
  //           "first": pair.first.name,
  //           "second": pair.second.name,
  //         },
  //       },
  //     );
  //   }

  //   return json;
  // }

  // static Future<void> loadLearningTopics() async {
  //   final saveDir = await getLearningTopicsSaveDir();

  //   File saveFile = File(saveDir.path + LEARNING_TOPICS_SAVE_FILE_NAME);

  //   if (!saveFile.existsSync()) {
  //     return;
  //   }

  //   String loadString = saveFile.readAsStringSync();

  //   Map<String, dynamic> json = jsonDecode(loadString);

  //   _setLearningTopicsFromJson(json);
  // }

  // static void _setLearningTopicsFromJson(Map<String, dynamic> json) {
  //   learningTopics = {};

  //   for (String key in json.keys) {
  //     Map<String, dynamic> pairJson = json[key];
  //     Pair<Subject, Topic> pair = Pair(
  //       Subject(name: pairJson["first"]),
  //       Topic(name: pairJson["second"]),
  //     );
  //     learningTopics.addAll({key: pair});
  //   }
  // }

  // static Future<void> saveLearningTopics() async {
  //   final saveDir = await getLearningTopicsSaveDir();

  //   File saveFile = File(saveDir.path + LEARNING_TOPICS_SAVE_FILE_NAME);

  //   Map<String, dynamic> json = _getLearningTopicsMapAsJson();

  //   String saveString = jsonEncode(json);

  //   saveFile.writeAsStringSync(saveString);
  // }

  static List<Pair<Subject, int>> getLearningTopics() {
    List<Pair<Subject, int>> learningTopics = [];

    for (Subject subject in subjects) {
      for (int i = 0; i < subject.topics.length; i++) {
        Topic topic = subject.topics[i];
        if (!topic.isLearningTopic) continue;
        learningTopics.add(
          Pair(subject, i),
        );
      }
    }

    return learningTopics;
  }

  static void removeSubjectAt(int index) {
    Subject removedSubject = subjects.removeAt(index);
    deleteSubject(removedSubject);
  }

  static Future<void> deleteSubject(Subject subject) async {
    final saveDir = await getSubjectsSaveDir();

    final filePath = saveDir.path + subject.name + SUBJECT_EXTENSION;
    File subjectFile = File(filePath);
    final dirPath = "${saveDir.path}${subject.name}/";
    Directory subjectDir = Directory(dirPath);

    try {
      if (subjectFile.existsSync()) {
        subjectFile.deleteSync();
      }
      if (subjectDir.existsSync()) {
        subjectDir.deleteSync(recursive: true);
      }
    } catch (e) {
      print(e);
    }
  }

  static void removeTopicAt(Subject subject, int index) {
    Topic removedTopic = subject.topics.removeAt(index);
    deleteTopic(subject, removedTopic);
  }

  static Future<void> deleteTopic(Subject subject, Topic topic) async {
    final saveDir = await getTopicsSaveDir(subject);

    final filePath = saveDir.path + topic.name + TOPIC_EXTENSION;
    File topicFile = File(filePath);
    final dirPath = "${saveDir.path}${topic.name}/";
    Directory topicDir = Directory(dirPath);

    try {
      if (topicFile.existsSync()) {
        topicFile.delete();
      }
      if (topicDir.existsSync()) {
        topicDir.delete(recursive: true);
      }
    } catch (e) {
      print(e);
    }
  }

  static void addSubject(Subject subject) {
    subjects.add(subject);
    saveSubject(subject);
  }

  static void addTopic(Subject subject, Topic topic) {
    subject.topics.add(topic);
    saveTopic(subject, topic);
  }

  static Future<void> loadSubjects({bool loadTopics_ = false}) async {
    final Directory saveDir = await getSubjectsSaveDir();

    List<FileSystemEntity> subjectFiles = saveDir.listSync(
      recursive: false,
      followLinks: false,
    );

    Map<String, Subject> loadingSubjectMap = {};

    for (int i = 0; i < subjectFiles.length; i++) {
      FileSystemEntity currFileEntity = subjectFiles[i];
      if (currFileEntity is Directory && loadTopics_) {
        Directory currDir = currFileEntity;
        final currDirName = path.basename(currDir.path);

        if (loadingSubjectMap[currDirName] == null) {
          loadingSubjectMap[currDirName] = Subject(name: currDirName);
        }

        await loadTopics(loadingSubjectMap[currDirName]!);
      } else if (currFileEntity is File) {
        File currFile = currFileEntity;
        final currFileName = path.basename(currFile.path);

        final currSubjectName = currFileName.replaceAll(SUBJECT_EXTENSION, "");

        if (loadingSubjectMap[currSubjectName] == null) {
          loadingSubjectMap[currSubjectName] = Subject(name: currSubjectName);
        }

        String json = await currFile.readAsString();
        try {
          final map = jsonDecode(json);
          loadingSubjectMap[currSubjectName]!.setParamsFromJson(map);

          subjects = loadingSubjectMap.values.toList();

          subjectStream.add(loadingSubjectMap[currSubjectName]!);
        } catch (e) {
          print(e);
        }
        //load topics
      }
    }
  }

  static Future<void> loadTopics(
    Subject subject, {
    bool loadStudyCards_ = false,
  }) async {
    Directory topicSaveDir = await getTopicsSaveDir(subject);

    topicSaveDir.createSync(recursive: false);

    List<FileSystemEntity> subjectFiles = topicSaveDir.listSync(
      recursive: false,
      followLinks: false,
    );

    Map<String, Topic> loadingTopicMap = {};

    for (int i = 0; i < subjectFiles.length; i++) {
      FileSystemEntity currFileEntity = subjectFiles[i];
      if (currFileEntity is Directory && loadStudyCards_) {
        Directory currDir = currFileEntity;

        final currDirName = path.basename(currDir.path);
        final currTopicName = currDirName;

        if (loadingTopicMap[currTopicName] == null) {
          loadingTopicMap[currTopicName] = Topic(name: currTopicName);
        }

        await loadStudyCards(subject, loadingTopicMap[currTopicName]!);
      } else if (currFileEntity is File) {
        File currFile = currFileEntity;
        final currFileName = path.basename(currFile.path);

        final currTopicName = currFileName.replaceAll(TOPIC_EXTENSION, "");

        if (loadingTopicMap[currTopicName] == null) {
          loadingTopicMap[currTopicName] = Topic(name: currTopicName);
        }

        String json = await currFile.readAsString();

        try {
          final map = jsonDecode(json);
          loadingTopicMap[currTopicName]!.setParamsFromJson(map);

          subject.topics = loadingTopicMap.values.toList();

          final pair = Pair(subject, loadingTopicMap[currTopicName]!);
          topicStream.add(pair);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  static Future<void> loadStudyCards(Subject subject, Topic topic) async {
    Directory topicSaveDir = await getStudyCardDir(subject, topic);

    topicSaveDir.createSync(recursive: false);

    List<FileSystemEntity> studyCardFiles = topicSaveDir.listSync(
      recursive: false,
      followLinks: false,
    );

    Map<String, StudyCard> loadingStudyCardsMap = {};

    for (int i = 0; i < studyCardFiles.length; i++) {
      FileSystemEntity currFileEntity = studyCardFiles[i];
      if (currFileEntity is File) {
        File currFile = currFileEntity;
        final currFileName = path.basename(currFile.path);

        final currStudyCardName =
            currFileName.replaceAll(STUDY_CARD_EXTENSION, "");

        if (loadingStudyCardsMap[currStudyCardName] == null) {
          loadingStudyCardsMap[currStudyCardName] =
              StudyCard(int.parse(currStudyCardName));
        }

        String json = await currFile.readAsString();

        try {
          final map = jsonDecode(json);
          loadingStudyCardsMap[currStudyCardName]!.setParamsFromJson(map);

          topic.studyCards = loadingStudyCardsMap.values.toList();

          final pair = Pair(topic, loadingStudyCardsMap[currStudyCardName]!);
          studyCardStream.add(pair);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  static Future<Directory> getLearningTopicsSaveDir() async {
    final Directory appDocumentsDir =
        await path_provider.getApplicationDocumentsDirectory();
    final saveDirPath = appDocumentsDir.path + LEARNING_TOPICS_SAVE_DIR_NAME;
    final Directory saveDir = Directory(saveDirPath);

    saveDir.createSync();

    return saveDir;
  }

  static Future<Directory> getSubjectsSaveDir() async {
    final Directory appDocumentsDir =
        await path_provider.getApplicationDocumentsDirectory();
    final saveDirPath = appDocumentsDir.path + SUBJECTS_SAVE_DIR_NAME;
    final Directory saveDir = Directory(saveDirPath);
    saveDir.createSync();

    return saveDir;
  }

  static Future<Directory> getTopicsSaveDir(Subject subject) async {
    Directory subjectSaveDir = await getSubjectsSaveDir();
    Directory topicSaveDir =
        Directory("${subjectSaveDir.path}${subject.name}/");

    topicSaveDir.createSync();
    return topicSaveDir;
  }

  static Future<Directory> getStudyCardDir(Subject subject, Topic topic) async {
    Directory topicSaveDir = await getTopicsSaveDir(subject);
    Directory studyCardsSaveDir =
        Directory("${topicSaveDir.path}${topic.name}/");

    studyCardsSaveDir.createSync();
    return studyCardsSaveDir;
  }

  static Future<void> saveSubjectAt(int index) async {
    Subject currSubject = subjects[index];
    saveSubject(currSubject);
  }

  static Future<void> saveSubject(Subject currSubject,
      {bool saveTopics_ = false}) async {
    final Directory saveDir = await getSubjectsSaveDir();

    Map<String, dynamic> json = currSubject.toJson();

    File subjectFile =
        File(saveDir.path + currSubject.name + SUBJECT_EXTENSION);

    await subjectFile.writeAsString(jsonEncode(json));

    Directory topicsDir = Directory("${saveDir.path}${currSubject.name}/");
    topicsDir.create();

    if (!saveTopics_) {
      return;
    }

    for (int i = 0; i < currSubject.topics.length; i++) {
      await saveTopicAt(currSubject, i);
    }
  }

  static Future<void> saveTopic(
    Subject subject,
    Topic currTopic, {
    bool saveStudyCards = false,
  }) async {
    Directory topicSaveDir = await getTopicsSaveDir(subject);

    Map<String, dynamic> json = currTopic.toJson();

    File topicFile = File(topicSaveDir.path + currTopic.name + TOPIC_EXTENSION);
    await topicFile.writeAsString(jsonEncode(json));

    if (currTopic.studyCards.isNotEmpty) {
      Directory topicsDir = Directory("${topicSaveDir.path}${currTopic.name}/");
      topicsDir.create();
    }
    if (!saveStudyCards) {
      return;
    }
    for (int i = 0; i < currTopic.studyCards.length; i++) {
      await saveStudyCardAt(subject, currTopic, i);
    }
  }

  static Future<void> saveTopicAt(Subject subject, int index,
      {bool saveStudyCards = false}) async {
    Topic currTopic = subject.topics[index];
    return saveTopic(subject, currTopic);
  }

  static Future<void> saveStudyCardAt(
      Subject subject, Topic topic, int index) async {
    StudyCard studyCard = topic.studyCards[index];

    final Directory saveDir = await getStudyCardDir(subject, topic);

    Map<String, dynamic> json = studyCard.toJson();

    File studyCardFile =
        File(saveDir.path + index.toString() + STUDY_CARD_EXTENSION);

    await studyCardFile.writeAsString(jsonEncode(json));
  }

  static Future<void> removeStudyCardAt(
      Subject subject, Topic topic, int index) async {
    topic.studyCards.removeAt(index);

    final saveDir = await getStudyCardDir(subject, topic);

    final filePath = saveDir.path + index.toString() + STUDY_CARD_EXTENSION;
    File studyCardFile = File(filePath);

    try {
      if (studyCardFile.existsSync()) {
        studyCardFile.deleteSync();
      }
      //da sich der Index ändert wenn man eine StudyCard löscht müssen wir neue zuweisen und die jeweiligen Datein umbenennen
      for (int i = index; i < topic.studyCards.length; i++) {
        await setNewStudyCardIndex(subject, topic, i, i,
            deleteOldFile: i == topic.studyCards.length - 1);
      }
    } catch (e) {
      print(e);
    }
  }

  static Future<void> setNewStudyCardIndex(
    Subject subject,
    Topic topic,
    int oldIndex,
    int newIndex, {
    bool deleteOldFile = true,
  }) async {
    int oldFileIndex = topic.studyCards[oldIndex].index;

    topic.studyCards[oldIndex].index = newIndex;

    StudyCard studyCard = topic.studyCards[oldIndex];

    //copy file from old index to new index
    //delete old index file

    final Directory saveDir = await getStudyCardDir(subject, topic);

    Map<String, dynamic> json = studyCard.toJson();

    File studyCardFile =
        File(saveDir.path + newIndex.toString() + STUDY_CARD_EXTENSION);

    studyCardFile.writeAsStringSync(jsonEncode(json));

    if (deleteOldFile) {
      File oldStudyCardFile =
          File(saveDir.path + oldFileIndex.toString() + STUDY_CARD_EXTENSION);

      if (oldStudyCardFile.existsSync()) {
        oldStudyCardFile.deleteSync();
      }
    }
  }

  static void addStudyCard(Subject subject, Topic topic, StudyCard studyCard) {
    topic.studyCards.add(studyCard);
    int index = topic.studyCards.length - 1;
    saveStudyCardAt(subject, topic, index);
  }

  static Future<void> renameSubjectAt(int index, String newName) async {
    Subject currSubject = subjects[index];
    return renameSubject(currSubject, newName);
  }

  //sets subject.name renames file and then saves it
  static Future<void> renameSubject(Subject currSubject, String newName) async {
    String oldName = currSubject.name;

    currSubject.setName(newName);

    Directory saveDir = await getSubjectsSaveDir();

    File currSubjectFile = File(saveDir.path + oldName + SUBJECT_EXTENSION);
    Directory currSubjectDir = Directory("${saveDir.path}$oldName/");

    if (currSubjectFile.existsSync()) {
      currSubjectFile
          .renameSync(saveDir.path + currSubject.name + SUBJECT_EXTENSION);

      saveSubject(currSubject);
    }

    if (currSubjectDir.existsSync()) {
      currSubjectDir.renameSync("${saveDir.path}${currSubject.name}/");
    }
  }

  static Future<void> renameTopicAt(
      Subject subject, int index, String name) async {
    Topic currTopic = subject.topics[index];
    return renameTopic(subject, currTopic, name);
  }

  //sets subject.name renames file and then saves it
  static Future<void> renameTopic(
      Subject subject, Topic currTopic, String newName) async {
    String oldName = currTopic.name;

    currTopic.setName(newName);

    Directory topicSaveDir = await getTopicsSaveDir(subject);

    File currTopicFile = File(topicSaveDir.path + oldName + TOPIC_EXTENSION);
    Directory currTopicDir = Directory("${topicSaveDir.path}$oldName/");

    if (currTopicFile.existsSync()) {
      currTopicFile
          .renameSync(topicSaveDir.path + currTopic.name + TOPIC_EXTENSION);

      saveTopic(subject, currTopic);
    }

    if (currTopicDir.existsSync()) {
      currTopicDir.renameSync("${topicSaveDir.path}${currTopic.name}/");
    }
  }
}
