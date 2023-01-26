import 'package:buff_lisa/8_SelectGroupWidget/select_group_widget_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';

import '../Files/AbstractClasses/abstract_widget_ui.dart';
import '../Files/Other/global.dart' as global;
import '../Providers/cluster_notifier.dart';
import '../Providers/theme_provider.dart';
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
              FlutterMap(
                mapController: state.controller,
                options: MapOptions(
                    minZoom: 2,
                    maxZoom: 18,
                    center: global.initCamera,
                    zoom: 19,
                    keepAlive: true,
                    interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "${Provider.of<ThemeProvider>(context).getCustomTheme.mapUrl}?api_key={api_key}",
                    additionalOptions: {
                      "api_key": global.apiKey
                    }
                  ),
                  CurrentLocationLayer(),
                  MarkerClusterLayerWidget(
                      options: MarkerClusterLayerOptions(
                        disableClusteringAtZoom: 17,
                        maxClusterRadius: 45,
                        size: const Size(40, 40),
                        fitBoundsOptions: const FitBoundsOptions(
                          padding: EdgeInsets.all(50),
                        ),
                        markers: Provider.of<ClusterNotifier>(context).getMarkers,
                        polygonOptions: const PolygonOptions(
                            borderColor: Colors.blueAccent,
                            color: Colors.black12,
                            borderStrokeWidth: 3),
                        builder: (context, markers) {
                          return FloatingActionButton(
                            heroTag: markers.first.key,
                            key: markers.first.key,
                            onPressed: null,
                            child: Text(markers.length.toString()),
                          );
                        },
                      ),
                  )
                ],
              ),
            ],
          ),
        ),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "filterYourOwnPins",
              onPressed: state.setUserFilter,
              backgroundColor: state.filterUser ?  global.cThird : Colors.grey,
              child: const Icon(Icons.person),
            ),
            const SizedBox(
              height: 3,
            ),
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