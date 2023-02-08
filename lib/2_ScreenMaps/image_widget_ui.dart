
import 'package:flutter/material.dart';

import '../Files/AbstractClasses/abstract_widget_ui.dart';
import '../Files/Other/global.dart' as global;
import 'image_widget_logic.dart';

class ImageWidgetUI extends StatefulUI<ShowImageWidget, ShowImageWidgetState> {

  const ImageWidgetUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: global.cThird,
          title: const Text("Image"),
          centerTitle: true,
        ),
        body:  Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width,
                  child: widget.pin.image.getWidget()
                )
              ),
              Text("username: ${state.widget.pin.username}"),
              getDelete()
            ]
        )
    );
  }

  Widget getDelete() {
    if (state.activeDelete) {
      return Align(
          alignment: Alignment.topCenter,
          child: OutlinedButton(
              onPressed: state.handleButtonPress,
              child: Text(
                "Delete",
                style: TextStyle(color: (state.activeDelete ? global.cPrime : Colors.grey)),
              )
          )
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}