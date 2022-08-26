import 'package:buff_lisa/Files/pin.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//circle
var circleRadius = 100.0;
Color circleColor = const Color(0x50B74093);

//maps
LatLng startLocation = const LatLng(49.006889, 8.403653); //Karlsruhe

//user
String username =  "";

//http
String host1 = "https://mona-sticker.herokuapp.com";
String host = "http://10.0.2.2:8080";
String getPinsOfUser = '$host/users/$username/pins';
String getOtherPins = '$host/pins/$username/radius';
String getOtherPinsCount = '$host/pins/$username/radiusCount';
String getMonaByPinId = '$host/monas?id=';
String postOrPutPin = '$host/users/$username/pins';
String postConsistency = '$host/pins/$username/check';
String checkUser = '$host/users/$username/check';
String postUsername = '$host/users/';
String checkVersion = '$host/version?number=';
String getPin = '$host/pins/';
String getLastVersion = '$host/version/last';
String getRanking = '$host/users/ranking';
String getUsernameByPin = '$host/pins/';

//sticker types
List<SType> stickerTypes = [SType(id: 0, name: "mona"), SType(id: 1, name: "TornadoDaVinci")];
List<Widget> stickerTypeImages = [const Image(image: AssetImage('images/mona.png')), const Image(image : AssetImage('images/tornado-da-vinci-v2.png'))];