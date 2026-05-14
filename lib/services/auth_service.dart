import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get currentUser => _auth.currentUser;
  static bool get isLoggedIn => _auth.currentUser != null;

  static Future<User?> signUp(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  static Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(email: email, password: password);
    return result.user;
  }

  static Future<void> logout() async {
    await _auth.signOut();
  }
}
