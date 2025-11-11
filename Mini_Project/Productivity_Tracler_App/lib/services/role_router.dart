// role_router.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Dashboards by Role
import '../screens/roles/admin_dashboard.dart';
import '../screens/roles/professor_dashboard.dart';
import '../screens/roles/student_dashboard.dart';
import '../screens/roles/vip_dashboard.dart';
import '../screens/roles/guest_screen.dart';

class RoleRouter {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  /// Handles login and redirects user based on role
  Future<void> handleLoginRouting(BuildContext context) async {
    final user = _auth.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      final docRef = _db.collection('users').doc(user.uid);
      final doc = await docRef.get();

      // 🧠 Create document if user not found
      if (!doc.exists) {
        await docRef.set({
          'uid': user.uid,
          'email': user.email,
          'role': 'student', // default role
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // ✅ Always re-fetch to ensure latest role
      final freshDoc = await docRef.get();
      final data = freshDoc.data() ?? {};
      final role = (data['role'] ?? 'student').toString();

      // ✅ Cache locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_role', role);

      // Navigate to dashboard
      _navigateToDashboard(context, role);
    } catch (e) {
      debugPrint("⚠️ Role fetch error: $e");
      _navigateToDashboard(context, 'student');
    }
  }

  /// ✅ NEW — Refresh user role dynamically (no logout)
  Future<void> refreshUserRole(BuildContext context, {bool allowBack = false}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docRef = _db.collection('users').doc(user.uid);
      final freshDoc = await docRef.get();

      if (freshDoc.exists) {
        final role = (freshDoc.data()?['role'] ?? 'student').toString();

        // Update locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', role);

        // Re-route instantly (with back button support if requested)
        _navigateToDashboard(context, role, allowBack: allowBack);
      } else {
        debugPrint("⚠️ User document not found during refresh.");
      }
    } catch (e) {
      debugPrint("⚠️ Error refreshing role: $e");
    }
  }

  /// Route navigation by role
  void _navigateToDashboard(BuildContext context, String role, {bool allowBack = false}) {
    Widget screen;

    // Handle role variations
    if (role.startsWith('admin')) {
      if (role.contains('professor')) {
        screen = const ProfessorDashboard();
      } else if (role.contains('student')) {
        screen = const AdminDashboard();
      } else {
        screen = const AdminDashboard();
      }
    } else {
      switch (role.toLowerCase()) {
        case 'professor':
          screen = const ProfessorDashboard();
          break;
        case 'vip':
          screen = const VipDashboard();
          break;
        case 'guest':
          screen = const GuestScreen();
          break;
        case 'student':
          screen = const StudentDashboard();
          break;
        default:
          screen = const StudentDashboard();
      }
    }

    if (allowBack) {
      // Use push to allow back navigation
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    } else {
      // Use pushReplacement for initial login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );
    }
  }

  /// Navigate to role dashboard with back button support
  Future<void> navigateToRoleDashboard(BuildContext context, String role) async {
    _navigateToDashboard(context, role, allowBack: true);
  }
}

/// ✅ Access Control Helper — use for conditional UI
class AccessControl {
  static bool canAccessAnalysis(String role) =>
      role == 'professor' || role == 'vip' || role == 'student';
  static bool hasLimitedAccess(String role) => role == 'user';
  static bool isGuest(String role) => role == 'guest';
}
