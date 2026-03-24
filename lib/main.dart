import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBDXtYyyHTJrVNhGed7ozTI74m02U6mHfg",
      authDomain: "shop-pos-system-b0eca.firebaseapp.com",
      projectId: "shop-pos-system-b0eca",
      storageBucket: "shop-pos-system-b0eca.firebasestorage.app",
      messagingSenderId: "469153202670",
      appId: "1:469153202670:web:6b4429e116fbe1ec590eff",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
