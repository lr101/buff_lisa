import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:camera_camera/camera_camera.dart';
import 'package:flutter/material.dart';

class CameraUI extends StatefulUI<CameraWidget, CameraControllerWidget> {

  const CameraUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Container(
          color: Colors.black,
          child: Padding(
              padding: const EdgeInsets.all(10),
              child: Scaffold(
                  body: CameraCamera(
                      enableAudio: false,
                      resolutionPreset: ResolutionPreset.low,
                      onFile: (image) =>
                      {
                        state.handlePictureTaken(image, widget.io)
                      }
                  )
              )
          )
      );
    }
}