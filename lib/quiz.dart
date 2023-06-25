import 'package:flutter/material.dart';
import 'package:law_quiz/classes/question.dart';

class Quiz extends StatefulWidget {
  const Quiz({
    super.key,
    required this.q,
    required this.nextQuiz,
    required this.changePoints,
  });

  final Question q;
  final Function nextQuiz;
  final Function changePoints;

  @override
  State<Quiz> createState() => _QuizState();
}

class _QuizState extends State<Quiz> {
  TextStyle questionTs = const TextStyle(
    fontSize: 24,
    color: Colors.lightBlue,
    decoration: TextDecoration.none,
  );
  TextStyle answerTs = const TextStyle(
    fontSize: 20,
    color: Colors.black,
    decoration: TextDecoration.none,
  );

  BoxDecoration defaultBoxDecoration = BoxDecoration(
    color: Colors.white60,
    borderRadius: BorderRadius.circular(10),
  );
  List<BoxDecoration> bds = [];

  bool guessed = false;
  bool rightAns = false;

  void fillBds() {
    bds.clear();
    for (int i = 0; i < widget.q.answers.length; i++) {
      bds.add(defaultBoxDecoration);
    }
  }

  @override
  void initState() {
    fillBds();
    super.initState();
  }

  @override
  void didUpdateWidget(Quiz oldWidget) {
    super.didUpdateWidget(oldWidget);
    fillBds();
    guessed = false;
    rightAns = false;
  }

  void ansSelect(String answer, int index) {
    if (guessed) return;
    widget.changePoints(widget.q.check(answer));
    fillBds();
    if (widget.q.check(answer)) {
      setState(() {
        bds[index] = BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(10),
        );
      });
      rightAns = true;
    } else {
      setState(() {
        bds[index] = BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(10),
        );
        bds[widget.q.getRightIndex()] = BoxDecoration(
          color: Colors.green[200],
          borderRadius: BorderRadius.circular(10),
        );
      });
    }
    guessed = true;
  }

  void nextQuiz() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Text(
                widget.q.question,
                style: questionTs,
              ),
            ),
          ),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.q.answers.length,
          shrinkWrap: true,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Container(
                decoration: bds[index],
                child: TextButton(
                  onPressed: () {
                    ansSelect(widget.q.answers[index], index);
                  },
                  style: const ButtonStyle(
                    splashFactory: InkSplash.splashFactory,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Text(
                      widget.q.answers[index],
                      style: answerTs,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          alignment: Alignment.bottomRight,
          child: guessed
              ? IconButton(
                  onPressed: () {
                    widget.nextQuiz(rightAns);
                  },
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  iconSize: 60,
                  color: Colors.green,
                  splashRadius: 40,
                  splashColor: Colors.white10,
                )
              : Container(),
        ),
      ],
    );
  }
}
