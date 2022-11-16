import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:status_view/status_view.dart';
import '../Files/AbstractClasses/abstract_widget_ui.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/global.dart' as global;
import '../Providers/cluster_notifier.dart';
import '../SelectGroupWidget/select_group_widget_logic.dart';
import 'maps_logic.dart';

class MapsUI extends StatefulUI<MapsWidget, MapsWidgetState> {

  const MapsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              GoogleMap(
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
                markers:  Provider.of<ClusterNotifier>(context).getMarkers,
                onMapCreated: state.onMapCreated,
                onCameraMove: state.onCameraMove,
                onCameraIdle: () {state.onCameraIdle(context);},
              ),
              const SelectGroupWidget(multiSelector: true,)
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
              onPressed: state.setFilter,
              backgroundColor: state.filterState % 5 != 0 ?  global.cThird : Colors.grey,
              child: (state.filterState % 5 == 0 ? const Icon(Icons.timeline_rounded) : Text(state.buttonText())),
            ),
            const SizedBox(
              height: 3,
            ),
            FloatingActionButton(
              heroTag: "setLocationBtn",
              onPressed: state.setLocation,
              backgroundColor: global.cThird,
              child: const Icon(Icons.location_on),
            ),
          ],
        )
    );
  }
}