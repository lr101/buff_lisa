import 'package:buff_lisa/2_ScreenMaps/imageWidget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/pin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../main.dart';
import 'io.dart';
import 'mapMarker.dart';

class MarkerHandler {
  List<Pin> allPins = [];
  List<Mona> userNewCreatedPins = [];
  List<MapMarker> markers = [];


  Future<void> addPin(Pin pin,IO io) async{
    allPins.add(pin);
    addPinToMarkers(pin, false, null, io);
    await io.clusterHandler.updateValues();
  }

  Future<void> removePin(int id, IO io) async {
    allPins.removeWhere((e) => e.id == id);
    removePinFromMarkers(id, false);
    await io.clusterHandler.updateValues();
  }

  Future<void> addUserPinsNewCreated(Mona mona, IO io) async{
    addPinToMarkers(mona.pin, true, mona.image, io);
    userNewCreatedPins.add(mona);
    await io.clusterHandler.updateValues();
  }

  Future<void> removeUserPinsNewCreated(int id, IO io) async{
    userNewCreatedPins.removeWhere((e) => e.pin.id == id);
    removePinFromMarkers(id, true);
    await io.clusterHandler.updateValues();
  }

  Future<void> addPinsToMarkers(List<Pin> pins, IO io) async{
    for (Pin pin in pins) {
        addPinToMarkers(pin, false, null, io);
        allPins.add(pin);
    }
    await io.clusterHandler.updateValues();
  }

  void removePinFromMarkers(int pinId, bool newPin) {
    markers.removeWhere((e) => e.id == (newPin ? "new${pinId.toString()}" : pinId.toString()));
  }


  Future<BitmapDescriptor> getBitMapDescriptor (int type) async {
    BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
    switch (type) {
      case 0 : bitmapDescriptor = await  BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(5, 5)), 'images/c_marker_lisa_100px.png'); break;
      case 1 : bitmapDescriptor = await  BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(5, 5)), 'images/c_marker_tornado_100px.png'); break;
    }
    return bitmapDescriptor;
  }

  void addPinToMarkers(Pin pin, bool newPin, XFile? image, IO io) {
    getBitMapDescriptor(pin.type.id)
        .then((d) {
      //customIcon = BitmapDescriptor.defaultMarkerWithHue(bitmapDescriptor);
      MapMarker marker = MapMarker(
          id: (newPin ? "new${pin.id.toString()}" : pin.id.toString()),
          position: LatLng(pin.latitude, pin.longitude),
          icon: d ,
          onMarkerTap: () {
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (context) => ShowImageWidget(image: image, id: pin.id, newPin: newPin, io: io)),
            );
          }
      );
      markers.add(marker);
    });

  }
}