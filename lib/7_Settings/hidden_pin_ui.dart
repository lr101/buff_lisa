import 'package:buff_lisa/7_Settings/hidden_pin_logic.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../Files/AbstractClasses/abstract_widget_ui.dart';
import '../Files/Widgets/CustomTitle.dart';
import '../Providers/cluster_notifier.dart';
import '../Providers/hidden_pin_page.dart';

class HiddenPinUI extends StatefulUI<HiddenPin, HiddenPinState> {

  const HiddenPinUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    Set<Pin> pins = Provider.of<HiddenPinPageNotifier>(context).pins;
    return Scaffold(
        body: ListView.builder(
          itemCount: pins.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return const CustomTitle(
                title: "Hidden Posts",
                back: true,
              );
            }
            index--;
            return Card(
              child: ListTile(
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
              ),
            );
          },
        )
    );
  }
}