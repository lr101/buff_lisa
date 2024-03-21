import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../2_ScreenMaps/ClickOnPin/image_widget_logic.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/pin.dart';
import '../main.dart';

class
MarkerNotifier with ChangeNotifier {

  /// map of pins and their corresponding markers that are currently selected by active groups
  /// includes all pins by active groups even when some are not shown by applying filters
  final Map<Pin, Marker> _allMarkers = {};

  /// list of markers that are currently shown
  /// filters affect the shown markers
  List<Marker> _shownMarkers = [];

  /// all pins than are created after [__filterDateMax] are removed
  /// all pins from 'infinity small' to [__filterDateMax] are NOT removed
  /// null: does NOT filter any pins
  DateTime? __filterDateMax;

  /// all pins that are created before [__filterDateMin] are removed
  /// all pins from [__filterDateMin] to current time are NOT removed
  /// null: does NOT filter any pins
  DateTime? __filterDateMin;

  /// list of users that are filtered in [_shownMarkers]
  List<String> __filterUsernames = [];

  void removeMarker(Pin pin) {
    _allMarkers.removeWhere((key, value) => key.id == pin.id && key.group.groupId == pin.group.groupId);
  }

  void addMarker(Pin pin) {
    _allMarkers[pin] = (
        Marker(
            key: Key((pin.isOffline ? "${pin.group.groupId}${pin.id.toString()}" : pin.id.toString())),
            point: LatLng(pin.latitude, pin.longitude),
            child: GestureDetector(
              child: pin.group.pinImage.getWidget(),
              onTap: () => Navigator.push(
                navigatorKey.currentContext!,
                MaterialPageRoute(builder: (context) => ShowImageWidget(pin: pin,)),
              ),
            )
        )
    );
  }

  /// updates the [_shownMarkers] list by rebuilding and filtering all markers form [_allMarkers]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  Future<void>  update() async {
    Map<Pin, Marker> mark = Map.from(_allMarkers);
    mark = _filterMaxDate(mark);
    mark = _filterMinDate(mark);
    mark = _filterUsers(mark);
    _shownMarkers = List.from(mark.values);
    notifyListeners();
  }

  /// set [__filterDateMin] to [filterDateMin]
  /// set [__filterDateMax] to [filterDateMax]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  void setFilterDate(DateTime? filterDateMin, DateTime? filterDateMax) {
    __filterDateMin = filterDateMin;
    __filterDateMax = filterDateMax;
    update();
  }

  /// set [__filterUsernames] to [usernames]
  /// REBUILD MAP MARKERS
  /// NOTIFIES CHANGES
  void setFilterUsername(List<String> usernames) {
    __filterUsernames = usernames;
    update();
  }

  void clear() {
    _shownMarkers.clear();
    _allMarkers.clear();
    __filterUsernames.clear();
    __filterDateMax = null;
    __filterDateMin = null;
    update();
  }

  /// filter to filter all pins in [mark] with [__filterDateMin]
  Map<Pin, Marker> _filterMinDate(Map<Pin, Marker> mark) {
    if (__filterDateMin == null) return mark;
    mark.removeWhere((k,v) => k.creationDate.isBefore(__filterDateMin!));
    return mark;
  }

  /// filter to filter all pins in [mark] with [__filterDateMax]
  Map<Pin, Marker> _filterMaxDate(Map<Pin, Marker> mark) {
    if (__filterDateMax == null) return mark;
    mark.removeWhere((k,v) => k.creationDate.isAfter(__filterDateMax!));
    return mark;
  }

  Map<Pin, Marker> _filterUsers(Map<Pin, Marker> mark) {
    if (__filterUsernames.isEmpty) return mark;
    if (__filterUsernames.length == 1)  {
      mark.removeWhere((key, value) => key.username != __filterUsernames.first);
    } else {
      mark.removeWhere((key, value) => !__filterUsernames.any((element) => element == key.username));
    }
    return mark;

  }

  List<Marker> get getMarkers => List.from(_shownMarkers);
}