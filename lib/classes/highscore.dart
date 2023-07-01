import 'package:law_quiz/classes/auth.dart';

class HighScore {
  int score;
  int outof;
  String displayname;
  Duration time;

  HighScore({
    required this.score,
    required this.outof,
    required this.time,
    this.displayname = "Unknown",
  });

  String timeAsString() {
    if (time.inMilliseconds == 0) {
      return "N/A";
    }
    StringBuffer s = StringBuffer();
    String deli = "";

    if (time.inHours > 0) {
      s.write("${time.inHours}".padLeft(2, '0'));
      deli = ":";
    }
    if (time.inMinutes > 0) {
      s.write(deli);
      s.write("${time.inMinutes.remainder(60)}".padLeft(2, '0'));
      deli = ":";
    }
    s.write(deli);
    s.write("${time.inSeconds.remainder(60)}".padLeft(2, '0'));
    deli = ":";

    s.write(deli);
    s.write("${time.inMilliseconds.remainder(1000)}"
        .padLeft(3, '0')
        .substring(0, 3));

    return s.toString();
  }

  Map<String, dynamic> toJSON() {
    return {
      "score": score,
      "outof": outof,
      "time": time.inMilliseconds,
      "displayname": Auth().getCurrentUser?.displayName ?? "Unknown",
    };
  }

  static HighScore fromJSON(Map<String, dynamic> json) {
    return HighScore(
      score: json["score"],
      outof: json["outof"],
      time: Duration(milliseconds: json["time"] ?? 0),
      displayname: json["displayname"] ?? "Unknown",
    );
  }
}
