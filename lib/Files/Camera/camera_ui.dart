import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Camera/camera_logic.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

import '../Other/global.dart' as global;


class CameraPageUI extends StatefulUI<CameraPage, CameraPageState>{

  const CameraPageUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
              height: MediaQuery.of(context).viewPadding.top
          ),
          FutureBuilder<void>(
            future: state.initializeControllerFuture(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                  return GestureDetector(
                      onScaleStart: (_) => state.basScaleFactor = state.scaleFactor,
                      onScaleUpdate: (details) => state.handleZoom(details),
                      child: getContainer(child: CameraPreview(state.controller), context: context)
                );
              } else {
                //TODO show better camera preview
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ],
      ),
      floatingActionButton: Stack(
        children: [
          GestureDetector(
            onTap: () => state.takePicture(),
            child: Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white,width: 2.0),
                  shape: BoxShape.circle
              ),
              height: 100,
            ),
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget getContainer({required Widget child, required BuildContext context}) {
    return SizedBox(
      height: state.getHeight(),
      width:  state.getWidth(),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: child,
      ),
    );
  }
}