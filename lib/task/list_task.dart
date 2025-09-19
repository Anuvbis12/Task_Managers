import 'task_model.dart';

final List<Task> initialTasks = [
  Task(title: 'Determine meeting schedule', category: 'Development', date: DateTime.now(), description: 'System Analyst', duration: '28 Nov'),
  Task(title: 'Personal branding', category: 'Marketing', date: DateTime.now().add(const Duration(days: 1)), description: 'Marketing Team', duration: '28 Nov'),
  Task(title: 'UI UX', category: 'Design', date: DateTime.now().add(const Duration(days: 3)), description: 'Design Team', duration: '30 Nov'),
  Task(title: 'Fixing Error Payment', category: 'Development', date: DateTime.now().add(const Duration(days: 3))),
  Task(title: 'Slicing UI', category: 'Development', date: DateTime.now().add(const Duration(days: 5)), description: 'Programmer'),
];
