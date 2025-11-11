import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final Function(int) onToggleComplete;

  TaskListWidget({required this.tasks, required this.onToggleComplete});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (BuildContext context, int index) {
        final task = tasks[index];

        return ListTile(
          leading: Checkbox(
            value: task.isDone,
            onChanged: (_) => onToggleComplete(index),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isDone ? TextDecoration.lineThrough : null,
            ),
          ),
        );
      },
    );
  }
}
