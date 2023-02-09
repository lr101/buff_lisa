import 'dart:typed_data';

import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/camera_group_notifier.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/DTOClasses/group.dart';
import '../Files/Other/global.dart' as global;
import '../Providers/camera_icon_notifier.dart';

class CameraUI extends StatefulUI<CameraWidget, CameraControllerWidget> {

  const CameraUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Stack(
                children: [
                  FutureBuilder<void>(
                      future: state.initializeControllerFuture(context),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return GestureDetector(
                              onDoubleTap: () => state.handleCameraChange(context),
                              onScaleStart: (_) => state.basScaleFactor = state.scaleFactor,
                              onScaleUpdate: (details) => state.handleZoom(details),
                              child: SizedBox(
                                height: state.getHeight(context),
                                width:  state.getWidth(context),
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
                  Align(
                   alignment: Alignment.topRight,
                   child: Consumer<CameraIconNotifier>(
                          builder: (context, value, child) {
                            return FloatingActionButton(
                                heroTag: "cameraBtnFlash",
                                backgroundColor: global.cThird,
                                onPressed: state.switchFlash,
                                child: Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: value.getFlashIcon(),
                                )
                            );
                           },
                    )
                  )
                ],
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
            future: group.profileImage.asyncValue(),
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