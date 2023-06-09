import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:law_quiz/auth.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool isLogin = false;
  String errorMessage = "";

  Future<void> loginRegister() async {
    if ((_name.text.isEmpty && !isLogin) ||
        _password.text.isEmpty ||
        _email.text.isEmpty) {
      setState(() {
        errorMessage = "Mindegyik mezőt ki kell tölteni.";
      });
      return;
    }

    setState(() {
      errorMessage = "";
    });

    if (isLogin) {
      try {
        await Auth()
            .signInWitEamil(email: _email.text, password: _password.text);
      } on FirebaseAuthException catch (ex) {
        setState(() {
          errorMessage = ex.message ?? "";
        });
      }
    } else {
      try {
        await Auth().createUser(
          email: _email.text,
          password: _password.text,
          displayName: _name.text,
        );
      } on FirebaseAuthException catch (ex) {
        setState(() {
          errorMessage = ex.message ?? "";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 200,
          ),
          Text(
            isLogin ? "Bejelentkezés" : "Regisztráció",
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
          ),
          const SizedBox(
            height: 20,
          ),
          !isLogin
              ? TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    hintText: "Becenév",
                    border: OutlineInputBorder(),
                  ),
                )
              : Container(),
          SizedBox(
            height: !isLogin ? 10 : 0,
          ),
          TextField(
            controller: _email,
            decoration: const InputDecoration(
              hintText: "Email",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(
              hintText: "Jelszó",
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(
            height: 6,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: "Inkább ",
                    ),
                    TextSpan(
                      text: isLogin ? "regisztálok" : "bejelentkezem",
                      style: const TextStyle(
                        color: Colors.blue,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                    ),
                    const TextSpan(text: "."),
                  ],
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: loginRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: isLogin ? Colors.lightBlue : Colors.green,
                padding: const EdgeInsets.all(20),
                foregroundColor: Colors.white,
              ),
              child: Text(
                isLogin ? "Bejelentkezés" : "Regisztrálás",
                style: const TextStyle(
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          !isLogin
              ? const Text(
                  "Az emailnek nem kell léteznie, csak a pontok miatt kell megkülönböztetésnek.",
                  style: TextStyle(
                    color: Colors.grey,
                    letterSpacing: 1,
                  ),
                )
              : Container(),
          const SizedBox(
            height: 10,
          ),
          Container(
            alignment: Alignment.centerLeft,
            child: Text(
              errorMessage,
              style: const TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
