import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:law_quiz/classes/answer.dart';
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
  List<Question> rightQuestions = []; // Answered correctly
  List<Question> wrongQuestions = []; // Answered incorrectly
  Question activeQuestion = Question("Loading...", right: "a");
  late Quiz activeQuiz;

  int questionCount = 0;
  int rightAnswerCount = 0;

  Stopwatch sw = Stopwatch();
  String timeAsString = "";
  late Timer t;

  @override
  void initState() {
    createQuestion();
    activeQuiz = Quiz(
      q: activeQuestion,
      nextQuiz: nextQuestion,
      changePoints: changePoints,
      closeQuiz: closeQuiz,
    );
    super.initState();
    sw.start();
    t = Timer.periodic(
      const Duration(milliseconds: 10),
      (timer) {
        setState(() {
          timeAsString = formatDuration(sw.elapsed);
        });
      },
    );
  }

  void createQuestion() async {
    List<String> questionLines = [];
    List<String> answers = [];

    // Load all the questions
    await readDataFromFiles(questionLines, answers);
    List<Question> qs = convertToQuestions(questionLines, answers);

    // Get special questions
    List<int> blockedIndexes = [116]; // Manually checked question index
    List<Question> whichIsRight = qs
        .where((q) =>
            q.question == "Melyik állítás igaz?" &&
            !blockedIndexes.contains(q.index))
        .toList();
    List<Question> whichIsWrong = qs
        .where((q) =>
            q.question == "Melyik állítás hamis?" &&
            !blockedIndexes.contains(q.index))
        .toList();

    // Remove special questions from the main list
    for (Question q in whichIsWrong) {
      qs.remove(q);
    }
    for (Question q in whichIsRight) {
      qs.remove(q);
    }

    // Collect the true and false statements
    List<Answer> trueAnswers = [];
    List<Answer> falseAnswers = [];
    collectTrureFalseAnswers(
      whichIsRight,
      whichIsWrong,
      trueAnswers,
      falseAnswers,
    );

    List<Question> finalQuestions =
        generateTrueFalseQuestions(trueAnswers, falseAnswers);
    Question temp;
    for (int i = 0; i < 15; ++i) {
      temp = qs[Random().nextInt(qs.length)];
      qs.remove(temp);
      finalQuestions.add(temp);
    }

    // Debug
    // List<String> lines = [];
    // addToLines(lines, trueAnswers, falseAnswers);
    // writeToFile(lines);

    setState(() {
      questions = finalQuestions;
      selectNextQuestion();
      activeQuiz = Quiz(
        q: activeQuestion,
        nextQuiz: nextQuestion,
        changePoints: changePoints,
        closeQuiz: closeQuiz,
      );
    });
  }

  Future<void> readDataFromFiles(
    List<String> questionLines,
    List<String> answers,
  ) async {
    String readData;
    readData = await rootBundle.loadString("assets/jogKerdesek.txt");
    List<String> splitted = readData.trim().split("\n");
    for (String line in splitted) {
      questionLines.add(line);
    }
    readData = await rootBundle.loadString("assets/jogValaszok.txt");
    splitted = readData.trim().split(";");
    for (String line in splitted) {
      answers.add(line);
    }
  }

  List<Question> convertToQuestions(
    List<String> questionLines,
    List<String> answers,
  ) {
    List<Question> qs = [];
    for (int i = 0; i < questionLines.length; i++) {
      qs.add(Question(questionLines[i], right: answers[i], index: i));
    }
    return qs;
  }

  void collectTrureFalseAnswers(
    List<Question> whichIsRight,
    List<Question> whichIsWrong,
    List<Answer> trueAnswers,
    List<Answer> falseAnswers,
  ) {
    for (Question q in whichIsRight) {
      if (q.getRightAnswer().text.contains("hamis") ||
          q.getRightAnswer().text.contains("sem igaz")) {
        for (Answer a in q.answers) {
          if (!a.right) {
            if (!a.text.toLowerCase().contains("mindhárom")) {
              falseAnswers.add(a);
            }
          }
        }
      } else {
        for (Answer a in q.answers) {
          if (a.right) {
            trueAnswers.add(a);
          } else {
            if (!a.text.toLowerCase().contains("mindhárom")) {
              falseAnswers.add(a);
            }
          }
        }
      }
    }

    for (Question q in whichIsWrong) {
      for (Answer a in q.answers) {
        if (a.right) {
          falseAnswers.add(a);
        } else {
          trueAnswers.add(a);
        }
      }
    }
  }

  List<Question> generateTrueFalseQuestions(
    List<Answer> trueAnswers,
    List<Answer> falseAnswers,
  ) {
    List<Question> result = [];

    final Random r = Random();
    List<Answer> tempList = [];
    Answer temp = Answer(text: "", right: true);

    // True statement questions
    for (int i = 0; i < 8; ++i) {
      for (int j = 0; j < 3; ++j) {
        tempList.add(falseAnswers[r.nextInt(falseAnswers.length)]);
        falseAnswers.remove(tempList[j]);
      }
      temp = trueAnswers[r.nextInt(trueAnswers.length)];
      trueAnswers.remove(temp);
      result.add(
        Question(
            "Mellyik állítás igaz?;${temp.text};${tempList[0].text};${tempList[1].text};${tempList[2].text}",
            right: "a"),
      );
      tempList.clear();
    }

    // False statement questions
    for (int i = 0; i < 7; ++i) {
      for (int j = 0; j < 3; ++j) {
        tempList.add(trueAnswers[r.nextInt(trueAnswers.length)]);
        trueAnswers.remove(tempList[j]);
      }
      temp = falseAnswers[r.nextInt(falseAnswers.length)];
      falseAnswers.remove(temp);
      result.add(
        Question(
            "Mellyik állítás hamis?;${temp.text};${tempList[0].text};${tempList[1].text};${tempList[2].text}",
            right: "a"),
      );
      tempList.clear();
    }

    return result;
  }

  void changePoints(bool rightAnswer) {
    setState(() {
      if (rightAnswer) rightAnswerCount++;
      questionCount++;
    });
    if (questionCount >= 30) {
      sw.stop();
      t.cancel();
    }
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
    if (questions.isNotEmpty) {
      setState(() {
        activeQuestion = questions[Random().nextInt(questions.length)];
        activeQuiz = Quiz(
          q: activeQuestion,
          nextQuiz: nextQuestion,
          changePoints: changePoints,
          closeQuiz: closeQuiz,
          last: questionCount >= 29,
        );
      });
    }
  }

  void closeQuiz() {
    t.cancel();
    saveScore();
    Navigator.of(context).pop();
  }

  void saveScore() {
    if (questionCount >= 30) {
      if (rightAnswerCount > widget.hs.score ||
          (rightAnswerCount >= widget.hs.score &&
              sw.elapsed < widget.hs.time)) {
        HighScore newhs = HighScore(
          score: rightAnswerCount,
          outof: 30,
          time: sw.elapsed,
        );
        Storage().writeToHighScore(map: newhs.toJSON());
        widget.setHs(newhs);
      }
    }
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
                  Row(
                    children: [
                      Text(
                        "${"$rightAnswerCount".padLeft(2)} / ${"$questionCount".padLeft(2)} (${(questionCount == 0) ? "N/A" : "${(rightAnswerCount * 100 / questionCount).toStringAsFixed(2)}%"})",
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        timeAsString,
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
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

  String formatDuration(Duration d) {
    StringBuffer s = StringBuffer();
    String deli = "";

    if (d.inHours > 0) {
      s.write("${d.inHours}".padLeft(2, '0'));
      deli = ":";
    }
    if (d.inMinutes > 0) {
      s.write(deli);
      s.write("${d.inMinutes.remainder(60)}".padLeft(2, '0'));
      deli = ":";
    }
    s.write(deli);
    s.write("${d.inSeconds.remainder(60)}".padLeft(2, '0'));
    deli = ":";

    s.write(deli);
    s.write(
        "${d.inMilliseconds.remainder(1000)}".padLeft(2, '0').substring(0, 2));

    return s.toString();
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

  void addToLines(
    List<String> lines,
    List<Answer> trueAnswers,
    List<Answer> falseAnswers,
  ) {
    int c = 1;
    lines.add("Igazak:");
    for (Answer a in trueAnswers) {
      lines.add("${"$c".padLeft(3)}:\t${a.text}");
      c++;
    }
    lines.add("Hamisak:");
    for (Answer a in falseAnswers) {
      lines.add("${"$c".padLeft(3)}:\t${a.text}");
      c++;
    }
  }
}
