import 'dart:convert';
import 'dart:io';
import 'package:buff_lisa/Files/pin.dart';
import 'package:flutter/services.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:http/http.dart' as http;
import 'global.dart' as global;

class RestAPI {

  static Future<List<Pin>> fetchAllPins() async {
    HttpClientResponse response = await createHttpsRequest("/api/pins/", {}, 0, null);
    if (response.statusCode == 200) {
      return toPinList(response);
    } else {
      throw Exception("Pins could not be loaded: ${response.statusCode} error code");
    }
  }

  static Future<String?> checkUser(String? name) async {
    name ??= global.username;
    HttpClientResponse response = await createHttpsRequest("/api/users/$name/password", {}, 0, null);
    if (response.statusCode == 200) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<bool> postUsername(String username, String hash, String email) async {
    final String json = jsonEncode(<String, dynamic>{
      "username" : username,
      "password" : hash,
      "email" : email
    });
    HttpClientResponse response = await createHttpsRequest("/api/users/", {}, 1, json);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  static Future<Mona?> fetchMonaFromPinId(int id) async {
    HttpClientResponse response = await createHttpsRequest("/api/monas/$id/", {}, 0, null);
    if (response.statusCode == 200) {
      return Mona.fromJson(json.decode(await response.transform(utf8.decoder).join()));
    } else {
      throw Exception("failed to load mona");
    }
  }

  static Future<List<Ranking>> fetchRanking() async {
    HttpClientResponse response = await createHttpsRequest("/api/ranking/", {}, 0, null);
    if (response.statusCode == 200) {
      List<dynamic> values = json.decode(await response.transform(utf8.decoder).join());
      List<Ranking> ranking = [];
      for (var element in values) {
        ranking.add(Ranking.fromJson(element));
      }
      return ranking;
    } else {
      return [];
    }
  }


  static Future<HttpClientResponse> postPin(Mona mona) async {
    final String json = jsonEncode(<String, dynamic> {
      "latitude" : mona.pin.latitude,
      "longitude" : mona.pin.longitude,
      "creationDate" : Pin.formatDateTim(DateTime.now()),
      "image": await mona.image.readAsBytes(),
      "typeId" : mona.pin.type.id,
      "username": global.username,
    });
    return await createHttpsRequest("/api/monas/", {}, 1, json);
  }

  static Future<List<Version>> checkVersion(int versionId) async {
    HttpClientResponse response = await createHttpsRequest("/api/versions", {"number" : versionId.toString()}, 0, null);
    if (response.statusCode == 200) {
      List<dynamic> values = json.decode(await response.transform(utf8.decoder).join());
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
    HttpClientResponse response = await createHttpsRequest("/api/pins/$id/", {}, 0, null);
    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(await response.transform(utf8.decoder).join()) as Map<String, dynamic>;
      if (json.isNotEmpty) {
        return Pin.fromJson(json);
      }
    }
    return null;
  }

  static Future<int?> getLastVersion() async {
    HttpClientResponse response = await createHttpsRequest("/api/versions/last/", {}, 0, null);
    if (response.statusCode == 200) {

      return int.parse(await response.transform(utf8.decoder).join());
    }
    return null;
  }

  static Future<int?> getUserPoints() async {
    HttpClientResponse response = await createHttpsRequest("/api/users/${global.username}/points/", {}, 0, null);
    if (response.statusCode == 200) {
      return int.parse(await response.transform(utf8.decoder).join());
    }
    return null;
  }

  static Future<String?> getUsernameByPin(int id) async {
    HttpClientResponse response = await createHttpsRequest("/api/pins/$id/user/", {}, 0, null);
    if (response.statusCode == 200) {
      return await response.transform(utf8.decoder).join();
    }
    return null;
  }

  static Future<bool> changePassword(String username, String password) async {
    final String json = jsonEncode(<String, dynamic> {
      "password" : password
    });
    HttpClientResponse response = await createHttpsRequest("/api/users/$username/", {}, 2, json);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<bool> changeEmail(String username, String email) async {
    final String json = jsonEncode(<String, dynamic> {
      "email" : email
    });
    HttpClientResponse response = await createHttpsRequest("/api/users/$username/", {}, 2, json);
    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  static Future<List<Pin>> toPinList(HttpClientResponse response) async {
    List<dynamic> values = json.decode(await response.transform(utf8.decoder).join());
    List<Pin> pins = [];
    for (var element in values) {
      pins.add(Pin.fromJson(element));
    }
    return pins;
  }

  static Future<HttpClientResponse> createHttpsRequest (String path, Map<String,dynamic> queryParameters, int requestType, String? encode) async {
    SecurityContext context = SecurityContext(withTrustedRoots: true);
    context.setTrustedCertificatesBytes(utf8.encode(await rootBundle.loadString('images/cert.pem')), password: "password");
    HttpClient client = HttpClient(context: context) ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    Uri url = Uri(scheme: "https", host: global.host, port: global.port, path: path, queryParameters: queryParameters);
    HttpClientRequest request;
    print(url);
    switch (requestType) {
      case 0: request = await client.getUrl(url);break;
      case 1: request = await client.postUrl(url);break;
      case 2: request = await client.putUrl(url);break;
      case 3: request = await client.deleteUrl(url);break;
      default: throw Exception("HTTPS Request method does not exist");
    }
    request.headers.add(FlutterConfig.get('API_KEY_NAME'), FlutterConfig.get('API_KEY_VALUE'));
    request.headers.add(FlutterConfig.get('API_KEY_ADMIN_NAME'), FlutterConfig.get('API_KEY_ADMIN_VALUE'));
    if ((requestType == 1 || requestType == 2) && encode != null) {
      request.headers.contentType =  ContentType('application', 'json', charset: 'utf-8');
      request.write(encode);
    }
    return await request.close();
  }

}

