import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';
import 'package:repair_cms/core/services/biometric_storage_service.dart';

final storage = GetStorage();
bool isUser = false;
bool isLocaleEng = false;
int? userIdFromServer;

class LocalSettings {
  Future initialize() async {
    debugPrint(
      'init token ckeck'
      "${storage.read('token')}",
    );
    if (storage.read('token') != null) {
      isUser = true;
      debugPrint(">>>>>>>>>>checking $isUser");
      userIdFromServer = storage.read('userId');
    } else {
      isUser = false;
      userIdFromServer = null;
    }

    storage.read('local') != null && storage.read('local') == 1
        ? isLocaleEng = true
        : isLocaleEng = false;
  }

  static Future<void> clearAll() async {
    // Erase all GetStorage data (including printer settings, tokens, etc.)
    await storage.erase();

    // Clear secure biometric data if any
    await BiometricStorageService.clearBiometricData();

    // Reset global state variables
    isUser = false;
    userIdFromServer = null;
    isLocaleEng = false;

    debugPrint('🧹 [Storage] All local storage and printer settings cleared');
  }
}

Future<void> clearLocalStorage() async {
  await LocalSettings.clearAll();
}
