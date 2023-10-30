import 'package:flutter/material.dart';

enum StudyCardStatus {
  ezKnown,
  known,
  unknown,
  notSure,
  none,
}

class StudyCardProvider extends ChangeNotifier {
  bool _isDragging = false;
  StudyCardStatus _status = StudyCardStatus.none;
  Offset _position = Offset.zero;
  double _angle = 0;

  Offset get position => _position;
  bool get isDragging => _isDragging;
  double get angle => _angle;
  StudyCardStatus get status => _status;

  Size _screenSize = Size.zero;

  void setScreenSize(Size size) => _screenSize = size;
  void resetStatus() => _status = StudyCardStatus.none;

  void resetPositionAndAngle() {
    _angle = 0;
    _position = Offset.zero;
    _isDragging = true; //damit keine animation gespielt wird..
    _status = StudyCardStatus.none;
  }

  void startPosition(DragStartDetails details) {
    _isDragging = true;
    notifyListeners();
  }

  void updatePosition(DragUpdateDetails details) {
    _position += details.delta;

    _angle = 45 * _position.dx / _screenSize.width;

    _status = getStatus();

    notifyListeners();
  }

  void endPosition() {
    _isDragging = false;

    _status = getStatus();

    switch (_status) {
      case StudyCardStatus.known:
        _angle = 20;
        _position += Offset(_screenSize.width, 0);
        break;
      case StudyCardStatus.unknown:
        _angle = -20;
        _position -= Offset(_screenSize.width, 0);
        break;
      case StudyCardStatus.notSure:
        _angle = 0;
        _position += Offset(0, _screenSize.height);
        break;
      case StudyCardStatus.ezKnown:
        _angle = 0;
        _position -= Offset(0, _screenSize.height);
        break;
      default:
        _position = Offset.zero;
        _angle = 0;
    }
    notifyListeners();
  }

  StudyCardStatus getStatus() {
    double delta = 100;

    // final forceSuperlike = _position.dx.abs() < delta / 5;

    if (_position.dx >= delta) {
      return StudyCardStatus.known;
    } else if (_position.dx <= -delta) {
      return StudyCardStatus.unknown;
    } else if (_position.dy >= delta / 2) {
      return StudyCardStatus.notSure;
    } else if (_position.dy <= -delta / 2) {
      return StudyCardStatus.ezKnown;
    }
    return StudyCardStatus.none;
  }
}
