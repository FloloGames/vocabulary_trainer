import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:vocabulary_trainer/code_behind/study_card.dart';
import 'package:vocabulary_trainer/code_behind/topic.dart';
import 'package:vocabulary_trainer/widgets/EditableTextWidget.dart';

class StudyCardEditor extends StatefulWidget {
  StudyCard studyCard;
  Topic parentTopic;
  StudyCardEditor(
      {super.key, required this.studyCard, required this.parentTopic});

  @override
  State<StudyCardEditor> createState() => _StudyCardEditorState();
}

class _StudyCardEditorState extends State<StudyCardEditor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: const Color.fromARGB(127, 127, 127, 127),
        backgroundColor: const Color.fromARGB(127, 127, 127, 127),
        title: Row(
          children: [
            Text("${widget.parentTopic.name} / "),
            EditableTextWidget(
              initialText: widget.studyCard.name,
              onTextSaved: (text) {
                widget.studyCard.setName(text);
                setState(() {});
              },
            ),
          ],
        ),
        actions: const [
          // IconButton(
          //   onPressed: _addNewStudyCard,
          //   icon: const Icon(Icons.add),
          // ),
        ],
      ),
      body: Center(
        child: Card(
          elevation: 0.0,
          margin: const EdgeInsets.all(16.0),
          color: Color(0x00000000),
          child: FlipCard(
            direction: FlipDirection.HORIZONTAL,
            side: CardSide.FRONT,
            flipOnTouch: true,
            speed: 1000,
            onFlipDone: (status) async {
              print("Status:");
              print(status);
            },
            front: Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF006666),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Front', style: Theme.of(context).textTheme.headline1),
                    Text('Click here to flip back',
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              ),
            ),
            back: Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFF006666),
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Back', style: Theme.of(context).textTheme.headline1),
                    Text('Click here to flip front',
                        style: Theme.of(context).textTheme.bodyText1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
