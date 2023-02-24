import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

import 'local_data.dart';

/// zoom when the maps controller sets the current location to the user location
double initialZoom = 17;

/// zoom of the map widget of the front of the feed item
double feedZoom = 13;

/// position of flutter map on start
/// Is set to the center of Karlsruhe, Germany
LatLng initCamera =  LatLng(49.006889, 8.403653);

/// server ip address loaded from .env file
/// useful ip addresses:
/// server: 54.234.245.153
/// localhost: 10.0.2.2
String host = dotenv.env["HOST"]!;

/// port of the server
int port = 8082;

/// api key for the stadia map service
/// loaded from .env file
String apiKey = dotenv.env["MAPS_API_KEY"]!;

/// list of available cameras
late List<CameraDescription> cameras;

/// holds information of data that is stored locally on device
/// is initialized on startup of app
late LocalData localData;