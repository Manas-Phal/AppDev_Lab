import 'dart:ui';
import 'package:appwrite/enums.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../appwrite_config.dart'; // ensure this file has AppwriteConfig

class ProfileScreen extends StatefulWidget {
  final Color themeColor;
  final bool isDark;

  const ProfileScreen({
    super.key,
    required this.themeColor,
    required this.isDark,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Account _account;
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

  @override
  void initState() {
    super.initState();
    _account = AppwriteConfig.account;
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    try {
      final u = await _account.get();
      setState(() {
        _user = u;
      });
    } catch (_) {
      setState(() {
        _user = null;
      });
    }
  }

  Future<void> _loginEmail() async {
    try {
      await _account.createEmailPasswordSession(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      await _getCurrentUser();
      _snack('Logged in successfully!');
    } catch (e) {
      _snack('Login failed: $e');
    }
  }

  Future<void> _loginOAuth(OAuthProvider provider) async {
    try {
      await _account.createOAuth2Session(provider: provider);
      await _getCurrentUser();
    } catch (e) {
      _snack('OAuth login failed: $e');
    }
  }

  Future<void> _logout() async {
    try {
      await _account.deleteSessions();
      setState(() {
        _user = null;
      });
      _snack('Logged out successfully!');
    } catch (e) {
      _snack('Logout failed: $e');
    }
  }

  Future<void> _forgotPassword() async {
    if (_email.text.trim().isEmpty) {
      _snack('Enter your email first.');
      return;
    }
    try {
      await _account.createRecovery(
        email: _email.text.trim(),
        url: 'https://YOUR_WEB_APP_URL/reset',
      );
      _snack('Password reset link sent to ${_email.text.trim()}');
    } catch (e) {
      _snack('Failed to send reset link: $e');
    }
  }

  void _snack(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          Positioned.fill(
              child: Container(color: Colors.black.withOpacity(0.45))),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _user == null ? _loginCard() : _profileCard(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _loginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.10),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.25)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Login',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              _glassField(
                  controller: _email,
                  label: 'Email',
                  icon: Icons.person_outline,
                  obscure: false),
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
                  const Text('Remember me',
                      style: TextStyle(color: Colors.white70)),
                  const Spacer(),
                  TextButton(
                    onPressed: _forgotPassword,
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
                        borderRadius: BorderRadius.circular(28)),
                    elevation: 0,
                  ),
                  child: const Text('Login',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.google,
                        color: Colors.white, size: 32),
                    tooltip: "Login with Google",
                    onPressed: () => _loginOAuth(OAuthProvider.google),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.github,
                        color: Colors.white, size: 32),
                    tooltip: "Login with GitHub",
                    onPressed: () => _loginOAuth(OAuthProvider.github),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

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
              // 🌈 Refined colorful logo
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.purple, Colors.pink],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4))
                  ],
                ),
                child: const CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _user?.name ?? _user?.email ?? 'User',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _logout,
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
        borderSide: BorderSide(color: Colors.white.withOpacity(0.6)));
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
              color: Colors.white),
        ),
        enabledBorder: base,
        focusedBorder: base.copyWith(
            borderSide: const BorderSide(color: Colors.lightBlueAccent)),
      ),
    );
  }
}
