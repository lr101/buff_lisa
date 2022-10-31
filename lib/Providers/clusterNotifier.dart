import 'package:camera/camera.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Files/global.dart' as global;
import '../2_ScreenMaps/imageWidget.dart';
import '../Files/fileHandler.dart';
import '../Files/mapHelper.dart';
import '../Files/mapMarker.dart';
import '../Files/pin.dart';
import '../main.dart';

class ClusterNotifier extends ChangeNotifier {
  final FileHandler _offlineFileHandler = FileHandler(fileName: global.fileName);
  final List<Pin> _allPins = [];
  final List<Mona> _offlinePins = [];
  final List<MapMarker> _markers = [];
  
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

  Future<void> addPin(Pin pin) async {
    _allPins.add(pin);
    await _addPinToMarkers(pin, false, null);
    _updateValues();
  }

  List<Pin> getAllPins() {return _allPins;}

  Future<void> addPins(List<Pin> pins) async{
    for (Pin pin in pins) {
      await _addPinToMarkers(pin, false, null);
      _allPins.add(pin);
    }
    _updateValues();
  }

  void removePin(int id) {
    _allPins.removeWhere((e) => e.id == id);
    _removePinFromMarkers(id, false);
    _updateValues();
    //await io.clusterHandler.updateValues();
  }

  List<Mona> getOfflinePins() {return _offlinePins;}

  Future<void> loadOfflinePins() async{
    List<Mona> monas = (await _offlineFileHandler.readFile(0)).map((e) => e as Mona).toList();
    for (Mona mona  in monas) {
      await _addOfflinePinToMarkers(mona);
    }
    _updateValues();
  }

  Future<void> deleteOfflinePin(int id) async{
    _removeOfflinePinFromMarkers(id);
    await _offlineFileHandler.saveList(_offlinePins);
    _updateValues();
  }

  Future<void> addOfflinePin(Mona mona) async{
    await _addOfflinePinToMarkers(mona);
    await _offlineFileHandler.saveList(_offlinePins);
    _updateValues();
  }


  Set<Marker> get getMarkers {
    return _googleMapsMarkers.toSet();
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

  Future<void> _addOfflinePinToMarkers(Mona mona) async{
    await _addPinToMarkers(mona.pin, true, mona.image);
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

  Future<BitmapDescriptor> _getBitMapDescriptor (int type) async {
    BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
    switch (type) {
      case 0 : bitmapDescriptor = await  BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(5, 5)), 'images/c_marker_lisa_100px.png'); break;
      case 1 : bitmapDescriptor = await  BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(5, 5)), 'images/c_marker_tornado_100px.png'); break;
    }
    return bitmapDescriptor;
  }

  Future<void> _addPinToMarkers(Pin pin, bool newPin, XFile? image) async {
    BitmapDescriptor icon = await _getBitMapDescriptor(pin.type.id);
    MapMarker marker = MapMarker(
        id: (newPin ? "new${pin.id.toString()}" : pin.id.toString()),
        position: LatLng(pin.latitude, pin.longitude),
        icon: icon ,
        onMarkerTap: () {
          Navigator.push(
            navigatorKey.currentContext!,
            MaterialPageRoute(builder: (context) => ShowImageWidget(image: image, id: pin.id, newPin: newPin)),
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
    List<String> ids = _allPins.where((element) => __filterUsernames.contains(element.username)).toList().map((e) => e.id.toString()).toList();
    if (__filterUsernames.contains(global.username)) ids.addAll(_offlinePins.map((e) => e.pin.id.toString()));
    return markers.where((element) => ids.contains(element.id)).toList();
  }

  List<MapMarker> _filterMinDate(List<MapMarker> markers) {
    if (__filterDateMin == null) return markers;
    List<String> ids = _allPins.where((element) => element.creationDate.isAfter(__filterDateMin!)).toList().map((e) => e.id.toString()).toList();
    ids.addAll(_offlinePins.where((element) => element.pin.creationDate.isAfter(__filterDateMin!)).toList().map((e) => e.pin.id.toString()).toList());
    return markers.where((element) => ids.contains(element.id)).toList();
  }

  List<MapMarker> _filterMaxDate(List<MapMarker> markers) {
    if (__filterDateMax == null) return markers;
    List<String> ids = _allPins.where((element) => element.creationDate.isBefore(__filterDateMax!)).toList().map((e) => e.id.toString()).toList();
    ids.addAll(_offlinePins.where((element) => element.pin.creationDate.isBefore(__filterDateMax!)).toList().map((e) => e.pin.id.toString()).toList());
    return markers.where((element) => ids.contains(element.id)).toList();
  }
}