
import 'package:buff_lisa/Files/Widgets/CustomTitle.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
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
                  action: (widget.pin.username == global.username) ? CustomAction(icon: const Icon(Icons.delete), action: () => state.handleButtonPress()) : null,
                ),
                child: Text("username: ${state.widget.pin.username}"),
              ),
              // -- image --
              Expanded(
                  child:Padding(
                    padding: const EdgeInsets.all(10.0),
                    // enable zoom into image:
                    child: InteractiveViewer(
                        panEnabled: false,
                        boundaryMargin: const EdgeInsets.all(100),
                        minScale: 1,
                        maxScale: 4,
                        child:  widget.pin.image.getWidget()
                    )
                  )
              ),
            ]
        )
    );
  }
}