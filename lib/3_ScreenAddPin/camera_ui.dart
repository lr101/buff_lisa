import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Camera/camera_logic.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../Files/Other/global.dart' as global;

class CameraUI extends StatefulUI<CameraWidget, CameraControllerWidget> {

  const CameraUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height - global.barHeight,
        child: CameraPage(
          onImage:(image) =>  state.handlePictureTaken(image, state.widget.io,),
          resolution: ResolutionPreset.medium,
        ),
      );
    }
}