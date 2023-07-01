import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:law_quiz/classes/auth.dart';
import 'package:law_quiz/classes/highscore.dart';

class Storage {
  FirebaseFirestore get getInstance => FirebaseFirestore.instance;
  String currentDocName = "highscoresv2";

  Future<void> writeToHighScore({
    required Map<String, dynamic> map,
  }) async {
    if (Auth().getCurrentUser?.email == null) return;
    final docRef = getInstance
        .collection(currentDocName)
        .doc(Auth().getCurrentUser!.email);

    await docRef.set(map);
  }

  Future<void> oldWriteHighscore({
    required Map<String, dynamic> map,
  }) async {
    if (Auth().getCurrentUser?.email == null) return;
    final docRef =
        getInstance.collection("highscores").doc(Auth().getCurrentUser!.email);

    await docRef.set(map);
  }

  Future<HighScore> getUsersHighscore() async {
    if (Auth().getCurrentUser?.email != null) {
      var document = getInstance
          .collection(currentDocName)
          .doc(Auth().getCurrentUser!.email);
      DocumentSnapshot<Map<String, dynamic>> map = await document.get();
      if (map.exists) {
        return HighScore.fromJSON(map.data()!);
      }
    }
    return HighScore(score: 0, outof: 0, time: Duration.zero);
  }

  Future<List<HighScore>> getAllHighscore() async {
    QuerySnapshot<Map<String, dynamic>> snapshots =
        await getInstance.collection(currentDocName).get();
    List<HighScore> returnList = [];
    for (var doc in snapshots.docs) {
      returnList.add(
        HighScore(
          score: doc.data()["score"] ?? 0,
          outof: doc.data()["outof"] ?? 0,
          time: Duration(milliseconds: doc.data()["time"] ?? 0),
          displayname: doc.data()["displayname"] ?? "Unknown",
        ),
      );
    }

    returnList.sort((HighScore h1, HighScore h2) {
      int comp = h1.score.compareTo(h2.score);
      if (comp == 0) {
        return h1.time.compareTo(h2.time);
      }
      return -comp;
    });
    return returnList;
  }
}
