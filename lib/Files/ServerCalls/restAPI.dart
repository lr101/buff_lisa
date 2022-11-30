import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

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
  static Future<HttpClientResponse> createHttpsRequest (String path, Map<String,dynamic> queryParameters, int requestType, String? encode) async {
    SecurityContext context = SecurityContext(withTrustedRoots: true);
    context.setTrustedCertificatesBytes(utf8.encode(await rootBundle.loadString('images/cert.pem')), password: "password");
    HttpClient client = HttpClient(context: context) ..badCertificateCallback = ((X509Certificate cert, String host, int port) => true);
    Uri url = Uri(scheme: "https", host: global.host, port: global.port, path: path, queryParameters: queryParameters);
    HttpClientRequest request;
    stderr.writeln(url);
    switch (requestType) {
      case 0: request = await client.getUrl(url);break;
      case 1: request = await client.postUrl(url);break;
      case 2: request = await client.putUrl(url);break;
      case 3: request = await client.deleteUrl(url);break;
      default: throw Exception("HTTPS Request method does not exist");
    }
    request.headers.add("Authorization", "Bearer ${global.token}");
    if (encode != null) {
      request.headers.contentType =  ContentType('application', 'json', charset: 'utf-8');
      request.write(encode);
    }
    print(request.uri.path);
    return await request.close();
  }

}

