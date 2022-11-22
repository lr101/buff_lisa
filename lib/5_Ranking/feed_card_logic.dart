import 'dart:typed_data';
import 'package:buff_lisa/5_Ranking/feed_card_ui.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/global.dart' as global;

class FeedCard extends StatefulWidget {
  const FeedCard({super.key, required this.pin});

  final Pin pin;

  @override
  FeedCardState createState() => FeedCardState();
}

class FeedCardState extends State<FeedCard>   with AutomaticKeepAliveClientMixin<FeedCard>{

  late Widget front;
  late Widget back;
  late FlipCardController controller;

  @override
  Widget build(BuildContext context)  {
    super.build(context);
    return FeedCardUI(state: this);
  }

  @override
  void initState() {
    super.initState();
    controller = FlipCardController();
  }


  Widget getMapOfPin(BuildContext context, Group group) {
    double width = MediaQuery.of(context).size.width;
    Pin pin = widget.pin;
    return SizedBox(
        height: width,
        width: width,
        child: GestureDetector(
            onTap: () => changeSize(context),
            child: AbsorbPointer(
                absorbing: true,
                child: FlutterMap(
                  options: MapOptions(
                      center: LatLng(pin.latitude, pin.longitude),
                      zoom: global.feedZoom,
                      keepAlive: true
                  ),
                  layers: [
                    TileLayerOptions(
                        urlTemplate: "${global.styleUrl}?api_key={api_key}",
                        additionalOptions: {
                          "api_key": global.apiKey
                        }
                    ),
                    MarkerLayerOptions(
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

  Widget getImageOfPin(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      height: width,
      width: width,
      child: GestureDetector(
          onTap: () => changeSize(context),
          child: widget.pin.getImageWidget()
      )
    );
  }

  void changeSize(BuildContext context) {
    controller.toggleCard();
  }

  @override
  bool get wantKeepAlive => true;

}