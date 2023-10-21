import 'package:vocabulary_trainer/code_behind/learning_objects.dart';

class StudyCard {
  String _name = "Subject";

  List<LearningObject> questionLearnObjects = [];
  List<LearningObject> awnserLearnObjects = [];

  StudyCard({required String name}) : _name = name;

  String get name => _name;
  void setName(String name) {
    _name = name;
  }
}
