import 'package:buff_lisa/10_UploadOffline/upload_offline_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../1_BottomNavigationBar/navbar_logic.dart';
import '../Files/Other/global.dart' as global;
import '../Files/DTOClasses/pin.dart';
import '../Providers/cluster_notifier.dart';
import '../Providers/file_handler.dart';

class UploadOfflinePage extends StatefulWidget {
  const UploadOfflinePage({super.key, required this.pins});

  final List<Pin> pins;

  @override
  UploadOfflinePageState createState() => UploadOfflinePageState();
}

class UploadOfflinePageState extends State<UploadOfflinePage> {
  @override
  Widget build(BuildContext context) => UploadOfflinePageUI(state: this);

  FileHandler fileHandler = FileHandler(fileName: global.fileName);


  Future<void> handleUploadAll() async {
      List<Pin> remainingPins = List.from(widget.pins);
      for (Pin pin in widget.pins) {
        await tryUpload(pin, remainingPins);
      }
      await fileHandler.savePinList(remainingPins);
      if (!mounted) return;
      Navigator.of(context).pop();
  }

  Future<void> tryUpload(Pin pin, List<Pin> remainingPins) async {
    try {
      Pin newPin = await FetchPins.postPin(pin);
      if (!mounted) return;
      Provider.of<ClusterNotifier>(context, listen: false).deleteOfflinePinAndAddToOnline(newPin, pin);
      remainingPins.removeWhere(((element) => element.id == pin.id && element.group.groupId == pin.group.groupId));
    } catch (e) {
      await Provider.of<ClusterNotifier>(context, listen: false).addPin(pin);
    }
  }

  Future<void> handleDeleteAll() async {
    await fileHandler.savePinList([]);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}