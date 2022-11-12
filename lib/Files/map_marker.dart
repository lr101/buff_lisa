import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  final Pin? pin;
  late final BitmapDescriptor icon;
  VoidCallback  onMarkerTap;

  MapMarker({
    required this.id,
    required this.position,
    required this.icon,
    required this.onMarkerTap,
    required this.pin,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
  }) : super(
    markerId: id,
    latitude: position.latitude,
    longitude: position.longitude,
    isCluster: isCluster,
    clusterId: clusterId,
    pointsSize: pointsSize,
    childMarkerId: childMarkerId,
  );

  Marker toMarker() => Marker(
    markerId: MarkerId(id),
    position: LatLng(
      position.latitude,
      position.longitude,
    ),
    onTap: onMarkerTap,
    icon: icon,
  );
}