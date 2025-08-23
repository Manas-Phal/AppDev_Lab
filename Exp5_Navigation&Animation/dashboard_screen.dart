
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import '../widgets/celebration_lottie.dart';

class DashboardScreen extends StatefulWidget {
  final List<Task> tasks;
  final Color initialThemeColor;
  final bool initialIsDark;
  final VoidCallback onChatPressed;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<bool> onThemeModeChanged;

  const DashboardScreen({
    Key? key,
    required this.tasks,
    required this.initialThemeColor,
    required this.initialIsDark,
    required this.onChatPressed,
    required this.onColorChanged,
    required this.onThemeModeChanged,
  }) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with TickerProviderStateMixin {
  late Color themeColor;
  late bool isDark;

  final List<String> motivationalQuotes = [
    "Push yourself, because no one else is going to do it for you.",
    "Success is the sum of small efforts repeated day in and day out.",
    "Don’t watch the clock; do what it does. Keep going.",
    "Your limitation—it's only your imagination.",
    "Great things never come from comfort zones."
  ];

  int dailyGoal = 3;
  int weeklyGoal = 20;
  bool showCelebration = false;

  late AnimationController _floatController;
  late AnimationController _quoteFadeController;
  late AnimationController _pulseController;

  late String currentQuote;
  int streak = 0;
  Set<String> completedDates = {};
  int _prevCompletedCount = 0;

  @override
  void initState() {
    super.initState();
    themeColor = widget.initialThemeColor;
    isDark = widget.initialIsDark;

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _quoteFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      lowerBound: 0.0,
      upperBound: 0.08,
    );

    currentQuote = getRandomQuote();
    _quoteFadeController.forward();

    _loadStreakFromPrefs();
    _prevCompletedCount = widget.tasks.where((t) => t.isDone).length;
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldCompleted = _prevCompletedCount;
    final currentCompleted = widget.tasks.where((t) => t.isDone).length;
    if (currentCompleted > oldCompleted) {
      _markTodayCompleted();
      _pulseController.forward(from: 0);
    }
    _prevCompletedCount = currentCompleted;
  }

