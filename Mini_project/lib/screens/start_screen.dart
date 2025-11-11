// lib/screens/start_screen.dart
import 'package:flutter/material.dart';
import 'login_signup_screen.dart';
import 'dashboard_screen.dart';
import '../services/news_service.dart';
import '../services/quote_service.dart';

class StartScreen extends StatelessWidget {
  final NewsService newsService;
  final QuoteService quoteService;

  const StartScreen({
    super.key,
    required this.newsService,
    required this.quoteService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to Productivity Tracker",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // ✅ Continue as User button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginSignupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text("Continue as User"),
              ),

              const SizedBox(height: 20),

              // ✅ Continue as Guest button
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DashboardScreen(
                        isDark: false,
                        onThemeChange: (v) {},
                        themeColor: Colors.green,
                        isGuest: true, userRole: '',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline),
                label: const Text("Continue as Guest"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: const BorderSide(color: Colors.green, width: 1.5),
                  foregroundColor: Colors.green,
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),

              const SizedBox(height: 30),

              // Optional note for clarity
              const Text(
                "Guests can explore the app but need to log in to save progress or access full features.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
