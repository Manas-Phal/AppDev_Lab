import 'package:flutter/material.dart';
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  final List<Task> tasks;
  final Function(Task) onAddTask;
  final Function(Task) onUpdateTask;
  final Function(Task) onDeleteTask;
  final Color themeColor;
  final bool isDark;

  const TasksScreen({
    Key? key,
    required this.tasks,
    required this.onAddTask,
    required this.onUpdateTask,
    required this.onDeleteTask,
    required this.themeColor,
    required this.isDark,
  }) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Task? activePomodoroTask;
  int? pomodoroDuration;

  // ---------------- Pomodoro Bar ----------------
  Widget _buildPomodoroBar() {
    return Container(
      padding: const EdgeInsets.all(8),
      color: widget.themeColor.withOpacity(0.2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Pomodoro: ${activePomodoroTask!.title} (${pomodoroDuration ?? 25} mins)",
              style: TextStyle(
                color: widget.isDark ? Colors.white : Colors.black,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              activePomodoroTask = null;
              pomodoroDuration = null;
            }),
          )
        ],
      ),
    );
  }

  // ---------------- Dialog for Add/Edit ----------------
  void _showAddOrEditDialog({Task? task}) {
    final titleController = TextEditingController(text: task?.title ?? "");
    final categoryController = TextEditingController(text: task?.category ?? "");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(task == null ? "Add Task" : "Edit Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: "Category"),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isEmpty || categoryController.text.isEmpty) return;
              final newTask = Task(
                id: task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                title: titleController.text,
                category: categoryController.text,
                isDone: task?.isDone ?? false,
              );
              task == null ? widget.onAddTask(newTask) : widget.onUpdateTask(newTask);
              Navigator.pop(ctx);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // ---------------- Dialog for Pomodoro ----------------
  void _showPomodoroSettingsDialog(Task task) {
    int duration = 25;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Pomodoro Settings"),
        content: DropdownButton<int>(
          value: duration,
          items: const [
            DropdownMenuItem(value: 25, child: Text("25 minutes")),
            DropdownMenuItem(value: 50, child: Text("50 minutes")),
          ],
          onChanged: (val) => setState(() => duration = val ?? 25),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                activePomodoroTask = task;
                pomodoroDuration = duration;
              });
              Navigator.pop(ctx);
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );
  }

  // ---------------- Section Header ----------------
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: widget.isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    final assigned = widget.tasks.where((t) => t.category.toLowerCase() == "assigned").toList();
    final ongoing = widget.tasks.where((t) => !t.isDone && t.category.toLowerCase() != "assigned").toList();
    final completed = widget.tasks.where((t) => t.isDone).toList();

    return Scaffold(
      backgroundColor: widget.isDark ? Colors.black : widget.themeColor.withOpacity(0.1),
      appBar: AppBar(
        backgroundColor: widget.themeColor,
        title: const Text("Tasks"),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: widget.themeColor,
        onPressed: () => _showAddOrEditDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          if (activePomodoroTask != null) _buildPomodoroBar(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Assigned
                if (assigned.isNotEmpty) _buildSectionHeader("Assigned"),
                ...assigned.map((task) => AnimatedTaskCard(
                  task: task,
                  onToggle: (val) {
                    setState(() => task.isDone = val ?? false);
                    widget.onUpdateTask(task);
                  },
                  onEdit: () => _showAddOrEditDialog(task: task),
                  onDelete: () => widget.onDeleteTask(task),
                  onPomodoro: () => _showPomodoroSettingsDialog(task),
                )),
                const SizedBox(height: 16),

                // Ongoing
                if (ongoing.isNotEmpty) _buildSectionHeader("Ongoing"),
                ...ongoing.map((task) => AnimatedTaskCard(
                  task: task,
                  onToggle: (val) {
                    setState(() => task.isDone = val ?? false);
                    widget.onUpdateTask(task);
                  },
                  onEdit: () => _showAddOrEditDialog(task: task),
                  onDelete: () => widget.onDeleteTask(task),
                  onPomodoro: () => _showPomodoroSettingsDialog(task),
                )),
                const SizedBox(height: 16),

                // Completed
                if (completed.isNotEmpty) _buildSectionHeader("Completed"),
                ...completed.map((task) => AnimatedTaskCard(
                  task: task,
                  onToggle: (val) {
                    setState(() => task.isDone = val ?? false);
                    widget.onUpdateTask(task);
                  },
                  onEdit: () => _showAddOrEditDialog(task: task),
                  onDelete: () => widget.onDeleteTask(task),
                  onPomodoro: () => _showPomodoroSettingsDialog(task),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Animated Task Card ----------------
class AnimatedTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onPomodoro;
  final ValueChanged<bool?> onToggle;

  const AnimatedTaskCard({
    Key? key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onPomodoro,
    required this.onToggle,
  }) : super(key: key);

  @override
  State<AnimatedTaskCard> createState() => _AnimatedTaskCardState();
}

class _AnimatedTaskCardState extends State<AnimatedTaskCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {}, // optional
          onHighlightChanged: (pressed) {
            setState(() {
              _scale = pressed ? 1.03 : 1.0;
            });
          },
          child: ListTile(
            title: Text(widget.task.title),
            subtitle: Text(widget.task.category),
            leading: Checkbox(
              value: widget.task.isDone,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: widget.onToggle,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: widget.onEdit),
                IconButton(icon: const Icon(Icons.delete), onPressed: widget.onDelete),
                IconButton(icon: const Icon(Icons.timer), onPressed: widget.onPomodoro),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
