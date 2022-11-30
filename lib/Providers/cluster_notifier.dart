import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../2_ScreenMaps/image_widget_logic.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/ServerCalls/fetch_pins.dart';
import '../Files/Other/global.dart' as global;
import '../main.dart';
import 'file_handler.dart';

class ClusterNotifier extends ChangeNotifier {

  /// FileHandler to save, read, delete offline pins
  final FileHandler _offlineFileHandler = FileHandler(fileName: global.fileName);

  /// list of groups the user is a member of
  final  List<Group> _userGroups = [];

  /// list of pins loaded from device or added from creating a new pin without internet
  final List<Pin> _offlinePins = [];

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

  /// adds a list of [Group] to [_userGroups] if they not already existing
  /// NOTIFIES CHANGES
  void addGroups(List<Group> groups) {
    for (Group group in groups) {
      if(!_userGroups.any((element) => element.groupId == group.groupId)) {
        _userGroups.add(group);
      }
    }
    notifyListeners();
  }

  /// removes a specific [group] form [_userGroups]
  /// removes the markers of this group from [_shownMarkers] and [_allMarkers] if the [group] is currently active
  /// NOTIFIES CHANGES
  void removeGroup(Group group) {
    if (group.active) {
      for (Pin pin in group.getSyncPins()) {
        removePin(pin);
      }
    }
    _userGroups.remove(group);
    notifyListeners();
  }

  /// adds a [group] to [_userGroups] if not already existing
  /// NOTIFIES CHANGES
  void addGroup(Group group) {
    if(!_userGroups.any((element) => element.groupId == group.groupId)) {
      _userGroups.add(group);
    }
    notifyListeners();
  }

  /// clears all values from lists, attributes and maps
  void clearAll() {
    //TODO remove all offline pins too?
    _userGroups.clear();
    _offlinePins.clear();
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
    (await group.getPins()).add(pin);
    if (group.active) {
      _addPinToMarkers(pin, false);
    }
    if (group.members != null) {
      group.members!.firstWhere((element) => element.username == global.username).addOnePoint();
      group.members!.sort((a,b) =>  a.points.compareTo(b.points) * -1);
    }
    _updateValues();
  }

  /// activates the [group] : the group will show its marker on the map and the feed
  /// also includes offline pins of this group
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> activateGroup(Group group) async{
    if (!group.active) {
      //get pins from server of the specific groups if not already loaded
      Set<Pin> pins = await group.getPins();
      //converts pins to markers on googel maps
      for (Pin pin in pins) {
        await _addPinToMarkers(pin, false);
      }
      //converts offline pins to markers if member of group
      for (Pin mona in _offlinePins) {
          await _addPinToMarkers(mona, true);
      }
      group.active = true;
      _updateValues();
    }
  }

  /// deactivate the [group] : the groups pins will be removed from the map and the feed
  /// also includes offline pins of this group
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deactivateGroup(Group group) async {
    if (group.active) {
      //removes markers from maps
      for (Pin pin in group.getSyncPins()) {
         _removePinFromMarkers(pin);
      }
      //removes offline markers from maps
      for (Pin mona in _offlinePins) {
        if (mona.group == group) {
          _removePinFromMarkers(mona);
        }
      }
      group.active = false;
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
    pin.group.removePin(pin);
    _removePinFromMarkers(pin);
    _updateValues();
  }

  /// returns [_offlinePins] attribute
  List<Pin> getOfflinePins() {return _offlinePins;}

  /// loads all offline pins from device storage
  Future<List<Pin>> loadOfflinePins() async{
    return await _offlineFileHandler.readFile(_userGroups);
  }

  /// removes [oldPin] from [_offlinePins]
  /// adds [newPin] to [newPin.group]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deleteOfflinePinAndAddToOnline(Pin newPin, Pin oldPin) async{
    await deleteOfflinePin(oldPin);
    addPin(newPin);
  }

  /// remove [mona] from [_offlinePins] and device storage
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> deleteOfflinePin(Pin mona) async{
    _removeOfflinePinFromMarkers(mona);
    await _offlineFileHandler.saveList(_offlinePins);
    _updateValues();
  }

  /// adds an offline [Pin] to device storage
  /// adds marker of offline pin to map if group is active
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> addOfflinePin(Pin mona) async{
    if (mona.group.active) {
      await _addOfflinePinToMarkers(mona);
    }
    await _offlineFileHandler.saveList(_offlinePins);
    _updateValues();
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

  /// adds [mona] to [_offlinePins] and to map markers
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void> _addOfflinePinToMarkers(Pin mona) async{
    await _addPinToMarkers(mona, true);
    _offlinePins.add(mona);
    _updateValues();
  }

  /// remove [mona] from [_offlinePins] and map markers
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  void _removeOfflinePinFromMarkers(Pin mona) {
    _offlinePins.remove(mona);
    _removePinFromMarkers(mona);
    _updateValues();
  }

  /// remove [pin] from [_allMarkers]
  void _removePinFromMarkers(Pin pin) {
    _allMarkers.remove(pin);
  }

  /// adds a Marker with attributes from [pin] to [_allMarkers]
  /// key id of pin: '[pin.id]'
  /// key of offline pin: 'new[pin.id]'
  _addPinToMarkers(Pin pin, bool offlinePin) {
    _allMarkers[pin] = (
      Marker(
          key: Key((offlinePin ? "new${pin.id.toString()}" : pin.id.toString())),
          point: LatLng(pin.latitude, pin.longitude), 
          builder: (_)  => GestureDetector(
            child: pin.group.getPinImageWidget(),
            onTap: () => Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => ShowImageWidget(newPin: offlinePin, pin: pin,)),
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