import 'package:cloud_firestore/cloud_firestore.dart';

enum HistoryAction {
  taskAdded,
  taskUpdated,
  taskDeleted,
  taskCompleted,
  taskSearched,
  pomodoroStarted,
  pomodoroCompleted,
}

class HistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  HistoryService(this.userId);

  /// Log a history action
  Future<void> logAction({
    required HistoryAction action,
    String? taskTitle,
    String? taskId,
    Map<String, dynamic>? additionalData,
  }) async {
    if (userId == 'guest') return;

    try {
      await _db
          .collection('users')
          .doc(userId)
          .collection('activityHistory')
          .add({
        'action': action.toString().split('.').last,
        'taskTitle': taskTitle,
        'taskId': taskId,
        'timestamp': FieldValue.serverTimestamp(),
        'additionalData': additionalData ?? {},
      });
    } catch (e) {
      print('Error logging history: $e');
    }
  }

  /// Get all history items
  Future<List<Map<String, dynamic>>> getHistory({int limit = 50}) async {
    if (userId == 'guest') return [];

    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('activityHistory')
          .orderBy('timestamp', descending: true)
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
      print('Error fetching history: $e');
      return [];
    }
  }

  /// Get history by action type
  Future<List<Map<String, dynamic>>> getHistoryByAction(HistoryAction action) async {
    if (userId == 'guest') return [];

    try {
      final actionString = action.toString().split('.').last;
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('activityHistory')
          .where('action', isEqualTo: actionString)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    } catch (e) {
      print('Error fetching history by action: $e');
      return [];
    }
  }

  /// Clear all history
  Future<void> clearHistory() async {
    if (userId == 'guest') return;

    try {
      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('activityHistory')
          .get();

      final batch = _db.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
}

