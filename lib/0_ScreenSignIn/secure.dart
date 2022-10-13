
import 'dart:convert';

import 'package:crypt/crypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Files/global.dart' as global;
import '../Files/restAPI.dart';

class Secure {

  static void saveSecure(String value, String key) {
    const FlutterSecureStorage().write(key: key, value: value);
  }

  static Future<String?> readSecure(String key) async {
    return await const FlutterSecureStorage().read(key: key);
  }

  static void removeSecure(String key) {
    const FlutterSecureStorage().delete(key: key);
  }

  static Future<bool> tryLocalLogin() async {
    const storage = FlutterSecureStorage();
    String? storedUsername = await storage.read(key: "username");
    String? storedToken = await storage.read(key: "auth");
    if (storedUsername != null && storedToken != null) {
      global.username = storedUsername;
      global.token = storedToken;
      print(global.username);
      print(global.token);
      return true;
    }
    return false;
  }

  static String encryptPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  static Future<bool> signupAuthentication(String username, String password, String email) async {
    String psw = Secure.encryptPassword(password);
    String? response = await RestAPI.postUsername(username, psw, email);
    if (response != null) {
      Secure.saveSecure(response, "auth");
      Secure.saveSecure(username, "username");
      global.token = response;
      global.username = username;
      return true;
    } else {
      return false;
    }
  }

  static Future<bool> loginAuthentication(String username, String password,) async {
    String? element = await RestAPI.checkUser(username);
    String? token;
    //TODO delete first part of if, when all password are changed to new format
    if (element != null && element.isNotEmpty &&
        Crypt(element).match(password)) {
      token = await RestAPI.checkUserToken(
          username, encryptPassword(password));
    } else {
      token = await RestAPI.auth(username, encryptPassword(password));
    }
    if (token != null) {
      saveSecure(username, "username");
      saveSecure(token, "auth");
      global.token = token;
      global.username = username;
      return true;
    } else {
      return false;
    }
  }
}