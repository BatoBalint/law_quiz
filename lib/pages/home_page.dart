import 'package:flutter/material.dart';
import 'package:law_quiz/auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            StreamBuilder(
              stream: Auth().getUserChanges,
              builder: (context, snapshot) {
                return Text(
                  Auth().getCurrentUser?.displayName ?? "No display name",
                );
              },
            ),
            const Text("HomePage"),
            ElevatedButton(
              onPressed: () => Auth().signOut(),
              child: const Text("Kijelentkezés"),
            ),
          ],
        ),
      ),
    );
  }
}
