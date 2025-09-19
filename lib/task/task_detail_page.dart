
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'task_model.dart';
import '../utility/app_theme.dart';

class TaskDetailPage extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;

  const TaskDetailPage({super.key, required this.task, required this.onTaskUpdated});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Task _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  void _toggleCompletion() {
    final updatedTask = _task.copyWith(isCompleted: !_task.isCompleted);
    setState(() {
      _task = updatedTask;
    });
    widget.onTaskUpdated(updatedTask);
  }

  void _showEditTaskDialog(BuildContext context) {
    final titleController = TextEditingController(text: _task.title);
    final descriptionController = TextEditingController(text: _task.description);
    String? selectedCategory = _task.category;
    DateTime? selectedDate = _task.date;
    TaskPriority selectedPriority = _task.priority;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInDialog) => AlertDialog(
          title: const Text('Edit Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title'), autofocus: true),
                const SizedBox(height: 8),
                TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Category'),
                  value: selectedCategory,
                  items: ['Development', 'Marketing', 'Design', 'Other'].map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (value) => setStateInDialog(() => selectedCategory = value),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<TaskPriority>(
                  decoration: const InputDecoration(labelText: 'Priority'),
                  value: selectedPriority,
                  items: TaskPriority.values.map((p) => DropdownMenuItem(value: p, child: Text(p.toString().split('.').last))).toList(),
                  onChanged: (value) => setStateInDialog(() => selectedPriority = value!),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text(selectedDate == null ? 'Select Date' : DateFormat.yMMMd().format(selectedDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: selectedDate ?? DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2030));
                    if (date != null) setStateInDialog(() => selectedDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && selectedCategory != null && selectedDate != null) {
                  final updatedTask = _task.copyWith(
                    title: titleController.text.trim(),
                    description: descriptionController.text.trim(),
                    category: selectedCategory,
                    date: selectedDate,
                    priority: selectedPriority,
                  );
                  setState(() {
                    _task = updatedTask;
                  });
                  widget.onTaskUpdated(updatedTask);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(_task.category);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _task.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.brightness == Brightness.dark ? Colors.white : Colors.black,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [categoryColor.withOpacity(0.6), categoryColor.withOpacity(0.2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _task.category,
                          style: theme.textTheme.labelLarge?.copyWith(color: categoryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildPriorityIndicator(theme, _task.priority),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(theme, Icons.calendar_today_outlined, 'Date', DateFormat.yMMMMd().format(_task.date)),
                  const SizedBox(height: 16),
                  _buildDetailRow(theme, Icons.description_outlined, 'Description', _task.description ?? 'No description provided.'),
                  const SizedBox(height: 16),
                  _buildStatusIndicator(theme, _task.isCompleted),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: theme.textTheme.bodySmall?.color, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: theme.textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityIndicator(ThemeData theme, TaskPriority priority) {
    final Color priorityColor;
    final String priorityText;
    switch (priority) {
      case TaskPriority.High:
        priorityColor = Colors.red;
        priorityText = 'High';
        break;
      case TaskPriority.Medium:
        priorityColor = Colors.orange;
        priorityText = 'Medium';
        break;
      case TaskPriority.Low:
      default:
        priorityColor = Colors.green;
        priorityText = 'Low';
        break;
    }
    return Row(
      children: [
        Icon(Icons.flag_outlined, color: priorityColor, size: 18),
        const SizedBox(width: 4),
        Text(priorityText, style: theme.textTheme.bodyMedium?.copyWith(color: priorityColor, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildStatusIndicator(ThemeData theme, bool isCompleted) {
    return Row(
      children: [
        Icon(
          isCompleted ? Icons.check_circle_outline : Icons.radio_button_unchecked_outlined,
          color: isCompleted ? Colors.green : theme.textTheme.bodySmall?.color,
          size: 20,
        ),
        const SizedBox(width: 16),
        Text(
          isCompleted ? 'Completed' : 'Pending',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isCompleted ? Colors.green : theme.textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: Icon(_task.isCompleted ? Icons.undo_outlined : Icons.check_circle_outline),
            label: Text(_task.isCompleted ? 'Mark as Pending' : 'Mark as Completed'),
            onPressed: _toggleCompletion,
            style: ElevatedButton.styleFrom(
              backgroundColor: _task.isCompleted ? Colors.grey : Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit'),
                onPressed: () => _showEditTaskDialog(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                label: const Text('Delete', style: TextStyle(color: Colors.red)),
                onPressed: () {
                  // TODO: Implement delete functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Delete functionality not implemented yet.')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Development':
        return AppTheme.primaryColor;
      case 'Marketing':
        return AppTheme.accentRed;
      case 'Design':
        return AppTheme.accentGrey;
      default:
        return Colors.orange;
    }
  }
}
