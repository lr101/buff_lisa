import 'package:buff_lisa/7_Settings/HiddenPins/hidden_pin_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:buff_lisa/Providers/hidden_pin_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Files/Widgets/CustomSliverList/custom_easy_title.dart';
import '../../Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import '../../Files/Widgets/custom_list_tile.dart';

class HiddenPinUI extends StatefulUI<HiddenPin, HiddenPinState> {

  const HiddenPinUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    Set<Pin> pins = Provider.of<HiddenPinPageNotifier>(context).pins;
    return Scaffold(appBar: null,
        body: CustomTitle(
          title: const CustomEasyTitle(
            title: Text("Hidden Users"),
            back: true,
          ),
          sliverList: CustomSliverList(
              itemCount: pins.length,
              itemBuilder: (index) => CustomListTile(
                leading: Text("${index + 1}."),
                title: Text("Post by: ${pins.elementAt(index).username}"),
                trailing: SizedBox(
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed:() => state.showDialogImage(pins.elementAt(index)),
                          child: const Text("show image"),
                        ),
                        TextButton(
                          onPressed:() => state.unHidePin(pins.elementAt(index)),
                          child: const Text("add"),
                        ),
                      ],
                    )
                )
              )
          ),
        )
    );
  }
}