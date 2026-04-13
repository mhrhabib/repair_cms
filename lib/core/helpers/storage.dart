import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';


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
    debugPrint('🧹 [Storage] Clearing session data (token, userId, etc.)');

    // Remove session-specific data
    await storage.remove('token');
    await storage.remove('userId');
    await storage.remove('userData');
    await storage.remove('email'); // Optional: clear pre-filled email if desired

    // Reset global state variables
    isUser = false;
    userIdFromServer = null;
    isLocaleEng = false;

    debugPrint('✅ [Storage] Session cleared. Biometrics and Printer settings preserved.');
  }
}

Future<void> clearLocalStorage() async {
  await LocalSettings.clearAll();
}
