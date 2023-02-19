import 'package:buff_lisa/10_UploadOffline/upload_offline_logic.dart';
import 'package:buff_lisa/5_Feed/FeedCard/feed_card_logic.dart';
import 'package:flutter/material.dart';

import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';


class UploadOfflinePageUI extends StatefulUI<UploadOfflinePage, UploadOfflinePageState> {

  const UploadOfflinePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
      body: ListView.builder(
        itemCount: state.widget.pins.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return getTitle();
          } else {
            return FeedCard(pin: state.widget.pins[index-1]);
          }
        },
      ),
      floatingActionButton: Container(
          width: MediaQuery.of(context).size.width - 50,
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: const Color(0x99ffffff)
          ),
          child: Row(
            children: [
              TextButton(onPressed: () => state.handleUploadAll(), child: const Text("upload all")),
              TextButton(onPressed: () => state.handleDeleteAll(), child: const Text("delete all"))
            ],
          )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget getTitle() {
    return SizedBox(
      height: 100,
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            SizedBox(height: 25,),
            Text("Approve uploads", style: TextStyle(fontSize: 20),)
          ]
      ),
    );
  }
}
