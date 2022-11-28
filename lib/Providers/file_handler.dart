import 'dart:convert';
import 'dart:io';

import 'package:buff_lisa/Files/DTOClasses/pin.dart';
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
  Future<void> saveList(List<Pin> list) async {
    final File fl = await getFile();
    List<Map<String, dynamic>> l = [];
    for (Pin item in list) {
      l.add(await item.toJsonOffline());
    }
    await fl.writeAsString(const JsonEncoder().convert(l));
  }

  /// reads a list of pins form device storage
  /// pins can only be created if a [Group] matches to the groupId saved on device
  Future<List<Pin>> readFile(List<Group> groups) async {
    final File fl = await getFile();
    final content = await fl.readAsString();
    if (content.isNotEmpty) {
      final List<dynamic> jsonData = await jsonDecode(content);
      List<Pin> list = [];
      for (Map<String, dynamic> data in jsonData) {
        Group group = groups.firstWhere((element) => element.groupId == data['groupId']);
        list.add(Pin.fromJsonOffline(data, group));
      }
      return list;
    }
    return [];
  }
}

