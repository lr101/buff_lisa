
import 'package:buff_lisa/2_ScreenMaps/imageWidget.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../Files/global.dart' as global;

class CheckImageWidget extends StatelessWidget{
  final XFile? image;
  const CheckImageWidget({Key? key, this.image}) : super(key: key) ;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Approve Image"),
        automaticallyImplyLeading: false,
        backgroundColor: global.cThird,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ShowImageWidgetState.getImageWidget(0, true, image, context),
            OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: OutlinedButton.styleFrom(
                  primary: global.cThird,
                  padding: const EdgeInsets.all(10),
                  textStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                  ),
                ),
                child: const Text("Approve")

            ),
            OutlinedButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                style: OutlinedButton.styleFrom(
                  primary: global.cFourth,
                  padding: const EdgeInsets.all(10),
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontSize: 40,
                  ),
                ),
                child: const Text("Back")
            )
          ],
        ),
      ),
    );
  }
}