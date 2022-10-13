import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:buff_lisa/0_ScreenSignIn/secure.dart';
import 'package:buff_lisa/2_ScreenMaps/bootMethods.dart';
import 'package:buff_lisa/3_ScreenAddPin/checkImageWidget.dart';
import 'package:buff_lisa/Files/locationClass.dart';
import 'package:buff_lisa/Files/pointsNotifier.dart';
import 'package:camera/camera.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import '../Files/io.dart';
import '../Files/pin.dart';
import '../main.dart';
import '../2_ScreenMaps/imageWidget.dart';
import '../Files/global.dart' as global;

class CameraStatefulWidget extends StatefulWidget {
  final IO io;

  const CameraStatefulWidget({super.key, required this.io});

  @override
  State<CameraStatefulWidget> createState() => _CameraStatefulWidgetState();
}

class _CameraStatefulWidgetState extends State<CameraStatefulWidget> with AutomaticKeepAliveClientMixin<CameraStatefulWidget>{

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Align(
        alignment: Alignment.topRight,
        child: FutureBuilder<Widget>(
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
                  child: CircularProgressIndicator(color: global.cSecond,),
                );
            }
            return child;
          },
        )
      )
    );
  }

  Future<Widget> mainCamera() async {

    // Obtain a list of the available cameras on the device.
    final cameras = await availableCameras();
    // Get a specific camera from the list of available cameras.
    final firstCamera = cameras.first;

    return TakePictureScreen(camera: firstCamera, io : widget.io);
  }

  @override
  bool get wantKeepAlive => true;

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



  @override
  Widget build(BuildContext context) {
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
              children: [switchType()]
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
      heroTag: "cameraBtn",
      onPressed: (){
        buttonPressCamera().then((value) {
          if (value) {
            Provider.of<PointsNotifier>(context, listen: false).incrementPoints();
            Provider.of<PointsNotifier>(context, listen: false).incrementNumAll();
            final BottomNavigationBar navigationBar = widget.io.globalKey.currentWidget! as BottomNavigationBar;
            navigationBar.onTap!(0);
          }
        });
      },
      backgroundColor: global.cThird,
      child: const Icon(Icons.camera_alt, color: Colors.white,),
    );
  }



  Widget switchType()  {
    return ToggleButtons(
      fillColor: global.cSecond,
      borderColor: global.cPrime,
      selectedBorderColor:global.cPrime ,
      splashColor: global.cPrime,
      borderWidth: 0.8,
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
        });
      },
      isSelected: isSelected,
      children: const <Widget>[
        Image(
          image: AssetImage('images/mona.png'),
          width: 30,
          height: 38,
          fit: BoxFit.cover,
        ),
        Image(
          image: AssetImage("images/tornado-da-vinci-v2.png"),
          width: 30,
          height: 38,
          fit: BoxFit.cover,
        ),
      ],
    );
  }

  Future<bool> buttonPressCamera() async {
    try {
      if (getSelectedIndex() == -1) return false;
      final navigator = Navigator.of(context);
      await _initializeControllerFuture;
      final image = await _controller.takePicture();
      final result = await navigator.push(
        MaterialPageRoute(builder: (context) => CheckImageWidget(image: image,)),
      );
      if (!mounted || !result) return false;
      preparePin(image);
    } catch (e) {
      print("Method: bttonPressCamera with Error: $e");
      return false;
    }
    return true;
  }

  int getSelectedIndex() {
    for (int i = 0; i < isSelected.length; i++) {
      if (isSelected[i]) {
        return i;
      }
    }
    return -1;
  }

  Future<void> preparePin(image) async {
    //location
    LocationData locationData = await LocationClass.getLocation();

    Pin pin = Pin(latitude: locationData.latitude!, longitude: locationData.longitude!, id: widget.io.clusterHandler.markerHandler.userNewCreatedPins.length, username: global.username, type: global.stickerTypes[getSelectedIndex()], creationDate: DateTime.now());

    Mona mona = Mona(image: image, pin: pin);
    await widget.io.addOfflinePin(mona);
    postPin(mona); //new thread
  }

  Future<void> postPin(Mona mona) async {
    HttpClientResponse response = await RestAPI.postPin(mona);
    if (response.statusCode == 201 || response.statusCode == 200) {
      await BootMethods.setTempToSavedPin(mona, response, widget.io);
    }
  }



}