import 'package:buff_lisa/5_Feed/feed_ui.dart';
import 'package:buff_lisa/Ads/custom_native_ad.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../Files/Other/global.dart' as global;
import 'FeedCard/feed_card_logic.dart';


class FeedPage extends StatefulWidget {
  const FeedPage({super.key});

  @override
  FeedPageState createState() => FeedPageState();
}

class FeedPageState extends State<FeedPage>  with AutomaticKeepAliveClientMixin<FeedPage>{

  /// Controller for the Paged List-view
  /// always shows first item first and loads 3 items that are out of view
  final PagingController<int, Widget> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 5);

  /// Set of Groups that are currently shown
  /// Used to reduce the amounts of Widgets that need to be created everytime the Provider updates its values
  late Set<Group> groups = {};

  /// Saves all Pins that could be seen in the feed with the Widget that is shown if already created
  late List<Pin> allWidgets = [];

  final _addEvery = 4;
  
  DateTime? lastSeen;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FeedUI(state: this);
  }

  /// Inits the pagingController and adds the methods to its scroll listener
  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    lastSeen = global.localData.getLastSeen();
    global.localData.setLastSeenNow();
    print(lastSeen);
    super.initState();
  }

  /// Adds a new Feed Widget to the Listview by appending it to the pagingController
  /// Checks if the Pin at the position [pageKey] already has an existing Widget
  /// If not a new one is created
  Future<void> _fetchPage(int pageKey) async {
    try {
        Pin key = allWidgets.elementAt(pageKey);
        Widget widget =  FeedCard(pin: key, update: pullRefresh,);
        if (key.group.active) {
          if (allWidgets.length == pageKey + 1) {
            pagingController.appendLastPage([widget]);
          } else {
            List<Widget> pages = [];
            // no new posts in the middle
            if (lastSeen != null && 
                pageKey > 0 && 
                allWidgets.elementAt(pageKey - 1).creationDate.isAfter(lastSeen!) &&
                key.creationDate.isBefore(lastSeen!)
            ) pages.add(alreadySeenEverything("You have seen all new posts\nTry adding something yourself"));
            // no new posts at the start
            if (lastSeen != null &&
                pageKey == 0 &&
                key.creationDate.isBefore(lastSeen!)
            ) pages.add(alreadySeenEverything("There are no new posts\nTry adding something yourself"));
            // add current feed page
            pages.add(widget);
            // add an ad
            if (pageKey % _addEvery == 0) pages.add(const Card(child: CustomNativeAd()));
            pagingController.appendPage(pages, pageKey + 1);
          }
        }
    } catch (error) {
      pagingController.appendLastPage([]);
    }
  }

  void init() {
    groups = Provider.of<ClusterNotifier>(context).getActiveGroups.toSet();
    pullRefresh();
  }

  Widget alreadySeenEverything(String text) {
    return SizedBox(
      height: 100,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundImage: Image.asset("images/pinGui.png").image,
            radius: 20,
          ),
          const SizedBox(width: 10,),
          Text(text,textAlign: TextAlign.center,)
        ],
      )
    );
  }


  Future<void> pullRefresh({refresh = false}) async {
    if (refresh) {
      lastSeen = global.localData.getLastSeen();
      global.localData.setLastSeenNow();
    }
    allWidgets.clear();
    for (Group group in groups) {
      Set<Pin> pins = refresh ? await group.pins.refresh() : await group.pins.asyncValue();
      allWidgets.addAll(pins);
    }
    allWidgets.sort((k1, k2) => k1.creationDate.compareTo(k2.creationDate) * -1);
    pagingController.refresh();
  }

  /// disposed the controller when the page is closed
  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  /// keeps Widget alive when changing tabs in navbar
  @override
  bool get wantKeepAlive => true;
}