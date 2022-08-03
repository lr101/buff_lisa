import 'dart:convert';
import 'dart:io';
import 'package:buff_lisa/Files/myMarkers.dart';
import 'package:buff_lisa/Files/pin.dart';
import 'package:path_provider/path_provider.dart';

class IO {

  File? _fileNew;
  File? _fileCreated;
  File? _fileFound;
  static const _fileNameNew = 'pin_new.txt';
  static const _fileNameCreated = 'pin_created.txt';
  static const _fileNameFound = 'pin_Found.txt';
  final MyMarkers markers = MyMarkers();



  // Get the data file
  Future<File> get fileNew async {
    if (_fileNew != null) return _fileNew!;

    _fileNew = await _initFile(_fileNameNew);
    return _fileNew!;
  }

  // Inititalize file
  Future<File> _initFile(String name) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    return File('$path/$name').create(recursive: true);
  }

  Future<void> addNewCreatedPinOffline(Mona mona) async {
    final File fl = await fileNew;
    markers.addUserPinsNewCreated(mona);
    List<Map<String, dynamic>> l = [];
    for (Mona mona in markers.userNewCreatedPins) {
      l.add(await mona.toJson());
    }
    await fl.writeAsString(const JsonEncoder().convert(l));
  }

  Future<void> readNewCreatedPinOffline() async {
    final File fl = await fileNew;
    final content = await fl.readAsString();
    try {
      final List<dynamic> jsonData = await jsonDecode(content);
      Set<Mona> monas = {};
      for (Map<String, dynamic> data in jsonData) {
        monas.add(Mona.fromJson(data));
      }
      markers.setUserPinsNewCreated(monas);
    }catch (e) {
      print(e);
    }
  }
  Future<void> deletePinOffline(Mona mona) async {
    final File fl = await fileNew;
    markers.userNewCreatedPins.removeWhere((e) => e == mona);
    List<Map<String, dynamic>> l = [];
    for (Mona mona in markers.userNewCreatedPins) {
      l.add(await mona.toJson());
    }
    await fl.writeAsString(const JsonEncoder().convert(l));
    markers.removeUserPinsNewCreated(mona);
  }


  /*
  Future<File> get fileFound async {
    if (_fileFound != null) return _fileFound!;

    _fileFound = await _initFile(_fileNameFound);
    return _fileFound!;
  }

  Future<File> get fileCreated async {
    if (_fileCreated != null) return _fileCreated!;

    _fileCreated = await _initFile(_fileNameCreated);
    return _fileCreated!;
  }

  Future<void> addCreatedPin(Pin pin) async {
    final File fl = await fileCreated;
    markers.userPinsCreated.add(pin);
    final userListMap = markers.userPinsCreated.map((e) => e.toJson()).toList();
    await fl.writeAsString(jsonEncode(userListMap));
  }

  Future<void> readCreatedPin() async {
    final File fl = await fileCreated;
    final content = await fl.readAsString();
    final List<dynamic> jsonData = jsonDecode(content);
    final List<Pin> pin = jsonData.map(
            (e) => Pin.fromJson(e as Map<String, dynamic>)).toList();
    markers.userPinsCreated = pin.toSet();
  }

  Future<void> addFoundOffline(Pin pin) async {
    final File fl = await fileFound;
    markers.userPinsFound.add(pin);
    final userListMap = markers.userPinsFound.map((e) => e.toJson()).toList();
    await fl.writeAsString(jsonEncode(userListMap));
  }

  Future<void> readFoundPin() async {
    final File fl = await fileFound;
    final content = await fl.readAsString();
    final List<dynamic> jsonData = jsonDecode(content);
    final List<Pin> pin = jsonData.map(
            (e) => Pin.fromJson(e as Map<String, dynamic>)).toList();
    markers.userPinsFound = pin.toSet();
  }*/

}

class _SecItem {
  _SecItem(this.key, this.value);

  final String key;
  final String value;
}