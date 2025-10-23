import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'models/task.dart';
import 'screens/profile_screen.dart';
import 'services/task_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/tasks_screen.dart';
import 'screens/analytics_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ✅ Firebase properly initialized
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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
  Color themeColor = Colors.blue;
  bool isDark = false;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    _taskService = TaskService(user?.uid ?? 'guest');

    FirebaseAuth.instance.userChanges().listen((user) {
      setState(() {
        _taskService = TaskService(user?.uid ?? 'guest');
      });
    });

    _initTasks();
  }

  Future<void> _initTasks() async {
    try {
      final initialTasks = await _taskService.getTasks();
      setState(() => tasks = initialTasks);
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
    }
  }

  // Task operations
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

  void _openChatPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chatbot coming soon!')),
    );
  }

  void _setThemeColor(Color color) => setState(() => themeColor = color);
  void _toggleDarkMode() => setState(() => isDark = !isDark);

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      DashboardScreen(
        tasks: tasks,
        initialThemeColor: themeColor,
        initialIsDark: isDark,
        onChatPressed: _openChatPlaceholder,
        onColorChanged: _setThemeColor,
        onThemeModeChanged: (bool newIsDark) =>
            setState(() => isDark = newIsDark),
      ),
      TasksScreen(
        tasks: tasks,
        themeColor: themeColor,
        isDark: isDark,
        onAddTask: _addTask,
        onUpdateTask: _updateTask,
        onDeleteTask: _deleteTask,
      ),
      AnalysisScreen(
        tasks: tasks,
        themeColor: themeColor,
        isDark: isDark,
      ),
      ProfileScreen(
        themeColor: themeColor,
        isDark: isDark,
      ),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primaryColor: themeColor,
        scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: themeColor.withAlpha(180),
          title: const Text('FocusFlow'),
          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: _openChatPlaceholder,
            ),
          ],
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: pages.map((page) => SizedBox.expand(child: page)).toList(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          selectedItemColor: themeColor,
          unselectedItemColor: isDark ? Colors.white70 : Colors.black54,
          onTap: (i) => setState(() => _selectedIndex = i),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
            BottomNavigationBarItem(
                icon: Icon(Icons.list_alt), label: 'Tasks'),
            BottomNavigationBarItem(
                icon: Icon(Icons.show_chart), label: 'Analysis'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
