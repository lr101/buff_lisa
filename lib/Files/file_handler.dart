import 'dart:convert';
import 'dart:io';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Providers/cluster_notifier.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'AbstractClasses/to_json.dart';
import 'DTOClasses/group.dart';
import 'DTOClasses/mona.dart';

class FileHandler {

  File? _file;
  late String fileName;

  FileHandler({required this.fileName});

  Future<File> getFile() async {
    if (_file != null) return _file!;
    _file = await _initFile(fileName);
    return _file!;
  }

  Future<File> _initFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$name').create(recursive: true);
  }

  Future<void> saveList(List<Mona> list, int groupId) async {
    final File fl = await getFile();
    List<Map<String, dynamic>> l = [];
    for (Mona item in list) {
      l.add(await item.toJson());
      l.add({'groupId' : groupId});
    }
    await fl.writeAsString(const JsonEncoder().convert(l));
  }

  Future<List<dynamic>> readFile(int type, List<Group> groups) async {
    final File fl = await getFile();
    final content = await fl.readAsString();
    if (content.isNotEmpty) {
      final List<dynamic> jsonData = await jsonDecode(content);
      List<dynamic> list = [];
      if (type == 0) {
        for (Map<String, dynamic> data in jsonData) {
          Group group = groups.firstWhere((element) => element.groupId == data['groupId']);
          list.add(Mona.fromJson2(data, group));
        }
      }
      return list;
    }
    return [];
  }
}

