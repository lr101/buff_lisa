import 'dart:typed_data';
import 'dart:ui';

import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:buff_lisa/Providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../Files/DTOClasses/pin.dart';
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
          child: SlidingUpPanel(
            color: Theme.of(context).scaffoldBackgroundColor,
            backdropEnabled: false,
            boxShadow: const [],
            minHeight: 20,
            maxHeight: 222,
            border: Border.all(color: Colors.grey),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0)),
            onPanelSlide: (position) => state.slider.value = position,
            onPanelOpened: () => state.onPanelOpen(),
            body: FlutterMap(
                mapController: state.controller,
                options: MapOptions(
                    minZoom: 2,
                    maxZoom: 18,
                    center: global.initCamera,
                    zoom: 5,
                    keepAlive: true,
                    interactiveFlags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                ),
                children: [
                  TileLayer(
                    urlTemplate: "${Provider.of<MapNotifier>(context).getMapUrl(Provider.of<ThemeNotifier>(context).getTheme.brightness)}?api_key={api_key}",
                    additionalOptions: {
                      "api_key": global.localData.getMapApiKey() ?? ""
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
            panel: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  height: 22,
                  decoration: BoxDecoration(
                      color: Provider.of<ThemeNotifier>(context).getTheme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)
                      ),
                  //  border: Border(top: BorderSide(), right: BorderSide(), left: BorderSide(), bottom: BorderSide.none)
                  ),
                  child: Center(
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          height: 5,
                          decoration: const BoxDecoration(
                              color: CustomTheme.c1,
                              borderRadius: BorderRadius.all(Radius.circular(2.5))
                          )
                      )
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: FutureBuilder<List<MapEntry<Pin,double>>>(
                    future: state.pinsCloseBy(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.requireData.isNotEmpty) {
                        return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.requireData.length,
                            itemBuilder: (context, index) => getEntry(snapshot.requireData[index], context),
                        );
                      } else if (snapshot.hasData) {
                        return const Center(child: Text("No posts near you", style: TextStyle(fontStyle: FontStyle.italic),));
                      } else {
                        return const SizedBox.square(
                          dimension: 50,
                            child: Center(child: CircularProgressIndicator())
                        );
                      }
                    }
                  )
                )
              ],
            ),
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
            ValueListenableBuilder(
              valueListenable: state.slider,
              builder: (context, double value, child) {
                return SizedBox(height: value * 200 + 10,);
              },
            ),
          ],
        )
    );
  }

  Widget getEntry(MapEntry<Pin, double> entry, BuildContext context) {
    return Column(
      children: [
        Container(
          color: Theme.of(context).scaffoldBackgroundColor,
            height: 20,
            width: 200,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => state.handleOpenGroup(entry.key),
                              child: Text(entry.key.group.name, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic)),
                            )
                          ],
                        )
                      ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("~${entry.value >= 1000 ? "${(entry.value ~/1000).toInt()}km" : "${entry.value.toInt()}m"}")
                    ],
                  )
                ],
              )
          ),
        ),
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: FutureBuilder<Uint8List>(
                future: entry.key.image.asyncValue(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              alignment: const Alignment(-.2, 0),
                              image: Image.memory(snapshot.requireData).image,
                              fit: BoxFit.cover
                          ),
                        ),
                        child: ClipRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: SizedBox(
                                height: 180,
                                width: 180,
                                child: Center(
                                    child: GestureDetector(
                                        onTap: () => state.handleTabOnImage(entry.key),
                                        child: Image.memory(snapshot.requireData)
                                    )
                                )
                            ),
                          ),
                        )
                    );
                  } else {
                    return Container(
                      height: 180,
                      width: 180,
                      color: Colors.grey,
                    );
                  }
                },
              ),
            ),
          )
        ],
    );
  }



}