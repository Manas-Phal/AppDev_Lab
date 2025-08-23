import 'package:appwrite/enums.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:appwrite/appwrite.dart'; // ✅ import for OAuthProvider

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    try {
      await _authService.login(
        _emailController.text,
        _passwordController.text,
      );
      // Navigate to home/dashboard
    } catch (e) {
      print("Login failed: $e");
    }
  }

  void _loginWithProvider(OAuthProvider provider) async {
    try {
      await _authService.loginWithOAuth(provider);
    } catch (e) {
      print("OAuth Login failed: $e");
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
            ElevatedButton(
              onPressed: _login,
              child: const Text("Login"),
            ),

            const SizedBox(height: 40),
            const Text("Or login with"),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Google
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.google, color: Colors.red),
                  iconSize: 40,
                  onPressed: () => _loginWithProvider(OAuthProvider.google),
                ),
                const SizedBox(width: 40),
                // GitHub
                IconButton(
                  icon: const FaIcon(FontAwesomeIcons.github, color: Colors.black),
                  iconSize: 40,
                  onPressed: () => _loginWithProvider(OAuthProvider.github),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
