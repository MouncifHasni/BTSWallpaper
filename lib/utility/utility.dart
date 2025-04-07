// @dart=2.9

import 'dart:io';
import 'dart:math';

import 'package:bts_wallpapers/models/imagesModel.dart';
import 'package:video_player/video_player.dart';

String globaleUserID;
List<ImageModel> images= List.empty();

//Generate Random String
String generateRandomString(int length) {
  const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  return String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
}

Future<bool> checkConnection() async {
  try {
    final result = await InternetAddress.lookup('www.google.com');
    if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
      //Connection Exist
      return true;
    }
  } on SocketException catch (_) {
    return false;
  }
}