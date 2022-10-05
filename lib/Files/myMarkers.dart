import 'dart:math';
import 'package:buff_lisa/3_ScreenAddPin/dialog.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/pin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../main.dart';
import 'io.dart';
import 'mapMarker.dart';

class MyMarkers {
  List<Pin> allPins = [];
  List<Mona> userNewCreatedPins = [];
  List<MapMarker> markers = [];
  int versionId = -1;
  final IO io;

  MyMarkers({required this.io});

  /*Future<void> loop() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      try {
        List<Version> versions = await RestAPI.checkVersion(versionId);
        for (Version v in versions) {
          if (v.type == 0) {
            Pin? pin = await RestAPI.fetchPin(v.pinId);
            if (pin != null) {
              addAllPins(pin);
            }
          } else if (v.type == 1) {
            removeById(v.pinId);
          }
          versionId = v.id;
        }
        int? p = await RestAPI.getUserPoints();
        io.userPoints = p!;
      } catch (e) {
        print(e);
      }
    }
  }*/

  void removeById(int id) {
    MapMarker? m2;
    for (MapMarker m in markers) {
      if (m.id == id.toString()) {
        m2 = m;
      }
    }
    markers.remove(m2);
    Pin? p;
    for (Pin pin in allPins) {
      if (pin.id == id) {
        p = pin;
      }
    }
    allPins.remove(p);
  }

  bool removePinFromSet(Set<Pin> pins, int id) {
    for (Pin pin in pins) {
      if (pin.id == id) {
        pins.remove(pin);
        return true;
      }
    }
    return false;
  }


  int numAllPins() {
    return markers.length;
  }

  void setAllPins(List<Pin> pins) {
    allPins = pins;
    addPinsToMarker(allPins, false);
  }

  void addAllPins(Pin pin) {
    allPins.add(pin);
    addPinToMarkers(pin, false, null);
    io.initFluster();
  }

  void setUserPinsNewCreated(List<Mona> monas) {
    userNewCreatedPins = monas;
    List<Pin> pins = [];
    for (var element in userNewCreatedPins) {pins.add(element.pin);}
    addPinsToMarker(pins,true);
  }

  void addUserPinsNewCreated(Mona mona) {
    userNewCreatedPins.add(mona);
    addPinToMarkers(mona.pin, true, mona.image);
    io.initFluster();
  }

  void removeUserPinsNewCreated(Mona mona) {
    userNewCreatedPins.remove(mona);
  }

  void addPinsToMarker(List<Pin> pins, bool newPin) {
    for (Pin pin in pins) {
        addPinToMarkers(pin, newPin, null);
    }
    io.initFluster();
  }


  Future<BitmapDescriptor> getBitMapDescriptor (int type) async {
    BitmapDescriptor bitmapDescriptor = BitmapDescriptor.defaultMarker;
    switch (type) {
      case 0 : bitmapDescriptor = await  BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(5, 5)), 'images/c_marker_lisa_100px.png'); break;
      case 1 : bitmapDescriptor = await  BitmapDescriptor.fromAssetImage(const ImageConfiguration(size: Size(5, 5)), 'images/c_marker_tornado_100px.png'); break;
    }
    return bitmapDescriptor;
  }

  void addPinToMarkers(Pin pin, bool newPin, XFile? image) {
    getBitMapDescriptor(pin.type.id)
        .then((d) {
      //customIcon = BitmapDescriptor.defaultMarkerWithHue(bitmapDescriptor);
      MapMarker marker = MapMarker(
          id: (newPin ? "new${pin.id.toString()}" : pin.id.toString()),
          position: LatLng(pin.latitude, pin.longitude),
          icon: d ,
          onMarkerTap: () {
            showDialog(
                context: navigatorKey.currentContext!,
                builder: (context) => SimpleDialogItem.getPinDialog(pin.id, newPin, image, navigatorKey.currentContext!)
            );
          }
      );
      markers.add(marker);
    });

  }
}