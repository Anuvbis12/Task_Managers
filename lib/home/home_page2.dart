import 'package:flutter/material.dart';
import '../task/task_model.dart';
import '../task/task_detail_page.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  State<HomePage2> createState() => _HomePage2State();
}

class _HomePage2State extends State<HomePage2> {
  final List<Task> _tasks = [
    Task(title: 'Determine meeting schedule', category: 'Development', date: DateTime.now(), description: 'System Analyst'),
    Task(title: 'Personal branding', category: 'Marketing', date: DateTime.now().add(const Duration(days: 1)), description: 'Marketing Team'),
    Task(title: 'UI UX', category: 'Design', date: DateTime.now().add(const Duration(days: 3)), description: 'Design Team'),
    Task(title: 'Fixing Error Payment', category: 'Development', date: DateTime.now().add(const Duration(days: 3))),
    Task(title: 'Slicing UI', category: 'Development', date: DateTime.now().add(const Duration(days: 5)), description: 'Programmer'),
  ];

  void _updateTask(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              leading: Icon(
                task.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                color: task.isCompleted ? Colors.green : theme.textTheme.bodySmall?.color,
              ),
              title: Text(
                task.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
              subtitle: Text(task.category, style: theme.textTheme.bodySmall),
              trailing: const Icon(Icons.chevron_right),
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailPage(
                      task: task,
                      onTaskUpdated: (updatedTask) {
                        _updateTask(updatedTask);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
