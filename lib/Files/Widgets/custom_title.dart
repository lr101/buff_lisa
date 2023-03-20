import 'dart:typed_data';

import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_sliver_list.dart';
import 'package:buff_lisa/Files/Widgets/custom_round_image.dart';
import 'package:flutter/material.dart';
import 'package:measured_size/measured_size.dart';
import 'package:provider/provider.dart';

import '../../9_Profile/ClickOnProfileImage/show_profile_image_logic.dart';
import '../../Providers/theme_provider.dart';
import '../Themes/custom_theme.dart';
import 'CustomSliverList/custom_easy_title.dart';

class CustomTitle extends StatefulWidget {
  const CustomTitle({
    super.key,
    this.sliverList,
    this.child,
    required this.title,
  }) : assert(sliverList != null || child != null);

  final CustomSliverList? sliverList;
  final Widget? child;
  final CustomEasyTitle title;

  @override
  CustomTitleState createState() => CustomTitleState();
}

class CustomTitleState extends State<CustomTitle> {



  @override
  Widget build(BuildContext context) {
    return Container(
        color: CustomTheme.grey,
        child: SafeArea(
           child: widget.sliverList != null ? _withList() :
             Scaffold(
               appBar: AppBar(
                 backgroundColor: Color.alphaBlend(CustomTheme.grey, Provider.of<ThemeNotifier>(context).getTheme.canvasColor),
                 leading: widget.title.leading,
                 title: widget.title.title,
                 actions: widget.title.right != null ? [widget.title.right!.build()] : null,
               ),
               body: Container(
                   color: Provider.of<ThemeNotifier>(context).getTheme.canvasColor,
                   child: widget.child
               ),
             )
        )
    );
  }

  Widget _withList() {
    return NestedScrollView(
        physics: const BouncingScrollPhysics(),
        headerSliverBuilder: (context, innerScrolled) => <Widget>[
          SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: widget.title
          )
        ],
        body: Container(
          color: Provider.of<ThemeNotifier>(context).getTheme.canvasColor,
          child: Column(children: [Expanded(child: (widget.sliverList!))])
        )
    );
  }
}
