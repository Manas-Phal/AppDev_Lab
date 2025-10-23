import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // --- Sign up with Email & Password ---
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Signup Error: ${e.message}");
      return null;
    }
  }

  // --- Login with Email & Password ---
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print("Login Error: ${e.message}");
      return null;
    }
  }

  // --- Logout User ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- Get current user stream ---
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
