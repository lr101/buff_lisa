import 'package:http/http.dart' as http;

import '../Other/global.dart' as global;

class RestAPI {

  /// creates and sends a https request to the server
  /// uses the certificate provided in the assets folder to send a secure request
  /// uses the user token to provide authentication of a user with every request
  /// [path] is the url path request to server as String
  /// [requestType] is the type of request: 0 - GET, 1 - POST, 2 - PUT, 3 - DELETE
  /// [queryParameters] are the url params added at the end of the url with '?' as a map; Format: {"NAME": value, ...}
  /// [encode] is the body formatted as json string; null: no body; String: body existing  -> Http ContentType is set to application/json
  /// returns a http response
  static Future<http.Response> createHttpsRequest (String path, Map<String,dynamic> queryParameters, int requestType, String? encode) async {
    Map<String, String> header = {"Authorization" : "Bearer ${global.token}"};
    if (encode != null) header["Content-Type"] = "application/json";
    print("$requestType https://${global.host}$path?${queryParameters.keys.join("&")}");
    switch (requestType) {
      case 0: return await http.get(Uri(scheme: "http", port: 8081, host: global.host, path: path, queryParameters: queryParameters), headers: header);
      case 1: return await http.post(Uri(scheme: "http", port: 8081, host: global.host, path: path, queryParameters: queryParameters), headers: header, body: encode);
      case 2: return await http.put(Uri(scheme: "http", port: 8081, host: global.host, path: path, queryParameters: queryParameters), headers: header, body: encode);
      case 3: return await http.delete(Uri(scheme: "http", port: 8081, host: global.host, path: path, queryParameters: queryParameters), headers: header, body: encode);
      default: throw Exception("HTTPS Request method does not exist");
    }
  }

}

