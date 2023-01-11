import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/group_repo.dart';
import 'package:buff_lisa/Files/DTOClasses/hive_handler.dart';
import 'package:buff_lisa/Files/DTOClasses/pin_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../2_ScreenMaps/image_widget_logic.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/ServerCalls/fetch_pins.dart';
import '../Files/Other/global.dart' as global;
import '../main.dart';

class ClusterNotifier extends ChangeNotifier {


  /// list of groups the user is a member of
  final  List<Group> _userGroups = [];

  /// group that was last selected by the [SelectGroupWidget] single select mode
  /// used to pre-select the same group when creating a new pin
  Group? _lastSelected;

  /// map of pins and their corresponding markers that are currently selected by active groups
  /// includes all pins by active groups even when some are not shown by applying filters
  final Map<Pin, Marker> _allMarkers = {};

  /// list of markers that are currently shown
  /// filters affect the shown markers
  List<Marker> _shownMarkers = [];

  /// list of users that are filtered in [_shownMarkers]
  List<String> __filterUsernames = [];

  /// all pins than are created after [__filterDateMax] are removed
  /// all pins from 'infinity small' to [__filterDateMax] are NOT removed
  /// null: does NOT filter any pins
  DateTime? __filterDateMax;

  /// all pins that are created before [__filterDateMin] are removed
  /// all pins from [__filterDateMin] to current time are NOT removed
  /// null: does NOT filter any pins
  DateTime? __filterDateMin;

  bool offline = false;

  /// adds a list of [Group] to [_userGroups] if they not already existing
  /// NOTIFIES CHANGES
  void addGroups(List<Group> groups) {
    for (Group group in groups) {
      if(!_userGroups.any((element) => element.groupId == group.groupId)) {
        _userGroups.add(group);
        group.pinImage.asyncValue(); //new thread - load pin image on startup
      }
    }
    notifyListeners();
  }

  /// adds a list of [Group] saved offline in [_offlineGroupHandler] in [_userGroups] if they not already existing
  /// NOTIFIES CHANGES
  Future<List<Group>> loadOfflineGroups() async {
    GroupRepo repo = GroupRepo();
    await repo.init(global.groupFileName);
    addGroups(repo.getGroups());
    return _userGroups;
  }

  /// removes a specific [group] form [_userGroups]
  /// removes the markers of this group from [_shownMarkers] and [_allMarkers] if the [group] is currently active
  /// NOTIFIES CHANGES
  void removeGroup(Group group) {
    if (group.active) {
      for (Pin pin in group.pins.syncValue ?? {}) {
        removePin(pin);
      }
    }
    _userGroups.remove(group);
    notifyListeners();
  }

  void updateGroup(Group group, Group changes) async {
    group.name = changes.name;
    group.description = changes.description;
    group.pinImage = changes.pinImage;
    group.profileImage = changes.profileImage;
    group.groupAdmin = changes.groupAdmin;
    group.visibility = changes.visibility;
    notifyListeners();
  }

  /// adds a [group] to [_userGroups] if not already existing
  /// NOTIFIES CHANGES
  void addGroup(Group group) {
    if(!_userGroups.any((element) => element.groupId == group.groupId)) {
      _userGroups.add(group);
    }
    notifyListeners(); // new thread
  }

  /// clears all values from lists, attributes and maps
  void clearAll() {
    //TODO remove all offline pins too?
    _userGroups.clear();
    _shownMarkers.clear();
    _allMarkers.clear();
    __filterUsernames.clear();
    __filterDateMax = null;
    __filterDateMin = null;
  }

