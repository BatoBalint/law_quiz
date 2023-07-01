import 'dart:async';

import 'package:flutter/material.dart';
import 'package:law_quiz/classes/question.dart';

class Quiz extends StatefulWidget {
  const Quiz({
    super.key,
    required this.q,
    required this.nextQuiz,
    required this.changePoints,
    required this.closeQuiz,
    this.last = false,
  });

  final Question q;
  final Function nextQuiz;
  final Function changePoints;
  final Function closeQuiz;
  final bool last;

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
  late Timer buttonEnableTimer;
  bool closeButtonEnabled = false;

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
    if (widget.last) {
      buttonEnableTimer =
          Timer(const Duration(seconds: 3), () => enableCloseButton());
    }
  }

  void ansSelect(int index) {
    if (guessed) return;
    widget.changePoints(widget.q.check(index));
    fillBds();
    if (widget.q.check(index)) {
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

  void enableCloseButton() {
    buttonEnableTimer.cancel();
    setState(() {
      closeButtonEnabled = true;
    });
  }

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
                    ansSelect(index);
                  },
                  style: const ButtonStyle(
                    splashFactory: InkSplash.splashFactory,
                    alignment: Alignment.centerLeft,
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    child: Text(
                      widget.q.answers[index].text,
                      style: answerTs,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        nextButton(),
      ],
    );
  }

  Widget nextButton() {
    return Container(
      alignment: Alignment.bottomRight,
      child: guessed
          ? (!widget.last
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
              : IconButton(
                  onPressed: closeButtonEnabled
                      ? () {
                          widget.closeQuiz();
                        }
                      : null,
                  disabledColor: const Color.fromARGB(255, 78, 42, 42),
                  icon: const Icon(Icons.close_rounded),
                  iconSize: 60,
                  color: Colors.red,
                  splashRadius: 40,
                  splashColor: Colors.white10,
                ))
          : Container(),
    );
  }
}
