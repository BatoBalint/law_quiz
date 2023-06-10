import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  static bool onlineLogin = true;

  User? get getCurrentUser => onlineLogin ? _firebaseAuth.currentUser : null;
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
  Stream<User?> get getUserChanges => _firebaseAuth.userChanges();

  Future<void> signInWitEamil({
    required String email,
    required String password,
  }) async {
    if (!onlineLogin) return;

    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (!onlineLogin) return;

    await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    getCurrentUser?.updateDisplayName(displayName);
  }

  Future<void> signOut() async {
    if (!onlineLogin) return;
    await _firebaseAuth.signOut();
  }
}
