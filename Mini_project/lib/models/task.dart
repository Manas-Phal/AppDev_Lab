// lib/models/task.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String title;
  final String description;
  final bool isDone;
  final String category;
  final int focusMinutes;
  final String createdBy;
  final DateTime createdAt;

  Task({
    this.id,
    required this.title,
    this.description = '',
    this.isDone = false,
    this.category = 'Ongoing',
    this.focusMinutes = 0,
    this.createdBy = 'guest',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// ✅ Keep fromFirestore (no need to rename)
  factory Task.fromFirestore(Map<String, dynamic> data, String id) {
    final createdAtField = data['createdAt'];
    DateTime createdAtValue;

    if (createdAtField is Timestamp) {
      createdAtValue = createdAtField.toDate();
    } else if (createdAtField is DateTime) {
      createdAtValue = createdAtField;
    } else {
      createdAtValue = DateTime.now();
    }

    return Task(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isDone: data['isDone'] ?? data['isCompleted'] ?? false,
      category: data['category'] ?? 'Ongoing',
      focusMinutes: data['focusMinutes'] ?? 0,
      createdBy: data['createdBy'] ?? 'guest',
      createdAt: createdAtValue,
    );
  }

  /// ✅ Add copyWith to fix “copyWith not defined”
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isDone,
    String? category,
    int? focusMinutes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isDone: isDone ?? this.isDone,
      category: category ?? this.category,
      focusMinutes: focusMinutes ?? this.focusMinutes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isDone': isDone,
      'category': category,
      'focusMinutes': focusMinutes,
      'createdBy': createdBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
