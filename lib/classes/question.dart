class Question {
  String question = "";
  String right = "";
  List<String> answers = [];

  Question(String qna, {required this.right}) {
    List<String> deli = [";a)", ";b)", ";c)", ";d)"];
    for (String d in deli) {
      qna = qna.replaceAll(d, ";");
    }
    List<String> data = qna.trim().split(";");
    question = data[0];
    for (var i = 1; i < data.length; i++) {
      answers.add(data[i].trim());
    }
  }

  bool check(int v) {
    if (v + 97 == right.codeUnitAt(0)) {
      return true;
    }
    return false;
  }

  int rightIndex() {
    return right.codeUnitAt(0) - 97;
  }
}
