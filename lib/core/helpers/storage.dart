import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';

final storage = GetStorage();
bool isUser = false;
bool isLocaleEng = false;
int? userIdFromServer;

class LocalSettings {
  Future initialize() async {
    if (kDebugMode) {
      print(
        'init token ckeck'
        "${storage.read('token')}",
      );
    }
    if (storage.read('token') != null) {
      isUser = true;
      debugPrint(">>>>>>>>>>checking $isUser");
      userIdFromServer = storage.read('userId');
    } else {
      isUser = false;
      userIdFromServer = null;
    }

    storage.read('local') != null && storage.read('local') == 1 ? isLocaleEng = true : isLocaleEng = false;
  }
}
