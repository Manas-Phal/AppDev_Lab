import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginSignupScreen extends StatefulWidget {
  final bool isDark;
  final Color themeColor;
  final ValueChanged<Color>? onThemeChange;
  final VoidCallback? onGuestMode;

  const LoginSignupScreen({
    Key? key,
    this.isDark = false,
    this.themeColor = Colors.teal,
    this.onThemeChange,
    this.onGuestMode,
  }) : super(key: key);

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false;
  bool _isLogin = true;

  Future<void> _signInEmail() async {
    setState(() => _loading = true);
    try {
      await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      _navigateToDashboard();
    } on FirebaseAuthException catch (e) {
      _show(e.message ?? 'Login failed');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signUpEmail() async {
    setState(() => _loading = true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': _name.text.trim(),
        'email': _email.text.trim(),
        'role': 'user', // Default role
        'createdAt': FieldValue.serverTimestamp(),
      });
      _show('Signup successful — logged in');
      _navigateToDashboard();
    } on FirebaseAuthException catch (e) {
      _show(e.message ?? 'Signup failed');
    } finally {
      setState(() => _loading = false);
    }
  }


  void _navigateToDashboard() {
    // Navigation handled by main.dart based on auth state
  }

  void _show(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.themeColor;
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    Text(
                      'FocusFlow',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: theme,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin
                          ? 'Login to continue'
                          : 'Create an account',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 16),
                    if (!_isLogin)
                      TextField(
                        controller: _name,
                        decoration:
                        const InputDecoration(labelText: 'Name'),
                      ),
                    TextField(
                      controller: _email,
                      decoration:
                      const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration:
                      const InputDecoration(labelText: 'Password'),
                    ),
                    const SizedBox(height: 16),
                    _loading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                      onPressed:
                      _isLogin ? _signInEmail : _signUpEmail,
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            _isLogin ? 'Login' : 'Sign Up',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin
                          ? "Don't have an account? Sign up"
                          : "Already have an account? Login"),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: widget.onGuestMode,
                      icon: const Icon(Icons.person_outline),
                      label: const Text('Continue as Guest'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        side: BorderSide(color: theme, width: 1.5),
                        foregroundColor: theme,
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
