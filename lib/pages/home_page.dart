import 'dart:async';

import 'package:flutter/material.dart';
import 'package:law_quiz/classes/auth.dart';
import 'package:law_quiz/classes/highscore.dart';
import 'package:law_quiz/pages/leaderboard_page.dart';
import 'package:law_quiz/pages/quiz_page.dart';
import 'package:law_quiz/classes/storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.logOutAsGuest});
  final Function logOutAsGuest;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String displayName = "Vendég";
  StreamSubscription? dpName;
  HighScore hs = HighScore(score: 0, outof: 0, percentage: 0);
  List<HighScore> highscores = [];

  @override
  void initState() {
    displayName = Auth().getCurrentUser?.displayName ?? "Vendég";
    dpName = Auth().getUserChanges.listen((event) {
      setState(() {
        displayName = Auth().getCurrentUser?.displayName ?? "Vendég";
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
    if (!Auth.onlineLogin) return;

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
  void dispose() {
    cancelDPNameSub();
    super.dispose();
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
              title(),
              menuButton(
                title: "Start",
                buttonFontColor: Colors.lightBlue,
                call: openQuizPage,
              ),
              const SizedBox(height: 20),
              menuButton(
                title: "Ranglista",
                buttonFontColor: Colors.yellow,
                call: openLeaderboard,
              ),
              const SizedBox(height: 20),
              menuButton(
                title: "Kijelentkezés",
                buttonFontColor: Colors.redAccent,
                call: () {
                  if (!Auth.onlineLogin) widget.logOutAsGuest();
                  Auth().signOut();
                },
              ),
              const SizedBox(height: 20),
              personalHighscore(),
              const SizedBox(height: 20),
              leaderBoardInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget title() {
    return Padding(
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
    );
  }

  openQuizPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return QuizPage(hs: hs, setHs: setHs);
        },
      ),
    );
  }

  openLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return const LeaderboardPage();
        },
      ),
    );
  }

  Widget menuButton({
    required String title,
    required Color buttonFontColor,
    required Function call,
  }) {
    return TextButton(
      style: const ButtonStyle(
        alignment: Alignment.centerLeft,
        backgroundColor: MaterialStatePropertyAll(Colors.white10),
      ),
      onPressed: () {
        call();
      },
      child: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            title,
            style: TextStyle(fontSize: 40, color: buttonFontColor),
          ),
        ),
      ),
    );
  }

  Widget personalHighscore() {
    return Text(
      "Legjobb elért pontszám:\n${hs.score} / ${hs.outof} (${hs.percentage.toStringAsFixed(2)}%)",
      style: const TextStyle(
        fontSize: 20,
      ),
    );
  }

  Widget leaderBoardInfo() {
    return Text(
      Auth.onlineLogin
          ? "A ranglistára kerüléshez legalább 20 kérdésre kell válaszolni."
          : "Vendégként nem lesz elmentve a pontszámod valamint a ranglistára sem kerülsz fel.",
      style: const TextStyle(
        fontSize: 20,
        color: Colors.grey,
      ),
    );
  }
}
