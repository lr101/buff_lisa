import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/DTOClasses/pin_repo.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/marker_notifier.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:flutter/foundation.dart';

import '../Files/Other/local_data.dart';

class ClusterNotifier extends ChangeNotifier {


  /// list of groups the user is a member of
  final  List<Group> _userGroups = [];

  /// flag if fetching of group was successfully
  /// true: server cannot be reached
  /// false: server can be reached
  bool offline = false;

  /// Groups that the user is not a user.
  /// Are used to save group information to reduce fetching amount in profile page.
  List<Group> otherGroups = [];

  /// Is initialized at the beginning.
  /// Used to notify changes of current user pins shown on profile page.
  late UserNotifier _userNotifier;

  late MarkerNotifier _markerNotifier;

  /// inits the user notifier.
  void init(UserNotifier userNotifier, MarkerNotifier markerNotifier) {
    _userNotifier = userNotifier;
    _markerNotifier = markerNotifier;
  }

  /// ads a group if it is not a part of the userGroups
  void addOtherGroup(Group group) {
    if (!_userGroups.any((element) => element.groupId == group.groupId)) {
      otherGroups.add(group);
      notifyListeners();
    }
  }

  /// clears [_userGroups] and ads a list of groups
  /// ads groups in order that is saved offline
  /// NOTIFIES CHANGES
  void addGroups(List<Group> groups) {
    _userGroups.clear();
    List<int> activeGroups = global.localData.getActiveGroups();
    List<int> updatedList = List.from(global.localData.groupOrder);
    for (int groupId  in global.localData.groupOrder) {
      int where = groups.indexWhere((element) => element.groupId == groupId);
      if (where != -1) {
        if (kDebugMode) print("add $groupId at ${_userGroups.length}");
        _add(groups[where], activeGroups);
        groups.removeAt(where);
      } else {
        updatedList.removeWhere((element) => element == groupId);
      }
    }
    for (Group group in groups) {
      if (kDebugMode) print("add ${group.groupId} at ${_userGroups.length}");
      if (otherGroups.any((element) => element.groupId == group.groupId)) {
        otherGroups.retainWhere((element) => element.groupId == group.groupId);
      }
      _add(group, activeGroups);
      updatedList.add(group.groupId);
    }
    global.localData.updateGroupOrder(updatedList);
    notifyListeners();
  }

  void _add(Group group, List<int> activeGroups) {
    _userGroups.add(group);
    group.pinImage.asyncValue(); //new thread - load pin image on startup
    if (activeGroups.any((element) => element == group.groupId)) activateGroup(group); // new thread - load pins of image
  }

  /// adds a list of [Group] saved offline in [_offlineGroupHandler] in [_userGroups] if they not already existing
  /// NOTIFIES CHANGES
  Future<void> loadOfflineGroups() async {
    addGroups(global.localData.groupRepo.getGroups());
  }

  /// removes a specific [group] form [_userGroups]
  /// removes the markers of this group from [_shownMarkers] and [_allMarkers] if the [group] is currently active
  /// NOTIFIES CHANGES
  void removeGroup(Group group) {
    if (group.active) {
      for (Pin pin in group.pins.syncValue ?? {}) {
        _removePin(pin);
      }
    }
    _userGroups.remove(group);
    global.localData.deleteOfflineGroup(group.groupId);
    notifyListeners();
    _userNotifier.clearPinsNotUser(global.localData.username);
  }

  void updateGroup(Group group, Group changes) async {
    group.name = changes.name;
    group.description.setValue(changes.description.syncValue!);
    group.pinImage.setValue(changes.pinImage.syncValue!);
    group.profileImage.setValue(changes.profileImage.syncValue!);
    group.groupAdmin.setValue(changes.groupAdmin.syncValue!);
    group.visibility = changes.visibility;
    group.inviteUrl = changes.inviteUrl;
    group.link.setValue(changes.link.syncValue);
    notifyListeners();
  }

  /// adds a [group] to [_userGroups] if not already existing
  /// NOTIFIES CHANGES
  void addGroup(Group group) {
    if(!_userGroups.any((element) => element.groupId == group.groupId)) {
      _userGroups.add(group);
      List<int> order = global.localData.groupOrder;
      order.add(group.groupId);
      global.localData.updateGroupOrder(order);
    }
    notifyListeners(); // new thread
    _userNotifier.clearPinsNotUser(global.localData.username);
  }

  /// clears all values from lists, attributes and maps
  void clearAll() {
    //TODO remove all offline pins too?
    _userGroups.clear();
    _markerNotifier.clear();
  }

  /// returns a [Group] by [groupId] if it is an item in [_userGroups]
  Group getGroupByGroupId(int groupId) {
    return _userGroups.firstWhere((element) => element.groupId == groupId, orElse: () => otherGroups.firstWhere((e) => e.groupId == groupId));
  }

  /// adds a pin to the [pin.group] Group
  /// if group is active to [pin] is added to shown markers on the map
  /// if the members of the group are already loaded ones from the server the point count of the current user is increased by one and the member list is sorted by points
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> addPin(Pin pin)  async {
    Group group = pin.group;
    bool success = await group.setPin(pin);
    if (success) {
      _userNotifier.addPin(global.localData.username, pin);
      if (group.active) {
        _markerNotifier.addMarker(pin);
        _markerNotifier.update();
      }
      addPointToMembers(group, pin);
    }
    notifyListeners();
  }

