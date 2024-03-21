import 'dart:math';
import 'dart:typed_data';

import 'package:buff_lisa/9_Profile/ClickOnProfileImage/show_profile_image_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Files/Widgets/custom_title.dart';
import '../../Providers/theme_provider.dart';

class ShowProfileImageUI extends StatefulUI<ShowProfileImage, ShowProfileImageState> {

  const ShowProfileImageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
      body: CustomTitle(
        title: CustomEasyTitle(
          title: Text("Profile Image", style: Provider.of<ThemeNotifier>(context).getTheme.textTheme.titleMedium),
          back: true,
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children:  [
              Expanded(
                  child: Padding(
                      padding: const EdgeInsets.all(5),
                      child:FutureBuilder<Uint8List?>(
                        future: state.widget.provide(),
                        builder: (context, snapshot) {
                          if (snapshot.data != null) {
                            return SizedBox.square(
                                dimension: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                                child: InteractiveViewer(
                                  transformationController: state.controller,
                                  boundaryMargin: const EdgeInsets.all(0),
                                  onInteractionEnd: (ScaleEndDetails endDetails) {
                                    state.controller.value = Matrix4.identity();
                                  },
                                  child: Image.memory(snapshot.requireData!),
                                )
                            );
                          } else if (snapshot.connectionState == ConnectionState.waiting){
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else {
                            return SizedBox.square(
                                dimension: min(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
                                child: widget.defaultImage
                            );
                          }
                        },
                      )
                  )
              )
            ]
        ),
      ),
    );
  }
}