import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task_model.dart';

class CompletedTasksPage extends StatelessWidget {
  final List<Task> allTasks;

  const CompletedTasksPage({super.key, required this.allTasks});

  @override
  Widget build(BuildContext context) {
    // Saring untuk mendapatkan hanya tugas yang sudah selesai
    final List<Task> completedTasks =
    allTasks.where((task) => task.isCompleted).toList();
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        Text(
          'Completed Tasks',
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8.0),
        Text(
          'You have completed ${completedTasks.length} tasks.',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24.0),

        // Tampilkan pesan jika tidak ada tugas yang selesai
        if (completedTasks.isEmpty)
          const Center(
            heightFactor: 5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No completed tasks yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey)),
                Text('Get to work and complete some tasks!',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),

        // Tampilkan daftar tugas yang selesai
        if (completedTasks.isNotEmpty)
          ...completedTasks.map((task) => _buildCompletedTaskItem(context, task)),
      ],
    );
  }

  Widget _buildCompletedTaskItem(BuildContext context, Task task) {
    final theme = Theme.of(context);

    // Kategori Ikon dan Warna
    final Map<String, IconData> categoryIcons = {
      'Development': Icons.code,
      'Meeting': Icons.people,
      'Design': Icons.design_services,
      'Marketing': Icons.campaign,
      'Sports': Icons.sports_basketball,
      'Default': Icons.task,
    };

    final icon = categoryIcons[task.category] ?? categoryIcons['Default']!;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.lineThrough, // Coret teks
            color: Colors.grey,
          ),
        ),
        subtitle: Text(
          'Completed on: ${DateFormat.yMMMd().format(task.date)}',
          style: const TextStyle(color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.check_circle,
          color: Colors.green,
        ),
      ),
    );
  }
}