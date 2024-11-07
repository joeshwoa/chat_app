import 'package:chat_app/Features/Auth/presintation/view/screens/sign_in_page.dart';
import 'package:chat_app/Features/Home/presintation/view/screens/home_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: Colors.black,
      ),
      home: FirebaseAuth.instance.currentUser == null ? SignInPage() : HomePage(),
    );
  }
}
