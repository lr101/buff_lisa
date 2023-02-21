import 'package:buff_lisa/10_UploadOffline/upload_offline_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin_repo.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../1_BottomNavigationBar/navbar_logic.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';

class UploadOfflinePage extends StatefulWidget {
  const UploadOfflinePage({super.key, required this.pins});

  final Set<Pin> pins;

  @override
  UploadOfflinePageState createState() => UploadOfflinePageState();
}

class UploadOfflinePageState extends State<UploadOfflinePage> {
  @override
  Widget build(BuildContext context) => UploadOfflinePageUI(state: this);

  PinRepo pinRepo = global.localData.pinRepo;


  Future<void> handleUploadAll() async {
      List<Pin> remainingPins = List.from(widget.pins);
      for (Pin pin in widget.pins) {
        await tryUpload(pin, remainingPins);
      }
      if (!mounted) return;
      Navigator.of(context).pop();
  }

  Future<void> tryUpload(Pin pin, List<Pin> remainingPins) async {
    try {
      Pin newPin = await FetchPins.postPin(pin);
      if (!mounted) return;
      Provider.of<ClusterNotifier>(context, listen: false).deleteOfflinePinAndAddToOnline(newPin, pin);
      pinRepo.deletePin(pin.id);
    } on Exception catch (_, e) {
      print(_);
      await Provider.of<ClusterNotifier>(context, listen: false).addPin(pin);
    }
  }

  Future<void> handleDeleteAll() async {
    await pinRepo.clear();
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}