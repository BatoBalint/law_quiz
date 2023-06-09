import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'package:law_quiz/question.dart';
import 'package:law_quiz/quiz.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

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
  double percentage = 0;

  @override
  void initState() {
    createQuestion();
    activeQuiz = Quiz(q: activeQuestion, nextQuiz: nextQuestion);
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
      qs.add(Question(questionLines[i], right: answers[i]));
    }
    setState(() {
      questions = qs;
      selectNextQuestion();
      activeQuiz = Quiz(q: activeQuestion, nextQuiz: nextQuestion);
    });
  }

  void nextQuestion(bool rightAnswer) {
    if (rightAnswer) {
      rightQuestions.add(activeQuestion);
    } else {
      wrongQuestions.add(activeQuestion);
    }
    setState(() {
      if (rightAnswer) rightAnswerCount++;
      questionCount++;
    });
    questions.remove(activeQuestion);
    selectNextQuestion();
  }

  void selectNextQuestion() {
    setState(() {
      activeQuestion = questions[Random().nextInt(questions.length)];
      activeQuiz = Quiz(q: activeQuestion, nextQuiz: nextQuestion);
    });
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
              child: Text(
                "$rightAnswerCount / $questionCount (${(questionCount == 0) ? "N/A" : "${(rightAnswerCount * 100 / questionCount).toStringAsFixed(2)}%"})",
                style: const TextStyle(
                  fontSize: 16,
                ),
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
}
