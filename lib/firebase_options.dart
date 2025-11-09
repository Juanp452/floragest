import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform, kIsWeb;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    // Solución para compatibilidad: verifica si es web antes del switch
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for ios.');
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.fuchsia:
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  // --- Web Configuration (floragest-2025) ---
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyCd1xSKZADzKCy4uX1CHtQNKHTZ2doiwh0",
    appId: "1:716321499233:web:94be13f6501a571cba6220",
    messagingSenderId: "716321499233",
    projectId: "floragest-2025",
    authDomain: "floragest-2025.firebaseapp.com",
    storageBucket: "floragest-2025.firebasestorage.app",
    measurementId: "G-FCHD8YC7DC",
  );

  // --- Android Configuration (floragest-2025) ---
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyCd1xSKZADzKCy4uX1CHtQNKHTZ2doiwh0",
    appId: "1:716321499233:android:913790d1271717dba6220",
    messagingSenderId: "716321499233",
    projectId: "floragest-2025",
    storageBucket: "floragest-2025.firebasestorage.app",
  );
}
