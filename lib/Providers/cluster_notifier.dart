import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Files/fetch_pins.dart';
import '../Files/global.dart' as global;
import '../2_ScreenMaps/image_widget_logic.dart';
import '../Files/file_handler.dart';
import '../Files/DTOClasses/pin.dart';
import '../main.dart';

class ClusterNotifier extends ChangeNotifier {
  final FileHandler _offlineFileHandler = FileHandler(fileName: global.fileName);
  late  List<Group> _userGroups = [];
  late List<Pin> _offlinePins = [];
  Group? _lastSelected;

  ///cluster
  Map<Pin, Marker> _allMarkers = {};
  List<Marker> _shownMarkers = [];
  List<String> __filterUsernames = [];
  DateTime? __filterDateMax;
  DateTime? __filterDateMin;

  ///public Methods

  void addGroups(List<Group> groups) {
    for (Group group in groups) {
      if(!_userGroups.any((element) => element.groupId == group.groupId)) {
        _userGroups.add(group);
      }
    }
    notifyListeners();
  }

  void addGroup(Group group) {
    if(!_userGroups.any((element) => element.groupId == group.groupId)) {
      _userGroups.add(group);
    }
    notifyListeners();
  }

  void clearAll() {
    //TODO remove all offline pins too?
    _userGroups.clear();
    _offlinePins.clear();
    _shownMarkers.clear();
    _allMarkers.clear();
    __filterUsernames.clear();
    __filterDateMax = null;
    __filterDateMin = null;
    notifyListeners();
  }

  Group getGroupByGroupId(int groupId) {
    return _userGroups.firstWhere((element) => element.groupId == groupId);
  }

  Future<void> addPin(Pin pin)  async {
    Group group = pin.group;
    (await group.getPins()).add(pin);
    if (group.active) {
      _addPinToMarkers(pin, false);
    }
    _updateValues();
  }

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

  Future<void> removePin(Pin pin) async {
    await FetchPins.deleteMonaFromPinId(pin.id);
    pin.group.removePin(pin);
    _removePinFromMarkers(pin);
    _updateValues();
  }

  List<Pin> getOfflinePins() {return _offlinePins;}

  Future<List<Pin>> loadOfflinePins() async{
    return (await _offlineFileHandler.readFile(0, _userGroups)).map((e) => e as Pin).toList();
  }

  Future<void> deleteOfflinePinAndAddToOnline(Pin newPin, Pin oldPin) async{
    await deleteOfflinePin(oldPin);
    addPin(newPin);
  }

  Future<void> deleteOfflinePin(Pin mona) async{
    _removeOfflinePinFromMarkers(mona);
    await _offlineFileHandler.saveList(_offlinePins);
    _updateValues();
  }

  Future<void> addOfflinePin(Pin mona) async{
    if (mona.group.active) {
      await _addOfflinePinToMarkers(mona);
    }
    await _offlineFileHandler.saveList(_offlinePins);
    _updateValues();
  }


  List<Marker> get getMarkers {
    return _shownMarkers;
  }

  List<Group> get getGroups {
    return _userGroups;
  }

  Group? get getLastSelected {
    return _lastSelected;
  }

  Set<Group> get getActiveGroups {
    Set<Group> activeGroups = {};
    for (Group group in _userGroups) {
      if (group.active) activeGroups.add(group);
    }
    return activeGroups;
  }

  void setLastSelected(Group group) {
    _lastSelected = group;
    notifyListeners();
  }
  ///private Methods

  void setFilterDate(DateTime? filterDateMin, DateTime? filterDateMax) {
    __filterDateMin = filterDateMin;
    __filterDateMax = filterDateMax;
    _updateValues();
  }

  void setFilterUsername(List<String> usernames) {
    __filterUsernames = usernames;
    _updateValues();
  }

  Future<void> _addOfflinePinToMarkers(Pin mona) async{
    await _addPinToMarkers(mona, true);
    _offlinePins.add(mona);
    _updateValues();
  }

  void _removeOfflinePinFromMarkers(Pin mona) {
    _offlinePins.remove(mona);
    _removePinFromMarkers(mona);
    _updateValues();
  }

  void _removePinFromMarkers(Pin pin) {
    _allMarkers.remove(pin);
  }


  _addPinToMarkers(Pin pin, bool newPin) {
    _allMarkers[pin] = (
      Marker(
          key: Key((newPin ? "new${pin.id.toString()}" : pin.id.toString())),
          point: LatLng(pin.latitude, pin.longitude), 
          builder: (_)  => GestureDetector(
            child: pin.group.getPinImageWidget(),
            onTap: () => Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => ShowImageWidget(newPin: newPin, pin: pin,)),
            ),
          )
      )
    );
  }


  Future<void>  _updateValues() async {
    Map<Pin, Marker> mark = Map.from(_allMarkers);
    _filterMaxDate(mark);
    _filterMinDate(mark);
    _shownMarkers = List.from(mark.values);
    notifyListeners();
  }

  void _filterMinDate(Map<Pin, Marker> mark) {
    if (__filterDateMin == null) return;
    mark.removeWhere((k,v) => k.creationDate.isBefore(__filterDateMin!));
  }

  void _filterMaxDate(Map<Pin, Marker> mark) {
    if (__filterDateMax == null) return;
    mark.removeWhere((k,v) => k.creationDate.isAfter(__filterDateMax!));
  }

}