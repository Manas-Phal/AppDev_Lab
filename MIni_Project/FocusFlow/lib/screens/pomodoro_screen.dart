import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/pomodoro_service.dart';

class PomodoroScreen extends StatefulWidget {
  final Task task;
  final int workDuration;
  final int breakDuration;
  final Color themeColor;
  final bool isDark;

  const PomodoroScreen({
    Key? key,
    required this.task,
    required this.workDuration,
    required this.breakDuration,
    required this.themeColor,
    required this.isDark,
  }) : super(key: key);

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  Timer? _timer;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isWorkTime = true;
  int _completedPomodoros = 0;
  
  late PomodoroService _pomodoroService;
  String? _currentSessionId;

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
    _pomodoroService = PomodoroService(userId);
    _totalSeconds = widget.workDuration * 60;
    _startPomodoroSession();
  }

  Future<void> _startPomodoroSession() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null || userId == 'guest') return;

      final sessionId = await _pomodoroService.startSession(
        taskId: widget.task.id ?? '',
        taskTitle: widget.task.title,
        workDuration: widget.workDuration,
        breakDuration: widget.breakDuration,
      );
      
      setState(() {
        _currentSessionId = sessionId;
      });
    } catch (e) {
      print('Error starting Pomodoro session: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds == 0) {
        timer.cancel();
        _onTimerComplete();
      } else {
        setState(() => _totalSeconds--);
      }
    });
  }

  void _pauseTimer() {
    setState(() {
      _isRunning = false;
      _timer?.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _timer?.cancel();
      _isRunning = false;
      _isWorkTime = true;
      _totalSeconds = widget.workDuration * 60;
    });
  }

  void _onTimerComplete() async {
    setState(() {
      _isRunning = false;
    });
    
    if (_isWorkTime) {
      // Complete work session
      if (_currentSessionId != null) {
        try {
          await _pomodoroService.completeWorkSession(_currentSessionId!);
        } catch (e) {
          print('Error completing work session: $e');
        }
      }
      
      setState(() {
        _completedPomodoros++;
        _isWorkTime = false;
        _totalSeconds = widget.breakDuration * 60;
      });
      
      _showBreakDialog();
    } else {
      // Complete break session
      if (_currentSessionId != null) {
        try {
          await _pomodoroService.completeBreakSession(_currentSessionId!);
        } catch (e) {
          print('Error completing break session: $e');
        }
      }
      
      setState(() {
        _isWorkTime = true;
        _totalSeconds = widget.workDuration * 60;
      });
      
      _showWorkDialog();
    }
  }

  void _showBreakDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Work Session Complete!'),
        content: Text('Take a ${widget.breakDuration} minute break.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _startTimer();
            },
            child: const Text('Start Break'),
          ),
        ],
      ),
    );
  }

  void _showWorkDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Break Complete!'),
        content: const Text('Ready to start another work session?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _resetTimer();
            },
            child: const Text('Start Work'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    final total = _isWorkTime ? widget.workDuration * 60 : widget.breakDuration * 60;
    return 1.0 - (_totalSeconds / total);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        backgroundColor: widget.themeColor,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.isDark
                ? [widget.themeColor.withOpacity(0.8), Colors.black87]
                : [widget.themeColor.withOpacity(0.5), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Task Info
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          widget.task.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isWorkTime ? 'Work Time' : 'Break Time',
                          style: TextStyle(
                            fontSize: 16,
                            color: widget.themeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Timer Display
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: _getProgress(),
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(widget.themeColor),
                      ),
                    ),
                    Text(
                      _formatTime(_totalSeconds),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: widget.isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                
                // Completed Pomodoros
                Text(
                  'Completed: $_completedPomodoros',
                  style: TextStyle(
                    fontSize: 18,
                    color: widget.isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 40),
                
                // Control Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRunning)
                      ElevatedButton.icon(
                        onPressed: _startTimer,
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.themeColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: _pauseTimer,
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    const SizedBox(width: 16),
                    OutlinedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: widget.themeColor,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
