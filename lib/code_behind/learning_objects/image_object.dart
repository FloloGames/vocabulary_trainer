import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:vocabulary_trainer/code_behind/learning_objects/learning_object.dart';

class ImageObject extends LearningObject {
  // ignore: constant_identifier_names
  static const TYPE_KEY = "ImageObject";
  // ignore: constant_identifier_names
  static const IMAGE_BYTES_KEY = "image_bytes_key";
  // ignore: constant_identifier_names
  static const IMAGE_WIDTH_KEY = "image_width_key";
  // ignore: constant_identifier_names
  static const IMAGE_HEIGHT_KEY = "image_heigth_key";

  Uint8List imagePngBytes;
  int imageWidth;
  int imageHeight;

  ImageObject(
    this.imagePngBytes,
    this.imageWidth,
    this.imageHeight,
    super.alignment,
    super.parent,
  );

  @override
  void updateScale(double delta) {
    scale += delta;

    if (scale <= 0.25) {
      scale = 0.25;
    }
    if (scale >= 1) {
      scale = 1;
    }
  }

  @override
  Widget createEditingWidget() {
    double aspectRatio = imageWidth / imageHeight;
    return createAlignmentWidget(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.fromSize(
          size: Size(
            aspectRatio * imageWidth * scale,
            aspectRatio * imageHeight * scale,
          ),
          child: ImageObjectEditingWidget(
            imagePngBytes: imagePngBytes,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
          ),
        ),
      ),
    );
  }

  @override
  Widget createLearningWidget() {
    double aspectRatio = imageWidth / imageHeight;
    return createAlignmentWidget(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox.fromSize(
          size: Size(
            aspectRatio * imageWidth * scale,
            aspectRatio * imageHeight * scale,
          ),
          child: ImageObjectEditingWidget(
            imagePngBytes: imagePngBytes,
            imageWidth: imageWidth,
            imageHeight: imageHeight,
          ),
        ),
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final superMap = super.toJson();
    // superMap.addAll({
    //   TEXT_KEY: text,
    //   LearningObject.TYPE_KEY: TYPE_KEY,
    // });
    superMap[LearningObject.TYPE_KEY] = TYPE_KEY;
    superMap[IMAGE_WIDTH_KEY] = imageWidth;
    superMap[IMAGE_HEIGHT_KEY] = imageHeight;
    superMap[IMAGE_BYTES_KEY] = base64Encode(imagePngBytes);

    return superMap;
  }

  @override
  void setParamsFromJson(Map<String, dynamic> json) {
    super.setParamsFromJson(json);
    imageWidth = json[IMAGE_WIDTH_KEY];
    imageHeight = json[IMAGE_HEIGHT_KEY];
    imagePngBytes = base64Decode(json[IMAGE_BYTES_KEY]);
  }
}

class ImageObjectEditingWidget extends StatelessWidget {
  Uint8List imagePngBytes;
  int imageWidth;
  int imageHeight;
  ImageObjectEditingWidget({
    super.key,
    required this.imagePngBytes,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Image.memory(
      imagePngBytes,
      scale: 0.1,
      width: imageWidth.toDouble(),
      height: imageHeight.toDouble(),
    );
  }
}
