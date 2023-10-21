abstract class LearningObject {
  double posX = 0;
  double posY = 0;

  LearningObject(this.posX, this.posY);

  void drawObject();
}

class TextObject extends LearningObject {
  String text = "text";

  TextObject(this.text, double posX, double posY) : super(posX, posY);

  @override
  void drawObject() {
    // TODO: implement drawObject
  }
}
