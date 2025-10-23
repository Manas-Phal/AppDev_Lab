import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// ✅ Firebase imports
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';

import '../services/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- Email + Password Login ---
  void _login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // ✅ Navigate to home or show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful!")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.message}")),
      );
    }
  }

  // --- Email + Password Signup ---
  void _signup() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful! You can now log in.")),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: ${e.message}")),
      );
    }
  }

  // --- Google Sign-In ---
  Future<void> _loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Google Login successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Login failed: $e")),
      );
    }
  }

  // --- GitHub Sign-In (Optional) ---
  Future<void> _loginWithGitHub() async {
    try {
      // Replace with your own values from Firebase Console → Authentication → GitHub Provider
      const clientId = 'Ov23lifZ9pxav366Koae';
      const clientSecret = '3383bd85cff0cb86bff1652a203dd583819cf4d1';
      const redirectUrl = 'https://focusflow-productivityapp.firebaseapp.com/__/auth/handler'; // e.g. yourapp://auth

      final result = await FlutterWebAuth.authenticate(
        url:
        "https://github.com/login/oauth/authorize?client_id=$clientId&redirect_uri=$redirectUrl&scope=read:user%20user:email",
        callbackUrlScheme: "yourapp", // match your app scheme
      );

      final code = Uri.parse(result).queryParameters['code'];

      final credential = GithubAuthProvider.credential(code!);
      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("GitHub Login successful!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("GitHub Login failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email + Password
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),

            // Login Button
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),

            const SizedBox(height: 10),

            // Signup Button
            OutlinedButton(
              onPressed: _signup,
              child: const Text("Signup"),
            ),

            const SizedBox(height: 40),
            const Text("Or login with"),
            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ✅ Google Login
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                  iconSize: 40,
                  onPressed: _loginWithGoogle,
                ),
                const SizedBox(width: 40),
                // ✅ GitHub Login
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github, color: Colors.black),
                  iconSize: 40,
                  onPressed: _loginWithGitHub,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
