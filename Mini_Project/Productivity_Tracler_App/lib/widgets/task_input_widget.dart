import 'package:flutter/material.dart';

class TaskInputWidget extends StatefulWidget {
  final Function(String, String) addTask;

  const TaskInputWidget({required this.addTask, super.key});

  @override
  _TaskInputWidgetState createState() => _TaskInputWidgetState();
}

class _TaskInputWidgetState extends State<TaskInputWidget> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();

  void _submitData() {
    final title = _titleController.text.trim();
    final category = _categoryController.text.trim();
    if (title.isEmpty || category.isEmpty) return;

    widget.addTask(title, category);
    _titleController.clear();
    _categoryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(10),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Task Title'),
          ),
          TextField(
            controller: _categoryController,
            decoration: const InputDecoration(labelText: 'Category'),
          ),
          ElevatedButton(
            onPressed: _submitData,
            child: const Text('Add Task'),
          ),
        ],
      ),
    );
  }
}
