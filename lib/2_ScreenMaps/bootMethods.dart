import 'package:buff_lisa/Files/locationClass.dart';
import 'package:location/location.dart';
import '../Files/io.dart';
import '../Files/pin.dart';
import '../Files/restAPI.dart';

class BootMethods {

  static Future<void> boot(IO io, Function callback) async {
    await io.readNewCreatedPinOffline();
    await tryOfflinePins(io);
    /*(RestAPI.fetchMyCreatedPins()).then((value) => callback(io.markers.setUserPinsCreated(value.toSet()))); //new thread
    (RestAPI.fetchMyFoundPins()).then((value) => callback(io.markers.setUserPinsFound(value.toSet()))); //new thread
    (RestAPI.fetchOtherPins()).then((value) async {
      LocationData loc = await LocationClass.getLocation();
      io.markers.setNotUserPins(value);
      io.markers.calcNotUserPinsInRadius(loc.latitude!, loc.longitude!);
      callback(null);
      });*/ //new thread
    (RestAPI.fetchAllPins()).then((value) => callback(io.markers.setAllPins(value)));
    RestAPI.getLastVersion().then((value) {
      if (value != null) {
        io.markers.versionId = value;
      }
      io.markers.loop(); //new thread
    });
  }

  static Future<List<Pin>> getNotUserPins() async {
    return await RestAPI.fetchOtherPins();
  }

  static Future<void> tryOfflinePins( IO io) async {
    List<Mona> monas = List<Mona>.from(io.markers.userNewCreatedPins);
    for (Mona mona in monas) {
      final response = await RestAPI.postPin(mona);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await io.deletePinOffline(mona);
      }
    }
  }
}