import 'dart:typed_data';

import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/Other/global.dart' as global;

class CameraUI extends StatefulUI<CameraWidget, CameraControllerWidget> {

  const CameraUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height - global.barHeight,
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  height: MediaQuery.of(context).viewPadding.top
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height - global.barHeight) * 0.8,
                child: FutureBuilder<void>(
                  future: state.initializeControllerFuture(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return GestureDetector(
                          onDoubleTap: () => state.handleCameraChange(context),
                          onScaleStart: (_) => state.basScaleFactor = state.scaleFactor,
                          onScaleUpdate: (details) => state.handleZoom(details),
                          child: SizedBox(
                            height: state.getHeight(),
                            width:  state.getWidth(),
                            child: Padding(
                              padding: const EdgeInsets.all(5.0),
                              child: CameraPreview(state.controller),
                            ),
                          )
                      );
                    } else {
                      //TODO show better camera preview
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height - global.barHeight) * 0.15,
                child: Stack(
                  children: [
                    Center(
                      child: PageView.builder(
                          itemCount: state.groups.length,
                          controller: PageController(viewportFraction: 0.3),
                          onPageChanged: (index) => state.onPageChange(index, context),
                          itemBuilder: (context, i) => groupCard(context, i)
                      ),
                    ),
                    GestureDetector(
                      onTap: () => state.takePicture(context),
                      child: Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white,width: 2.0),
                            shape: BoxShape.circle
                        ),
                        height: (MediaQuery.of(context).size.height - global.barHeight) * 0.15,
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        )
      );
    }

  /// returns the page view item widget
  /// returns a round representation (profile image) of the group identified by [index]
  Widget groupCard(BuildContext context,int index) {
    Group group = state.groups[index];
    Color color = Colors.grey;
    return Padding(
        padding: const EdgeInsets.all(5),
        child: CircleAvatar(
          radius: 35,
          backgroundColor: color,
          child: FutureBuilder<Uint8List>(
            future: group.getProfileImage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return CircleAvatar(backgroundImage: Image.memory(snapshot.data!).image, radius: (MediaQuery.of(context).size.height - global.barHeight) * 0.06,);
              } else {
                return CircleAvatar(backgroundColor: Colors.grey, radius: (MediaQuery.of(context).size.height - global.barHeight) * 0.06,);
              }
            },
          ),
        )
    );
  }
}