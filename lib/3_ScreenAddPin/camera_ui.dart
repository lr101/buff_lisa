import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:camera_camera/camera_camera.dart';
import '../Files/global.dart' as global;
import 'package:flutter/material.dart';

class CameraUI extends StatefulUI<CameraWidget, CameraControllerWidget> {

  const CameraUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Container(
          color: Colors.black,
          child: Scaffold(
              body: Container(
                  constraints: const BoxConstraints(minWidth: double.infinity, maxWidth: double.infinity),
                  decoration: const BoxDecoration(
                    color: Colors.black
                  ),
                  child: SizedBox(
                      width: state.getWidth(),
                      height: state.getHeight(),
                      child: CameraCamera(
                          enableAudio: false,
                          resolutionPreset: ResolutionPreset.high,
                          onFile: (image) => state.handlePictureTaken(image.readAsBytesSync(), widget.io)
                      )
                  ),
              )
        )
      );
    }
}