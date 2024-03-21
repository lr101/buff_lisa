import 'package:buff_lisa/Files/AbstractClasses/async_type.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mutex/mutex.dart';

import '../Other/global.dart' as global;

class User {

  final String username;

  late final AsyncType<Uint8List> profileImageSmall;
  late final AsyncType<Uint8List> profileImage;

  List<Pin>? pins;

  ReadWriteMutex m = ReadWriteMutex();

  User({required this.username, Uint8List? profileImage}) {
    this.profileImage = AsyncType<Uint8List>(value: profileImage, callback: () => FetchUsers.fetchProfilePicture(username), builder: (_) => Image.memory(_), callbackDefault: _defaultProfileImage, retry: false);
    profileImageSmall = AsyncType<Uint8List>(value: profileImage, callback: () => FetchUsers.fetchProfilePictureSmall(username), builder: (_) => Image.memory(_), callbackDefault: _defaultProfileImage, retry: false);
  }

  Future<Uint8List> _defaultProfileImage () async => (await rootBundle.load('images/profile.jpg')).buffer.asUint8List();

  Future<void> updatePins(List<Pin> pins) async {
    await m.protectWrite(() async {
      this.pins = pins;
      _filter(pins);
      pins.sort((a,b) => a.creationDate.compareTo(b.creationDate) * -1);
    });
  }

  /// Filters pins to not show hidden users and pins.
  void _filter(List<Pin> pins) {
    Set<Pin> removesPins = {};
    List<String> usernames = global.localData.hiddenUsers.keys();
    List<int> posts = global.localData.hiddenPosts.keys();
    List<Pin> iterator = List.from(pins);
    for (Pin pin in iterator) {
      if (posts.any((element) => element == pin.id) || usernames.any((element) => element == pin.username)) {
        pins.remove(pin);
        removesPins.add(pin);
      }
    }
  }

  Future<List<Pin>?> get getPins async {
    List<Pin>? list;
    await m.protectRead(() async {
      list =pins != null ? List.from(pins!) : null;
    });
    return list;
  }

  Future<void> removePin(int id) async {
    await m.protectRead(() async {
      if (pins != null) pins!.removeWhere((element) => element.id == id);
    });
  }

  Future<void> addPin(Pin pin) async {
    await m.protectWrite(() async {
      if (pins != null) {
        pins!.insert(0, pin);
      }
    });
  }
}