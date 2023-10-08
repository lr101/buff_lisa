import 'package:buff_lisa/Files/Other/global.dart' as global;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RestAPI {

  /// creates and sends a https request to the server
  /// uses the certificate provided in the assets folder to send a secure request
  /// uses the user token to provide authentication of a user with every request
  /// [path] is the url path request to server as String
  /// [requestType] is the type of request: 0 - GET, 1 - POST, 2 - PUT, 3 - DELETE
  /// [queryParameters] are the url params added at the end of the url with '?' as a map; Format: {"NAME": value, ...}
  /// [encode] is the body formatted as json string; null: no body; String: body existing  -> Http ContentType is set to application/json
  /// [timeout] is the time in seconds until the requests times out, if null the default timeout time is used
  /// returns a http response
  static Future<http.Response> createHttpsRequest (String path, Map<String,dynamic> queryParameters, int requestType, {String? encode, int timeout = 30}) async {
    Map<String, String> header = {"Authorization" : "Bearer ${global.localData.token}"};
    if (encode != null) header["Content-Type"] = "application/json";
    Uri uri = Uri(scheme: "http", host: "10.0.2.2", port: 3000, path: path, queryParameters: queryParameters);
    //Uri uri = Uri(scheme: "https", host: global.host, path: path, queryParameters: queryParameters);
    if (kDebugMode) {
      String uriDebug = "";
      switch (requestType) {
        case 0: uriDebug += "GET ";break;
        case 1: uriDebug += "POST ";break;
        case 2: uriDebug += "PUT ";break;
        case 3: uriDebug += "DELETE ";break;
        default: uriDebug += "ERROR (NO TYPE) ";break;
      }
      uriDebug += uri.toString();
      print(uriDebug);
      print(header);
    }
    switch (requestType) {
      case 0: return await http.get(uri, headers: header,).timeout(Duration(seconds: timeout));
      case 1: return await http.post(uri, headers: header, body: encode).timeout(Duration(seconds: timeout));
      case 2: return await http.put(uri, headers: header, body: encode).timeout(Duration(seconds: timeout));
      case 3: return await http.delete(uri, headers: header, body: encode).timeout(Duration(seconds: timeout));
      default: throw Exception("HTTPS Request method does not exist");
    }
  }

}

