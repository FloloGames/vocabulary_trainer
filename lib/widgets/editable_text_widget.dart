import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final TextStyle textStyle;
  final String initialText;
  final String preText;
  final Function(String) onTextSaved;

  const EditableTextWidget(
      {super.key,
      required this.initialText,
      this.preText = "",
      this.textStyle = const TextStyle(),
      required this.onTextSaved});

  @override
  _EditableTextWidgetState createState() => _EditableTextWidgetState();
}

class _EditableTextWidgetState extends State<EditableTextWidget> {
  bool isEditing = false;
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController(text: widget.initialText);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isEditing = true;
        });
      },
      child: isEditing
          ? TextField(
              autofocus: true,
              style: widget.textStyle,
              textAlign: TextAlign.center,
              controller: textEditingController,
              onSubmitted: (newText) {
                setState(() {
                  isEditing = false;
                  // Handle the edited text and notify the parent
                  final editedText = textEditingController.text;
                  widget.onTextSaved(editedText);
                });
              },
            )
          : Text(
              widget.preText + textEditingController.text,
              textAlign: TextAlign.center,
              style: widget.textStyle,
            ),
    );
  }
}
