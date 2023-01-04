import 'dart:convert';
import 'dart:io';

import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../Files/DTOClasses/group.dart';

class FileHandler {

  /// File on device
  File? _file;

  /// name of file in file path
  final String fileName;

  /// Constructor
  /// sets [fileName]
  FileHandler({required this.fileName});

  /// returns the file from device storage or creates a new one
  Future<File> getFile() async {
    if (_file != null) return _file!;
    _file = await _initFile(fileName);
    return _file!;
  }

  /// creates a new file with [name] as file name
  Future<File> _initFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$name').create(recursive: true);
  }

  /// saves a list of pins to device storage by converting the pins into a json format
  Future<void> savePinList(List<Pin> list) async {
    if (kDebugMode) print("START: saving complete pins list, length: ${list.length}");
    final File fl = await getFile();
    List<Map<String, dynamic>> l = [];
    for (Pin item in list) {
      l.add(await item.toJsonOffline());
    }
    await fl.writeAsString(const JsonEncoder().convert(l));

    if (kDebugMode) print("END: saving complete pins list: ${const JsonEncoder().convert(l)}");
  }

  Future<void> removePin(int id, List<Group> groups) async{
    List<Pin> pins = await readPins(groups);
    pins.removeWhere((element) => element.id == id);
    await savePinList(pins);
  }

  Future<void> addPin(Pin pin, List<Group> groups) async{
    List<Pin> pins = await readPins(groups);
    pins.add(pin);
    await savePinList(pins);
  }

  /// reads a list of pins form device storage
  /// pins can only be created if a [Group] matches to the groupId saved on device
  Future<List<Pin>> readPins(List<Group> groups) async {
    if (kDebugMode) print("START: reading complete pins list");
    final File fl = await getFile();
    final content = await fl.readAsString();
    if (content.isNotEmpty) {
      List<dynamic> jsonData;
      try {
        jsonData  = await jsonDecode(content);
      } catch (e) {
        print(e);
        jsonData = [];
      }
      List<Pin> list = [];
      for (Map<String, dynamic> data in jsonData) {
        Group group = groups.firstWhere((element) => element.groupId == data['groupId'], orElse: () => Group(groupId: data['groupId'], name: "default", visibility: 0, inviteUrl: null));
        list.add(Pin.fromJsonOffline(data, group));
      }
      if (kDebugMode) print("END: reading complete pins list, length: ${list.length}");
      return list;
    }
    if (kDebugMode) print("END: reading complete pins list, length: 0");
    return [];
  }
}

