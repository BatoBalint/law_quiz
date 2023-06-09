import 'dart:async';

import 'package:flutter/material.dart';
import 'package:law_quiz/auth.dart';
import 'package:law_quiz/highscore.dart';
import 'package:law_quiz/pages/leaderboard_page.dart';
import 'package:law_quiz/pages/quiz_page.dart';
import 'package:law_quiz/storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String displayName = "";
  StreamSubscription? dpName;
  HighScore hs = HighScore(score: 0, outof: 0, percentage: 0);
  List<HighScore> highscores = [];

  @override
  void initState() {
    displayName = Auth().getCurrentUser?.displayName ?? "";
    dpName = Auth().getUserChanges.listen((event) {
      setState(() {
        displayName = Auth().getCurrentUser?.displayName ?? "No displayname";
      });
    });
    if (Auth().getCurrentUser != null &&
        Auth().getCurrentUser?.displayName != null) {
      cancelDPNameSub();
    }

    loadHighscore();

    loadLeaderboardHighscores();

    super.initState();
  }

  Future<void> loadHighscore() async {
    hs = await Storage().getUsersHighscore();
    setHs(hs);
  }

  Future<void> loadLeaderboardHighscores() async {
    highscores = await Storage().getAllHighscore();
  }

  void setHs(HighScore newHs) {
    setState(() {
      hs = newHs;
    });
    loadLeaderboardHighscores();
  }

  Future<void> cancelDPNameSub() async {
    await dpName?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Container(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hello $displayName",
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
              TextButton(
                style: const ButtonStyle(
                    alignment: Alignment.centerLeft,
                    backgroundColor: MaterialStatePropertyAll(Colors.white10)),
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (context) {
                    return QuizPage(hs: hs, setHs: setHs);
                  }));
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Start",
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                style: const ButtonStyle(
                    alignment: Alignment.centerLeft,
                    backgroundColor: MaterialStatePropertyAll(Colors.white10)),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) {
                        return LeaderboardPage(
                          highscores: highscores,
                        );
                      },
                    ),
                  );
                },
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Ranglista",
                      style: TextStyle(fontSize: 40, color: Colors.yellow),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextButton(
                style: const ButtonStyle(
                    alignment: Alignment.centerLeft,
                    backgroundColor: MaterialStatePropertyAll(Colors.white10)),
                onPressed: () => Auth().signOut(),
                child: const SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "Kijelentkezés",
                      style: TextStyle(fontSize: 40, color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "Legjobb elért pontszám:\n${hs.score} / ${hs.outof} (${hs.percentage.toStringAsFixed(2)})",
                style: const TextStyle(
                  fontSize: 20,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "A ranglistára kerüléshez legalább 20 kérdésre kell válaszolni.",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
