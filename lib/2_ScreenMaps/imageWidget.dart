import 'dart:typed_data';
import 'package:buff_lisa/Providers/clusterNotifier.dart';
import 'package:buff_lisa/Providers/pointsNotifier.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../Files/providerContext.dart';
import '../Files/pin.dart';
import '../Files/restAPI.dart';
import '../Files/global.dart' as global;

class ShowImageWidget extends StatefulWidget {
  const ShowImageWidget({Key? key, required this.image, required this.id, required this.newPin}) : super(key: key);

  final XFile? image;
  final int id;
  final bool newPin;
  @override
  State<ShowImageWidget> createState() => ShowImageWidgetState();

}

class ShowImageWidgetState extends State<ShowImageWidget> {

  bool activeDelete = false;
  String username = "---";

  @override
  void initState() {
    super.initState();
    if (widget.newPin) {
      username = global.username;
    } else {
      _getUsername(widget.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: global.cThird,
        title: const Text("Image"),
        centerTitle: true,
      ),
      body:  Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          getImageWidget(widget.id, widget.newPin, widget.image, context),
          Text("username: $username"),
          _getButton(widget.id, widget.newPin, context)
        ]
      )
    );
  }

  Widget _getButton(int id, bool newPin, BuildContext context) {
    return Align(
        alignment: Alignment.topCenter,
        child: OutlinedButton(
          onPressed: () async {
            if (activeDelete) {
              if (newPin) {
                await Provider.of<ClusterNotifier>(context, listen:false).deleteOfflinePin(id);
                Navigator.pop(this.context);
              } else {
                RestAPI.deleteMonaFromPinId(id).then((value) {
                  Provider.of<ClusterNotifier>(context, listen:false).removePin(id);
                  Provider.of<PointsNotifier>(context, listen: false).decrementNumAll();
                  Provider.of<PointsNotifier>(context, listen: false).decrementPoints();
                  Navigator.pop(context);
                });
                }
              }
            }, child: Text("Delete", style: TextStyle(color: (activeDelete ? global.cPrime : Colors.grey)),),
        )
    );
  }

  static Widget getImageWidget(int? id, bool newPin, XFile? image, BuildContext context) {
    return Center(
          child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.width,
              child: getImage(id, newPin, image),
            )
    );
  }

  static Widget getImage(int? id, bool newPin, XFile? image) {
    if (image != null) {
      return FutureBuilder<Uint8List>(
          future: image.readAsBytes(),
          builder: (context, AsyncSnapshot<Uint8List> snapshot) {
            return (snapshot.hasData)
                ? Image.memory(snapshot.data!)
                : const Center(child: CircularProgressIndicator());
          }
      );
    }
    return FutureBuilder<Mona?>(
      future: RestAPI.fetchMonaFromPinId(id!),
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

  Future<void> _getUsername(int id) async{
    username = (await RestAPI.getUsernameByPin(id))!;
    if (username == global.username) {
      activeDelete = true;
    }
    setState(() {});
  }

}