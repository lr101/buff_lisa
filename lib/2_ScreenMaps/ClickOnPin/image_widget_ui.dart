
import 'dart:typed_data';

import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';

import '../../Files/Widgets/custom_popup_menu_button.dart';
import 'image_widget_logic.dart';

class ImageWidgetUI extends StatefulUI<ShowImageWidget, ShowImageWidgetState> {

  const ImageWidgetUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    DateTime now = state.widget.pin.creationDate;
    return Scaffold(appBar: null,
        body: CustomTitle(
          title: CustomEasyTitle(
            title: const Text("Image"),
            back: true,
            right: getActionBar(),
          ),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("username: ${state.widget.pin.username}"),
                const SizedBox(height: 18,),
                Text("created on: ${now.year.toString()}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}"),
                const SizedBox(height: 18,),
                GestureDetector(
                  onTap: state.handleOpenGroup,
                  child: Text("group: ${widget.pin.group.name}", style: const TextStyle(fontStyle: FontStyle.italic),),
                ),
                // -- image --
                FutureBuilder<Uint8List>(
                  future: widget.pin.image.asyncValue(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Expanded(
                        child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: InteractiveViewer(
                              transformationController: state.controller,
                              boundaryMargin: const EdgeInsets.all(0),
                              onInteractionEnd: (ScaleEndDetails endDetails) {
                                state.controller.value = Matrix4.identity();
                              },
                              child: Image.memory(snapshot.requireData),
                            )
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator() );
                    }
                  },
                )

              ]
          ),
        )
    );
  }

  /// delete button only shown when current user is owner of pin
  CustomEasyAction getActionBar() {
    if(widget.pin.username == global.localData.username) {
      return CustomEasyAction(child: const Icon(Icons.delete), action: () => state.handleButtonPress());
    } else {
      return CustomEasyAction(child: CustomPopupMenuButton(pin: state.widget.pin, update: () async => Navigator.of(state.context).pop(),),);
    }
  }


}