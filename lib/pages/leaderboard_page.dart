import 'package:flutter/material.dart';
import 'package:law_quiz/classes/highscore.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key, required this.highscores});

  final List<HighScore> highscores;
  final ts = const TextStyle(
    fontSize: 20,
  );

  Widget createTable() {
    List<TableRow> rows = [];
    rows.add(
      TableRow(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "#",
              style: ts,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "Név",
              style: ts,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "pont/",
              style: ts,
              textAlign: TextAlign.end,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "max",
              style: ts,
              textAlign: TextAlign.start,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(
              "%",
              textAlign: TextAlign.end,
              style: ts,
            ),
          ),
        ],
      ),
    );
    for (int i = 0; i < highscores.length; ++i) {
      HighScore hs = highscores[i];
      rows.add(TableRow(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "${i + 1}.",
            style: ts,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            hs.displayname,
            style: ts,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "${hs.score}/",
            style: ts,
            textAlign: TextAlign.end,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "${hs.outof}",
            style: ts,
            textAlign: TextAlign.start,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            hs.percentage.toStringAsFixed(2),
            textAlign: TextAlign.end,
            style: ts,
          ),
        ),
      ]));
    }
    return Table(
      children: rows,
      columnWidths: const {
        0: FractionColumnWidth(.12),
        2: FractionColumnWidth(.14),
        3: FractionColumnWidth(.12),
        4: FractionColumnWidth(.22)
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 12, bottom: 32),
                  child: Center(
                    child: Text(
                      "Ranglista",
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                ),
                createTable(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
