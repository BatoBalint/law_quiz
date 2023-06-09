import 'package:law_quiz/auth.dart';

class HighScore {
  int score;
  int outof;
  double percentage;
  String displayname;

  HighScore({
    required this.score,
    required this.outof,
    required this.percentage,
    this.displayname = "Unknown",
  });

  Map<String, dynamic> toJSON() {
    return {
      "score": score,
      "outof": outof,
      "percentage": percentage,
      "displayname": Auth().getCurrentUser?.displayName ?? "Unknown",
    };
  }

  static HighScore fromJSON(Map<String, dynamic> json) {
    return HighScore(
      score: json["score"],
      outof: json["outof"],
      percentage: json["percentage"],
      displayname: json["displayname"] ?? "Unknown",
    );
  }
}
