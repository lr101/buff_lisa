import 'dart:async';
import 'dart:typed_data';
import 'package:image/image.dart' as images;
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'map_marker.dart';

/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.
class MapHelper {

  static Future<images.Image> setMarkerImage() async {
    ByteData data = await rootBundle.load('images/c_marker_cluster_105px.png');
    List<int> bytes = Uint8List.view(data.buffer);
    return images.decodeImage(bytes)!;
  }

  /// Inits the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.
  static Future<Fluster<MapMarker>> initClusterManager(
      List<MapMarker> markers,
      int minZoom,
      int maxZoom,
      ) async {
    Map<int,BitmapDescriptor> icons = await getClusterIcons();
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 50,
      extent: 1024,
      nodeSize: 64,
      points: markers,
      createCluster: (
          BaseCluster? cluster,
          double? lng,
          double? lat,
          ) =>
          MapMarker(
            id: cluster!.id.toString(),
            position: LatLng(lat!, lng!),
            isCluster: cluster.isCluster,
            clusterId: cluster.id,
            pointsSize: cluster.pointsSize,
            childMarkerId: cluster.childMarkerId,
            icon: getClusterIcon(cluster.pointsSize!, icons)!,
            onMarkerTap: () {  },
          ),
    );
  }

  static BitmapDescriptor? getClusterIcon(int size, Map<int, BitmapDescriptor> icons) {
    if (size == 2) {
      return icons[2];
    } else if (size == 3) {
      return icons[3];
    } else if (size == 4) {
      return icons[4];
    } else if (size == 5) {
      return icons[5];
    } else if (size < 10) {
      return icons[10];
    } else if (size < 25) {
      return icons[25];
    } else if (size < 50) {
      return icons[50];
    } else if (size <= 99) {
      return icons[99];
    } else if (size >= 100) {
      return icons[100];
    } else {
      return icons[0];
    }
  }

  static Future<Map<int, BitmapDescriptor>> getClusterIcons() async{
    Map<int, BitmapDescriptor> icons = {};
    icons[0] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster_105px.png');
    icons[2] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster2.png');
    icons[3] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster3.png');
    icons[4] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster4.png');
    icons[5] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster5.png');
    icons[10] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster10.png');
    icons[25] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster25.png');
    icons[50] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster50.png');
    icons[99] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster100.png');
    icons[100] = await BitmapDescriptor.fromAssetImage(const ImageConfiguration(), 'images/c_marker_cluster100+.png');
    return icons;
  }
  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].
  static List<Marker> getClusterMarkers(
      Fluster<MapMarker>? clusterManager,
      int currentZoom,) {
    if (clusterManager == null) return [];
    return clusterManager.clusters(
      [-180, -85, 180, 85],
      currentZoom,
    ).map((mapMarker) => mapMarker.toMarker()).toList();
  }
}