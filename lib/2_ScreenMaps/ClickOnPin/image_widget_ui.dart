import 'dart:typed_data';

import 'package:buff_lisa/Files/AbstractClasses/abstract_widget_ui.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:buff_lisa/Files/Themes/custom_theme.dart';
import 'package:buff_lisa/Files/Widgets/CustomSliverList/custom_easy_title.dart';
import 'package:buff_lisa/Files/Widgets/custom_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../../Files/Widgets/custom_popup_menu_button.dart';
import '../../Files/Widgets/custom_round_image.dart';
import '../../Providers/map_notifier.dart';
import '../../Providers/theme_provider.dart';
import '../../Providers/user_notifier.dart';
import 'image_widget_logic.dart';

class ImageWidgetUI extends StatefulUI<ShowImageWidget, ShowImageWidgetState> {
  const ImageWidgetUI({super.key, required state}) : super(state: state);

  @override
  Widget build(BuildContext context) {
    DateTime now = state.widget.pin.creationDate;
    return Scaffold(
        appBar: null,
        body: CustomTitle(
            title: CustomEasyTitle(
              title: const Text("Image"),
              back: true,
              right: getActionBar(),
            ),
            child: SlidingUpPanel(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border.all(color: Colors.grey),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0)),
                body: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                          height: 40,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 5,),
                                    Padding(
                                      padding: const EdgeInsets.all(2),
                                      child: CustomRoundImage(
                                        size: 16,
                                        imageCallback:
                                            Provider.of<UserNotifier>(context,
                                                    listen: false)
                                                .getUser(
                                                    state.widget.pin.username)
                                                .profileImageSmall
                                                .asyncValue,
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: state.handleOpenUserProfile,
                                          child: Text(widget.pin.username),
                                        ),
                                        GestureDetector(
                                          onTap: state.handleOpenGroup,
                                          child: Text(
                                            widget.pin.group.name,
                                            style: const TextStyle(
                                                fontSize: 12,
                                                fontStyle: FontStyle.italic),
                                          ),
                                        )
                                      ],
                                    )
                                  ]),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(DateFormat('d. MMMM y').format(now)),
                                  const SizedBox(width: 5,),
                                ],
                              )
                            ],
                          )),
                      // -- image --
                      FutureBuilder<Uint8List>(
                        future: widget.pin.image.asyncValue(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Padding(
                                padding: const EdgeInsets.all(5),
                                child: InteractiveViewer(
                                  transformationController: state.controller,
                                  boundaryMargin: const EdgeInsets.all(0),
                                  onInteractionEnd:
                                      (ScaleEndDetails endDetails) {
                                    state.controller.value = Matrix4.identity();
                                  },
                                  child: Image.memory(snapshot.requireData),
                                ));
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        },
                      )
                    ]),
                panel: Column(children: [
                  SizedBox(
                    height: 40,
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
                  Expanded(
                    child: FlutterMap(
                    options: MapOptions(
                        minZoom: 2,
                        maxZoom: 18,
                        center:
                            LatLng(widget.pin.latitude, widget.pin.longitude),
                        zoom: global.feedZoom,
                        keepAlive: false),
                    children: [
                      TileLayer(
                          urlTemplate:
                              "${Provider.of<MapNotifier>(context).getMapUrl(Provider.of<ThemeNotifier>(context).getTheme.brightness)}?api_key={api_key}",
                          additionalOptions: {
                            "api_key": global.localData.getMapApiKey()
                          }),
                      CurrentLocationLayer(),
                      MarkerLayer(markers: [
                        Marker(
                            point: LatLng(state.widget.pin.latitude,
                                state.widget.pin.longitude),
                            width: 50,
                            height: 50,
                            builder: (BuildContext context) =>
                                state.widget.pin.group.pinImage.getWidget())
                      ])
                    ],
                  )),
                ]))));
  }

  /// delete button only shown when current user is owner of pin
  CustomEasyAction getActionBar() {
    if (widget.pin.username == global.localData.username) {
      return CustomEasyAction(
          child: const Icon(Icons.delete),
          action: () => state.handleButtonPress());
    } else {
      return CustomEasyAction(
        child: CustomPopupMenuButton(
          pin: state.widget.pin,
          update: () async => Navigator.of(state.context).pop(),
        ),
      );
    }
  }
}
