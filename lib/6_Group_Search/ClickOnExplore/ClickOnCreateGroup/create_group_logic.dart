import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'create_group_ui.dart';

//TODO Gruppen werden dobbelt ge-POST-tet
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends State<CreateGroupPage> {

  /// flag for preventing multiple uploads
  bool uploading = false;

  /// adds a ChangeNotifierProvider to the build
  @override
  Widget build(BuildContext context) {
    final state = this;
    return ChangeNotifierProvider<CreateGroupNotifier>(
      create: (_) {
      return CreateGroupNotifier();
      },
        builder: ((context, child) => CreateGroupUI(state: state))
    );
  }

  /// when the slider is moved the value is registered in the Provider to trigger a rebuild of the slider widget
  void sliderOnChange(double value, BuildContext context) {
    Provider.of<CreateGroupNotifier>(context, listen: false).setSliderValue(value);
  }

  /// Tries to create the Group with the context given in the input fields
  /// TODO input values checked for constrains. What are the Constraines?
  void createGroup(BuildContext context) {
    if (!uploading) {
      try{
        uploading = true;
        final controller1 = Provider
            .of<CreateGroupNotifier>(context, listen: false)
            .getText1;
        final controller2 = Provider
            .of<CreateGroupNotifier>(context, listen: false)
            .getText2;
        final controller3 = Provider
            .of<CreateGroupNotifier>(context, listen: false)
            .getText3;
        final image = Provider
            .of<CreateGroupNotifier>(context, listen: false)
            .getImage;
        final sliderValue = Provider
            .of<CreateGroupNotifier>(context, listen: false)
            .getSliderValue;
        if (controller1.text.isNotEmpty && controller2.text.isNotEmpty &&
            image != null) {
          FetchGroups.postGroup(
              controller1.text, controller2.text, image, sliderValue.toInt(), controller3.text == "" ? null : controller3.text)
              .then((group) {
            if (group != null) {
              Provider.of<ClusterNotifier>(context, listen: false).addGroup(
                  group);
              Navigator.pop(context);
            }
          });
        }
      } finally{
        uploading = false;
      }
    }
  }

}

