import 'package:buff_lisa/10_UploadOffline/upload_offline_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/DTOClasses/pin_repo.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../1_BottomNavigationBar/navbar_logic.dart';
import '../Files/Other/local_data.dart';

class UploadOfflinePage extends StatefulWidget {
  const UploadOfflinePage({super.key, required this.pins});

  /// Offline that are shown and supposed to be uploaded.
  final Set<Pin> pins;

  @override
  UploadOfflinePageState createState() => UploadOfflinePageState();
}

class UploadOfflinePageState extends State<UploadOfflinePage> {
  @override
  Widget build(BuildContext context) => UploadOfflinePageUI(state: this);

  /// Uploads all images to server if possible.
  /// Closes the page after finishing.
  Future<void> handleUploadAll() async {
      List<Pin> remainingPins = List.from(widget.pins);
      for (Pin pin in widget.pins) {
        await tryUpload(pin, remainingPins);
      }
      if (!mounted) return;
      openNavBar();
  }

  /// Upload pin and remove pin from remainingPins list.
  /// On success is the pin deleted from local storage and
  /// pin returned from upload added to pins of group.
  Future<void> tryUpload(Pin pin, List<Pin> remainingPins) async {
    try {
      Pin newPin = await FetchPins.postPin(pin);
      if (!mounted) return;
      Provider.of<ClusterNotifier>(context, listen: false).deleteOfflinePinAndAddToOnline(newPin, pin);
      (await PinRepo.fromInit(LocalData.pinFileNameKey)).deletePin(pin.id);
    } on Exception catch (_, e) {
      print(_);
      await Provider.of<ClusterNotifier>(context, listen: false).addPin(pin);
    }
  }

  /// Clears the local storage und closes the page.
  Future<void> handleDeleteAll() async {
    await (await PinRepo.fromInit(LocalData.pinFileNameKey)).clear();
    if (!mounted) return;
    openNavBar();
  }

  void openNavBar() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const BottomNavigationWidget()
        ),
        ModalRoute.withName("/navbar")
    );
  }
}