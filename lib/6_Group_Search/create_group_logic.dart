import 'dart:io';
import 'dart:math';

import 'package:buff_lisa/5_Ranking/ranking_ui.dart';
import 'package:buff_lisa/6_Group_Search/search_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:buff_lisa/Providers/create_group_notifier.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:images_picker/images_picker.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/ranking.dart';
import '../Providers/cluster_notifier.dart';
import 'create_group_ui.dart';


class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  CreateGroupPageState createState() => CreateGroupPageState();
}

class CreateGroupPageState extends State<CreateGroupPage> {
  @override
  Widget build(BuildContext context) {
    final state = this;
    return ChangeNotifierProvider<CreateGroupProvider>(
      create: (_) {
      return CreateGroupProvider();
      },
        builder: ((context, child) => CreateGroupUI(state: state))
    );
  }

  void sliderOnChange(double value, BuildContext context) {
    Provider.of<CreateGroupProvider>(context, listen: false).setSliderValue(value);
  }

  void createGroup(BuildContext context) {
    final controller1 = Provider.of<CreateGroupProvider>(context, listen: false).getText1;
    final controller2 = Provider.of<CreateGroupProvider>(context, listen: false).getText2;
    final image = Provider.of<CreateGroupProvider>(context, listen: false).getImage;
    final sliderValue = Provider.of<CreateGroupProvider>(context, listen: false).getSliderValue;
    if (controller1.text.isNotEmpty && controller2.text.isNotEmpty && image != null) {
      RestAPI.postGroup(controller1.text, controller2.text, image, sliderValue.toInt()).then((group) {
        if (group != null) {
          Provider.of<ClusterNotifier>(context, listen:false).addGroup(group);
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> handleImageUpload(BuildContext context) async {
    List<Media>? res = await ImagesPicker.pick(
      count: 1,
      pickType: PickType.image,
    );
    if (res != null && res.length == 1) {
      print(res[0].size);
      if(!mounted) return;
      Provider.of<CreateGroupProvider>(context, listen: false).setImage(File(res[0].path));
    }
  }
}

