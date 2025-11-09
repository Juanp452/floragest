import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Importaciones de pantallas
import 'package:floragest/screens/base_screen.dart';
import 'package:floragest/screens/login_screen.dart';
import 'package:floragest/screens/register_screen.dart';
import 'package:floragest/screens/cart_screen.dart';
import 'package:floragest/screens/ai_feature_screen.dart';
import 'package:floragest/screens/support_screen.dart';

import 'package:floragest/models/user_profile.dart';
import 'package:floragest/services/firestore_service.dart';
import 'firebase_options.dart';

// --- CONFIGURACION GLOBAL ---
const geminiApiKey = "";
const geminiApiUrl =
    "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$geminiApiKey";
final FirestoreService firestoreService = FirestoreService();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Error CRÍTICO al inicializar Firebase: $e');
  }

  runApp(const FloragestApp());
}

class FloragestApp extends StatelessWidget {
  const FloragestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floragest E-Commerce',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/home': (context) => BaseScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/cart': (context) => CartScreen(),
        '/ai_chat': (context) => const AiFeatureScreen(),
        '/support': (context) => const SupportScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return BaseScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
