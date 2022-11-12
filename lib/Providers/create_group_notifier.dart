import 'dart:io';

import 'package:flutter/cupertino.dart';

class CreateGroupProvider with ChangeNotifier {

  File? image;
  final controller1 = TextEditingController();
  final controller2 = TextEditingController();
  double sliderValue = 0;

  File? get getImage {return image;}
  TextEditingController get getText1 {return controller1;}
  TextEditingController get getText2 {return controller2;}
  double get getSliderValue {return sliderValue;}

  void setImage(File image) {this.image = image;notifyListeners();}
  void setSliderValue(double value) {sliderValue = value;notifyListeners();}

}