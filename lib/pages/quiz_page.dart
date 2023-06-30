import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:law_quiz/classes/highscore.dart';

import 'package:law_quiz/classes/question.dart';
import 'package:law_quiz/quiz.dart';
import 'package:law_quiz/classes/storage.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.hs, required this.setHs});

  final HighScore hs;

  final Function setHs;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  List<Question> questions = [];
  List<Question> rightQuestions = [];
  List<Question> wrongQuestions = [];
  Question activeQuestion = Question("Loading...", right: "a");
  Quiz? activeQuiz;

  int questionCount = 0;
  int rightAnswerCount = 0;

  @override
  void initState() {
    createQuestion();
    activeQuiz = Quiz(
      q: activeQuestion,
      nextQuiz: nextQuestion,
      changePoints: changePoints,
    );
    super.initState();
  }

  void createQuestion() async {
    String readData;
    readData = await rootBundle.loadString("assets/jogKerdesek.txt");
    List<String> questionLines = readData.trim().split("\n");
    readData = await rootBundle.loadString("assets/jogValaszok.txt");
    List<String> answers = readData.trim().split(";");

    List<Question> qs = [];
    for (int i = 0; i < questionLines.length; i++) {
      qs.add(Question(questionLines[i], right: answers[i], index: i));
    }

    qs = qs.where(
      (Question q) {
        return q.question == "Melyik állítás igaz?" ||
            q.question == "Melyik állítás hamis?";
      },
    ).toList();

    List<String> lines = [];

    writeToFile(lines);

    setState(() {
      questions = qs;
      selectNextQuestion();
      activeQuiz = Quiz(
        q: activeQuestion,
        nextQuiz: nextQuestion,
        changePoints: changePoints,
      );
    });
  }

  void changePoints(bool rightAnswer) {
    setState(() {
      if (rightAnswer) rightAnswerCount++;
      questionCount++;
    });
  }

  void nextQuestion(bool rightAnswer) {
    if (rightAnswer) {
      rightQuestions.add(activeQuestion);
    } else {
      wrongQuestions.add(activeQuestion);
    }

    questions.remove(activeQuestion);
    selectNextQuestion();
  }

  void selectNextQuestion() {
    setState(() {
      activeQuestion = questions[Random().nextInt(questions.length)];
      activeQuiz = Quiz(
        q: activeQuestion,
        nextQuiz: nextQuestion,
        changePoints: changePoints,
      );
    });
  }

  void closeQuiz() {
    if (questionCount >= 20 &&
        rightAnswerCount * 100 / questionCount > widget.hs.percentage) {
      HighScore newhs = HighScore(
        score: rightAnswerCount,
        outof: questionCount,
        percentage: rightAnswerCount * 100 / questionCount,
      );
      Storage().writeToHighScore(map: newhs.toJSON());
      widget.setHs(newhs);
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$rightAnswerCount / $questionCount (${(questionCount == 0) ? "N/A" : "${(rightAnswerCount * 100 / questionCount).toStringAsFixed(2)}%"})",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () => closeQuiz(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 40,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: activeQuiz,
            ),
            const SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }

  Future<void> writeToFile(List<String> lines) async {
    List<Directory>? dirs = await getExternalStorageDirectories();
    dirs ??= [];
    if (dirs.isNotEmpty) {
      var dir = dirs[0];
      var file = File("${dir.path}/output.txt");

      if (!file.existsSync()) {
        await file.create();
      }

      var sink = file.openWrite();

      for (String line in lines) {
        sink.write("$line\n");
      }

      sink.close();
    }
  }
}
