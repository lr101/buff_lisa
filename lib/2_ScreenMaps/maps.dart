import 'package:buff_lisa/Files/ClusterHandler.dart';
import 'package:buff_lisa/Files/locationClass.dart';
import 'package:buff_lisa/Files/pointsNotifier.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../2_ScreenMaps/bootMethods.dart';
import '../Files/io.dart';
import '../Files/global.dart' as global;

class MapSample extends StatefulWidget {
  final IO io;
  const MapSample({super.key, required this.io});

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> with AutomaticKeepAliveClientMixin<MapSample> {
  late GoogleMapController _controller;
  late final ClusterHandler _cluster = widget.io.clusterHandler;
  double _currentZoom = global.initialZoom.toDouble();
  int filterState = 0;

  void getPins() async {
    if (!widget.io.mapBooted) {
      BootMethods.getPins(widget.io, callback);
    }
  }

  void callback() {
    setState(() {});
  }

  void _setLocation() async {
    LocationData loc = await LocationClass.getLocation();
    LatLng latLong = LatLng(loc.latitude!, loc.longitude!);
    await _controller.animateCamera(
        CameraUpdate.newCameraPosition(
            CameraPosition(target: latLong, zoom: global.initialZoom.toDouble())
        )
    );
  }


  @override
  void initState(){
    super.initState();
    getPins(); //new thread
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              StreamBuilder<List<Marker>>(
                  stream: _cluster.markers,
                  builder: (context, snapshot) {
                    return GoogleMap(
                      initialCameraPosition: global.initCamera,
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomGesturesEnabled: true,
                      compassEnabled: true,
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: true,
                      rotateGesturesEnabled: true,
                      tiltGesturesEnabled: false,
                      mapToolbarEnabled: false,
                      markers: (snapshot.data != null) ? snapshot.data!.map((e) => e).toSet() : {},
                      onMapCreated: _onMapCreated,
                      onCameraMove: _onCameraMove,
                      onCameraIdle: _onCameraIdle,
                    );
                  }),
              SizedBox(
                height: MediaQuery.of(context).viewPadding.top*2,
                width: MediaQuery.of(context).size.width,
                child: Column(
                  children: [
                    Container(
                        height: MediaQuery.of(context).viewPadding.top,
                        width: double.infinity,
                        color: global.cThird
                    ),
                    Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).viewPadding.top,
                        decoration: const BoxDecoration(
                          color: global.cThird,
                          borderRadius: BorderRadius.only(bottomLeft:  Radius.circular(40), bottomRight: Radius.circular(40))
                        ),
                        child: Center(
                            child: Text("Total: ${Provider.of<PointsNotifier>(context).getNumAll} - Your Score: ${Provider.of<PointsNotifier>(context).getUserPoints}", style: const TextStyle(color: Colors.white),)
                        )
                    ),
                  ],
                )
              )
            ],
          ),
        ),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "setFilterBtn",
              onPressed: _setFilter,
              backgroundColor: filterState % 5 != 0 ?  global.cThird : Colors.grey,
              child: (filterState % 5 == 0 ? const Icon(Icons.timeline_rounded) : Text(_buttonText())),
            ),
            const SizedBox(
              height: 3,
            ),
            FloatingActionButton(
              heroTag: "setLocationBtn",
              onPressed: _setLocation,
              backgroundColor: global.cThird,
              child: const Icon(Icons.location_on),
            ),
          ],
        )
    );
  }

  String _buttonText() {
    String t = "";
    switch (filterState) {
      case 1: t = "1d";break;
      case 2: t = "1w";break;
      case 3: t = "1m";break;
      case 4: t = "1y";break;
    }
    return t;
  }



  Future<void> _setFilter() async {
    setState(() {
      filterState = (filterState+1) % 5;
    });
    switch (filterState) {
      case 0: _setFilterDate(null);break;
      case 1: _setFilterDate(1);break;
      case 2: _setFilterDate(7);break;
      case 3: _setFilterDate(30);break;
      case 4: _setFilterDate(365);break;
    }

    await widget.io.clusterHandler.updateValues();
  }

  void _setFilterDate(int? days) {
    if (days == null) {
      widget.io.clusterHandler.filterDateMin = null;
    } else {
      widget.io.clusterHandler.filterDateMin = DateTime.now().subtract(Duration(days: days));
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _controller = controller;
    //STYLES
    _controller.setMapStyle(await DefaultAssetBundle.of(context).loadString('images/style.json'));
    _setLocation();
  }

  // May be called as often as every frame, so just track the last zoom value.
  void _onCameraMove(CameraPosition cameraPosition) {
    _currentZoom = cameraPosition.zoom;
  }

  void _onCameraIdle() {
    _cluster.setCameraZoom(_currentZoom);
  }

  @override
  bool get wantKeepAlive => true;

}