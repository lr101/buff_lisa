import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/group.dart';

import 'package:buff_lisa/Files/DTOClasses/ranking.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/6_Group_Search/ClickOnExplore/ClickOnCreateGroup/create_group_logic.dart';
import 'package:flutter/material.dart';

/// ChangeNotifier saving changes and information of the [CreateGroupPage] Widget
class CreateGroupNotifier with ChangeNotifier {

  /// Byte list of the image selected in the [CreateGroupPage] image selector
  Uint8List? _image;
  bool _imageChange = false;

  /// text controller of the group name input text field
  final _controller1 = TextEditingController();
  late String initName;

  /// text controller of the group description input text field
  final _controller2 = TextEditingController();
  late String initDesc;

  /// slider value of the public, private selector
  double _sliderValue = 0;
  late double initPublic;

  List<DropdownMenuItem<String>> menuItems = [];

  String? currentItem = global.localData.username;
  late String initAdmin = global.localData.username;

  Future<void> init(Group group) async {
    _sliderValue = group.visibility != 0 ? 1 : 0;
    initPublic = _sliderValue;
    _controller1.text = group.name;
    initName = group.name;
    _controller2.text = await group.description.asyncValue();
    initDesc = await group.description.asyncValue();
    _image = await group.profileImage.asyncValue();
    menuItems = await getMembers(group);
    notifyListeners();
  }

  Future<List<DropdownMenuItem<String>>> getMembers(Group group) async {
    List<Ranking> members = await group.members.asyncValue();
    List<DropdownMenuItem<String>> items = [];
    for (Ranking ranking in members) {
      items.add(DropdownMenuItem(value: ranking.username,
          child: Center(child: Text(ranking.username),)));
    }
    return items;
  }

  void setCurrentItem(String username) {
    currentItem = username;
    notifyListeners();
  }

  /// get method of the [_image]
  Uint8List? get getImage {
    return _image;
  }

  /// get method of the [_controller1]
  TextEditingController get getText1 {
    return _controller1;
  }

  TextEditingController? get getText1IfChanged {
    return _controller1.text == initName ? null : _controller1;
  }

  /// set method of the text inside the first text field
  void setText1(String text) {
    _controller1.text = text;
    notifyListeners();
  }

  /// get method of the [_controller2]
  TextEditingController get getText2 {
    return _controller2;
  }

  TextEditingController? get getText2IfChanged {
    return _controller2.text == initDesc ? null : _controller2;
  }

  /// set method of the text inside the second text field
  void setText2(String text) {
    _controller2.text = text;
    notifyListeners();
  }

  /// get method of the [_sliderValue]
  double get getSliderValue {
    return _sliderValue;
  }

  double? get getSliderValueIfChanged {
    return _sliderValue != initPublic ? _sliderValue : null;
  }

  /// set [_image] attribute by passing a byte list
  /// NOTIFIES CHANGES
  void setImage(Uint8List image2) {
    _image = image2;
    _imageChange = true;
    notifyListeners();
  }

  Uint8List? get getImageIfChanged {
    return _imageChange ? _image : null;
  }

  /// set [_sliderValue] attribute by passing a byte value
  /// 0: public
  /// 1: private
  /// 2: TODO not existing yet
  /// NOTIFIES CHANGES
  void setSliderValue(double value) {
    _sliderValue = value;
    notifyListeners();
  }

  void setMenuItems(List<DropdownMenuItem<String>> items) {
    menuItems = items;
    notifyListeners();
  }

  String? get getAdminIfChanged {
    return currentItem != initAdmin ? currentItem : null;
  }

}