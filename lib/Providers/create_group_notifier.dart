import 'dart:typed_data';
import '../Files/Other/global.dart' as global;
import 'package:buff_lisa/6_Group_Search/create_group_logic.dart';
import 'package:flutter/material.dart';

/// ChangeNotifier saving changes and information of the [CreateGroupPage] Widget
class CreateGroupNotifier with ChangeNotifier {

  /// Byte list of the image selected in the [CreateGroupPage] image selector
  Uint8List? _image;

  /// text controller of the group name input text field
  final _controller1 = TextEditingController();

  /// text controller of the group description input text field
  final _controller2 = TextEditingController();

  /// slider value of the public, private selector
  double _sliderValue = 0;

  List<DropdownMenuItem<String>> menuItems = [];

  String? currentItem = global.username;

  /// get method of the [_image]
  Uint8List? get getImage {return _image;}
  bool flagImageChange = false;

  /// get method of the [_controller1]
  TextEditingController get getText1 {return _controller1;}
  /// set method of the text inside the first text field
  void setText1(String text) {_controller1.text = text; notifyListeners();}

  /// get method of the [_controller2]
  TextEditingController get getText2 {return _controller2;}
  /// set method of the text inside the second text field
  void setText2(String text) {_controller2.text = text; notifyListeners();}

  /// get method of the [_sliderValue]
  double get getSliderValue {return _sliderValue;}

  /// set [_image] attribute by passing a byte list
  /// NOTIFIES CHANGES
  void setImage(Uint8List image2) {_image = image2;notifyListeners();}

  /// set [_sliderValue] attribute by passing a byte value
  /// 0: public
  /// 1: private
  /// 2: TODO not existing yet
  /// NOTIFIES CHANGES
  void setSliderValue(double value) {_sliderValue = value;notifyListeners();}

  void setMenuItems(List<DropdownMenuItem<String>> items) {
    menuItems = items;
    notifyListeners();
  }

}