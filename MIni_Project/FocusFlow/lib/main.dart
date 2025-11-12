// lib/main.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

// screens
import 'screens/login_signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/history_screen.dart';

import 'models/task.dart';
import 'services/task_service.dart';
import 'services/role_access.dart';
import 'screens/roles/guest_screen.dart';
import 'services/ai_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final existingApp = Firebase.apps.isNotEmpty ? Firebase.apps.first : null;
  if (existingApp == null) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }

  // ✅ Configure Firestore safely
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  print('Firebase Project ID: ${FirebaseFirestore.instance.app.options.projectId}');
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatefulWidget {
  const FocusFlowApp({Key? key}) : super(key: key);

  @override
  State<FocusFlowApp> createState() => _FocusFlowAppState();
}

class _FocusFlowAppState extends State<FocusFlowApp> {
  late TaskService _taskService;

  List<Task> tasks = [];
  Color themeColor = Colors.teal;
  bool isDark = false;
  int _selectedIndex = 0; // Default to Dashboard
  User? currentUser;
  String userRole = 'guest';
  bool _isGuestMode = false;

  @override
  void initState() {
    super.initState();
    currentUser = FirebaseAuth.instance.currentUser;
    _taskService = TaskService(currentUser?.uid ?? 'guest');
    _loadPreferences();
    _initializeAI();

    FirebaseAuth.instance.userChanges().listen((user) async {
      setState(() {
        currentUser = user;
        if (user != null) _isGuestMode = false;
        _taskService = TaskService(user?.uid ?? 'guest');
        userRole = user == null ? 'guest' : 'user';
      });

      await _fetchUserRole();
      await _initTasks();

      if (user != null) {
        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.exists && snapshot.data()?['role'] != null) {
            final newRole = snapshot.data()!['role'] as String;
            if (mounted && newRole != userRole) {
              setState(() => userRole = newRole);
            }
          }
        });
      }
    });

    _fetchUserRole();
    _initTasks();
  }

  Future<void> _initializeAI() async {
    await AIConfig.loadApiKey();
  }

  Future<void> _fetchUserRole() async {
    try {
      if (currentUser != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .get();
        if (doc.exists && doc.data()?['role'] != null) {
          setState(() => userRole = doc.data()!['role']);
        }
      }
    } catch (e) {
      debugPrint('Error fetching role: $e');
    }
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDark = prefs.getBool('isDark') ?? false;
      int? colorValue = prefs.getInt('themeColor');
      if (colorValue != null) themeColor = Color(colorValue);
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    await prefs.setInt('themeColor', themeColor.value);
  }

  Future<void> _initTasks() async {
    try {
      final fetched = await _taskService.getTasks();
      setState(() => tasks = fetched);
    } catch (e) {
      debugPrint('Error loading tasks: $e');
    }
  }

  Future<void> _addTask(Task task) async {
    await _taskService.addTask(task);
    _initTasks();
  }

  Future<void> _updateTask(Task updatedTask) async {
    await _taskService.updateTask(updatedTask);
    _initTasks();
  }

  Future<void> _deleteTask(Task taskToDelete) async {
    await _taskService.deleteTask(taskToDelete);
    _initTasks();
  }

  void _toggleDarkMode() async {
    setState(() => isDark = !isDark);
    await _savePreferences();
  }

  void _changeThemeColor(Color newColor) async {
    setState(() => themeColor = newColor);
    await _savePreferences();
  }

  void _enableGuestMode() {
    setState(() {
      _isGuestMode = true;
      userRole = 'guest';
      currentUser = null;
      _taskService = TaskService('guest');
    });
    _initTasks();
  }

  @override
  Widget build(BuildContext context) {
    // 🔹 If not signed in and not in guest mode, show login/signup
    if (currentUser == null && !_isGuestMode) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: LoginSignupScreen(
          themeColor: themeColor,
          isDark: isDark,
          onThemeChange: _changeThemeColor,
          onGuestMode: _enableGuestMode,
        ),
      );
    }

    // 🔹 If logged in but role is guest, show the same Guest screen as "Continue as Guest"
    if (currentUser != null && userRole == 'guest') {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: themeColor,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const GuestScreen(),
      );
    }

    // 🔹 Pages setup (Dashboard, Tasks, Analytics, History, Profile)
    final pages = <Widget>[
      DashboardScreen(
        themeColor: themeColor,
        isDark: isDark,
        onThemeChange: _changeThemeColor,
        userRole: userRole,
        isGuest: _isGuestMode,
      ),
      TasksScreen(
        tasks: tasks,
        themeColor: themeColor,
        isDark: isDark,
        onAddTask: _addTask,
        onUpdateTask: _updateTask,
        onDeleteTask: _deleteTask,
        currentUserId: currentUser?.uid ?? 'guest',
      ),
      AnalyticsScreen(
        tasks: tasks,
        themeColor: themeColor,
        isDark: isDark,
        role: userRole,
      ),
      HistoryScreen(
        userId: currentUser?.uid ?? 'guest',
        themeColor: themeColor,
        isDark: isDark,
      ),
      ProfileScreen(
        themeColor: themeColor,
        isDark: isDark,
        onToggleTheme: _toggleDarkMode,
        isGuest: _isGuestMode,
        onLogoutRequested: () async {
          // Exit guest mode if active, otherwise sign out
          if (_isGuestMode) {
            setState(() {
              _isGuestMode = false;
              userRole = 'guest';
              currentUser = null;
              _selectedIndex = 0;
              _taskService = TaskService('guest');
            });
            await _initTasks();
          } else {
            await FirebaseAuth.instance.signOut();
          }
        },
        onRoleChanged: () async {
          await _fetchUserRole();
          setState(() {});
        },
      ),
    ];

    // 🔹 Bottom Navigation Items
    final navItems = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.task_outlined), label: 'Tasks'),
      BottomNavigationBarItem(
        icon: Icon(RoleAccess.isVIP(userRole) ? Icons.show_chart : Icons.lock),
        label: 'Analytics',
      ),
      const BottomNavigationBarItem(
          icon: Icon(Icons.history), label: 'History'),
      const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline), label: 'Profile'),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [
                themeColor.withOpacity(0.8),
                Colors.black.withOpacity(0.95),
              ]
                  : [
                themeColor.withOpacity(0.5),
                Colors.white.withOpacity(0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: themeColor,
          unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
          onTap: (i) {
            // Restrict Analytics tab for non-VIP users
            if (i == 2 && !RoleAccess.isVIP(userRole)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Analytics access is restricted to VIP users only'),
                  duration: Duration(seconds: 2),
                ),
              );
              return;
            }
            setState(() => _selectedIndex = i);
          },
          items: navItems,
        ),
      ),
    );
  }
}
