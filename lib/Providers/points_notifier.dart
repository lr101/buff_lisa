import 'package:flutter/material.dart';

class PointsNotifier extends ChangeNotifier {
  int _userPoints = 0;
  int _numAll = 0;

  int get getUserPoints {
    return _userPoints;
  }

  int get getNumAll {
    return _numAll;
  }

  void incrementNumAll() {
    _numAll++;
    notifyListeners();
  }

  void decrementNumAll() {
    _numAll--;
    notifyListeners();
  }

  void setNumAll(int num) {
    _numAll = num;
    notifyListeners();
  }

  void incrementPoints() {
    _userPoints++;
    notifyListeners();
  }

  void decrementPoints() {
    _userPoints--;
    notifyListeners();
  }
}