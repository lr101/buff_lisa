import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:latlong2/latlong.dart';

//circle
var circleRadius = 100.0;
Color circleColor = const Color(0x50B74093);

//maps
double initialZoom = 17;
double feedZoom = 12;

String username =  "";
String token = "";
bool pinsLoaded = false;

String host1 = "54.234.245.153";
int port = 8081;
String host2 = "10.0.2.2";
String host = FlutterConfig.get("HOST") ?? "54.234.245.153";
//sticker types
List<Widget> stickerTypeImages = [const Image(image: AssetImage('images/mona.png')), const Image(image : AssetImage('images/tornado-da-vinci-v2.png'))];

String fileName = 'pin_new.txt';
String fileNameExisting = 'existing_pins.txt';
String styleUrl = "https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png";
String apiKey = "1c574330-845b-49b7-9110-dcc8146dc436";
LatLng initCamera =  LatLng(49.006889, 8.403653);

const Color cPrime = Color(0xFF455a64);
const Color cSecond = Color(0xFFcfdbd5);
const Color cThird = Color(0xFF2085B8);
const Color cFourth = Color(0xFFf06449);
const Color cFifth = Color(0xFFb5446e);

const int barHeight = 58;

String shopUrl = "https://www.etsy.com/de/shop/MonaSticker";