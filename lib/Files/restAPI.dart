import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:buff_lisa/Files/DTOClasses/group.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter/services.dart';
import 'global.dart' as global;

class RestAPI {

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

