import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../Files/io.dart';
import '../Files/pin.dart';
import '../Files/restAPI.dart';
import '../Files/global.dart' as global;

class SimpleDialogItem {

  static Widget getPinDialog(int? id, bool newPin, XFile? image, BuildContext context) {
    var size = MediaQuery.of(context).size.width;
    return Dialog(
      child: SizedBox(
         width: size - 100,
         height: (size - 100) * (4 / 3),
         child: Column(
          children: [
            SizedBox(
               width: size - 150,
               height: (size - 150) * (4 / 3),
               child:getImageWidget(id, newPin, image,  context)
            ),
           getUsernameOfPin(id, newPin)],
         )
       ),
    );
  }

  static Widget getUsernameOfPin(int? id, bool newPin) {
    if (newPin) {
      return Text("username: ${global.username}");
    } else {
      return FutureBuilder<String?> (
        future: RestAPI.getUsernameByPin(id!),
        builder: (context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.hasData) {
            return Text("username: ${snapshot.data}");
          } else{
            return const Text("username: ---");
          }
        }
      );
    }
  }


  static Widget getImageWidget(int? id, bool newPin, XFile? image, BuildContext context) {
    if (newPin) {
        return FutureBuilder<Uint8List>(
            future: image?.readAsBytes(),
            builder: (context, AsyncSnapshot<Uint8List> snapshot) {
              if (snapshot.hasData) {
                return Image.memory(snapshot.data!);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
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
                  if (snapshot.hasData) {
                    return Image.memory(snapshot.data!);
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                }
            );
          } else {
            // Otherwise, display a loading indicator.
            return const Center(child: CircularProgressIndicator());
          }
        },
    );
  }
}