  @override
  void dispose() {
    _floatController.dispose();
    _quoteFadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  String todayKey() {
    final now = DateTime.now();
    return "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadStreakFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      streak = prefs.getInt('streak') ?? 0;
      completedDates = (prefs.getStringList('completedDates') ?? []).toSet();
    });
  }

  Future<void> _saveStreakToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('streak', streak);
    await prefs.setStringList('completedDates', completedDates.toList());
  }

  void _markTodayCompleted() {
    final key = todayKey();
    if (!completedDates.contains(key)) {
      setState(() {
        completedDates.add(key);
        streak += 1;
      });
      _saveStreakToPrefs();
    }
  }

  String getRandomQuote() {
    motivationalQuotes.shuffle();
    return motivationalQuotes.first;
  }

  void _refreshQuote() {
    setState(() {
      currentQuote = getRandomQuote();
      _quoteFadeController.forward(from: 0);
    });
  }

  void _showGoalDialog() {
    final dailyController = TextEditingController(text: dailyGoal.toString());
    final weeklyController = TextEditingController(text: weeklyGoal.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Set Goals"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dailyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Daily Goal (tasks)"),
            ),
            TextField(
              controller: weeklyController,
              keyboardType: TextInputType.number,
              decoration:
              const InputDecoration(labelText: "Weekly Goal (tasks)"),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                dailyGoal = int.tryParse(dailyController.text) ?? dailyGoal;
                weeklyGoal = int.tryParse(weeklyController.text) ?? weeklyGoal;
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  String greeting() {
    final h = DateTime.now().hour;
    if (h >= 5 && h < 12) return "Good Morning";
    if (h >= 12 && h < 17) return "Good Afternoon";
    if (h >= 17 && h < 21) return "Good Evening";
    return "Good Night";
  }

  Task? getNextTask() {
    try {
      return widget.tasks.firstWhere((t) => !t.isDone);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completed = widget.tasks.where((t) => t.isDone).length;
    final total = widget.tasks.length;
    final percent = total == 0 ? 0.0 : (completed / total);

    // trigger celebration
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (percent == 1.0 && completed > 0 && !showCelebration) {
        setState(() => showCelebration = true);
        Future.delayed(
            const Duration(seconds: 3),
                () => setState(() => showCelebration = false));
      }
    });

    final nextTask = getNextTask();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeColor,
        title: Text('${greeting()},'),
        actions: [
          PopupMenuButton<Color>(
            icon: const Icon(Icons.color_lens),
            tooltip: 'Change Theme Color',
            onSelected: (color) {
              setState(() => themeColor = color);
              widget.onColorChanged(color);
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: Colors.blue, child: _colorCircle(Colors.blue)),
              PopupMenuItem(value: Colors.red, child: _colorCircle(Colors.red)),
              PopupMenuItem(
                  value: Colors.green, child: _colorCircle(Colors.green)),
              PopupMenuItem(
                  value: Colors.orange, child: _colorCircle(Colors.orange)),
              PopupMenuItem(
                  value: Colors.purple, child: _colorCircle(Colors.purple)),
            ],
          ),
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () {
              setState(() => isDark = !isDark);
              widget.onThemeModeChanged(isDark);
            },
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Open Chatbot',
            onPressed: widget.onChatPressed,
          ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            color: isDark ? Colors.black : Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 220), // Reserve space for pulse circle

                  // ✅ Motivational Quote
                  FadeTransition(
                    opacity: _quoteFadeController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '"$currentQuote"',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          color: themeColor,
                          tooltip: "New Quote",
                          onPressed: _refreshQuote,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ✅ Next Task Card with pop-out effect
                  if (nextTask != null)
                    _PopOutCard(
                      themeColor: themeColor,
                      isDark: isDark,
                      task: nextTask,
                      onDelete: () {
                        setState(() {
                          widget.tasks.remove(nextTask);
                        });
                      },
                    ),

                  const SizedBox(height: 120), // space for goals card
                ],
              ),
            ),
          ),

          if (showCelebration) const CelebrationLottie(),

          // ✅ Pulse Circular Progress
          Positioned(
            top: 120,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final scale = 1 + _pulseController.value;
                  return Transform.scale(scale: scale, child: child);
                },
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: percent,
                        strokeWidth: 14,
                        color: themeColor.withOpacity(0.9),
                        backgroundColor: themeColor.withOpacity(0.2),
                      ),
                      Text(
                        '${(percent * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ Floating Goals Card
          Positioned(
            bottom: 20,
            left: 16,
            right: 16,
            child: Transform.translate(
              offset: Offset(0, math.sin(_floatController.value * math.pi) * 4),
              child: Container(
                constraints: const BoxConstraints(minHeight: 100),
                child: Card(
                  color: isDark ? Colors.grey[900] : Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Your Goals",
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    isDark ? Colors.white : Colors.black)),
                            IconButton(
                                icon: const Icon(Icons.edit),
                                color: themeColor,
                                onPressed: _showGoalDialog),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: dailyGoal == 0
                              ? 0
                              : (completed / dailyGoal).clamp(0, 1),
                          backgroundColor: themeColor.withOpacity(0.2),
                          color: themeColor,
                        ),
                        const SizedBox(height: 6),
                        Text("Daily: $completed / $dailyGoal tasks",
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black87)),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: weeklyGoal == 0
                              ? 0
                              : (completed / weeklyGoal).clamp(0, 1),
                          backgroundColor: themeColor.withOpacity(0.2),
                          color: themeColor,
                        ),
                        const SizedBox(height: 6),
                        Text("Weekly: $completed / $weeklyGoal tasks",
                            style: TextStyle(
                                color: isDark
                                    ? Colors.white70
                                    : Colors.black87)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _colorCircle(Color c) => Container(
    width: 24,
    height: 24,
    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
  );
}

/// ✅ Small helper widget for Next Task with pop-out effect
class _PopOutCard extends StatefulWidget {
  final Task task;
  final Color themeColor;
  final bool isDark;
  final VoidCallback onDelete;

  const _PopOutCard({
    Key? key,
    required this.task,
    required this.themeColor,
    required this.isDark,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<_PopOutCard> createState() => _PopOutCardState();
}

class _PopOutCardState extends State<_PopOutCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 1.03),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 180),
        child: Card(
          elevation: 3,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next Task',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.themeColor,
                        fontSize: 16)),
                const SizedBox(height: 8),
                Text(widget.task.title,
                    style: TextStyle(
                        fontSize: 16,
                        color: widget.isDark
                            ? Colors.white70
                            : Colors.black87)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: widget.themeColor,
                      onPressed: () {
                        // TODO: Edit task logic
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: widget.themeColor,
                      onPressed: widget.onDelete,
                    ),
                    IconButton(
                      icon: const Icon(Icons.timer),
                      color: widget.themeColor,
                      onPressed: () {
                        // TODO: Start Pomodoro
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
