import 'dart:async';
import 'package:buff_lisa/Files/locationClass.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:location/location.dart';
import '../Files/io.dart';
import '../Files/pin.dart';
import '../main.dart';
import 'dialog.dart';
import '../Files/global.dart' as global;

class CameraStatefulWidget extends StatefulWidget {
  final IO io;

  const CameraStatefulWidget({super.key, required this.io});

  @override
  State<CameraStatefulWidget> createState() => _CameraStatefulWidgetState();
}

class _CameraStatefulWidgetState extends State<CameraStatefulWidget> {

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: mainCamera(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        Widget child;
        if (snapshot.hasData) {
          child = (snapshot.data) as Widget;
        } else if (snapshot.hasError) {
          child = const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 60,
          );
        }else {
          child =
            const SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(),
            );
        }
        return child;
      },
    );
  }

  Future<Widget> mainCamera() async {

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    return TakePictureScreen(camera: firstCamera, io : widget.io);
  }

}





class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    required this.io
  });

  final CameraDescription camera;
  final IO io;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}




class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<bool> isSelected = <bool>[false, false];
  final CarouselController controller = CarouselController();
  Widget? dialog;
  List<Widget> images = [];
  int index = -1;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.low,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  void setIndex(int index, int length)  {
    this.index = index % (length - 1);
  }

  Widget buildDialogNew(BuildContext context) {
    List<Widget> dialogImages = [];
    for (Widget image in global.stickerTypeImages) {
      dialogImages.add(GestureDetector(
          onTap: () {
            if (index == -1) {
              index = 0;
            }
            Navigator.pop(navigatorKey.currentContext!);
          }, // Image tapped
          child: image
      ));
    }
    return SimpleDialogItem.getSwipeDialog(context, widget.io, setIndex, dialogImages);
  }

  void buildDialogOld(BuildContext context) {
    for (Pin pin in widget.io.markers.notUserPinsInRadius) {
      images.add(GestureDetector(
          onTap: () {
            if (index == -1) {
              index = 0;
            }
            Navigator.pop(navigatorKey.currentContext!);
          }, // Image tapped
          child: SimpleDialogItem.getImageWidget(pin.id, false, null, context)
      ));
    }
    dialog = SimpleDialogItem.getSwipeDialog(context, widget.io, setIndex, images);
  }




  @override
  Widget build(BuildContext context) {
    buildDialogOld(navigatorKey.currentContext!);
    var size = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                  width: size - 100,
                  height: (size - 100) * (4 / 3),
                  child: cameraPreview()
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [switchOldNew()]
          ),
        ),
        Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [button()]
            )
        ),

      ],
    );
  }

  Widget cameraPreview() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return CameraPreview(_controller);
        } else {
          // Otherwise, display a loading indicator.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget button() {
    return FloatingActionButton(
      onPressed: (){
        buttonPressCamera().then((element) {
          if (element) {
            Navigator.pop(context);
          }
        });
      },
      child: const Icon(Icons.camera_alt),
    );
  }



  Widget switchOldNew()  {
    return ToggleButtons(
      onPressed: (int index) {
        setState(() {
          for (int buttonIndex = 0; buttonIndex <
              isSelected.length; buttonIndex++) {
            if (buttonIndex == index) {
              isSelected[buttonIndex] = true;
            } else {
              isSelected[buttonIndex] = false;
            }
          }
          this.index = -1;
          Widget dialogWidget = (isSelected[1] ? dialog! : buildDialogNew(context));
          showDialog(
              context: navigatorKey.currentContext!,
              builder: (context) => dialogWidget
          );
        });
      },
      isSelected: isSelected,
      children: const <Widget>[
        Text("NEW"),
        Text("OLD")
      ],
    );
  }

  Future<bool> buttonPressCamera() async {
    try {
      if (index == -1) {
        return false;
      }
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      Pin? foundPin = (isSelected[1] ? widget.io.markers.movePinToFound(index) : null);
      await preparePin(image, foundPin);
    } catch (e) {
      print(e);
      return false;
    }
    return true;
  }

  Future<void> preparePin(image, Pin? foundPin) async {
    Pin pin;
    if (foundPin != null) {
      pin = foundPin;
    } else {
      //location
      LocationData locationData = await LocationClass.getLocation();
      pin = Pin(latitude: locationData.latitude!, longitude: locationData.longitude!, id: widget.io.markers.markers.length, distance: Double(), type: global.stickerTypes[index], creationDate: DateTime.now());
    }
    Mona mona = Mona(image: image, pin: pin);
    if (isSelected[0]) {
      await widget.io.addNewCreatedPinOffline(mona);
    }
    postPin(mona); //new thread
  }

  Future<void> postPin(Mona mona) async {
    if (isSelected[0]) {
      final response = await RestAPI.postPin(mona);
      if (response.statusCode == 201 || response.statusCode == 200) {
        await widget.io.deletePinOffline(mona);
      }
    } else {
      await RestAPI.putPin(mona);
      //TODO save pin if response code not 200 to disk
    }
    _controller.dispose();
  }



}