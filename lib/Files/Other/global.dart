import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

/// zoom when the maps controller sets the current location to the user location
double initialZoom = 17;

/// zoom of the map widget of the front of the feed item
double feedZoom = 12;

/// position of flutter map on start
/// Is set to the center of Karlsruhe, Germany
LatLng initCamera =  LatLng(49.006889, 8.403653);

/// username of the current user
/// set on login/signup or loaded from secure storage
String username =  "";

/// user token to authenticate user on the server
/// set on login/signup or loaded from secure storage
String token = "";

/// flag for an already existing login
/// is set to true when user opens app
/// resets provider information of pins of the old user when user logs out via logout button
bool pinsLoaded = false;

/// server ip address loaded from .env file
/// useful ip addresses:
/// server: 54.234.245.153
/// localhost: 10.0.2.2
String host = dotenv.env["HOST"]!;

/// port of the server
int port = 8082;

/// filename of the file where offline pins are saved on the device
String fileName = 'pin_new';

/// filename of the file where user groups are saved on the device
String groupFileName = 'groups';

String hiddenUsers = "hiddenUsers";

String hiddenPosts = "hiddenPosts";


/// api key for the stadia map service
/// loaded from .env file
String apiKey = dotenv.env["MAPS_API_KEY"]!;

/// Style color palette
const Color cPrime = Color(0xFF455a64);
const Color cSecond = Color(0xFFcfdbd5);
const Color cThird = Color(0x992085B8);
const Color cFourth = Color(0xFFf06449);
const Color cFifth = Color(0xFFb5446e);

/// height of the SelectGroupWidget selector
const int barHeight = 58;

/// list of available cameras
late List<CameraDescription> cameras;