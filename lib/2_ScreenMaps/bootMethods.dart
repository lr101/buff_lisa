import 'dart:convert';
import 'package:provider/provider.dart';
import '../Files/global.dart' as global;
import '../Files/providerContext.dart';
import '../Files/pin.dart';
import '../Providers/clusterNotifier.dart';
import '../Providers/pointsNotifier.dart';
import '../Files/restAPI.dart';

class BootMethods {

  static Future<void> getPins(ProviderContext io, callback) async {
    if (io.mapBooted) return;
    io.mapBooted = true;
    await Provider.of<ClusterNotifier>(io.context, listen:false).loadOfflinePins();
    await tryOfflinePins(io);
    RestAPI.fetchAllPins().then((pins) async {
      await Provider.of<ClusterNotifier>(io.context, listen:false).addPins(pins);
      updateUserPoints(io);
    });


  }

  static void updateUserPoints(ProviderContext io) {
    List<Pin> pins = List.from(Provider.of<ClusterNotifier>(io.context, listen:false).getAllPins());
    List<Mona> monas = List.from(Provider.of<ClusterNotifier>(io.context, listen:false).getOfflinePins());
    Provider.of<PointsNotifier>(io.context, listen: false).setNumAll(pins.length + monas.length);
    for (Pin pin in pins) {
      if (pin.username == global.username) {
        Provider.of<PointsNotifier>(io.context, listen: false).incrementPoints();
      }
    }
  }


  static Future<void> tryOfflinePins(ProviderContext io) async {
    List<Mona> monas = List.from(Provider.of<ClusterNotifier>(io.context, listen:false).getOfflinePins());
    for (Mona mona in monas) {
      final response = await RestAPI.postPin(mona);
      if (response.statusCode == 201 || response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>;
        Pin pin = Pin.fromJson(json);
        _add(pin, mona, io);
      }
    }
  }

  static void _add(Pin pin, Mona mona, ProviderContext io) {
    Provider.of<ClusterNotifier>(io.context, listen:false).deleteOfflinePin(mona.pin.id);
    Provider.of<ClusterNotifier>(io.context, listen:false).addPin(pin);
  }

}