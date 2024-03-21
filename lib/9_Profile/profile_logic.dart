import 'dart:math';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:buff_lisa/9_Profile/profile_ui.dart';
import 'package:buff_lisa/Files/AbstractClasses/async_type.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mutex/mutex.dart';
import 'package:provider/provider.dart';

import '../2_ScreenMaps/ClickOnPin/image_widget_logic.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/Other/global.dart' as global;
import '../Files/Routes/routing.dart';
import '../Files/ServerCalls/fetch_users.dart';
import '../Providers/user_notifier.dart';
import 'ClickOnProfileImage/show_profile_image_logic.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.username});

  /// Shows profile page of this user identified by this username
  final String username;

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> with AutomaticKeepAliveClientMixin {

  /// number of rows added by the pagingController added, when paging is activated
  static const _pageSize = 5;

  /// number of images shown in a row
  static const _gridWidth = 3;

  /// number of pages loaded and held in storage that are not visible currently
  static const _invisibleThresh = 3;

  final m = Mutex();

  /// Controller for the Paged List-view
  /// always shows first item first and loads 3 items that are out of view
  final PagingController<int, Widget> pagingController = PagingController(
      firstPageKey: 0, invisibleItemsThreshold: _invisibleThresh);

  /// Async loading operation that is currently active or completed
  CancelableOperation? operation;

  /// List of pins shown that are shown on the profile page
  late AsyncType<List<Pin>> pinList;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ProfilePageUI(state: this);
  }

  /// Inits the pagingController
  /// Inits pinList
  @override
  void initState() {
    pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
    List<Group> groups = List.from(Provider.of<ClusterNotifier>(context, listen: false).otherGroups);
    groups.addAll(Provider.of<ClusterNotifier>(context, listen: false).getGroups);
    pinList = AsyncType(callback: () => _getPins(groups));
  }

  /// starts a new operation if pins is null and updates the shown pins.
  /// Sort und update shown pins if pins is not null.
  /// Always refreshed the pagingController.
  Future<bool> init(List<Pin>? pins) async {
    try {
      bool offline = Provider.of<ClusterNotifier>(context, listen: false).offline;
      if (pins == null) {
        List<Pin>? pins = await initPins(offline ? await Provider.of<ClusterNotifier>(context, listen: false).getAllOfflinePins() : await pinList.refresh());
        if (!mounted) return false;
        Provider.of<UserNotifier>(context, listen: false)
            .updatePins(widget.username, pins);
      }
      return true;
    } catch(_) {
      return false;
    }
  }

  /// Pins from the pinList are added to the group pins, if the pins are not yet loaded.
  /// If loaded the pin from the group with the same id substitutes the pin instance from the pinList.
  /// Makes it possible, that images that are already loaded dont have to reloaded from the server again.
  /// Filters pins to not show hidden users and pins.
  /// Sorts the pin by creation date descending.
  Future<List<Pin>> initPins(List<Pin> pinList) async {
      List<Pin> pins = [];
      for (Pin pin in pinList) {
        Group group = pin.group;
        if (!group.pins.isLoaded) {
          Set<Pin> thPins = group.pins.syncValue ?? {};
          pin = thPins.firstWhere((element) => element.id == pin.id, orElse: () => pin);
          thPins.add(pin);
          pins.add(pin);
          await group.pins.setValueButNotLoaded(thPins);
        } else {
          Pin thePin = group.pins.syncValue!.firstWhere((element) => element.id == pin.id, orElse: () => pin);
          pins.add(thePin);
        }
      }
      pins.sort((a,b) => a.creationDate.compareTo(b.creationDate) * -1);
      return pins;
  }

  /// Callback function used in _getPins.
  /// Returns a group by a given id.
  /// Group is fetched from server if not currently in groups list.
  Future<Group> getGroup(int id, List<Group> groups) async {
    if (groups.any((element) => element.groupId == id)) {
      return groups.firstWhere((element) => element.groupId == id);
    } else {
      Group group = await FetchGroups.getGroup(id);
      if (mounted) {
        Provider.of<ClusterNotifier>(context, listen: false).addOtherGroup(group);
        groups.add(group);
        return group;
      } else {
        throw FlutterError("Not mounted");
      }
    }
  }

  /// returns the list of pins that a user created and is visible to current user
  Future<List<Pin>> _getPins(List<Group> groups) => FetchPins.fetchUserPins(widget.username,groups, getGroup);

  /// Callback function for paging controller, when fetching a new page.
  /// Creates rows based of the current user pin list.
  void _fetchPage(int pageKey, ) async {
    int width = MediaQuery.of(context).size.width ~/ _gridWidth;
    List<Pin> pins = await Provider.of<UserNotifier>(context, listen: false).getUser(widget.username).getPins ?? [];
    int currentIndex = (_pageSize * _gridWidth) * pageKey;
    int end = (_pageSize * _gridWidth) * (pageKey + 1) < pins.length ? (_pageSize * _gridWidth) * (pageKey + 1) : pins.length - 1;
    end = end < 0 ? 0 : end;

    try {
      await FetchPins.fetchPreviewsOfPins(pins.sublist(currentIndex, end), width);
      if ((_pageSize * _gridWidth) * (pageKey + 1) < pins.length) {
        pagingController.appendPage(
            List.generate(
                _pageSize,
                (index) =>
                    getImageRow(currentIndex + index * _gridWidth, pins)),
            pageKey + 1);
      } else {
        pagingController.appendLastPage(List.generate(
            _pageSize - (pins.length - currentIndex) ~/ (_pageSize * _gridWidth),
            (index) => getImageRow(currentIndex + index * _gridWidth, pins)));
      }
    } catch(_) {
      pagingController.appendLastPage([]);
    }
  }

  /// Returns a image row using the current index.
  Widget getImageRow(int pageKey, List<Pin> pins) {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: pageKey < pins.length ? buildImage(pins[pageKey]) : const SizedBox.shrink(),
            ),
            Expanded(
              flex: 1,
              child: pageKey + 1 < pins.length ? buildImage(pins[pageKey + 1]) : const SizedBox.shrink(),
            ),
            Expanded(
              flex: 1,
              child: pageKey + 2 < pins.length ? buildImage(pins[pageKey + 2]) : const SizedBox.shrink(),
            )
          ],
    );
  }

  /// Builds the actual square image.
  /// Image is touchable and opens a more detailed view.
  Widget buildImage(Pin pin) {
    return LayoutBuilder(
        builder: (context, constraints){
          final size = min(constraints.maxWidth, constraints.maxHeight);
          return GestureDetector(
            onTap: () => handleTabOnImage(pin),
            child: SizedBox(
                height: size,
                width: size,
                child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: FutureBuilder<Uint8List>(
                      future: pin.preview.asyncValue(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Image.memory(snapshot.requireData, fit: BoxFit.cover,);
                        } else {
                          return Container(color: Colors.grey,);
                        }
                      },
                    )
                )
            ),
          );
        }
    );
  }

  /// Used in profile page ui as a callback function to display the profile image of a user.
  Future<Uint8List?> provideProfileImage(Uint8List image, BuildContext context) async {
    await FetchUsers.changeProfilePicture(global.localData.username, image);
    if (!mounted) return null;
    Provider.of<UserNotifier>(context, listen: false).removeUser(global.localData.username);
    return await Provider.of<UserNotifier>(context, listen: false).getUser(global.localData.username).profileImage.asyncValue();
  }

  /// Opens a widget as a new page.
 void handlePushPage(Widget widget) {
   Routing.to(context,  widget);
 }

 /// Opens the profile image in a new page.
  void handleOpenImage() {
    handlePushPage(ShowProfileImage(provide: () => Provider.of<UserNotifier>(context, listen: false).getUser(widget.username).profileImage.asyncValue(), defaultImage: const Image(image: AssetImage("images/profile.jpg"),)));
  }

  /// Opens a pin image in a new page.
  void handleTabOnImage(Pin pin) {
    handlePushPage(ShowImageWidget(pin: pin));
  }


  @override
  bool get wantKeepAlive => true;
}