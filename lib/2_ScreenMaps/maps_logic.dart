import 'package:buff_lisa/2_ScreenMaps/maps_ui.dart';
import 'package:buff_lisa/Files/location_class.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/provider_context.dart';
import '../Files/global.dart' as global;
import '../Providers/cluster_notifier.dart';

class MapsWidget extends StatefulWidget {
  final ProviderContext io;
  const MapsWidget({super.key, required this.io});

  @override
  State<MapsWidget> createState() => MapsWidgetState();
}

class MapsWidgetState extends State<MapsWidget> with AutomaticKeepAliveClientMixin<MapsWidget> {
  int filterState = 0;
  MapController controller = MapController();

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MapsUI(state: this);
  }

  @override
  void initState(){
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setLocation();
    });
  }

  /// sets google maps location to the current user position via GoogleMapsController
  void setLocation() async {
    LocationData loc = await LocationClass.getLocation();
    LatLng latLong = LatLng(loc.latitude!, loc.longitude!);
    controller.move(latLong, global.initialZoom);
  }

  /// returns the button text that will be shown depending on @filterState
  String buttonText() {
    String t = "";
    switch (filterState) {
      case 1: t = "1d";break;
      case 2: t = "1w";break;
      case 3: t = "1m";break;
      case 4: t = "1y";break;
    }
    return t;
  }

  /// rotates filter options [0 - 4]
  void setFilter()  {
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
  }

  /// updates the marker list via provider to filter for the pins created int the last @days
  void _setFilterDate(int? days) {
    if (days == null) {
      Provider.of<ClusterNotifier>(widget.io.context, listen:false).setFilterDate(null, null);
    } else {
      Provider.of<ClusterNotifier>(widget.io.context, listen:false).setFilterDate(DateTime.now().subtract(Duration(days: days)), null);
    }
  }


  @override
  bool get wantKeepAlive => true;

}