  /// returns a [Group] by [groupId] if it is an item in [_userGroups]
  Group getGroupByGroupId(int groupId) {
    return _userGroups.firstWhere((element) => element.groupId == groupId);
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
      if (group.active) {
        _addPinToMarkers(pin);
      }
      if (!group.members.isEmpty && pin.username == global.username) {
        group.members.syncValue!.firstWhere((element) => element.username == global.username).addOnePoint();
        group.members.syncValue!.sort((a,b) =>  a.points.compareTo(b.points) * -1);
      }
    }
    _updateValues();
  }

  /// activates the [group] : the group will show its marker on the map and the feed
  /// also includes offline pins of this group
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> activateGroup(Group group) async{
    if (!group.active) {
      group.active = true;
      notifyListeners();
      final HiveHandler<int, dynamic> offlineActiveGroups = await HiveHandler.fromInit<int, dynamic>("activeGroups");
      offlineActiveGroups.put(null, key: group.groupId);
      print(await offlineActiveGroups.keys());
      //get pins from server of the specific groups if not already loaded
      Set<Pin> pins = await group.pins.asyncValue();
      //converts pins to markers on google maps
      for (Pin pin in pins) {
        await _addPinToMarkers(pin);
      }
      _updateValues();
    }
  }

  /// deactivate the [group] : the groups pins will be removed from the map and the feed
  /// also includes offline pins of this group
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deactivateGroup(Group group) async {
    if (group.active) {
      group.active = false;
      notifyListeners();
      final HiveHandler<int, dynamic> offlineActiveGroups = await HiveHandler.fromInit<int, dynamic>("activeGroups");
      offlineActiveGroups.deleteByKey(group.groupId);
      //removes markers from maps
      for (Pin pin in group.pins.syncValue ?? {}) {
         _removePinFromMarkers(pin);
      }
      _updateValues();
    }
  }

  /// removes a single pin from the server and the local object
  /// 1. API call to server
  /// 2. remove from group pins
  /// 3. remove from [_allMarkers]
  /// 4. rebuild [_shownMarkers] list
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> removePin(Pin pin) async {
    await FetchPins.deleteMonaFromPinId(pin.id);
    hidePin(pin);
  }

  Future<void> hidePin(Pin pin) async {
    pin.group.removePin(pin);
    _removePinFromMarkers(pin);
    _updateValues();
  }

  Future<void> updateFilter() async {
    for (Group group in _userGroups) {
      for (var element in (await group.filter())) {
        _removePinFromMarkers(element);
      }
    }
    _updateValues();
  }

  /// loads all offline pins from device storage
  Future<List<Pin>> loadOfflinePins() async {
    PinRepo pinRepo = PinRepo();
    await pinRepo.init(global.fileName);
    return pinRepo.getPins(_userGroups);
  }

  /// removes [oldPin] from [_offlinePins]
  /// adds [newPin] to [newPin.group]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deleteOfflinePinAndAddToOnline(Pin newPin, Pin oldPin) async{
    await deleteOfflinePin(oldPin);
    await addPin(newPin);
  }

  /// remove [mona] from [_offlinePins] and device storage
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deleteOfflinePin(Pin mona) async{
    _removePinFromMarkers(mona);
    mona.group.removePin(mona);
    PinRepo pinRepo = PinRepo();
    await pinRepo.init(global.fileName);
    pinRepo.deletePin(mona.id);
    _updateValues();
  }

  /// adds an offline [Pin] to device storage
  /// adds marker of offline pin to map if group is active
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> addOfflinePin(Pin mona) async{
    if (!kIsWeb) {
      PinRepo pinRepo = PinRepo();
      await pinRepo.init(global.fileName);
      pinRepo.setPin(mona);
      if (mona.group.active) {
        await _addPinToMarkers(mona);
      }
      _updateValues();
    }
  }

  /// get method of [_shownMarkers] attribute
  List<Marker> get getMarkers {
    return _shownMarkers;
  }

  /// get method of [_userGroups] attribute
  List<Group> get getGroups {
    return _userGroups;
  }

  /// get method of [_lastSelected] attribute
  Group? get getLastSelected {
    return _lastSelected;
  }

  /// get method of all currently active groups inside [_userGroups]
  Set<Group> get getActiveGroups {
    Set<Group> activeGroups = {};
    for (Group group in _userGroups) {
      if (group.active) activeGroups.add(group);
    }
    return activeGroups;
  }

  /// set [_lastSelected] to [group]
  /// NOTIFIES CHANGES
  void setLastSelected(Group group) {
    _lastSelected = group;
    notifyListeners();
  }

  /// set [__filterDateMin] to [filterDateMin]
  /// set [__filterDateMax] to [filterDateMax]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  void setFilterDate(DateTime? filterDateMin, DateTime? filterDateMax) {
    __filterDateMin = filterDateMin;
    __filterDateMax = filterDateMax;
    _updateValues();
  }

  /// set [__filterUsernames] to [usernames]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  void setFilterUsername(List<String> usernames) {
    __filterUsernames = usernames;
    _updateValues();
  }

  /// remove [pin] from [_allMarkers]
  void _removePinFromMarkers(Pin pin) {
    _allMarkers.removeWhere((key, value) => key.id == pin.id && key.group.groupId == pin.group.groupId);
  }

  /// adds a Marker with attributes from [pin] to [_allMarkers]
  /// key id of pin: '[pin.id]'
  /// key of offline pin: 'new[pin.id]'
  _addPinToMarkers(Pin pin) {
    _allMarkers[pin] = (
      Marker(
          key: Key((pin.isOffline ? "${pin.group.groupId}${pin.id.toString()}" : pin.id.toString())),
          point: LatLng(pin.latitude, pin.longitude), 
          builder: (_)  => GestureDetector(
            child: pin.group.pinImage.getWidget(),
            onTap: () => Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => ShowImageWidget(newPin: pin.isOffline, pin: pin,)),
            ),
          )
      )
    );
  }

  /// updates the [_shownMarkers] list by rebuilding and filtering all markers form [_allMarkers]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void>  _updateValues() async {
    Map<Pin, Marker> mark = Map.from(_allMarkers);
    _filterMaxDate(mark);
    _filterMinDate(mark);
    _shownMarkers = List.from(mark.values);
    notifyListeners();
  }

  /// filter to filter all pins in [mark] with [__filterDateMin]
  void _filterMinDate(Map<Pin, Marker> mark) {
    if (__filterDateMin == null) return;
    mark.removeWhere((k,v) => k.creationDate.isBefore(__filterDateMin!));
  }

  /// filter to filter all pins in [mark] with [__filterDateMax]
  void _filterMaxDate(Map<Pin, Marker> mark) {
    if (__filterDateMax == null) return;
    mark.removeWhere((k,v) => k.creationDate.isAfter(__filterDateMax!));
  }

}