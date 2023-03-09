import 'package:buff_lisa/Files/AbstractClasses/async_type.dart';
import 'package:buff_lisa/Files/DTOClasses/pin.dart';
import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class User {

  final String username;

  late final AsyncType<Uint8List> profileImageSmall;
  late final AsyncType<Uint8List> profileImage;

  List<Pin>? pins;

  User({required this.username, Uint8List? profileImage}) {
    this.profileImage = AsyncType<Uint8List>(value: profileImage, callback: () => FetchUsers.fetchProfilePicture(username), builder: (_) => Image.memory(_), callbackDefault: _defaultProfileImage, retry: false);
    profileImageSmall = AsyncType<Uint8List>(value: profileImage, callback: () => FetchUsers.fetchProfilePictureSmall(username), builder: (_) => Image.memory(_), callbackDefault: _defaultProfileImage, retry: false);
  }

  Future<Uint8List> _defaultProfileImage () async => (await rootBundle.load('images/profile.jpg')).buffer.asUint8List();

  void updatePins(List<Pin> pins) {
    this.pins = pins;
  }

  List<Pin>? get getPins => pins != null ? List.from(pins!) : null;
}