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

  late Brightness theme;

  late List<int> groupOrder;

  late HiveHandler<String, DateTime> hiddenUsers;

  late HiveHandler<int, DateTime> hiddenPosts;

  late HiveHandler<String, dynamic> offlineDataStorage;

  late GroupRepo repo;

  late PinRepo pinRepo;

  static Future<LocalData> fromInit() async {
    LocalData localData = LocalData();
    await localData.init();
    return localData;
  }

  Future<void> init() async {
    // init secure boxes
    username = await secure.readSecure(usernameKey) ?? "";
    token = await secure.readSecure(tokenKey) ?? "";
    // init hive boxes
    hiddenUsers = await HiveHandler.fromInit<String, DateTime>(hiddenUsersKey);
    hiddenPosts = await HiveHandler.fromInit<int, DateTime>(hiddenPostsKey);
    repo = await GroupRepo.fromInit(groupFileNameKey);
    pinRepo = await PinRepo.fromInit(pinFileNameKey);
    offlineDataStorage = await HiveHandler.fromInit<String, dynamic>(offlineKeyValue);
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
    await repo.clear();
    await pinRepo.clear();
    await offlineDataStorage.clear();
  }

  void login(String username, String token) async {
    secure.saveSecure(usernameKey, username);
    this.username = username;
    secure.saveSecure(tokenKey, token);
    this.token = token;
  }

  void setTheme(Brightness theme) {
    offlineDataStorage.put(key: themeKey, theme == Brightness.dark ? 1 : 0);
  }

  Future<void> updateGroupOrder(List<int> order) async {
    await offlineDataStorage.put(key: orderKey, order);
    groupOrder = order;
  }

  void deleteOfflineGroup(int groupId) {
    deactivateGroup(groupId);
    repo.deleteGroup(groupId);
  }

  bool getExpanded() {
    return offlineDataStorage.get(expandKey) as bool? ?? true;
  }

  void setExpanded(bool expand) {
    offlineDataStorage.put(expand, key: expandKey);
  }

  void activateGroup(int groupId) {
    List<int> activeGroups = getActiveGroups();
    if (!activeGroups.any((element) => element == groupId)) {
      activeGroups.add(groupId);
      offlineDataStorage.put(activeGroups, key: activeGroupKey);
    }
  }

  void deactivateGroup(int groupId) {
    List<int> activeGroups = getActiveGroups();
    activeGroups.removeWhere((element) => element == groupId);
    offlineDataStorage.put(getActiveGroups(), key: activeGroupKey);
  }

  List<int> getActiveGroups() {
    return offlineDataStorage.get(activeGroupKey) ?? [];
  }

  DateTime? getLastSeen() {
    return offlineDataStorage.get(lastSeenKey);
  }

  void setLastSeenNow() {
    offlineDataStorage.put(DateTime.now(), key: lastSeenKey);
  }

}