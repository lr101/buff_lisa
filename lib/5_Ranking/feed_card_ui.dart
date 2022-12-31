import 'dart:typed_data';

import 'package:buff_lisa/5_Ranking/feed_card_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';


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
            height: width + 30,
            width: width,
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                  width: width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.grey,
                          child: FutureBuilder<Uint8List?>(
                              future: FetchUsers.fetchProfilePictureSmall(widget.pin.username),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  if (snapshot.data != null) {
                                    return CircleAvatar(backgroundImage: Image.memory(snapshot.data!).image, radius: 12,);
                                  } else {
                                    return CircleAvatar(backgroundImage: const Image(image: AssetImage("images/profile.jpg"),).image, radius: 12,);
                                  }
                                } else {
                                  return const CircleAvatar(backgroundColor: Colors.grey, radius: 12,);
                                }
                              },
                          ),
                      ),
                      Text(widget.pin.username),
                      const Text(" - "),
                      Text(widget.pin.creationDate.toLocal().toIso8601String())
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




}