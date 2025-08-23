Profile_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:carousel_slider/carousel_slider.dart';

class ProfileScreen extends StatefulWidget {
  final Color themeColor;
  final bool isDark;
  final List<String> variants;

  const ProfileScreen({
    super.key,
    required this.themeColor,
    required this.isDark,
    required this.variants,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // --------- VARIABLES ----------
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _remember = false;
  bool _obscure = true;

  final List<String> _bg = [
    'https://source.unsplash.com/random/800x600/?nature,water',
    'https://source.unsplash.com/random/800x600/?tech',
    'https://source.unsplash.com/random/800x600/?city',
  ];

  // ----------------- AUTH BACKEND -----------------
  Future<void> _loginEmail() async {
    try {
      final c = await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      setState(() => _user = c.user);
    } catch (e) {
      _snack(e.toString());
    }
  }

  Future<void> _loginGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final gAuth = await googleUser.authentication;
      final cred = GoogleAuthProvider.credential(
        idToken: gAuth.idToken,
        accessToken: gAuth.accessToken,
      );
      final c = await _auth.signInWithCredential(cred);
      setState(() => _user = c.user);
      _snack('Signed in with Google');
    } catch (e) {
      _snack('Google sign-in failed: $e');
    }
  }

  Future<void> _loginGithub() async {
    try {
      final provider = GithubAuthProvider();
      final c = await _auth.signInWithProvider(provider);
      setState(() => _user = c.user);
      _snack('Signed in with GitHub');
    } catch (e) {
      _snack('GitHub sign-in failed: $e');
    }
  }

  Future<void> _forgot() async {
    try {
      if (_email.text.trim().isEmpty) {
        _snack('Enter your email first.');
        return;
      }
      await _auth.sendPasswordResetEmail(email: _email.text.trim());
      _snack('Password reset link sent to ${_email.text.trim()}');
    } catch (e) {
      _snack(e.toString());
    }
  }

  void _snack(String m) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  // ----------------- UI -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        // Background carousel
        Positioned.fill(
          child: CarouselSlider.builder(
            itemCount: _bg.length,
            options: CarouselOptions(
              height: double.infinity,
              viewportFraction: 1,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 6),
              autoPlayAnimationDuration: const Duration(milliseconds: 1200),
              enableInfiniteScroll: true,
              scrollPhysics: const NeverScrollableScrollPhysics(),
            ),
            itemBuilder: (_, i, __) => SizedBox.expand(
              child: Image.network(
                _bg[i],
                fit: BoxFit.cover,
                loadingBuilder: (c, w, p) =>
                p == null ? w : Container(color: const Color(0xFF1E1E1E)),
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1E1E1E)),
              ),
            ),
          ),
        ),
        // Soft overlay for readability
        Positioned.fill(
          child: Container(color: Colors.black.withOpacity(0.45)),
        ),
        // Big title
        Positioned(
          top: 48,
          left: 20,
          right: 20,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              'Productivity\nTracker',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.02,
                fontSize: 56,
                letterSpacing: -0.5,
              ),
            ),
          ),
        ),
        // Card
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: _user == null ? _loginCard() : _profileCard(),
            ),
          ),
        ),
      ]),
    );
  }

  // ----------- LOGIN CARD ----------
  Widget _loginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Login',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              _glassField(
                controller: _email,
                label: 'Email',
                icon: Icons.person_outline,
                obscure: false,
              ),
              const SizedBox(height: 12),
              _glassField(
                controller: _password,
                label: 'Password',
                icon: Icons.lock_outline,
                obscure: _obscure,
                onToggle: () => setState(() => _obscure = !_obscure),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Checkbox(
                    value: _remember,
                    onChanged: (v) => setState(() => _remember = v ?? false),
                    side: const BorderSide(color: Colors.white70),
                    activeColor: Colors.white,
                    checkColor: Colors.black,
                  ),
                  const Text('Remember me', style: TextStyle(color: Colors.white70)),
                  const Spacer(),
                  TextButton(
                    onPressed: _forgot,
                    child: const Text('Forgot Password?',
                        style: TextStyle(color: Colors.white70)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loginEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 0,
                  ),
                  child: const Text('Login',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialIcon(
                    tooltip: 'Sign in with Google',
                    imageUrl:
                    'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                    onTap: _loginGoogle,
                  ),
                  const SizedBox(width: 28),
                  _socialIcon(
                    tooltip: 'Sign in with GitHub',
                    imageUrl:
                    'https://cdn-icons-png.flaticon.com/512/733/733553.png',
                    onTap: _loginGithub,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.center,
                children: const [
                  Text("Don’t have an account? ",
                      style: TextStyle(color: Colors.white70)),
                  Text("Register",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------- PROFILE CARD ----------
  Widget _profileCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _user?.photoURL != null
                    ? NetworkImage(_user!.photoURL!)
                    : null,
                child: _user?.photoURL == null
                    ? const Icon(Icons.person, color: Colors.white, size: 40)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                _user?.displayName ?? _user?.email ?? 'User',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () async {
                    await _auth.signOut();
                    setState(() => _user = null);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscure,
    VoidCallback? onToggle,
  }) {
    final base = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.white.withOpacity(0.6)),
    );
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      cursorColor: Colors.white,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: onToggle == null
            ? null
            : IconButton(
          onPressed: onToggle,
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
        ),
        enabledBorder: base,
        focusedBorder: base.copyWith(
          borderSide: const BorderSide(color: Colors.lightBlueAccent),
        ),
      ),
    );
  }

  Widget _socialIcon({
    required String imageUrl,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: Image.network(imageUrl, width: 44, height: 44),
      ),
    );
  }
}
