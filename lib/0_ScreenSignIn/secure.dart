
import 'dart:convert';

import 'package:crypt/crypt.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Files/ServerCalls/fetch_users.dart';
import '../Files/Other/global.dart' as global;

class Secure {

  /// save a given value via a given key with the secure flutter storage package
  static void saveSecure(String value, String key) {
    const FlutterSecureStorage().write(key: key, value: value);
  }

  /// read a value via a given key from secure storage
  static Future<String?> readSecure(String key) async {
    return await const FlutterSecureStorage().read(key: key);
  }

  /// remove a value via a given key from secure storage
  static void removeSecure(String key) {
    const FlutterSecureStorage().delete(key: key);
  }

  /// loading username and token to check if user is already logged in on this device
  /// -> if logged in then the username and token are saved in global file and true is returned
  static Future<bool> tryLocalLogin() async {
    const storage = FlutterSecureStorage();
    String? storedUsername = await storage.read(key: "username");
    String? storedToken = await storage.read(key: "auth");
    if (storedUsername != null && storedToken != null) {
      global.username = storedUsername;
      global.token = storedToken;
      return true;
    }
    return false;
  }

  /// encrypt a given string with the sh256 encryption package
  static String encryptPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  /// signup with a given username, password and email
  /// saves on successful account creation the username and token in secure storage and returns true
  static Future<bool> signupAuthentication(String username, String password, String email) async {
    String psw = Secure.encryptPassword(password);
    String? response = await FetchUsers.signupNewUser(username, psw, email);
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

  /// signin process sends encoded password to server and obtains a JWT token on success
  /// saves after successful login username and token in secure storage and returns true
  static Future<bool> loginAuthentication(String username, String password,) async {
    String? element = await FetchUsers.checkUser(username);
    String? token;
    //TODO delete first part of if, when all password are changed to new format
    if (element != null && element.isNotEmpty &&
        Crypt(element).match(password)) {
      token = await FetchUsers.checkUserToken(
          username, encryptPassword(password));
    } else {
      token = await FetchUsers.auth(username, encryptPassword(password));
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