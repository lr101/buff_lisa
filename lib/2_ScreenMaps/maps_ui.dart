import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';

import '../Files/Themes/custom_theme.dart';
import '../Providers/map_notifier.dart';
import '../Providers/marker_notifier.dart';
import 'maps_logic.dart';

class MapsUI extends StatefulUI<MapsWidget, MapsWidgetState> {

  const MapsUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: null,
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
                    zoom: global.initialZoom,
                    keepAlive: true,
                    interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "${Provider.of<MapNotifier>(context).getMapUrl(Provider.of<ThemeNotifier>(context).getTheme.brightness)}?api_key={api_key}",
                    additionalOptions: {
                      "api_key": global.localData.getMapApiKey()
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
                        markers: Provider.of<MarkerNotifier>(context).getMarkers,
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
              backgroundColor: state.filterUser ?  CustomTheme.c1 : Colors.grey,
              child: const Icon(Icons.person),
            ),
            const SizedBox(
              height: 3,
            ),
            FloatingActionButton(
              heroTag: "setFilterBtn",
              onPressed: state.setFilter,
              backgroundColor: state.filterState % 5 != 0 ?  CustomTheme.c1 : Colors.grey,
              child: (state.filterState % 5 == 0 ? const Icon(Icons.timeline_rounded) : Text(state.buttonText())),
            ),
            const SizedBox(
              height: 3,
            ),
            FloatingActionButton(
              heroTag: "setLocationBtn",
              onPressed: state.setLocation,
              backgroundColor: CustomTheme.c1,
              child: const Icon(Icons.location_on),
            ),
          ],
        )
    );
  }
}