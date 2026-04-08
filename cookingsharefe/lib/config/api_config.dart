import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }

    if (Platform.isAndroid) {
      if (Platform.isAndroid && !kIsWeb) {
        // Android emulator needs special IP
        return 'http://10.0.2.2:3000/api';
      }
      // Physical Android device should use your computer's IP address
      return 'http://192.168.1.x:3000/api'; // Replace with your IP
    }

    // Default to localhost for other platforms
    return 'http://localhost:3000/api';
  }
}
