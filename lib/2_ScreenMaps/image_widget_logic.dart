import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/2_ScreenMaps/image_widget_ui.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/mona.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/restAPI.dart';
import '../Files/global.dart' as global;

class ShowImageWidget extends StatefulWidget {
  const ShowImageWidget({Key? key, required this.image, required this.id, required this.newPin, required this.groupId}) : super(key: key);

  final File? image;
  final int id;
  final bool newPin;
  final int groupId;
  @override
  State<ShowImageWidget> createState() => ShowImageWidgetState();

}

class ShowImageWidgetState extends State<ShowImageWidget> {

  bool activeDelete = false;
  String username = "---";

  @override
  Widget build(BuildContext context) => ImageWidgetUI(state: this);

  /// Fetches the username of the creator during initialization
  @override
  void initState() {
    super.initState();
    if (widget.newPin) {
      username = global.username;
    } else {
      _getUsername(widget.id);
    }
  }


  /// This method tries deleting the selected pin and goes back to the previous page if successful
  /// Works only if @activeDelete is true
  Future<void> handleButtonPress() async{
      if (activeDelete) {
        if (widget.newPin) {
          await Provider.of<ClusterNotifier>(context, listen: false).deleteOfflinePin(widget.id);
        } else {
          bool deleted = await RestAPI.deleteMonaFromPinId(widget.id);
          if (deleted && mounted) {
            Provider.of<ClusterNotifier>(context, listen: false).removePin(widget.id, widget.groupId);
          }
        }
        if (!mounted) return;
        Navigator.pop(context);
      }
  }

  /// This methods builds the image of the selected pin in a FutureBuilder
  /// Image can be an offline saved pin (@image not null) or dynamically loaded from server
  /// An CircularProgressIndicator is returned during the loading time
  Widget getImageWidget() {
    if (widget.image != null) {
      return FutureBuilder<Uint8List>(
          future: widget.image?.readAsBytes(),
          builder: (context, AsyncSnapshot<Uint8List> snapshot) {
            return (snapshot.hasData)
                ? Image.memory(snapshot.data!)
                : const Center(child: CircularProgressIndicator());
          }
      );
    }
    return FutureBuilder<Mona?>(
      future: RestAPI.fetchMonaFromPinId(widget.id),
      builder: (context, AsyncSnapshot<Mona?> snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder<Uint8List>(
              future: snapshot.data?.image.readAsBytes(),
              builder: (context, AsyncSnapshot<Uint8List> snapshot) {
                return (snapshot.hasData)
                    ? Image.memory(snapshot.data!)
                    : const Center(child: CircularProgressIndicator());
              }
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Fetches the username of the current pin
  /// Sets @activeDelete to true if the username is the current user
  Future<void> _getUsername(int id) async{
    username = (await RestAPI.getUsernameByPin(id))!;
    if (username == global.username) {
      activeDelete = true;
    }
    setState(() {});
  }

}