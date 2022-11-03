
import 'dart:io';

import 'package:buff_lisa/Providers/toggle_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/global.dart' as global;
import 'check_image_ui.dart';

class CheckImageWidget extends StatefulWidget {
  const CheckImageWidget({Key? key, this.image}) : super(key: key) ;
  final File? image;

  @override
  State<StatefulWidget> createState() => StateCheckImageWidget();
}


class StateCheckImageWidget extends State<CheckImageWidget>{

  @override
  Widget build(BuildContext context)  => CheckImageIU(state: this);

  /// updates selected type by using the provider
  void handleToggle (int index) {
    Provider.of<ToggleNotifier>(context, listen: false).setSelected(index);
  }

  /// on button press of approve button
  /// returns back to the camera page with the type information selected by the user
  void handleApprove() {
    int? index = Provider.of<ToggleNotifier>(context, listen: false).getSelected;
    if (index != null) {
      Navigator.pop(context, {"approve" : true, "type": global.stickerTypes[index]});
    }
  }

  /// on button press of back button
  /// returns back to the camera
  void handleBack() {
    Navigator.pop(context, {"approve" : false});
  }

  /// builds the image widget
  Future<Widget> handleFutureImage() async{
    final bytes = await widget.image?.readAsBytes();
    return Image.memory(bytes!);
  }




}