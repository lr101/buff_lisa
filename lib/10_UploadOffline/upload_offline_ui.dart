import 'package:buff_lisa/10_UploadOffline/upload_offline_logic.dart';
import 'package:buff_lisa/5_Feed/FeedCard/feed_card_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:flutter/material.dart';

import '../Files/Widgets/custom_title.dart';


class UploadOfflinePageUI extends StatefulUI<UploadOfflinePage, UploadOfflinePageState> {

  const UploadOfflinePageUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
      body: CustomTitle.withoutSlivers(title: const CustomEasyTitle(title: Text("Approve upload"),back:  false),
            child: ListView.builder(
          itemCount: state.widget.pins.length,
          itemBuilder: (context, index) => FeedCard(pin: state.widget.pins.elementAt(index))
      ),),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(onPressed: () => state.handleDeleteAll(), tooltip: "delete all", child: const Icon(Icons.delete)),
          const SizedBox(height: 10,),
          FloatingActionButton(onPressed: () => state.handleUploadAll(), tooltip: "upload all", child: const Icon(Icons.upload),),
        ],
      ),
    );
  }
}
