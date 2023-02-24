import 'dart:typed_data';

import 'package:buff_lisa/6_Group_Search/ClickOnGroup/ClickOnEdit/edit_group_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

//TODO Gruppen werden dobbelt ge-POST-tet
class EditGroupPage extends StatefulWidget {
  const EditGroupPage({super.key, required this.group});

  final Group group;

  @override
  EditGroupPageState createState() => EditGroupPageState();
}

class EditGroupPageState extends State<EditGroupPage> {

  @override
  late BuildContext context;

  /// adds a ChangeNotifierProvider to the build
  @override
  Widget build(BuildContext context) {
    final state = this;
    return ChangeNotifierProvider<CreateGroupNotifier>(
      create: (_) {
        return CreateGroupNotifier();
      },
        builder: ((context, child) {
          this.context = context;
          return EditGroupUI(state: state);
        })
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      Provider.of<CreateGroupNotifier>(context, listen: false).init(widget.group);
    });
  }



  /// when the slider is moved the value is registered in the Provider to trigger a rebuild of the slider widget
  void sliderOnChange(double value, BuildContext context) {
    Provider.of<CreateGroupNotifier>(context, listen: false).setSliderValue(value);
  }

  /// Tries to create the Group with the context given in the input fields
  /// TODO input values checked for constrains. What are the Constraines?
  void editGroup(BuildContext context) {
    final controller1 = Provider.of<CreateGroupNotifier>(context, listen: false).getText1IfChanged;
    final controller2 = Provider.of<CreateGroupNotifier>(context, listen: false).getText2IfChanged;
    Uint8List? image = Provider.of<CreateGroupNotifier>(context, listen: false).getImageIfChanged;
    final sliderValue = Provider.of<CreateGroupNotifier>(context, listen: false).getSliderValueIfChanged;
    final groupAdmin = Provider.of<CreateGroupNotifier>(context, listen: false).getAdminIfChanged;
    if (( controller1 == null || controller1.text.isNotEmpty) && (controller2 == null || controller2.text.isNotEmpty)) {
      FetchGroups.putGroup(widget.group.groupId, controller1?.text, controller2?.text, image, sliderValue, groupAdmin).then((group) {
        if (group != null) {
          Provider.of<ClusterNotifier>(context, listen:false).updateGroup(widget.group, group);
          Navigator.pop(context);
        }
      });
    }
  }

  void close() {
    Navigator.pop(context);
  }

}

