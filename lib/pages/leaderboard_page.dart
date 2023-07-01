import 'package:flutter/material.dart';
import 'package:law_quiz/classes/highscore.dart';
import 'package:law_quiz/classes/storage.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  final TextStyle textStyle = const TextStyle(
    fontSize: 20,
  );

  Widget createTable(List<HighScore>? highscores) {
    List<TableRow> rows = [];
    rows.add(
      TableRow(
        children: [
          createTableItem(text: "#"),
          createTableItem(text: "Név"),
          createTableItem(text: "Pont", alignRight: true),
          createTableItem(text: "Idő", alignRight: true),
        ],
      ),
    );
    if (highscores != null) {
      for (int i = 0; i < highscores.length; ++i) {
        HighScore hs = highscores[i];
        rows.add(
          TableRow(
            children: [
              createTableItem(text: "${i + 1}."),
              createTableItem(text: hs.displayname),
              createTableItem(text: hs.score.toString(), alignRight: true),
              createTableItem(text: hs.timeAsString(), alignRight: true),
            ],
          ),
        );
      }
    }
    return Table(
      children: rows,
      columnWidths: const {
        0: FractionColumnWidth(.10),
        1: FractionColumnWidth(.40),
        2: FractionColumnWidth(.15)
      },
    );
  }

  Widget createTableItem({
    String text = "",
    bool alignRight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        text,
        textAlign: alignRight ? TextAlign.end : TextAlign.start,
        style: textStyle,
      ),
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
                topBar(context),
                title(),
                FutureBuilder(
                  future: Storage().getAllHighscore(),
                  builder: (context, snapshot) {
                    return createTable(snapshot.data);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget topBar(BuildContext context) {
    return Container(
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
    );
  }

  Widget title() {
    return const Padding(
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
    );
  }
}
