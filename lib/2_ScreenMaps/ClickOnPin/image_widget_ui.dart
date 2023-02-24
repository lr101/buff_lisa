
import 'dart:typed_data';

import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';

import '../../Files/Widgets/custom_popup_menu_button.dart';
import 'image_widget_logic.dart';

class ImageWidgetUI extends StatefulUI<ShowImageWidget, ShowImageWidgetState> {

  const ImageWidgetUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -- title --
              CustomTitle(
                titleBar: CustomTitleBar(
                  title: "Image",
                  back: true,
                  action: getActionBar(),
                  actionBar: getOtherActionBar(),
                ),
              ),
              GestureDetector(
                onTap: state.handleOpenUserProfile,
                child: Text("username: ${state.widget.pin.username}"),
              ),
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
        )
    );
  }

  /// delete button only shown when current user is owner of pin
  CustomAction? getActionBar() {
    if(widget.pin.username == global.localData.username) {
      return CustomAction(icon: const Icon(Icons.delete), action: () => state.handleButtonPress());
    } else {
      return null;
    }
  }

  /// popup menu for hiding post when current user is NOT owner of pin
  Widget? getOtherActionBar() {
    if(widget.pin.username != global.localData.username) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
       children: [
         IconButton(onPressed: () => Navigator.pop(state.context), icon: const Icon(Icons.arrow_back)),
         const Text("Image"),
         CustomPopupMenuButton(pin: state.widget.pin, update: () async => Navigator.of(state.context).pop(),),
       ],
      );
    } else {
      return null;
    }
  }


}