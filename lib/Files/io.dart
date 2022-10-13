import 'dart:convert';
import 'dart:io';
import 'package:buff_lisa/Files/ClusterHandler.dart';
import 'package:buff_lisa/Files/fileHandler.dart';
import 'package:buff_lisa/Files/MarkerHandler.dart';
import 'package:buff_lisa/Files/pin.dart';
import 'package:buff_lisa/Files/pointsNotifier.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import '../Files/global.dart' as global;
import 'mapHelper.dart';
import 'mapMarker.dart';
import 'MarkerHandler.dart';

class IO {

  FileHandler offlinePins = FileHandler(fileName: global.fileName);
  late ClusterHandler clusterHandler;
  late GlobalKey globalKey;
  bool mapBooted = false;
  late BuildContext context;

  IO(this.globalKey, MarkerHandler markerHandler, this.context) {
    clusterHandler = ClusterHandler(markerHandler);
  }

  Future<void> loadOfflinePins() async{
    List<Mona> monas = (await offlinePins.readFile(0)).map((e) => e as Mona).toList();
    for (Mona mona  in monas) {
      await clusterHandler.markerHandler.addUserPinsNewCreated(mona, this);
    }
  }

  Future<void> deleteOfflinePin(int id) async{
    await clusterHandler.markerHandler.removeUserPinsNewCreated(id, this);
    await offlinePins.saveList(clusterHandler.markerHandler.userNewCreatedPins);
  }

  Future<void> addOfflinePin(Mona mona) async{
    await clusterHandler.markerHandler.addUserPinsNewCreated(mona, this);
    await offlinePins.saveList(clusterHandler.markerHandler.userNewCreatedPins);
  }



}
