import 'dart:typed_data';

import 'package:buff_lisa/3_ScreenAddPin/camera_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:buff_lisa/Providers/camera_icon_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:snapping_page_scroll/snapping_page_scroll.dart';

import '../Files/Themes/custom_theme.dart';
import '../Providers/camera_notifier.dart';

class CameraUI extends StatefulUI<CameraWidget, CameraControllerWidget> {

  const CameraUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
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
                        alignment: FractionalOffset.bottomCenter,
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                            child: SizedBox(
                              height: 50,
                              child:  Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Consumer<CameraIconNotifier>(
                                    builder: (context, value, child) =>
                                      Padding(
                                        padding: const EdgeInsets.all(2.5),
                                        child:CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.grey.withOpacity(0.5),
                                            child: Center(child: IconButton(
                                                onPressed: state.switchFlash,
                                                icon: value.getFlashIcon()
                                            ),)
                                        ))
                                  ),
                                  ListView.builder(
                                    shrinkWrap: true,
                                      scrollDirection: Axis.horizontal,
                                      itemCount: global.cameras.length,
                                      itemBuilder: (context, index) => Padding(
                                        padding: const EdgeInsets.all(2.5),
                                          child:CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Provider.of<CameraNotifier>(context).currentCameraIndex == index ? CustomTheme.c1.withOpacity(0.8) : Colors.grey.withOpacity(0.5),
                                            child: Center(child: IconButton(
                                                onPressed: () => state.handleCameraChange(context, index),
                                                icon: global.cameras[index].lensDirection == CameraLensDirection.back ? const Icon(Icons.landscape) : const Icon(Icons.person)
                                            ),)
                                      ))
                                    ),
                                  const SizedBox.square(dimension: 45,)
                                ],),
                        ))
                      )
                    ],
                  ),
              ),
              SizedBox(
                height: (MediaQuery.of(context).size.height) * 0.15,
                child: Stack(
                  children: [
                    Center(
                      child:SnappingPageScroll(
                          controller: state.pageController,
                          onPageChanged: (index) => state.onPageChange(index, context),
                          children: List.generate(state.groups.length, (index) => groupCard(context, index),
                        ),
                      ),
                    ),
                      IgnorePointer(
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(width: 3.0, color: CustomTheme.c1),
                              shape: BoxShape.circle,
                          ),
                          height: (MediaQuery.of(context).size.height) * 0.15,
                        ),
                      )
                  ],
                ),
              ),
              const SizedBox(height: 5,)
            ],
          ),
      );
    }

  /// returns the page view item widget
  /// returns a round representation (profile image) of the group identified by [index]
  Widget groupCard(BuildContext context,int index) {
    Group group = state.groups[index];
    return Padding(
        padding: const EdgeInsets.all(5),
        child: GestureDetector(
          onTap: () => state.takePicture(context, index),
          child:  CustomRoundImage(
            size: (MediaQuery.of(context).size.height) * 0.065,
            imageCallback: group.profileImage.asyncValue,
            clickable: false,
          )
        )
    );
  }
}