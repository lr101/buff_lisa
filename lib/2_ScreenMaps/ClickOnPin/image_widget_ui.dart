
import 'dart:typed_data';

import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import '../../Files/Widgets/custom_popup_menu_button.dart';
import 'image_widget_logic.dart';

class ImageWidgetUI extends StatefulUI<ShowImageWidget, ShowImageWidgetState> {

  const ImageWidgetUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body:  Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // -- title --
              CustomTitle(
                titleBar: CustomTitleBar(
                  title: "Image",
                  back: true,
                  action: getActionBar(),
                ),
                child: getOtherActionBar(),
              ),
              Text("username: ${state.widget.pin.username}"),
              // -- image --
              FutureBuilder<Uint8List>(
                future: widget.pin.image.asyncValue(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Expanded(
                        child:Padding(
                            padding: const EdgeInsets.all(10.0),
                            // enable zoom into image:
                            child: InteractiveViewer(
                                panEnabled: false,
                                boundaryMargin: const EdgeInsets.all(100),
                                minScale: 1,
                                maxScale: 4,
                                child:  Image.memory(snapshot.requireData)
                            )
                        )
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

  CustomAction? getActionBar() {
    if(widget.pin.username == global.username) {
      return CustomAction(icon: const Icon(Icons.delete), action: () => state.handleButtonPress());
    } else {
      return null;
    }
  }

  Widget getOtherActionBar() {
    if(widget.pin.username != global.username) {
      return CustomPopupMenuButton(pin: state.widget.pin, update: () async => Navigator.of(state.context).pop(),);
    } else {
      return const SizedBox.shrink();
    }
  }


}