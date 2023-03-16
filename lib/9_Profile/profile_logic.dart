import 'dart:math';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:buff_lisa/9_Profile/profile_ui.dart';
import 'package:buff_lisa/Files/AbstractClasses/async_type.dart';
import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_groups.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mutex/mutex.dart';
import 'package:provider/provider.dart';
import '../2_ScreenMaps/ClickOnPin/image_widget_logic.dart';
import '../7_Settings/settings_logic.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/Other/global.dart' as global;
import '../Files/DTOClasses/pin.dart';
import '../Files/ServerCalls/fetch_users.dart';
import '../Files/Widgets/custom_show_and_pick.dart';
import '../Files/Widgets/custom_title.dart';
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
  static const _pageSize = 3;

  /// number of images shown in a row
  static const _gridWidth = 3;

  /// number of pages loaded and held in storage that are not visible currently
  static const _invisibleThresh = 4;

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
    if (pins == null) {
      if (operation != null && !operation!.isCanceled && !operation!.isCompleted) operation!.cancel();
      operation = CancelableOperation.fromFuture(
        initPins(await pinList.refresh()),
        onCancel: () => {debugPrint('onCancel')},
      );
      CancelableOperation cancelableOperation = operation!;
      pins = await cancelableOperation.value;
      if (!cancelableOperation.isCanceled && mounted) {
        Provider.of<UserNotifier>(context, listen: false).getUser(widget.username).updatePins(pins!);
        pagingController.refresh();
      }
      return !cancelableOperation.isCanceled;
    } else {
      pins.sort((a,b) => a.creationDate.compareTo(b.creationDate) * -1);
      Provider.of<UserNotifier>(context, listen: false).getUser(widget.username).updatePins(pins);
    }
    return true;
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
        await m.protect(() async {
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
        });
      }
      _filter(pins);
      pins.sort((a,b) => a.creationDate.compareTo(b.creationDate) * -1);
      return pins;
  }

  /// Filters pins to not show hidden users and pins.
  void _filter(List<Pin> pins) {
    Set<Pin> removesPins = {};
    List<String> usernames = global.localData.hiddenUsers.keys();
    List<int> posts = global.localData.hiddenPosts.keys();
    List<Pin> iterator = List.from(pins);
    for (Pin pin in iterator) {
      if (posts.any((element) => element == pin.id) || usernames.any((element) => element == pin.username)) {
        pins.remove(pin);
        removesPins.add(pin);
      }
    }
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
    List<Pin> pins = Provider.of<UserNotifier>(context, listen: false).getUser(widget.username).getPins ?? [];
    if (pageKey >= pins.length) {
      pagingController.appendLastPage([]);
    } else {
      List<Widget> rows = [];
      int p = pageKey;
      int end = pageKey + _pageSize * _gridWidth < pins.length ? pageKey + _pageSize * _gridWidth : pins.length - 1;
      await FetchPins.fetchImageOfPins(pins.sublist(pageKey, end));
      for (; pageKey < pins.length && pageKey < p + _pageSize * _gridWidth ; pageKey += _gridWidth){
        rows.add(await getImageRow(pageKey, pins));
      }
      pagingController.appendPage(rows, pageKey + _pageSize);
    }
  }

  /// Returns a image row using the current index.
  Future<Widget> getImageRow(int pageKey, List<Pin> pins)async {
    return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              flex: 1,
              child: pageKey < pins.length ? await buildImage(pins[pageKey]) : const SizedBox.shrink(),
            ),
            Expanded(
              flex: 1,
              child: pageKey + 1 < pins.length ? await buildImage(pins[pageKey + 1]) : const SizedBox.shrink(),
            ),
            Expanded(
              flex: 1,
              child: pageKey + 2 < pins.length ? await buildImage(pins[pageKey + 2]) : const SizedBox.shrink(),
            )
          ],
    );
  }

  /// Builds the actual square image.
  /// Image is touchable and opens a more detailed view.
  Future<Widget> buildImage(Pin pin) async {
    Uint8List image = await pin.image.asyncValue();
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
                    child: Image.memory(image, errorBuilder: (context, error, stackTrace) => const Center(child: Text("Image data invalid"),), fit: BoxFit.cover,
                    )
                )
            ),
          );
        }
    );
  }

  /// Used in profile page ui as a callback function to display the profile image of a user.
  Future<Uint8List?> provideProfileImage(Uint8List image, BuildContext context) async {
    Provider.of<UserNotifier>(context, listen: false).removeUser(global.localData.username);
    return FetchUsers.changeProfilePicture(global.localData.username, image);
  }

  /// Opens a widget as a new page.
 void handlePushPage(Widget widget) {
   Navigator.push(
     context,
     MaterialPageRoute(builder: (context) => widget),
   );
 }

 /// Opens the profile image in a new page.
  void handleOpenImage() {
    handlePushPage(ShowProfileImage(provide: () => Provider.of<UserNotifier>(context, listen: false).getUser(widget.username).profileImage.asyncValue(), defaultImage: const Image(image: AssetImage("images/profile.jpg"),)));
  }

  /// Opens a pin image in a new page.
  void handleTabOnImage(Pin pin) {
    handlePushPage(ShowImageWidget(pin: pin, newPin: false));
  }


  @override
  bool get wantKeepAlive => true;
}