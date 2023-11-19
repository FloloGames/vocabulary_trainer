import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx;
import 'package:vocabulary_trainer/code_behind/learning_objects/learning_object.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/widgets/editable_text_widget.dart';

class TextObject extends LearningObject {
  // ignore: constant_identifier_names
  static const TYPE_KEY = "TextObject";
  // ignore: constant_identifier_names
  static const TEXT_KEY = "text_key";

  String text = "text";

  TextObject(this.text, super.alignment, super.parent);

  @override
  Widget creatEditingWidget() {
    return createAlignmentWidget(
      child: TextObjectEditingWidget(
        initialText: text,
        onTextSaved: (value) {
          text = value;
          editingWidgetChangedStream.add(null);
        },
      ),
    );
  }

  @override
  Widget creatLearningWidget({Widget? child}) {
    return createAlignmentWidget(
      child: TextObjectLearningWidget(
        text: text,
      ),
    );
  }

  @override
  void setParamsFromJson(Map<String, dynamic> json) {
    super.setParamsFromJson(json);
    text = json[TEXT_KEY];
  }

  @override
  Map<String, dynamic> toJson() {
    final superMap = super.toJson();
    superMap.addAll({
      TEXT_KEY: text,
      LearningObject.TYPE_KEY: TYPE_KEY,
    });

    return superMap;
  }
}

class TextObjectEditingWidget extends StatelessWidget {
  String initialText = "";

  Function(String) onTextSaved;

  TextObjectEditingWidget(
      {super.key, required this.initialText, required this.onTextSaved});

  @override
  Widget build(BuildContext context) {
    return EditableTextWidget(
      preText: "",
      initialText: initialText,
      textStyle: const TextStyle(
        color: Colors.black,
        fontSize: 22,
      ),
      onTextSaved: onTextSaved,
    );
  }
}

class TextObjectLearningWidget extends StatelessWidget {
  String text;

  TextObjectLearningWidget({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      // "index: ${widget.studyCardList[currCardIndex].third.index}\nscore: ${widget.studyCardList[currCardIndex].third.learningScore}\n${(widget.studyCardList[currCardIndex].third.questionLearnObjects[0] as TextObject).text}",
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 22,
      ),
    );
  }
}
