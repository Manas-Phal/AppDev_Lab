import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../screens/profile_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: Colors.redAccent,
        automaticallyImplyLeading: true, // Enable back button
        actions: [
          // Change Role button
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Change Role',
            onPressed: () {
              // Navigate to profile to change role
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    themeColor: Colors.redAccent,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    onToggleTheme: () {},
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Welcome, Admin!\nYou can manage users and roles here.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate back to main app
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to Main App'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
