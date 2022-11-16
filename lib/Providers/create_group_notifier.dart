import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class CreateGroupNotifier with ChangeNotifier {

  Uint8List? image;
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  double sliderValue = 0;

  Uint8List? get getImage {return image;}
  TextEditingController get getText1 {return controller1;}
  TextEditingController get getText2 {return controller2;}
  double get getSliderValue {return sliderValue;}

  void setImage(Uint8List image) {this.image = image;notifyListeners();}
  void setSliderValue(double value) {sliderValue = value;notifyListeners();}

}