import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/chat_screen.dart';
import 'services/api_service.dart';
import 'screens/welcome.dart';
import 'screens/signup.dart';
import 'screens/login.dart';
import 'screens/home.dart';
import 'screens/about.dart';
import 'screens/user.dart';
import 'screens/diatrack.dart';
import 'screens/health.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.containsKey('jwt_token');
  runApp(DiabetesApp(isLoggedIn: isLoggedIn));
}

class DiabetesApp extends StatelessWidget {
  final bool isLoggedIn;
  const DiabetesApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => ApiService(),
      child: MaterialApp(
        title: 'DiabetIQ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1565C0),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Roboto',
        ),
        home: isLoggedIn ? const HomeScreen() : const WelcomeScreen(),
        routes: {
          '/welcome': (context) => const WelcomeScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/about': (context) => const AboutScreen(),
          '/user': (context) => const UserScreen(),
          '/diachat': (context) => const ChatScreen(),
          '/diatrack': (context) => const DiaTrackScreen(),
          '/health': (context) => const HealthPage(),
        },
      ),
    );
  }
}
