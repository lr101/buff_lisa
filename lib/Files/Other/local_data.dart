import 'package:buff_lisa/Files/DTOClasses/pin_repo.dart';
import 'package:flutter/cupertino.dart';

import '../../0_ScreenSignIn/secure.dart';
import '../DTOClasses/group_repo.dart';
import '../DTOClasses/hive_handler.dart';

class LocalData {

  static const String usernameKey = "username";
  static const String tokenKey = "auth";
  static const String pinFileNameKey = 'pin_new';
  static const String groupFileNameKey = 'groups';
  static const String hiddenUsersKey = "hiddenUsers";
  static const String hiddenPostsKey = "hiddenPosts";
  static const String activeGroupKey = "activeGroups";
  static const String offlineKeyValue = "offlineKeyValue";
  static const String themeKey = "themeKey";
  static const String orderKey = "orderKey";
  static const String langKey = "langKey";
  static const String expandKey = "expandKey";
  static const String lastSeenKey = "lastSeenKey";


  late Secure secure = Secure();

  /// username of the current user
  /// set on login/signup or loaded from secure storage
  late String username;

  /// user token to authenticate user on the server
  /// set on login/signup or loaded from secure storage
  late String token;

  /// dark or light mode
  late Brightness theme;

  /// Order of groups displayed. Contains group ids as int.
  late List<int> groupOrder;

  /// Storage to save usernames of hidden users.
  late HiveHandler<String, DateTime> hiddenUsers;

  /// Storage to save ids of hidden posts.
  late HiveHandler<int, DateTime> hiddenPosts;

  late GroupRepo groupRepo;

  /// Storage for multiple offline data:
  /// 1. theme
  /// 2. order
  /// 3. language
  /// 4. top-bar expansion flag
  /// 5. last seen date
  late HiveHandler<String, dynamic> offlineDataStorage;


  /// static function to create an LocalData instance asynchrony
  static Future<LocalData> fromInit() async {
    LocalData localData = LocalData();
    await localData.init();
    return localData;
  }

  /// Initializes all storages and gets the relevant information.
  Future<void> init() async {
    // init secure boxes
    username = await secure.readSecure(usernameKey) ?? "";
    token = await secure.readSecure(tokenKey) ?? "";
    // init hive boxes
    hiddenUsers = await HiveHandler.fromInit<String, DateTime>(hiddenUsersKey);
    hiddenPosts = await HiveHandler.fromInit<int, DateTime>(hiddenPostsKey);
    offlineDataStorage = await HiveHandler.fromInit<String, dynamic>(offlineKeyValue);
    groupRepo = (await GroupRepo.fromInit(LocalData.groupFileNameKey));
    // theme
    int? themeIndex = (await offlineDataStorage.get(themeKey)) as int?;
    if (themeIndex == null) {
      theme = WidgetsBinding.instance.window.platformBrightness;
    } else if (themeIndex == 0) {
      theme = Brightness.light;
    } else {
      theme = Brightness.dark;
    }
    // group Order
    groupOrder = (await offlineDataStorage.get(orderKey)) as List<int>? ?? [];

  }

  /// clears all relevant storages of the data of the previous user
  Future<void> logout() async {
    // remove username
    secure.removeSecure(username);
    username == "";
    // remove token
    secure.removeSecure(tokenKey);
    token = "";
    // clear content of hive boxes
    await hiddenUsers.clear();
    await hiddenPosts.clear();
    groupRepo.clear();
    (await GroupRepo.fromInit(LocalData.pinFileNameKey)).clear();
    await offlineDataStorage.clear();
  }

  /// save username and login token in secure storage.
  void login(String username, String token) async {
    secure.saveSecure(usernameKey, username);
    this.username = username;
    secure.saveSecure(tokenKey, token);
    this.token = token;
  }

  /// update theme and save offline.
  void setTheme(Brightness theme) {
    offlineDataStorage.put(key: themeKey, theme == Brightness.dark ? 1 : 0);
  }

  /// update group order and save offline
  Future<void> updateGroupOrder(List<int> order) async {
    await offlineDataStorage.put(key: orderKey, order);
    groupOrder = order;
  }

  /// delete an offline pin by id
  void deleteOfflineGroup(int groupId) async {
    deactivateGroup(groupId);
    groupRepo.deleteGroup(groupId);
  }

  /// true: top-bar is expanded
  /// false: top-bar is collapsed
  bool getExpanded() {
    return offlineDataStorage.get(expandKey) as bool? ?? true;
  }

  /// update expanded and save offline
  void setExpanded(bool expand) {
    offlineDataStorage.put(expand, key: expandKey);
  }

  /// activate a group and save offline
  void activateGroup(int groupId) {
    List<int> activeGroups = getActiveGroups();
    if (!activeGroups.any((element) => element == groupId)) {
      activeGroups.add(groupId);
      offlineDataStorage.put(activeGroups, key: activeGroupKey);
    }
  }

  /// deactivate a group and save offline
  void deactivateGroup(int groupId) {
    List<int> activeGroups = getActiveGroups();
    activeGroups.removeWhere((element) => element == groupId);
    offlineDataStorage.put(getActiveGroups(), key: activeGroupKey);
  }

  /// returns the list of active groups.
  List<int> getActiveGroups() {
    return offlineDataStorage.get(activeGroupKey) ?? [];
  }

  /// returns the last seen date
  DateTime? getLastSeen() {
    return offlineDataStorage.get(lastSeenKey);
  }

  /// updates last seen to the current time
  void setLastSeenNow() {
    offlineDataStorage.put(DateTime.now(), key: lastSeenKey);
  }

}