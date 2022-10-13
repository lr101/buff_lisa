import 'dart:async';
import 'package:buff_lisa/Files/MarkerHandler.dart';
import 'package:buff_lisa/Files/pin.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Files/global.dart' as global;
import 'mapHelper.dart';
import 'mapMarker.dart';
import 'MarkerHandler.dart';

class ClusterHandler {

  int _currentZoom = global.initialZoom;
  MarkerHandler markerHandler;
  final _markerController = StreamController<List<Marker>>.broadcast();
  final _cameraZoomController = StreamController<double>.broadcast();
  List<String> filterUsernames = [];
  DateTime? filterDateMax;
  DateTime? filterDateMin;

  /// Outputs.
  Stream<List<Marker>> get markers => _markerController.stream;
  Stream<double> get cameraZoom => _cameraZoomController.stream;

  /// Inputs.
  Function(List<Marker>) get addMarkers => _markerController.sink.add;
  Function(double) get setCameraZoom => _cameraZoomController.sink.add;



  /// Fluster!
  late Fluster<MapMarker> _fluster;
  late StreamSubscription _cameraZoomSubscription;

  ClusterHandler (this.markerHandler) {

    _cameraZoomSubscription = cameraZoom.listen((zoom) {
      if (_currentZoom != zoom.toInt()) {
        _currentZoom = zoom.toInt();

        updateValues();
      }
    });
  }

  /// markers are already loaded by now
  Future<void> updateValues() async {
    List<MapMarker> markers = List.from(markerHandler.markers);
    markers = _filterUsernames(markers);
    markers = _filterMinDate(markers);
    markers = _filterMaxDate(markers);
    _fluster = await MapHelper.initClusterManager(markers, 0, 14);
    await displayMarkers();
  }

  displayMarkers() async {
    List<Marker> markers = MapHelper.getClusterMarkers(_fluster, _currentZoom);
    addMarkers(markers);
  }

  dispose() {
    _cameraZoomSubscription.cancel();

    _markerController.close();
    _cameraZoomController.close();
  }

  List<MapMarker> _filterUsernames(List<MapMarker> markers) {
    if (filterUsernames.isEmpty) return markers;
    List<String> ids = markerHandler.allPins.where((element) => filterUsernames.contains(element.username)).toList().map((e) => e.id.toString()).toList();
    if (filterUsernames.contains(global.username)) ids.addAll(markerHandler.userNewCreatedPins.map((e) => e.pin.id.toString()));
    return markers.where((element) => ids.contains(element.id)).toList();
  }

  List<MapMarker> _filterMinDate(List<MapMarker> markers) {
    if (filterDateMin == null) return markers;
    List<String> ids = markerHandler.allPins.where((element) => element.creationDate.isAfter(filterDateMin!)).toList().map((e) => e.id.toString()).toList();
    ids.addAll(markerHandler.userNewCreatedPins.where((element) => element.pin.creationDate.isAfter(filterDateMin!)).toList().map((e) => e.pin.id.toString()).toList());
    return markers.where((element) => ids.contains(element.id)).toList();
  }

  List<MapMarker> _filterMaxDate(List<MapMarker> markers) {
    if (filterDateMax == null) return markers;
    List<String> ids = markerHandler.allPins.where((element) => element.creationDate.isBefore(filterDateMax!)).toList().map((e) => e.id.toString()).toList();
    ids.addAll(markerHandler.userNewCreatedPins.where((element) => element.pin.creationDate.isBefore(filterDateMax!)).toList().map((e) => e.pin.id.toString()).toList());
    return markers.where((element) => ids.contains(element.id)).toList();
  }


}