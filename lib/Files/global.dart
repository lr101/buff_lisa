import 'package:buff_lisa/Files/pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

//circle
var circleRadius = 100.0;
Color circleColor = const Color(0x50B74093);

//maps
LatLng startLocation = const LatLng(49.006889, 8.403653); //Karlsruhe
int initialZoom = 17;

String username =  "";
String token = "";


String host1 = "54.234.245.153";
int port = 8081;
String host2 = "10.0.2.2";
String host = FlutterConfig.get("HOST") ?? "54.234.245.153";
//sticker types
List<SType> stickerTypes = [SType(id: 0, name: "mona"), SType(id: 1, name: "TornadoDaVinci")];
List<Widget> stickerTypeImages = [const Image(image: AssetImage('images/mona.png')), const Image(image : AssetImage('images/tornado-da-vinci-v2.png'))];

String fileName = 'pin_new.txt';
String fileNameExisting = 'existing_pins.txt';
CameraPosition initCamera =  CameraPosition(target: startLocation,zoom: 5);

const Color cPrime = Color(0xFF455a64);
const Color cSecond = Color(0xFFcfdbd5);
const Color cThird = Color(0xFF2085B8);
const Color cFourth = Color(0xFFf06449);
const Color cFifth = Color(0xFFb5446e);

const int barHeight = 58;

String shopUrl = "https://www.etsy.com/de/shop/MonaSticker";