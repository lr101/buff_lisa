import 'package:buff_lisa/Files/DTOClasses/user.dart';
import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:flutter/cupertino.dart';

class MapNotifier with ChangeNotifier {

  void setMapApiKey(String apiKey) {
    global.localData.setMapApiKey(apiKey);
    notifyListeners();
  }

  String get mapApiKey => global.localData.getMapApiKey();

  void setMapStyle(int? style) {
    global.localData.setMapStyle(style);
    notifyListeners();
  }

  String getMapUrl(Brightness mode) {
    int? style = global.localData.getMapStyle();
    String url = "https://tiles.stadiamaps.com/tiles/";
    switch (style) {
      case 0 : url += "alidade_smooth";
 break;
      case 1 : url += "alidade_smooth_dark";
 break;
      case 2 : url += "outdoors";
 break;
      case 3 : url += "osm_bright";
 break;
      default : url += (mode == Brightness.dark) ? "alidade_smooth_dark" : "osm_bright";
    }
    return url += "/{z}/{x}/{y}{r}.png";
  }
}