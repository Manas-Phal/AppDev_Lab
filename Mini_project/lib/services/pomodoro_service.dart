import 'package:cloud_firestore/cloud_firestore.dart';
import 'history_service.dart';

class PomodoroService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;
  late HistoryService _historyService;

  PomodoroService(this.userId) {
    _historyService = HistoryService(userId);
  }

  /// Start a Pomodoro session
  Future<String> startSession({
    required String taskId,
    required String taskTitle,
    required int workDuration,
    required int breakDuration,
  }) async {
    if (userId == 'guest') throw Exception('Guest cannot start Pomodoro sessions');

    try {
      final sessionRef = await _db
          .collection('users')
          .doc(userId)
          .collection('pomodoroSessions')
          .add({
        'taskId': taskId,
        'taskTitle': taskTitle,
        'workDuration': workDuration,
        'breakDuration': breakDuration,
        'startTime': FieldValue.serverTimestamp(),
        'status': 'work',
        'completed': false,
      });

      // Log to history
      await _historyService.logAction(
        action: HistoryAction.pomodoroStarted,
        taskTitle: taskTitle,
        taskId: taskId,
        additionalData: {
          'workDuration': workDuration,
          'breakDuration': breakDuration,
        },
      );

      return sessionRef.id;
    } catch (e) {
      print('Error starting Pomodoro session: $e');
      rethrow;
    }
  }

  /// Complete a Pomodoro work session
  Future<void> completeWorkSession(String sessionId) async {
    if (userId == 'guest') return;

    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('pomodoroSessions')
          .doc(sessionId)
          .update({
        'workEndTime': FieldValue.serverTimestamp(),
        'status': 'break',
      });
    } catch (e) {
      print('Error completing work session: $e');
    }
  }

  /// Complete a Pomodoro break session
  Future<void> completeBreakSession(String sessionId) async {
    if (userId == 'guest') return;

    try {
      final sessionDoc = await _db
          .collection('users')
          .doc(userId)
          .collection('pomodoroSessions')
          .doc(sessionId)
          .get();

      if (sessionDoc.exists) {
        final data = sessionDoc.data()!;
        await _db
            .collection('users')
            .doc(userId)
            .collection('pomodoroSessions')
            .doc(sessionId)
            .update({
          'breakEndTime': FieldValue.serverTimestamp(),
          'status': 'completed',
          'completed': true,
        });

        // Log to history
        await _historyService.logAction(
          action: HistoryAction.pomodoroCompleted,
          taskTitle: data['taskTitle'] ?? 'Unknown Task',
          taskId: data['taskId'] ?? '',
          additionalData: {
            'workDuration': data['workDuration'] ?? 0,
          },
        );
      }
    } catch (e) {
      print('Error completing break session: $e');
    }
  }

  /// Get all Pomodoro sessions for a user
  Future<List<Map<String, dynamic>>> getSessions({int limit = 50}) async {
    if (userId == 'guest') return [];

    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('pomodoroSessions')
          .orderBy('startTime', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching Pomodoro sessions: $e');
      return [];
    }
  }

  /// Get today's Pomodoro sessions
  Future<List<Map<String, dynamic>>> getTodaySessions() async {
    if (userId == 'guest') return [];

    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('pomodoroSessions')
          .where('startTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .orderBy('startTime', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching today\'s Pomodoro sessions: $e');
      return [];
    }
  }

  /// Get Pomodoro statistics
  Future<Map<String, dynamic>> getStatistics() async {
    if (userId == 'guest') {
      return {
        'totalSessions': 0,
        'todaySessions': 0,
        'totalWorkMinutes': 0,
        'todayWorkMinutes': 0,
      };
    }

    try {
      final allSessions = await getSessions(limit: 1000);
      final todaySessions = await getTodaySessions();

      int totalWorkMinutes = 0;
      int todayWorkMinutes = 0;

      for (var session in allSessions) {
        final workDuration = session['workDuration'] ?? 0;
        if (session['completed'] == true) {
          totalWorkMinutes += (workDuration as num).toInt();
        }
      }

      for (var session in todaySessions) {
        final workDuration = session['workDuration'] ?? 0;
        if (session['completed'] == true) {
          todayWorkMinutes += (workDuration as num).toInt();
        }
      }

      return {
        'totalSessions': allSessions.where((s) => s['completed'] == true).length,
        'todaySessions': todaySessions.where((s) => s['completed'] == true).length,
        'totalWorkMinutes': totalWorkMinutes,
        'todayWorkMinutes': todayWorkMinutes,
      };
    } catch (e) {
      print('Error getting Pomodoro statistics: $e');
      return {
        'totalSessions': 0,
        'todaySessions': 0,
        'totalWorkMinutes': 0,
        'todayWorkMinutes': 0,
      };
    }
  }
}

