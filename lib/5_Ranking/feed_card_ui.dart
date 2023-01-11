import 'dart:typed_data';

import 'package:buff_lisa/5_Ranking/feed_card_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../Files/Other/global.dart' as global;

class FeedCardUI extends StatefulUI<FeedCard, FeedCardState>{

  const FeedCardUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    state.front = state.getMapOfPin(context);
    state.back  = state.getImageOfPin(context);
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: SizedBox(
            height: width + 40,
            width: width,
            child: Column(
              children: [
                SizedBox(
                  height: 40,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.grey,
                              child: FutureBuilder<Uint8List?>(
                                  future: Provider.of<UserNotifier>(context, listen: false).getUser(state.widget.pin.username).profileImage.asyncValue(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      if (snapshot.data != null) {
                                        return CircleAvatar(backgroundImage: Image.memory(snapshot.data!).image, radius: 12,);
                                      } else {
                                        return CircleAvatar(backgroundImage: const Image(image: AssetImage("images/profile.jpg"),).image, radius: 12,);
                                      }
                                    } else {
                                      return Shimmer.fromColors(
                                          baseColor: Colors.grey.shade700,
                                          highlightColor: Colors.grey.shade900,
                                          child: const CircleAvatar(backgroundColor: Colors.white, radius: 12,)
                                      );
                                    }
                                  },
                              ),
                          ),
                          Text(" ${widget.pin.username} in '${widget.pin.group.name}'")
                        ]
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(formatTime()),
                          menuButton(
                              menu: PopupMenuButton(
                                  itemBuilder: (context){
                                    return [
                                      const PopupMenuItem<int>(
                                        value: 0,
                                        child: Text("Hide this user"),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 1,
                                        child: Text("Hide this post"),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 2,
                                        child: Text("Report this user"),
                                      ),
                                      const PopupMenuItem<int>(
                                        value: 3,
                                        child: Text("Report this post"),
                                      ),
                                    ];
                                  },
                                  onSelected:(value){
                                    switch (value) {
                                      case 0: state.handleHideUsers(context);break;
                                      case 1: state.handleHidePost(context);break;
                                      case 2: state.handleReportUser(context);break;
                                      case 3: state.handleReportPost(context);break;
                                    }
                                  }
                              ),
                          )
                        ],
                      )
                    ],
                  )
                ),
                FlipCard(
                  controller: state.controller,
                  fill: Fill.fillBack,
                  direction: FlipDirection.HORIZONTAL, // default
                  front: state.front,
                  back: state.back,
                  flipOnTouch: false,
                )
              ],
            )
        )
    );
  }

  Widget menuButton({required Widget menu}) {
    if (global.username != state.widget.pin.username) {
      return menu;
    } else {
      return const SizedBox.shrink();
    }
  }

  String formatTime() {
    DateTime now = DateTime.now();
    DateTime time = widget.pin.creationDate;
    final difference = now.difference(time);
    if (difference.inDays >= 365) {
      return "${difference.inDays ~/ 365} years ago";
    } else if (difference.inDays >= 7) {
      return "${difference.inDays ~/ 7} weeks ago";
    } else if (difference.inDays >= 1) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours} hours ago";
    } else {
      return "${difference.inMinutes} min. ago";
    }
  }




}