import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'auth_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyABQx3Xh_LkMJc5Te1FHyCQWjEVj9Sj_3E",
      authDomain: "friend-4132a.firebaseapp.com",
      projectId: "friend-4132a",
      storageBucket: "friend-4132a.appspot.com",
      messagingSenderId: "244537942251",
      appId: "1:244537942251:web:2122ab86d8536f5d705eae",
    ),
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Friend App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue[800],
          foregroundColor: Colors.white,
        ),
      ),
      home: AuthScreen(),
    );
  }
}
