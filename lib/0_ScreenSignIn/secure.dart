
import 'package:crypt/crypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Files/global.dart' as global;
import '../Files/restAPI.dart';

class Secure {


  static String setPassword(String password) {
    String hashedPassword = Crypt.sha256(password).toString();
    return hashedPassword;
  }

  static void setUsername(String username, FlutterSecureStorage storage) {
    global.username = username;
    storage.write(key: "username", value: username);
  }

  static void removeUsername(FlutterSecureStorage storage) {
    global.username = "";
    storage.delete(key: "username");
  }

  static Future<bool> tryLocalLogin(FlutterSecureStorage storage) async {
    String? storedUsername = await storage.read(key: "username");
    if (storedUsername != null) {
      global.username = storedUsername;
      return true;
    }
    return false;
  }

  static Future<bool> checkPasswordOnline(String username, String password, FlutterSecureStorage storage) async {
    return RestAPI.checkUser(null).then((String? element) {
      if (element == null || element.isEmpty || !Crypt(element).match(password)) {
        return false;
      }
      setUsername(username, storage);
      return true;
    });

  }
}