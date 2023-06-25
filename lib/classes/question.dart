import 'dart:math';

class Question {
  String question = "";
  int rightIndex = 0;
  String right;
  List<String> answers = [];
  int index;

  Question(String qna, {required this.right, this.index = -1}) {
    List<String> deli = [";a)", ";b)", ";c)", ";d)"];
    for (String d in deli) {
      qna = qna.replaceAll(d, ";");
    }
    List<String> data = qna.trim().split(";");
    question = data[0];

    Random r = Random();
    List availableIndexes =
        List.generate(data.length - 1, (index) => index + 1);
    int c = 0;
    while (availableIndexes.isNotEmpty) {
      int rnd = r.nextInt(availableIndexes.length);
      if (right.codeUnitAt(0) - 96 == availableIndexes[rnd]) {
        rightIndex = c;
      }
      answers.add(data[availableIndexes[rnd]].trim());
      availableIndexes.removeAt(rnd);
      c++;
    }
  }

  bool check(String v) {
    return v == answers[rightIndex];
  }

  int getRightIndex() {
    return rightIndex;
  }
}
