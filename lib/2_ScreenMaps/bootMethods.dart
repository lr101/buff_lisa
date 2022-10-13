import 'dart:convert';
import 'dart:io';
import 'package:provider/provider.dart';

import '../Files/global.dart' as global;
import 'package:camera/camera.dart';
import '../0_ScreenSignIn/secure.dart';
import '../Files/io.dart';
import '../Files/pin.dart';
import '../Files/pointsNotifier.dart';
import '../Files/restAPI.dart';

class BootMethods {

  static Future<void> getPins(IO io, callback) async {
    if (io.mapBooted) return;
    io.mapBooted = true;
    await io.loadOfflinePins();
    await tryOfflinePins(io);
    RestAPI.fetchAllPins().then((pins) async {
      await io.clusterHandler.markerHandler.addPinsToMarkers(pins, io);
      await io.clusterHandler.updateValues();
      updateUserPoints(io);
      callback();
    });


  }

  static void updateUserPoints(IO io) {
    Provider.of<PointsNotifier>(io.context, listen: false).setNumAll(io.clusterHandler.markerHandler.allPins.length + io.clusterHandler.markerHandler.userNewCreatedPins.length);
    for (Pin pin in io.clusterHandler.markerHandler.allPins) {
      if (pin.username == global.username) {
        Provider.of<PointsNotifier>(io.context, listen: false).incrementPoints();
      }
    }
  }


  static Future<void> tryOfflinePins(IO io) async {
    List<Mona> monas = List.from(io.clusterHandler.markerHandler.userNewCreatedPins);
    for (Mona mona in monas) {
      final response = await RestAPI.postPin(mona);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await setTempToSavedPin(mona, response, io);
      }
    }
  }

  static Future<void> setTempToSavedPin(Mona mona, HttpClientResponse response, IO io) async {
    Map<String, dynamic> json = jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>;
    Pin pin = Pin.fromJson(json);
    await io.deleteOfflinePin(mona.pin.id);
    await io.clusterHandler.markerHandler.addPin(pin, io);
  }
}