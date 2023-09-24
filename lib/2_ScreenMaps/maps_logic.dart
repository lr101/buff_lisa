import 'dart:typed_data';
import 'dart:ui';

import 'package:buff_lisa/2_ScreenMaps/maps_ui.dart';
import 'package:buff_lisa/7_Settings/EditMap/edit_map.dart';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Other/location_class.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/marker_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../6_Group_Search/ClickOnGroup/show_group_logic.dart';
import '../Files/DTOClasses/pin.dart';
import '../Files/Routes/routing.dart';
import '../Files/Widgets/cusotm_alert_dialog.dart';
import 'ClickOnPin/image_widget_logic.dart';

class MapsWidget extends StatefulWidget {

  const MapsWidget({super.key});

  @override
  State<MapsWidget> createState() => MapsWidgetState();
}

class MapsWidgetState extends State<MapsWidget> with AutomaticKeepAliveClientMixin<MapsWidget>, TickerProviderStateMixin {

  /// state of the filter by date [0-4]
  /// 0: no filter
  /// 1: 1 day
  /// 2: 1 week
  /// 3: 1 month
  /// 4: 1 year
  int filterState = 0;

  ValueNotifier<double> slider = ValueNotifier<double>(0);

  /// flag for showing only pins of user or all
  /// false: all pins are shown
  /// true: only user pins are shown
  bool filterUser = false;

  /// controller of the flutter_map
  /// used to recenter to user location from button press
  MapController controller = MapController();

  late AnimationController _controller;
  late CurvedAnimation _animation;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return MapsUI(state: this);
  }

  /// sets callback for after build is complete to move maps camera to current location
  @override
  void initState(){
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 750));
    _animation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setLocation();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.stop();
    _controller.dispose();
  }

  Future<void> setLocation() async  {
    final destLocation = await LocationClass.getLocation();
 
    final latTween = Tween<double>(begin: controller.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(begin: controller.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: controller.zoom, end: global.initialZoom);
    
    final animateController = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    final Animation<double> animation = CurvedAnimation(parent: animateController, curve: Curves.fastOutSlowIn);

    animateController.addListener(() {
      controller.move(
          LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
          zoomTween.evaluate(animation));
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animateController.dispose();
      } else if (status == AnimationStatus.dismissed) {
        animateController.dispose();
      }
    });

    animateController.forward();
  }

  /// returns the button text that will be shown depending on [filterState]
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

  /// rotates filter options [0 - 4]
  void setUserFilter()  {
    setState(() {
      filterUser = !filterUser;
    });
    if (filterUser) {
      Provider.of<MarkerNotifier>(context, listen:false).setFilterUsername([global.localData.username]);
    } else {
      Provider.of<MarkerNotifier>(context, listen:false).setFilterUsername([]);
    }
  }

  /// updates the marker list via provider to filter for the pins created int the last [days]
  void _setFilterDate(int? days) {
    if (days == null) {
      Provider.of<MarkerNotifier>(context, listen:false).setFilterDate(null, null);
    } else {
      Provider.of<MarkerNotifier>(context, listen:false).setFilterDate(DateTime.now().subtract(Duration(days: days)), null);
    }
  }

  Future<List<MapEntry<Pin, double>>> pinsCloseBy() async {
    try {
      Set<Group> groups = Provider.of<ClusterNotifier>(context).getActiveGroups;
      final destLocation = await LocationClass.getLocation();
      final LatLng position =
          LatLng(destLocation.latitude, destLocation.longitude);
      Map<Pin, double> pins = {};
      const Distance d = Distance();
      for (Group group in groups) {
        for (Pin pin in await group.pins.asyncValue()) {
          double distance2 =
              d.distance(LatLng(pin.latitude, pin.longitude), position);
          pins[pin] = distance2;
        }
      }
      List<MapEntry<Pin, double>> sorted = pins.entries.toList()
        ..sort((e1, e2) => e1.value.compareTo(e2.value));
      return sorted.sublist(0, sorted.length > 10 ? 10 : sorted.length);
    } catch(e) {
      return [];
    }
  }



  void handleTabOnImage(Pin pin) {
    Routing.to(context, ShowImageWidget(pin: pin));
  }

  Future<void> onPanelOpen() async {
    setState(() {});
  }

  void handleOpenGroup(Pin pin) {
    Routing.to(context,   ShowGroupPage(group: pin.group, myGroup: true));
  }


  @override
  bool get wantKeepAlive => true;

}