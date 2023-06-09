import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:law_quiz/classes/auth.dart';
import 'package:law_quiz/pages/home_page.dart';
import 'classes/firebase_options.dart';

import 'package:law_quiz/pages/login_register.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jog Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.lightBlue,
          brightness: Brightness.dark,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !Auth.onlineLogin
          ? HomePage(
              logOutAsGuest: logoutAsGuest,
            )
          : StreamBuilder(
              stream: Auth().authStateChanges,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return HomePage(
                    logOutAsGuest: loginAsGuest,
                  );
                } else {
                  return LoginRegisterPage(
                    loginAsGuest: loginAsGuest,
                  );
                }
              },
            ),
    );
  }

  logoutAsGuest() {
    setState(() {
      Auth.onlineLogin = true;
    });
  }

  loginAsGuest() {
    setState(() {
      Auth.onlineLogin = false;
    });
  }
}
