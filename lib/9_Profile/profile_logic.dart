import 'dart:typed_data';

import 'package:buff_lisa/9_Profile/profile_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:provider/provider.dart';
import '../7_Settings/settings_logic.dart';
import '../Files/Other/global.dart' as global;
import '../Files/DTOClasses/pin.dart';
import '../Files/ServerCalls/fetch_users.dart';
import '../Files/Widgets/custom_show_and_pick.dart';
import '../Files/Widgets/custom_title.dart';
import '../Providers/user_notifier.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.username});

  final String username;

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {

  /// Controller for the Paged List-view
  /// always shows first item first and loads 3 items that are out of view
  final PagingController<int, Widget> pagingController = PagingController(firstPageKey: 0, invisibleItemsThreshold: 2);

  List<Pin> pins = [];

  late double width;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProfilePageUI(state: this);
  }

  /// Inits the pagingController and adds the methods to its scroll listener
  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  Future<void> init() async {
    width = (MediaQuery.of(context).size.width / 3);
    pins = await FetchPins.fetchUserPins(widget.username, Provider.of<ClusterNotifier>(context).getGroups);
    setState(() {});
  }

  void _fetchPage(int pageKey) {
      late Widget widget;
      if (pageKey == 0) {
        pagingController.appendPage([getTitle()], pageKey + 1);
      } else {
        if (pageKey >= pins.length) {
          pagingController.appendLastPage([const Text("That's all")]);
        } else {
          pagingController.appendPage([
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                pageKey-1 < pins.length ? buildImage(pageKey - 1) : const SizedBox.shrink(),
                pageKey < pins.length ? buildImage(pageKey) : const SizedBox.shrink(),
                pageKey+1 < pins.length ? buildImage(pageKey + 1) : const SizedBox.shrink(),
              ],
            )
          ], pageKey + 3);
        }
      }

  }

  Widget buildImage(int index) {
    return FutureBuilder<Uint8List?>(
        builder: (context, snapshot) => SizedBox(
          height: width,
          width:  width,
          child: Expanded(
              child:(!snapshot.hasData || snapshot.requireData == null) ?
                Container(color: Colors.grey,) :
                Image.memory(snapshot.requireData!)
          )
        )
    );
  }

  Widget getTitle() {
    if (widget.username == global.localData.username) {
      return CustomTitle(
          titleBar: CustomTitleBar(
              title: widget.username,
              back: false,
              action: CustomAction(icon: const Icon(Icons.settings),
                action: () => handlePushPage(const Settings()),)
          ),
          child: CustomShowAndPick(
            provide: () =>
                FetchUsers.fetchProfilePicture(widget.username),
            updateCallback: provideImage,
          )
      );
    } else {
      return CustomTitle(
        titleBar: CustomTitleBar(
            title: widget.username,
            back: true
        ),
        imageCallback: () =>
            FetchUsers.fetchProfilePicture(widget.username),
      );
    }
  }

  Future<Uint8List?> provideImage(Uint8List image, BuildContext context) async {
    Provider.of<UserNotifier>(context, listen: false).removeUser(global.localData.username);
    return FetchUsers.changeProfilePicture(global.localData.username, image);
  }

 void handlePushPage(Widget widget) {
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => widget),
   );
 }


  @override
  bool get wantKeepAlive => true;
}