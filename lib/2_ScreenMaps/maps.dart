import 'package:buff_lisa/3_ScreenAddPin/addPinScreen.dart';
import 'package:buff_lisa/2_ScreenMaps/bootMethods.dart';
import 'package:buff_lisa/Files/locationClass.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Files/global.dart' as global;
import '../Files/io.dart';

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController _controller;
  final Location _location = Location();
  final LatLng _initCamera =  global.startLocation;
  late IO io = IO();
  bool loopBool = true;

  Future<void> loop() async {
    while (loopBool) {
      LocationData loc = await _location.getLocation();
      setPinsInsideCircle(loc);
      await Future.delayed(const Duration(seconds: 20));
    }
  }

  void setPinsInsideCircle(LocationData loc) {
    setState(() {
      io.markers.calcNotUserPinsInRadius(loc.latitude!, loc.longitude!);
    });
  }

  void getPins() async{
      await BootMethods.boot(io, callback);
  }

  void callback(dynamic d) {
    setState(() {});
  }

  void setStartLocation() async {
    LocationData loc = await LocationClass.getLocation();
    LatLng latLong = LatLng(loc.latitude!, loc.longitude!);
    await _controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: latLong, zoom: 17)
        )
    );
    setState(() {});
  }


  @override
  void initState(){
    super.initState();
    getPins(); //new thread
    loop(); //new thread
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sticker Map --  ${io.markers.numUserPins()}/${io.markers.numAllPins()}"),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(target: _initCamera, zoom: 5),
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: false,
              markers: io.markers.markers,
              onMapCreated: (controller) { //method called when map is created
                _controller = controller;
                setStartLocation();
              }
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "btn1",
              onPressed: () {},
              tooltip: 'Pins near you',
              elevation: 5,
              splashColor: Colors.grey,
              child: Text(io.markers.notUserPinsInRadius.length.toString()),
            ),
            const SizedBox(width: 10),
            FloatingActionButton(
              heroTag: "btn2",
              onPressed: () {
                _navigateAndDisplaySelection(context); //new thread
              },
              tooltip: 'Add a Sticker',
              elevation: 20,
              splashColor: Colors.grey,
              child: const Icon(Icons.add),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    loopBool = false;
    await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(builder: (context) => AddPinScreen(io : io)),
    );
    setState(() {
      loopBool = true;
    });
  }
}