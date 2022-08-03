import 'dart:math';
import 'package:buff_lisa/3_ScreenAddPin/dialog.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../Files/global.dart' as global;
import 'package:buff_lisa/Files/pin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../main.dart';
import 'mapMarker.dart';

class MyMarkers {
  Set<Pin> userPinsCreated = {};
  Set<Pin> userPinsFound = {};
  Set<Mona> userNewCreatedPins = {};
  List<Pin> notUserPins = [];
  List<MapMarker> markers = [];
  List<Pin> notUserPinsInRadius = [];
  int versionId = -1;

  Future<void> loop() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 10));
      try {
        List<Version> versions = await RestAPI.checkVersion(versionId);
        for (Version v in versions) {
          if (v.type == 0) {
            Pin? pin = await RestAPI.fetchPin(v.pinId);
            if (pin != null) {
              addNotUserPin(pin);
            }
          } else if (v.type == 1) {
            removeById(v.pinId);
          }
          versionId = v.id;
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void removeById(int id) {
    MapMarker? m2;
    for (MapMarker m in markers) {
      if (m.id == id.toString()) {
        m2 = m;
      }
    }
    markers.remove(m2);
    Pin? p;
    for (Pin pin in notUserPins) {
      if (pin.id == id) {
        p = pin;
      }
    }
    notUserPins.remove(p);
    notUserPinsInRadius.remove(p);
    if (p != null) {
      if (removePinFromSet(userPinsFound, id)) {
        removePinFromSet(userPinsCreated, id);
      }
    }
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

  int numUserPins() {
    return userPinsCreated.length + userNewCreatedPins.length + userPinsFound.length;
  }

  int numAllPins() {
    return markers.length;
  }

  void setUserPinsCreated(Set<Pin> pins) {
    userPinsCreated = pins;
    addPinsToMarker(userPinsCreated, false);
  }

  void addUserPinsCreated(Pin pin) {
    userPinsCreated.add(pin);
    addPinToMarkers(pin, false, null);

  }

  void setUserPinsFound(Set<Pin> pins) {
    userPinsFound = pins;
    addPinsToMarker(userPinsFound, false);
  }

  void addUserPinsFound(Pin pin) {
    userPinsFound.add(pin);
    addPinToMarkers(pin, false, null);
  }

  void setUserPinsNewCreated(Set<Mona> monas) {
    userNewCreatedPins = monas;
    Set<Pin> pins = {};
    for (var element in userNewCreatedPins) {pins.add(element.pin);}
    addPinsToMarker(pins,true);
  }

  void addUserPinsNewCreated(Mona mona) {
    userNewCreatedPins.add(mona);
    addPinToMarkers(mona.pin, true, mona.image);
  }

  void removeUserPinsNewCreated(Mona mona) {
    userNewCreatedPins.remove(mona);
  }

  void setNotUserPins(List<Pin> pins) {
    notUserPins = pins;
    addPinsToMarker(notUserPins.toSet(), false);
  }

  void addNotUserPin(Pin pin) {
    notUserPins.add(pin);
    addPinToMarkers(pin, false, null);
  }

  void addPinsToMarker(Set<Pin> pins, bool newPin) {
    for (Pin pin in pins) {
        addPinToMarkers(pin, newPin, null);
    }
  }

  Pin movePinToFound(int index) {
    Pin pin = notUserPinsInRadius[index];
    notUserPinsInRadius.remove(pin);
    notUserPins.remove(pin);
    userPinsFound.add(pin);
    for (MapMarker marker in markers) {
      if (marker.id == pin.id.toString()) {
        markers.remove(marker);
        addPinToMarkers(pin, false, null);
        break;
      }
    }
    return pin;
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


  void calcNotUserPinsInRadius(double lat, double long) {
    notUserPinsInRadius.clear();
    for (var element in notUserPins) {
      if (filter(element, lat, long)) {
        notUserPinsInRadius.add(element);
      }
    }
    notUserPinsInRadius.sort((a,b) => sort(a, b, lat, long));
  }

  static int sort(Pin a, Pin b, double lat, double lang) {
    double d1 = calcDistance(a.latitude, a.longitude, lat, lang);
    double d2 = calcDistance(b.latitude, b.longitude, lat, lang);
    a.distance.d = d1;
    b.distance.d = d2;
    if (d1 < d2) {
      return (d2 - d1).round();
    } else {
      return (d1 - d2).round();
    }
  }

  static bool filter(Pin a,  double lat, double long) {
    return (calcDistance(a.latitude, a.longitude, lat, long) <= global.circleRadius);
  }

  static double calcDistance(double lat1,double lon1,double lat2,double lon2) {
    double p = 0.017453292519943295;
    double a = 0.5 - cos((lat2 - lat1) * p)/2 +
        cos(lat1 * p) * cos(lat2 * p) *
            (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

}