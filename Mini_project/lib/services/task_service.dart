import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';
import 'history_service.dart';

class TaskService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;
  late HistoryService _historyService;

  TaskService(this.userId) {
    _historyService = HistoryService(userId);
    print('TaskService initialized for userId: $userId');
  }

  /// Add a new task to Firestore
  Future<String> addTask(Task task) async {
    try {
      if (userId == 'guest') {
        throw Exception('Guest cannot add tasks');
      }
      print('Adding task for user: $userId with title: ${task.title}');

      final docRef = await _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .add({
        'title': task.title,
        'description': task.description,
        'isDone': task.isDone,
        'category': task.category,
        'focusMinutes': task.focusMinutes,
        'createdBy': task.createdBy,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Task added with ID: ${docRef.id}');

      // Log to history
      await _historyService.logAction(
        action: HistoryAction.taskAdded,
        taskTitle: task.title,
        taskId: docRef.id,
      );

      return docRef.id;
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  /// Fetch all tasks for this user
  Future<List<Task>> getTasks() async {
    try {
      if (userId == 'guest') {
        print('Guest user: returning empty task list');
        return [];
      }

      print('Fetching tasks for user: $userId');

      final snapshot = await _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .get();

      print('Fetched ${snapshot.docs.length} tasks');

      return snapshot.docs
          .map((doc) => Task.fromFirestore(
        doc.data(),
        doc.id,
      ))
          .toList();
    } catch (e) {
      print('Error fetching tasks: $e');
      return [];
    }
  }

  /// Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      if (userId == 'guest') throw Exception('Guest cannot update tasks');
      if (task.id == null || task.id!.isEmpty) {
        throw Exception('task.id is empty');
      }

      print('Updating task ${task.id} for user $userId');

      await _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .update({
        'title': task.title,
        'description': task.description,
        'isDone': task.isDone,
        'category': task.category,
        'focusMinutes': task.focusMinutes,
      });

      // Log to history
      await _historyService.logAction(
        action: task.isDone ? HistoryAction.taskCompleted : HistoryAction.taskUpdated,
        taskTitle: task.title,
        taskId: task.id,
      );

      print('Task ${task.id} updated successfully');
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  /// Delete a task
  Future<void> deleteTask(Task task) async {
    try {
      if (userId == 'guest') throw Exception('Guest cannot delete tasks');
      if (task.id == null || task.id!.isEmpty) {
        throw Exception('task.id is empty');
      }

      print('Deleting task ${task.id} for user $userId');

      // Log to history before deleting
      await _historyService.logAction(
        action: HistoryAction.taskDeleted,
        taskTitle: task.title,
        taskId: task.id,
      );

      await _db
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .doc(task.id)
          .delete();

      print('Task ${task.id} deleted successfully');
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }
}
