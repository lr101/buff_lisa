import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:latlong2/latlong.dart';

import '../DTOClasses/group.dart';
import 'local_data.dart';

/// zoom when the maps controller sets the current location to the user location
double initialZoom = 12;

/// zoom of the map widget of the front of the feed item
double feedZoom = 13;

/// position of flutter map on start
/// Is set to the center of Karlsruhe, Germany
LatLng initCamera =  const LatLng(49.006889, 8.403653);

/// server ip address loaded from .env file
/// useful ip addresses:
/// server: 54.234.245.153
/// localhost: 10.0.2.2
String host = dotenv.env["HOST"]!;

/// list of available cameras
late List<CameraDescription> cameras;

/// holds information of data that is stored locally on device
/// is initialized on startup of app
late LocalData localData;

Group basicGroup = Group(groupId: -1, name: "", visibility: 0, inviteUrl: "", description: "", saveOffline: false);