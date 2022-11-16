import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Files/DTOClasses/mona.dart';
import '../Files/global.dart' as global;
import '../2_ScreenMaps/image_widget_logic.dart';
import '../Files/file_handler.dart';
import '../Files/map_helper.dart';
import '../Files/map_marker.dart';
import '../Files/DTOClasses/pin.dart';
import '../main.dart';

class ClusterNotifier extends ChangeNotifier {
  final FileHandler _offlineFileHandler = FileHandler(fileName: global.fileName);
  late  List<Group> _userGroups = [];
  late List<Mona> _offlinePins = [];
  late List<MapMarker> _markers = [];
  Group? _lastSelected;

  ///cluster
  List<Marker> _googleMapsMarkers = [];
  int _currentZoom = global.initialZoom;
  late Fluster<MapMarker> _fluster;
  List<String> __filterUsernames = [];
  DateTime? __filterDateMax;
  DateTime? __filterDateMin;

  ClusterNotifier()  {
    _updateValues();
  }

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
    _userGroups = [];
    _offlinePins = [];
    _markers =  [];
    _googleMapsMarkers = [];
    __filterUsernames = [];
    __filterDateMax = null;
    __filterDateMin = null;
    _updateValues();
  }

  Future<void> addPin(Pin pin, int groupId) async {
    _userGroups.firstWhere((element) => element.groupId == groupId).pins.add(pin);
    await _addPinToMarkers(pin, false, null, groupId);
    _updateValues();
  }

  int getAllPoints() {
    int points = 0;
    for (Group group in _userGroups) {
      points += group.pins.length;
    }
    return points;
  }

  Future<void> activateGroup(Group group) async{
    if (!group.active) {
      //get pins from server of the specific groups if not already loaded
      if (!group.loaded) {
        group.pins = await RestAPI.fetchGroupPins(group.groupId);
        group.loaded = true;
      }
      //converts pins to markers on googel maps
      for (Pin pin in group.pins) {
        await _addPinToMarkers(pin, false, null, group.groupId);
      }
      //converts offline pins to markers if member of group
      for (Mona mona in _offlinePins) {
        if (mona.pin.groupId == group.groupId) {
          await _addPinToMarkers(mona.pin, true, mona.image, group.groupId);
        }
      }
      group.active = true;
      _updateValues();
    }
  }

  Future<void> deactivateGroup(Group group) async {
    if (group.active) {
      //removes markers from maps
      for (Pin pin in group.pins) {
         _removePinFromMarkers(pin.id, false);
      }
      //removes offline markers from maps
      for (Mona mona in _offlinePins) {
        if (mona.pin.groupId == group.groupId) {
          _removePinFromMarkers(mona.pin.id, true);
        }
      }
      group.active = false;
      _updateValues();
    }
  }

  void removePin(int id, int groupId) {
    Group group = _userGroups.firstWhere((element) => element.groupId == groupId);
    group.pins.removeWhere((e) => e.id == id);
    _removePinFromMarkers(id, false);
    _updateValues();
    //await io.clusterHandler.updateValues();
  }

  List<Mona> getOfflinePins() {return _offlinePins;}

  Future<void> loadOfflinePins() async{
    List<Mona> monas = (await _offlineFileHandler.readFile(0)).map((e) => e as Mona).toList();
    for (Mona mona  in monas) {
      await _addOfflinePinToMarkers(mona, mona.pin.groupId);
    }
    _updateValues();
  }

  Future<void> deleteOfflinePin(int id) async{
    _removeOfflinePinFromMarkers(id);
    await _offlineFileHandler.saveList(_offlinePins);
    _updateValues();
  }

  Future<void> addOfflinePin(Mona mona) async{
    await _addOfflinePinToMarkers(mona, mona.pin.groupId);
    await _offlineFileHandler.saveList(_offlinePins);
    _updateValues();
  }


  Set<Marker> get getMarkers {
    return _googleMapsMarkers.toSet();
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

  void setZoom(int zoom) {
    if (_currentZoom != zoom) {
      _currentZoom = zoom;
      _updateValues();
    }
  }

  void setFilterDate(DateTime? filterDateMin, DateTime? filterDateMax) {
    __filterDateMin = filterDateMin;
    __filterDateMax = filterDateMax;
    _updateValues();
  }

  void setFilterUsername(List<String> usernames) {
    __filterUsernames = usernames;
    _updateValues();
  }

  ///private Methods

  Future<void> _addOfflinePinToMarkers(Mona mona, int groupId) async{
    await _addPinToMarkers(mona.pin, true, mona.image, groupId);
    _offlinePins.add(mona);
    _updateValues();
  }

  void _removeOfflinePinFromMarkers(int id) {
    _offlinePins.removeWhere((e) => e.pin.id == id);
    _removePinFromMarkers(id, true);
    _updateValues();
  }

  void _removePinFromMarkers(int pinId, bool newPin) {
    _markers.removeWhere((e) => e.id == (newPin ? "new${pinId.toString()}" : pinId.toString()));
  }

  Future<BitmapDescriptor> _getBitMapDescriptor (int groupId) async {

    try {
      return BitmapDescriptor.fromBytes(_userGroups.firstWhere((element) => element.groupId == groupId).pinImage!);
    } catch(_) {
      //Default image
      return await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_logo.png');
    }
  }

  Future<void> _addPinToMarkers(Pin pin, bool newPin, Uint8List? image, groupId) async {
    BitmapDescriptor icon = await _getBitMapDescriptor(groupId);
    MapMarker marker = MapMarker(
        id: (newPin ? "new${pin.id.toString()}" : pin.id.toString()),
        pin: pin,
        position: LatLng(pin.latitude, pin.longitude),
        icon: icon ,
        onMarkerTap: () {
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (context) => ShowImageWidget(image: image, id: pin.id, newPin: newPin, groupId: groupId)),
          );
        }
    );
    _markers.add(marker);
  }


  Future<void>  _updateValues() async {
    List<MapMarker> markers = List.from(_markers);
    markers = _filterUsernames(markers);
    markers = _filterMinDate(markers);
    markers = _filterMaxDate(markers);
    _fluster = await MapHelper.initClusterManager(markers, 0, 14);
    _displayMarkers();
  }

  _displayMarkers() {
    _googleMapsMarkers = MapHelper.getClusterMarkers(_fluster, _currentZoom);
    notifyListeners();
  }

  List<MapMarker> _filterUsernames(List<MapMarker> markers) {
    if (__filterUsernames.isEmpty) return markers;
    List<String> ids = _markers.where((element) => __filterUsernames.contains(element.pin!.username)).toList().map((e) => e.id.toString()).toList();
    if (__filterUsernames.contains(global.username)) ids.addAll(_offlinePins.map((e) => e.pin.id.toString()));
    return markers.where((element) => ids.contains(element.id)).toList();
  }

  List<MapMarker> _filterMinDate(List<MapMarker> markers) {
    if (__filterDateMin == null) return markers;
    List<String> ids = _markers.where((element) => element.pin!.creationDate.isAfter(__filterDateMin!)).toList().map((e) => e.id.toString()).toList();
    ids.addAll(_offlinePins.where((element) => element.pin.creationDate.isAfter(__filterDateMin!)).toList().map((e) => e.pin.id.toString()).toList());
    return markers.where((element) => ids.contains(element.id)).toList();
  }

  List<MapMarker> _filterMaxDate(List<MapMarker> markers) {
    if (__filterDateMax == null) return markers;
    List<String> ids = _markers.where((element) => element.pin!.creationDate.isBefore(__filterDateMax!)).toList().map((e) => e.id.toString()).toList();
    ids.addAll(_offlinePins.where((element) => element.pin.creationDate.isBefore(__filterDateMax!)).toList().map((e) => e.pin.id.toString()).toList());
    return markers.where((element) => ids.contains(element.id)).toList();
  }
}