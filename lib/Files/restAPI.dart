import 'dart:convert';
import 'package:buff_lisa/Files/pin.dart';
import 'package:http/http.dart' as http;
import 'global.dart' as global;

class RestAPI {

  static Future<List<Pin>> fetchAllPins() async {
    return fetchPins(global.getPin);
  }

  static Future<List<Pin>> fetchMyCreatedPins() async {
    return fetchPins("${global.getPinsOfUser}?type=1");
  }

  static Future<List<Pin>> fetchMyFoundPins() async {
    return fetchPins("${global.getPinsOfUser}?type=2");
  }

  static Future<List<Pin>> fetchOtherPins() async {
    return fetchPins("${global.getPinsOfUser}?type=3");
  }

  static Future<String?> checkUser() async {
    final response = await http.get(Uri.parse(global.checkUser));
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

  static Future<bool> postUsername(String username, String hash) async {
    final String json = jsonEncode(<String, dynamic>{
      "username" : username,
      "password" : hash
    });
    final response = await httpPost(global.postUsername, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<Mona?> fetchMonaFromPinId(int id) async {
    final response = await http.get(Uri.parse("${global.getMonaByPinId}$id"));
    if (response.statusCode == 200) {
      return Mona.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  static Future<List<Pin>> fetchPins(String sql) async {
    final response = await http.get(Uri.parse(sql));
    if (response.statusCode == 200) {
      List<dynamic> values = json.decode(response.body);
      List<Pin> pins = [];
      for (var element in values) {
        pins.add(Pin.fromJson(element));
      }
      return pins;
    } else {
       throw Exception("failed to load pins");
    }
  }

  static Future<List<Ranking>> fetchRanking() async {
    final response = await http.get(Uri.parse(global.getRanking));
    if (response.statusCode == 200) {
      List<dynamic> values = json.decode(response.body);
      List<Ranking> ranking = [];
      for (var element in values) {
        ranking.add(Ranking.fromJson(element));
      }
      return ranking;
    } else {
      return [];
    }
  }

  static Future<http.BaseResponse> putPin(Mona mona) async {
    final String json = jsonEncode(<String, dynamic> {
      "image": await mona.image.readAsBytes(),
      "id" : mona.pin.id
    });
    return await httpPut(global.postOrPutPin, json);
  }


  static Future<http.BaseResponse> postPin(Mona mona) async {
    final String json = jsonEncode(<String, dynamic> {
      "latitude" : mona.pin.latitude,
      "longitude" : mona.pin.longitude,
      "creationDate" : Pin.formatDateTim(DateTime.now()),
      "image": await mona.image.readAsBytes(),
      "typeId" : mona.pin.type.id,
    });
    return await httpPost(global.postOrPutPin, json);
  }

  static Future<http.BaseResponse> httpPost (String url, String json) async {
   return await http.post(
          Uri.parse(url),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: json
      );
  }

  static Future<http.BaseResponse> httpPut (String url, String json) async {
    return await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json
    );
  }

  static Future<List<Version>> checkVersion(int versionId) async {
    final response = await http.get(Uri.parse("${global.checkVersion}$versionId"));
    if (response.statusCode == 200) {
      List<dynamic> values = json.decode(response.body);
      List<Version> versions = [];
      for (var element in values) {
        versions.add(Version.fromJson(element));
      }
      return versions;
    } else {
     return [];
    }
  }

  static Future<Pin?> fetchPin(int id) async {
    final response = await http.get(Uri.parse("${global.getPin}$id?username=${global.username}"));
    if (response.statusCode == 200 && response.body != "") {
      Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      if (json.isNotEmpty) {
        return Pin.fromJson(json);
      }
    }
    return null;
  }

  static Future<int?> getLastVersion() async {
    final response = await http.get(Uri.parse(global.getLastVersion));
    if (response.statusCode == 200) {
      return int.parse(response.body);
    }
    return null;
  }

  static Future<String?> getUsernameByPin(int id) async {
    final response = await http.get(Uri.parse("${global.getUsernameByPin}$id/user"));
    if (response.statusCode == 200) {
      return response.body;
    }
    return null;
  }

}

