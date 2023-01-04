import 'dart:convert';
import 'dart:io';

import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../Files/DTOClasses/group.dart';

class FileHandlerGroup {

  /// File on device
  File? _file;

  /// name of file in file path
  final String fileName;

  /// Constructor
  /// sets [fileName]
  FileHandlerGroup({required this.fileName});

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

  Future<void> saveGroupList(List<Group> list) async {
    if (kDebugMode) print("START: saving complete group list, length: ${list.length}");
    final File fl = await getFile();
    List<Map<String, dynamic>> l = [];
    for (Group item in list) {
      l.add(await item.toJsonOffline());
    }
    await fl.writeAsString(const JsonEncoder().convert(l));
    if (kDebugMode) print("END: saving complete group list");
  }

  Future<List<Group>> readGroups() async {
    if (kDebugMode) print("START: reading complete group list");
    final File fl = await getFile();
    final content = await fl.readAsString();
    if (content.isNotEmpty) {
      final List<dynamic> jsonData = await jsonDecode(content);
      List<Group> list = [];
      for (Map<String, dynamic> data in jsonData) {
        list.add(Group.fromJsonOffline(data));
      }
      if (kDebugMode) print("END: reading complete group list, length: ${list.length}");
      return list;
    }
    if (kDebugMode) print("END: reading complete group list, length: 0");
    return [];
  }
}

