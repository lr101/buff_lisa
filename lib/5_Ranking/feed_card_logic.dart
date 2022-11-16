import 'package:buff_lisa/5_Ranking/feed_card_ui.dart';
import 'package:buff_lisa/Files/restAPI.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flip_card/flip_card_controller.dart';
import 'package:flutter/material.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../Files/DTOClasses/group.dart';
import '../Files/DTOClasses/mona.dart';


class FeedCard extends StatefulWidget {
  const FeedCard({super.key, required this.pin});

  final Pin pin;

  @override
  FeedCardState createState() => FeedCardState();
}

class FeedCardState extends State<FeedCard>  {

  late Widget front;
  late Widget back;
  late FlipCardController controller;

  @override
  Widget build(BuildContext context)  {
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
                child: GoogleMap(
                  mapType: MapType.normal,
                  zoomControlsEnabled: false,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(pin.latitude, pin.longitude), zoom: 10),
                  markers: <Marker>{
                    Marker(markerId: const MarkerId("0"),
                        icon: BitmapDescriptor.fromBytes(group.pinImage!),
                        position: LatLng(pin.latitude, pin.longitude))
                  },
                )
            ),
          )
    );
  }

  Widget getImageOfPin(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Pin pin = widget.pin;
    return SizedBox(
      height: width,
      width: width,
      child: GestureDetector(
          onTap: () => changeSize(context),
          child: FutureBuilder<Mona?>(
              future: RestAPI.fetchMonaFromPinId(pin.id, pin.groupId),
              builder: ((context, snapshot) {
                if (snapshot.hasData) {
                  return Image.memory(
                      snapshot.data!.image,
                      gaplessPlayback: true,);
                } else {
                  return const CircularProgressIndicator();
                }
              })
          ),
      )
    );
  }

  void changeSize(BuildContext context) {
    controller.toggleCard();
  }

}