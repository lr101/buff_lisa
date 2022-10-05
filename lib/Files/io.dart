import 'dart:convert';
import 'dart:io';
import 'package:buff_lisa/Files/myMarkers.dart';
import 'package:buff_lisa/Files/pin.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../Files/global.dart' as global;
import 'mapHelper.dart';
import 'mapMarker.dart';

class IO {

  File? _fileNew;
  late MyMarkers markers = MyMarkers(io: this);
  late Fluster<MapMarker> fluster;
  bool _isMapLoading = true;
  bool _isListUpdating = false;
  double oldZoom =  5;
  late Set<Marker> googleMarkers = {};
  late List<Pin> pinsInRadius = [];
  late GlobalKey globalKey;
  bool mapBooted = false;
  int userPoints = 0;

  IO({required this.globalKey});

  Future<List<Ranking>> getRanking() async {
    return await RestAPI.fetchRanking();
  }

  void initFluster() {
    _isMapLoading = true;
    MapHelper.initClusterManager(markers.markers, 0, 16).then((value) => fluster = value);
    _isMapLoading = false;
  }

  Future<void> updateMarkers(CameraPosition position) async {
    global.initCamera = position;
    double zoom = position.zoom;
    if (_isMapLoading|| oldZoom == zoom || _isListUpdating) return;
    _isListUpdating = true;
    oldZoom == zoom;

    List<Marker> updatedMarkers;
    try {
      updatedMarkers = MapHelper.getClusterMarkers(
        fluster,
        zoom,
      );
    } catch(e) {
      updatedMarkers = [];
    }


    googleMarkers
      ..clear()
      ..addAll(updatedMarkers);
    _isListUpdating = false;
  }

  // Get the data file
  Future<File> get fileNew async {
    if (_fileNew != null) return _fileNew!;

    _fileNew = await _initFile(global.fileName);
    return _fileNew!;
  }


  // Inititalize file
  Future<File> _initFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$name').create(recursive: true);
  }

  Future<void> addNewCreatedPinOffline(Mona mona) async {
    final File fl = await fileNew;
    markers.addUserPinsNewCreated(mona);
    List<Map<String, dynamic>> l = [];
    for (Mona mona in markers.userNewCreatedPins) {
      l.add(await mona.toJson());
    }
    await fl.writeAsString(const JsonEncoder().convert(l));
  }

  Future<void> readNewCreatedPinOffline() async {
    final File fl = await fileNew;
    final content = await fl.readAsString();
    try {
      final List<dynamic> jsonData = await jsonDecode(content);
      List<Mona> monas = [];
      for (Map<String, dynamic> data in jsonData) {
        monas.add(Mona.fromJson(data));
      }
      markers.setUserPinsNewCreated(monas);
    }catch (e) {
      print(e);
    }
  }
  Future<void> deletePinOffline(Mona mona) async {
    final File fl = await fileNew;
    markers.userNewCreatedPins.removeWhere((e) => e == mona);
    List<Map<String, dynamic>> l = [];
    for (Mona mona in markers.userNewCreatedPins) {
      l.add(await mona.toJson());
    }
    await fl.writeAsString(const JsonEncoder().convert(l));
    markers.removeUserPinsNewCreated(mona);
  }


}
