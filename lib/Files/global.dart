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

String host = "54.234.245.153";
int port = 8081;
String host1 = "10.0.2.2";

//sticker types
List<SType> stickerTypes = [SType(id: 0, name: "mona"), SType(id: 1, name: "TornadoDaVinci")];
List<Widget> stickerTypeImages = [const Image(image: AssetImage('images/mona.png')), const Image(image : AssetImage('images/tornado-da-vinci-v2.png'))];