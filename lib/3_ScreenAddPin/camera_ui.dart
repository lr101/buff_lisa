import 'dart:typed_data';

import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Providers/camera_icon_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CameraUI extends StatefulUI<CameraWidget, CameraControllerWidget> {

  const CameraUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(appBar: null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
             Expanded(
                child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: FutureBuilder<void>(
                          future: state.initializeControllerFuture(context),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.done && state.init) {
                              return GestureDetector(
                                  onDoubleTap: () => state.handleCameraChange(context),
                                  onScaleStart: (_) => state.basScaleFactor = state.scaleFactor,
                                  onScaleUpdate: (details) => state.handleZoom(details),
                                  child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: CameraPreview(state.controller),
                                  )
                              );
                            } else {
                              //TODO show better camera preview
                              return const Center(child: CircularProgressIndicator());
                            }
                          },
                        ),
                      ),
                      Align(
                          alignment: Alignment.topRight,
                          child: Consumer<CameraIconNotifier>(
                            builder: (context, value, child) {
                              return Padding(
                                  padding:const EdgeInsets.all(10),
                                  child: Column(
                                    children: [
                                         FloatingActionButton(
                                          backgroundColor:  Provider.of<ThemeNotifier>(context).getCustomTheme.c1,
                                          heroTag: "cameraBtnFlash",
                                          onPressed: state.switchFlash,
                                          child: value.getFlashIcon(),
                                        ),
                                        const SizedBox(height: 5,),
                                        FloatingActionButton(
                                          backgroundColor:  Provider.of<ThemeNotifier>(context).getCustomTheme.c1,
                                          heroTag: "cameraSwitch",
                                          onPressed: () => state.handleCameraChange(context),
                                          child: const Icon(Icons.switch_camera),
                                        )
                                      ],
                                    )
                                  );
                            },
                          )
                      )
                    ],
                  ),
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height) * 0.15,
                child: Stack(
                  children: [
                    Center(
                      child: PageView.builder(
                          itemCount: state.groups.length,
                          controller: state.pageController,
                          onPageChanged: (index) => state.onPageChange(index, context),
                          itemBuilder: (context, i) => groupCard(context, i)
                      ),
                    ),
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 3.0, color: Provider.of<ThemeNotifier>(context).getCustomTheme.c1),
                              shape: BoxShape.circle,
                          ),
                          height: (MediaQuery.of(context).size.height) * 0.15,
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
        child: GestureDetector(
          onTap: () => state.takePicture(context, index),
          child: CircleAvatar(
            radius: (MediaQuery.of(context).size.height) * 0.065,
            backgroundColor: color,
            child: FutureBuilder<Uint8List>(
              future: group.profileImage.asyncValue(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CircleAvatar(backgroundImage: Image.memory(snapshot.data!).image, radius: (MediaQuery.of(context).size.height) * 0.06,);
                } else {
                  return CircleAvatar(backgroundColor: Colors.grey, radius: (MediaQuery.of(context).size.height) * 0.06,);
                }
              },
            ),
          )
        )
    );
  }
}