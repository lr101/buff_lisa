import 'package:flutter/material.dart';

class ToggleNotifier extends ChangeNotifier {
  late List<bool> _isSelected;
  int? _selectedIndex;

  ToggleNotifier(int length) {
    _isSelected = List.generate(length, (index) => false);
  }

  List<bool> get getIsSelected {
    return _isSelected;
  }

  int? get getSelected {
    return _selectedIndex;
  }

  void setSelected(int index) {
    if (index >= 0 && index < _isSelected.length) {
      if (_selectedIndex != null) {
        _isSelected[_selectedIndex!] = false;
      }
      _isSelected[index] = true;
      _selectedIndex = index;
    }
    notifyListeners();
  }
}