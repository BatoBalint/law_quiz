import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:law_quiz/classes/auth.dart';

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key, required this.loginAsGuest});
  final Function loginAsGuest;
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
    if ((_name.text.trim().isEmpty && !isLogin) ||
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
        await Auth().signInWitEamil(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );
      } on FirebaseAuthException catch (ex) {
        setState(() {
          errorMessage = ex.message ?? "";
        });
      }
    } else {
      try {
        await Auth().createUser(
          email: _email.text.trim(),
          password: _password.text.trim(),
          displayName: _name.text.trim(),
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
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 150),
        title(),
        const SizedBox(height: 20),
        if (!isLogin) displayNameInput(),
        if (!isLogin) const SizedBox(height: 10),
        emailInput(),
        const SizedBox(height: 10),
        passwordInput(),
        const SizedBox(height: 10),
        loginRegSwitcher(),
        const SizedBox(height: 20),
        loginRegButtons(),
        const SizedBox(height: 20),
        emailNotRequiredMessage(),
        const SizedBox(height: 10),
        errorMessageText(),
      ],
    );
  }

  Widget title() {
    return Text(
      isLogin ? "Bejelentkezés" : "Regisztráció",
      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
    );
  }

  Widget displayNameInput() {
    return TextField(
      controller: _name,
      decoration: const InputDecoration(
        hintText: "Becenév",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget emailInput() {
    return TextField(
      controller: _email,
      decoration: const InputDecoration(
        hintText: "Email",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget passwordInput() {
    return TextField(
      controller: _password,
      decoration: const InputDecoration(
        hintText: "Jelszó",
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget loginRegSwitcher() {
    return Container(
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
    );
  }

  Widget loginRegButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ElevatedButton(
          onPressed: () => widget.loginAsGuest(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            padding: const EdgeInsets.all(20),
            foregroundColor: Colors.white,
          ),
          child: const Text(
            "Vendég felhasználó",
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (isLogin) {
              Auth().signInWitEamil(
                email: _email.text,
                password: _password.text,
              );
            } else {
              Auth().createUser(
                email: _email.text,
                password: _password.text,
                displayName: _name.text,
              );
            }
          },
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
      ],
    );
  }

  Widget emailNotRequiredMessage() {
    return !isLogin
        ? const Text(
            "Az emailnek nem kell léteznie, csak a pontok miatt kell megkülönböztetésnek.",
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 1,
            ),
          )
        : Container();
  }

  Widget errorMessageText() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        errorMessage,
        style: const TextStyle(
          color: Colors.red,
        ),
      ),
    );
  }
}
