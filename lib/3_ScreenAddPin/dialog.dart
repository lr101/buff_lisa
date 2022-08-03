import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
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
          child: getImageWidget(id, newPin, image,  context),
      )
    );
  }

  static Widget getSwipeDialog(BuildContext context, IO io, Function callback, List<Widget> images) {
    var size = MediaQuery.of(context).size.width;
    return Dialog(
        child: SizedBox(
          width: size - 100,
          height: (size - 100) * (4 / 3),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CarouselSlider(
                    options: CarouselOptions(
                      height: (size - 150) * (4 / 3),
                      autoPlay: true,
                      aspectRatio: 0.5,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) => callback(index, images.length)
                    ),
                    items: images
                ),
                const Text("Select by tapping on image"),
              ]
          ),
        )
    );
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