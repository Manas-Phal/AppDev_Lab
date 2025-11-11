import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  final String title;
  final bool isDone;

  const TaskTile({
    super.key,
    required this.title,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title,
          style: TextStyle(
              decoration:
              isDone ? TextDecoration.lineThrough : null)),
      trailing: Icon(
          isDone ? Icons.check_circle : Icons.circle_outlined),
    );
  }
}
