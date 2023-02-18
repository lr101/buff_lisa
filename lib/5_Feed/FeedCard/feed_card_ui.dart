import 'dart:typed_data';
import 'dart:ui';

import 'package:buff_lisa/5_Feed/FeedCard/feed_card_logic.dart';
import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Providers/user_notifier.dart';
import 'package:configurable_expansion_tile_null_safety/configurable_expansion_tile_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;

import '../../Files/Widgets/custom_popup_menu_button.dart';
import '../../Providers/theme_provider.dart';

class FeedCardUI extends StatefulUI<FeedCard, FeedCardState>{

  const FeedCardUI({super.key, required state}) : super(state: state);



  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: LayoutBuilder(
            builder: (p0, p1) => SizedBox(
            width: MediaQuery.of(p0).size.width,
            height: MediaQuery.of(p0).size.width + 80,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    child: SizedBox(
                      height: 40,
                      width: MediaQuery.of(p0).size.width,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                    onTap: state.handleOpenUserProfile,
                                    child:Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                      child:Provider.of<UserNotifier>(context, listen: false).getUser(state.widget.pin.username).profileImage.customWidget(
                                          callback: (Uint8List? image, bool defaultValue) {
                                            if (image != null) {
                                              return CircleAvatar(backgroundImage: Image.memory(image).image, radius: 18,);
                                            } else {
                                              return CircleAvatar(backgroundImage: const Image(image: AssetImage("images/profile.jpg"),).image, radius: 18,);
                                            }
                                          }
                                      ),
                                    ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: state.handleOpenUserProfile,
                                      child: Text(widget.pin.username),
                                    ),
                                    GestureDetector(
                                      onTap: state.handleOpenGroup,
                                      child: Text(widget.pin.group.name, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),),
                                    )
                                  ],
                                )
                              ]
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(formatTime()),
                              menuButton(
                                  menu: CustomPopupMenuButton(pin: state.widget.pin, update: state.widget.update,)
                              )
                            ],
                          )
                        ],
                      )
                    )
                  ),
                Positioned(
                  top: 80,
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                      child: LayoutBuilder(
                          builder: (c0, _) => SizedBox(
                              height: MediaQuery.of(c0).size.width - 10,
                              width: MediaQuery.of(c0).size.width - 20 ,
                              child: FutureBuilder<Uint8List>(
                                future: state.widget.pin.image.asyncValue(),
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
                                              height: MediaQuery.of(c0).size.width - 10,
                                              width: MediaQuery.of(c0).size.width - 10,
                                              child: Center(
                                                  child: InteractiveViewer(
                                                      panEnabled: false,
                                                      boundaryMargin: const EdgeInsets.all(0),
                                                      minScale: 1.1,
                                                      maxScale: 4,
                                                      child: Image.memory(snapshot.requireData)
                                                  )
                                              )
                                          ),
                                        ),
                                       )
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                },
                                )
                            )
                        )
                    )
                  ),
                Positioned(
                  top: 40,
                    child: ConfigurableExpansionTile(
                        header: SizedBox(
                            height: 38,
                            width: MediaQuery.of(p0).size.width,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Icon(Icons.pin_drop),
                                ),
                                FutureBuilder<List<Placemark>>(
                                    future: placemarkFromCoordinates(state.widget.pin.latitude, state.widget.pin.longitude),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData && snapshot.requireData.isNotEmpty) {
                                        Placemark first = snapshot.requireData.first;
                                        String near = "";
                                        if (first.locality != null) {
                                          near += first.locality!;
                                          if (first.isoCountryCode != null) near += " (${first.isoCountryCode})";
                                        } else if (first.country != null) {
                                          near += first.country!;
                                        }
                                        return Text(near);
                                      } else {
                                        return const Text("...");
                                      }
                                    },
                                )
                              ],
                            )
                        ),
                        childrenBody: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(
                                    height: MediaQuery.of(p0).size.width,
                                    width: MediaQuery.of(p0).size.width - 10,
                                    child:  Stack(
                                    children: [
                                     AbsorbPointer(
                                        absorbing: true,
                                        child: FlutterMap(
                                          mapController: state.controller,
                                          options: MapOptions(
                                              minZoom: 2,
                                              maxZoom: 18,
                                              center: state.center,
                                              zoom: global.feedZoom,
                                              keepAlive: false
                                          ),
                                          children: [
                                            TileLayer(
                                                urlTemplate: "${Provider.of<ThemeProvider>(context).getCustomTheme.mapUrl}?api_key={api_key}",
                                                additionalOptions: {
                                                  "api_key": global.apiKey
                                                }
                                            ),
                                            MarkerLayer(
                                                markers: [
                                                  Marker(
                                                      point: LatLng(state.widget.pin.latitude, state.widget.pin.longitude),
                                                      width: 50,
                                                      height: 50,
                                                      builder: (BuildContext context) => state.widget.pin.group.pinImage.getWidget()
                                                  )
                                                ]
                                            )
                                          ],
                                          ),
                                        ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              FloatingActionButton(onPressed: state.zoomIn, backgroundColor: Colors.black.withOpacity(0.1), child: const Icon(Icons.zoom_in)),
                                              FloatingActionButton(onPressed: state.zoomOut, backgroundColor: Colors.black.withOpacity(0.1), child: const Icon(Icons.zoom_out),)
                                            ],
                                          ),
                                        )
                                      )
                                    ],
                                )
                          )
                          ]
                      )
                    )
                ),
              ],
            )
          )
        )
    );
  }

  Widget menuButton({required Widget menu}) {
    if (global.username != state.widget.pin.username) {
      return menu;
    } else {
      return const SizedBox(width: 48,);
    }
  }

  String formatTime() {
    DateTime now = DateTime.now().toUtc();
    DateTime time = widget.pin.creationDate.toUtc();
    final difference = now.difference(time);
    if (difference.inDays >= 365) {
      return "${difference.inDays ~/ 365} years ago";
    } else if (difference.inDays >= 7) {
      return "${difference.inDays ~/ 7} weeks ago";
    } else if (difference.inDays >= 1) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours} hours ago";
    } else {
      return "${difference.inMinutes} min. ago";
    }
  }




}