import 'dart:ui';

import 'package:flutter/material.dart';

class StudyCardProgressBar extends StatefulWidget {
  late double notSetPercent;
  late double unknownPercent;
  late double notSurePercent;
  late double knownPercent;
  late double ezKnownPercent;

  late double widthOfCanvas;

  StudyCardProgressBar({
    super.key,
    required int notSetCardCount,
    required int unknownCardsCount,
    required int notSureCardCount,
    required int knownCardCount,
    required int ezKnownCardCount,
  }) {
    int totalCount = notSetCardCount +
        unknownCardsCount +
        notSureCardCount +
        knownCardCount +
        ezKnownCardCount;
    notSetPercent = notSetCardCount / totalCount;
    unknownPercent = unknownCardsCount / totalCount;
    notSurePercent = notSureCardCount / totalCount;
    knownPercent = knownCardCount / totalCount;
    ezKnownPercent = ezKnownCardCount / totalCount;
  }

  @override
  State<StudyCardProgressBar> createState() => _StudyCardProgressBarState();
}

class _StudyCardProgressBarState extends State<StudyCardProgressBar> {
  double containerMargin = 8;
  double containerWidth = 0;

  @override
  Widget build(BuildContext context) {
    containerWidth = MediaQuery.of(context).size.width -
        containerMargin * 2; //because of left and right..

    return Container(
      margin: EdgeInsets.all(containerMargin),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 15,
          width: double.infinity,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: Colors.grey,
                height: 15,
                width: getGreyWidth(),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: Colors.red,
                height: 15,
                width: getRedWidth(),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: Colors.yellow,
                height: 15,
                width: getYellowWidth(),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: Colors.green,
                height: 15,
                width: getGreenWidth(),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                color: Colors.blue,
                height: 15,
                width: getBlueWidth(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double getGreyWidth() {
    return getSizeFromPercent(widget.notSetPercent);
  }

  double getRedWidth() {
    return getSizeFromPercent(widget.unknownPercent);
  }

  double getYellowWidth() {
    return getSizeFromPercent(widget.notSurePercent);
  }

  double getGreenWidth() {
    return getSizeFromPercent(widget.knownPercent);
  }

  double getBlueWidth() {
    return getSizeFromPercent(widget.ezKnownPercent);
  }

  double getSizeFromPercent(double percent) {
    return lerpDouble(0, containerWidth, percent) ?? 0;
  }
}
