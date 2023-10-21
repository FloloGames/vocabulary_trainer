import 'package:flutter/material.dart';

class EditableTextWidget extends StatefulWidget {
  final String initialText;
  final Function(String) onTextSaved;

  EditableTextWidget({required this.initialText, required this.onTextSaved});

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
              textEditingController.text,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
    );
  }
}
