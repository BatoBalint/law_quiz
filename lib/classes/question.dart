import 'dart:math';

import 'package:law_quiz/classes/answer.dart';

class Question {
  String question = "";
  String right;
  List<Answer> answers = [];
  int index;

  Question(String qna, {required this.right, this.index = -1}) {
    List<String> deli = [";a)", ";b)", ";c)", ";d)"];
    for (String d in deli) {
      qna = qna.replaceAll(d, ";");
    }
    List<String> data = qna.trim().split(";");
    question = data[0];

    for (var i = 1; i < data.length; i++) {
      answers.add(Answer(text: data[i], right: i == right.codeUnitAt(0) - 96));
    }

    Random r = Random();
    for (int i = 0; i < 5; ++i) {
      answers.sort((a, b) => 1 - r.nextInt(3));
    }
  }

  bool check(int v) {
    int c = 0;
    while (!answers[c].right) {
      c++;
    }
    return c == v;
  }

  Answer getRightAnswer() {
    return answers[getRightIndex()];
  }

  int getRightIndex() {
    int c = 0;
    while (!answers[c].right) {
      c++;
    }
    return c;
  }
}
