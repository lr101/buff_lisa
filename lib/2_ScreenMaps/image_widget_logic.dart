import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/2_ScreenMaps/image_widget_ui.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_pins.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/ServerCalls/restAPI.dart';
import '../Files/global.dart' as global;

class ShowImageWidget extends StatefulWidget {
  const ShowImageWidget({Key? key, required this.pin, required this.newPin}) : super(key: key);

  /// Boolean for showing if shown pin is a new pin and therefore an online saved pin
  /// true: Pin is an offline Pin
  /// false: Pin is a Pin that is saved on server
  final bool newPin;

  /// The Pin that is shown on this page
  final Pin pin;

  @override
  State<ShowImageWidget> createState() => ShowImageWidgetState();

}

class ShowImageWidgetState extends State<ShowImageWidget> {

  /// Boolean for keeping track if the delete Button is usable (Clickable)
  /// Delete Button will be activated if the current user is also the user that created this pin
  /// true: Delete Button is clickable
  /// false: Delete Button is deactivated
  bool activeDelete = false;
  String username = "---";

  @override
  Widget build(BuildContext context) => ImageWidgetUI(state: this);

  /// Fetches the username of the creator during initialization
  @override
  void initState() {
    super.initState();
    username = widget.pin.username;
    if (username == global.username) {
      activeDelete = true;
    }
  }


  /// This method tries deleting the selected pin and goes back to the previous page if successful
  /// Works only if [activeDelete] is true
  Future<void> handleButtonPress() async{
      if (activeDelete) {
        if (widget.newPin) {
          await Provider.of<ClusterNotifier>(context, listen: false).deleteOfflinePin(widget.pin);
        } else {
          await Provider.of<ClusterNotifier>(context, listen: false).removePin(widget.pin);
        }
        if (!mounted) return;
        Navigator.pop(context);
      }
  }

}