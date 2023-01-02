import 'package:buff_lisa/5_Ranking/feed_card_ui.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../Files/Other/global.dart' as global;

class FeedCard extends StatefulWidget {
  const FeedCard({super.key, required this.pin});

  /// Pin shown on this Card shown in the feed
  final Pin pin;

  @override
  FeedCardState createState() => FeedCardState();
}

class FeedCardState extends State<FeedCard>   with AutomaticKeepAliveClientMixin<FeedCard>{

  /// Widget shown on the front of the flip card
  late Widget front;

  /// Widget shown on the back of the flip card
  late Widget back;

  /// FlipcardController is used to toggle Flipcard on button press
  late FlipCardController controller;

  @override
  Widget build(BuildContext context)  {
    super.build(context);
    return FeedCardUI(state: this);
  }

  /// Init FlipCardController before build
  @override
  void initState() {
    super.initState();
    controller = FlipCardController();
  }


  /// returns the front widget
  /// Creates a Flutter_Map with the pin location in the center
  /// All interactions are absorbed instead a single tab toggles the flip card
  Widget getMapOfPin(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Pin pin = widget.pin;
    return SizedBox(
        height: width,
        width: width,
        child: GestureDetector(
            onTap: () => toggleCard(context),
            child: AbsorbPointer(
                absorbing: true,
                child: FlutterMap(
                  options: MapOptions(
                      center: LatLng(pin.latitude, pin.longitude),
                      zoom: global.feedZoom,
                      keepAlive: true
                  ),
                  children: [
                    TileLayer(
                        urlTemplate: "${global.styleUrl}?api_key={api_key}",
                        additionalOptions: {
                          "api_key": global.apiKey
                        }
                    ),
                    MarkerLayer(
                        markers: [
                            Marker(
                              point: LatLng(pin.latitude, pin.longitude),
                              width: 50,
                              height: 50,
                              builder: (BuildContext context) => pin.group.getPinImageWidget()
                            )
                        ]
                    )
                  ],
                )
            ),
          )
    );
  }

  /// returns the back Widget of the FlipCard
  /// returns the Image of the pin
  /// A single tab toggles the FlipCard
  Widget getImageOfPin(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: width,
      width: width,
      child: GestureDetector(
          onTap: () => toggleCard(context),
          child: widget.pin.getImageWidget()
      )
    );
  }

  /// toggles the card from back to front or front to back
  void toggleCard(BuildContext context) {
    controller.toggleCard();
  }

  /// keeps the Widget alive (keep toggle state) in the list view
  @override
  bool get wantKeepAlive => true;

}