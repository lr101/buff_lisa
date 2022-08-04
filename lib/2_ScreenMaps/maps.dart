import 'package:buff_lisa/3_ScreenAddPin/addPinScreen.dart';
import 'package:buff_lisa/2_ScreenMaps/bootMethods.dart';
import 'package:buff_lisa/Files/locationClass.dart';
import 'package:fluster/fluster.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Files/global.dart' as global;
import '../Files/io.dart';
import '../Files/mapHelper.dart';
import '../Files/mapMarker.dart';
import '../Files/pin.dart';

class MapSample extends StatefulWidget {
  final IO io;
  const MapSample({super.key, required this.io});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  late GoogleMapController _controller;

  void getPins() async {
    if (!widget.io.mapBooted) {
      BootMethods.boot(widget.io, callback);
    }
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

    setState(() {
      widget.io.oldZoom = 17;
    });
  }


  @override
  void initState(){
    super.initState();
    getPins(); //new thread
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: widget.io.initCamera,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              zoomGesturesEnabled: true,
              compassEnabled: true,
              scrollGesturesEnabled: true,
              rotateGesturesEnabled: true,
              tiltGesturesEnabled: false,
              markers: widget.io.googleMarkers,
              onMapCreated: (controller) { //method called when map is created
                _controller = controller;
                setStartLocation();
              },
              onCameraMove: (position) => setState((){widget.io.updateMarkers(position);}),
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
              child: Text(widget.io.pinsInRadius.length.toString()),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

}