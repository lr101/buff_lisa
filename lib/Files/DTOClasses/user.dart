import 'dart:typed_data';

import 'package:buff_lisa/Files/AbstractClasses/async_type.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:buff_lisa/Files/ServerCalls/fetch_users.dart';

class User {

  final String username;

  late final AsyncType<Uint8List> profileImage;

  User({required this.username, Uint8List? profileImage}) {
    this.profileImage = AsyncType<Uint8List>(value: profileImage, callback: () => FetchUsers.fetchProfilePictureSmall(username), builder: (_) => Image.memory(_), callbackDefault: _defaultProfileImage, retry: false);
  }

  Future<Uint8List> _defaultProfileImage () async => (await rootBundle.load('images/profile.jpg')).buffer.asUint8List();
}