  addPointToMembers(Group group, Pin pin) {
    if (!group.members.isEmpty && pin.username == global.localData.username) {
      group.members.syncValue!.firstWhere((element) => element.username == global.localData.username).addOnePoint();
      group.members.syncValue!.sort((a,b) =>  a.points.compareTo(b.points) * -1);
    }
  }

  removePointFromMembers(Group group, Pin pin) {
    if (!group.members.isEmpty && pin.username == global.localData.username) {
      group.members.syncValue!.firstWhere((element) => element.username == global.localData.username).subOnePoint();
      group.members.syncValue!.sort((a,b) =>  a.points.compareTo(b.points) * -1);
    }
  }

  Future<void> addPins(Set<Pin> pins) async {
    for (Pin pin in pins) {
      bool success = await pin.group.setPin(pin);
      if (success && pin.group.active) {
        _markerNotifier.addMarker(pin);
      }
    }
    _markerNotifier.update();
    notifyListeners();
  }

  /// activates the [group] : the group will show its marker on the map and the feed
  /// also includes offline pins of this group
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> activateGroup(Group group) async{
    if (!group.active) {
      group.active = true;
      notifyListeners();
      global.localData.activateGroup(group.groupId);
      _loadGroupPins(group);  // new thread
    }
  }

  Future<List<Pin>> getAllOfflinePins() async {
    return (await PinRepo.fromInit(LocalData.pinFileNameKey)).getPins(_userGroups).toList();
  }

  Future<void> _loadGroupPins(Group group) async {
    //get pins from server or load from offline
    if (offline && group.pins.syncValue == null) group.pins.setValue((await PinRepo.fromInit(LocalData.pinFileNameKey)).getPins([group]));
    Set<Pin> pins = await group.pins.asyncValueMerge((isLoaded, current, asyncVal) {
      if (!isLoaded && current != null) {
        for (Pin pin in current) {
          asyncVal.removeWhere((element) => element.id == pin.id);
          asyncVal.add(pin);
        }
      }
      return asyncVal;
    });
    //converts pins to markers on google maps
    for (Pin pin in pins) {
      _markerNotifier.addMarker(pin);
    }
    _markerNotifier.update();
  }

  /// deactivate the [group] : the groups pins will be removed from the map and the feed
  /// also includes offline pins of this group
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deactivateGroup(Group group) async {
    if (group.active) {
      group.active = false;
      notifyListeners();
      global.localData.deactivateGroup(group.groupId);
      //removes markers from maps
      for (Pin pin in group.pins.syncValue ?? {}) {
         _markerNotifier.removeMarker(pin);
      }
      _markerNotifier.update();
    }
  }

  /// removes a single pin from the server and the local object
  /// 1. API call to server
  /// 2. remove from group pins
  /// 3. remove from [_allMarkers]
  /// 4. rebuild [_shownMarkers] list
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<bool> _removePin(Pin pin) async {
    try {
      await FetchPins.deleteMonaFromPinId(pin.id);
      await _userNotifier.removePin(pin.username, pin.id);
      pin.group.removePin(pin);
      _userNotifier.removePin(global.localData.username, pin.id);
      _markerNotifier.removeMarker(pin);
      _markerNotifier.update();
      removePointFromMembers(pin.group, pin);
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<bool> removePin(Pin pin) async {
    bool ret = await _removePin(pin);
    notifyListeners();
    return ret;
  }

  Future<void> hidePin(Pin pin) async {
    pin.group.removePin(pin);
    _userNotifier.clearPinsNotUser(global.localData.username);
    _markerNotifier.removeMarker(pin);
    _markerNotifier.update();
  }

  Future<void> updateFilter() async {
    for (Group group in _userGroups) {
      for (var pin in (await group.filter())) {
        _markerNotifier.removeMarker(pin);
      }
    }
    _markerNotifier.update();
    _userNotifier.clearPinsNotUser(global.localData.username);
  }

  /// removes [oldPin] from [_offlinePins]
  /// adds [newPin] to [newPin.group]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deleteOfflinePinAndAddToOnline(Pin newPin, Pin oldPin) async{
    await deleteOfflinePin(oldPin);
    await addPin(newPin);
    notifyListeners();
  }

  /// remove [pin] from [_offlinePins] and device storage
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deleteOfflinePin(Pin pin) async{
    _markerNotifier.removeMarker(pin);
    _markerNotifier.update();
    pin.group.removePin(pin);
    await _userNotifier.removePin(pin.username, pin.id);
    (await PinRepo.fromInit(LocalData.pinFileNameKey)).deletePin(pin.id);
    removePointFromMembers(pin.group, pin);
    notifyListeners();
  }

  /// adds an offline [Pin] to device storage
  /// adds marker of offline pin to map if group is active
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> addOfflinePin(Pin mona) async{
    if (!kIsWeb) {
      (await PinRepo.fromInit(LocalData.pinFileNameKey)).setPin(mona);
      addPin(mona);
      notifyListeners();
    }
  }

  /// get method of [_userGroups] attribute
  List<Group> get getGroups {
    return List.from(_userGroups);
  }

  /// get method of all currently active groups inside [_userGroups]
  Set<Group> get getActiveGroups {
    Set<Group> activeGroups = {};
    for (Group group in _userGroups) {
      if (group.active) activeGroups.add(group);
    }
    return activeGroups;
  }

}