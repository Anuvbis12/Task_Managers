// File: home_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utility/auth_screen.dart';
import '../task/completed_tasks_page.dart';
import '../utility/settings_page.dart';
import '../task/task_model.dart';
import '../notification/notification_model.dart';
import '../notification/notifications_page.dart';
import '../utility/app_theme.dart';
import '../models/user_model.dart';
import '../task/task_detail_page.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final VoidCallback toggleTheme;
  const HomePage({super.key, required this.userName, required this.userEmail, required this.toggleTheme});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedSidebarIndex = 0;
  late User _currentUser;
  final _searchController = TextEditingController();

  bool _isCalendarVisible = true;
  DateTime _displayedMonth = DateTime.now();
  DateTime? _selectedDay;
  late List<TaskBase> _selectedEvents;

  // --- POLYMORPHISM: Menggunakan List<TaskBase> untuk menampung berbagai jenis tugas ---
  final List<TaskBase> _tasks = [
    Task(title: 'Determine meeting schedule', category: 'Development', date: DateTime.now(), description: 'System Analyst', duration: '28 Nov'),
    Task(title: 'Personal branding', category: 'Marketing', date: DateTime.now().add(const Duration(days: 1)), description: 'Marketing Team', duration: '28 Nov'),
    SimpleTask(title: 'Quick Standup Meeting', isCompleted: true), // Contoh SimpleTask
    Task(title: 'UI UX', category: 'Design', date: DateTime.now().add(const Duration(days: 3)), description: 'Design Team', duration: '30 Nov'),
    Task(title: 'Fixing Error Payment', category: 'Development', date: DateTime.now().add(const Duration(days: 3))),
    Task(title: 'Slicing UI', category: 'Development', date: DateTime.now().add(const Duration(days: 5)), description: 'Programmer'),
  ];
  final List<AppNotification> _notifications = [
    AppNotification(id: '1', title: 'Task Reminder', message: 'Finish UI Design task!', timestamp: DateTime.now().subtract(const Duration(minutes: 20)))
  ];

  @override
  void initState() {
    super.initState();
    _currentUser = User(fullName: widget.userName, email: widget.userEmail, password: "password");
    _searchController.addListener(() => setState(() {}));

    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _selectedEvents = _getEventsForDay(_selectedDay!);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- Fungsi Logika ---
  List<TaskBase> _getEventsForDay(DateTime day) {
    return _tasks.where((task) {
      if (task is Task) { // Hanya Task yang punya properti date
        return DateUtils.isSameDay(task.date, day);
      }
      return false;
    }).toList();
  }

  void _onDaySelected(DateTime day) => setState(() { _selectedDay = day; _selectedEvents = _getEventsForDay(day); });
  void _changeMonth(int increment) => setState(() => _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + increment, 1));
  void _addTask(Task newTask) => setState(() {
    _tasks.add(newTask);
    if (_selectedDay != null && DateUtils.isSameDay(newTask.date, _selectedDay!)) {
      _selectedEvents = _getEventsForDay(_selectedDay!);
    }
  });

  void _editTask(Task updatedTask) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        if (_selectedDay != null) {
          _selectedEvents = _getEventsForDay(_selectedDay!);
        }
      }
    });
  }

  void _toggleTaskCompletion(TaskBase task) {
     setState(() {
      task.toggleComplete(); // Menggunakan metode dari TaskBase
      if (task is Task && task.isCompleted) {
         _notifications.add(AppNotification(id: UniqueKey().toString(), title: 'Task Completed!', message: 'You have completed: "${task.title}".', timestamp: DateTime.now()));
      }
    });
  }


  void _deleteTask(TaskBase task) {
    setState(() {
      _tasks.removeWhere((t) => t.id == task.id);
      if (_selectedDay != null) {
        _selectedEvents = _getEventsForDay(_selectedDay!);
      }
    });
  }


  // --- UI BUILDERS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: _buildDesktopSidebar(),
          ),
          Expanded(
            flex: _isCalendarVisible ? 3 : 5,
            child: _getCurrentPageWidget(),
          ),
          if (_isCalendarVisible)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 24, 24, 24),
                child: _buildCalendarColumn(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _getCurrentPageWidget() {
    switch (_selectedSidebarIndex) {
      case 1: return NotificationsPage(notifications: _notifications, onMarkAsRead: (id) => setState(() => _notifications.firstWhere((n) => n.id == id).isRead = true), onClearAll: () => setState(() => _notifications.clear()));
      case 2: return CompletedTasksPage(allTasks: _tasks.whereType<Task>().toList()); // Kirim hanya Task
      case 3:
        return SettingsPage(
          currentUser: _currentUser,
          toggleTheme: widget.toggleTheme,
          onUserUpdated: (updatedUser) {
            setState(() {
              _currentUser = updatedUser;
            });
          },
          onLogout: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => AuthScreen(toggleTheme: widget.toggleTheme)),
                (route) => false,
          ),
        );
      case 0:
      default: return _buildMainContentPage();
    }
  }

  Widget _buildDesktopSidebar() {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
                radius: 24,
                backgroundColor: theme.colorScheme.primary.withAlpha(51),
                child: Text(
                    _currentUser.fullName.isNotEmpty ? _currentUser.fullName[0].toUpperCase() : '?',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)
                )
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentUser.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(_currentUser.email, style: theme.textTheme.bodySmall),
                  ]
              ),
            ),
          ]),
          const SizedBox(height: 24),
          _buildSidebarNavItem(Icons.home_outlined, 'Home', 0),
          _buildSidebarNavItem(Icons.notifications_outlined, 'Notifications', 1),
          _buildSidebarNavItem(Icons.task_alt_outlined, 'Task', 2),
          const Spacer(),
          _buildSidebarNavItem(Icons.settings_outlined, 'Settings', 3),
          Text('2025 JKW licence', style: theme.textTheme.bodySmall?.copyWith(color: theme.textTheme.bodySmall?.color?.withAlpha(153))),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(IconData icon, String title, int index) {
    final isSelected = _selectedSidebarIndex == index;
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => setState(() => _selectedSidebarIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withAlpha(26) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          Icon(icon, color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodySmall?.color),
          const SizedBox(width: 12),
          Text(title, style: theme.textTheme.titleMedium?.copyWith(color: isSelected ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ]),
      ),
    );
  }

  Widget _buildMainContentPage() {
    final theme = Theme.of(context);

    _tasks.sort((a, b) {
      if (a is Task && b is Task) {
        return a.orderIndex.compareTo(b.orderIndex);
      }
      return 0;
    });

    final allPendingTasks = _tasks.where((t) => !t.isCompleted).toList();
    final highlightTasks = allPendingTasks.whereType<Task>().take(3).toList();
    final filteredWeeklyTasks = allPendingTasks.where((task) {
      final query = _searchController.text.toLowerCase();
      if (query.isEmpty) return true;
      final title = task.title.toLowerCase();
      final description = (task is Task) ? task.description?.toLowerCase() ?? '' : '';
      return title.contains(query) || description.contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Text(
            'Selamat datang, ${widget.userName}!',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        hintText: 'Search Task or Description...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true,
                        fillColor: theme.cardColor
                    )
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(
                  _isCalendarVisible ? Icons.calendar_month : Icons.calendar_month_outlined,
                  color: theme.colorScheme.primary,
                ),
                tooltip: _isCalendarVisible ? 'Sembunyikan Kalender' : 'Tampilkan Kalender',
                onPressed: () => setState(() => _isCalendarVisible = !_isCalendarVisible),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Text(DateFormat('d MMMM y').format(DateTime.now()), style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: highlightTasks.length,
            itemBuilder: (context, index) {
              final task = highlightTasks[index];
              return Container(
                width: 250,
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: _getCategoryColor(task.category), borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(task.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(task.description ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(onPressed: () => _toggleTaskCompletion(task), style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: _getCategoryColor(task.category)), child: const Text('Mark as Done', style: TextStyle(fontWeight: FontWeight.bold))),
                  ),
                ]),
              );
            },
          ),
        ),
        const SizedBox(height: 30),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Weekly Task', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              ElevatedButton.icon(onPressed: () => _showAddTaskDialog(context), icon: const Icon(Icons.add, size: 18), label: const Text('New Task')),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            itemCount: filteredWeeklyTasks.length,
            itemBuilder: (context, index){
              final task = filteredWeeklyTasks[index];
              return Card(
                key: ValueKey(task.id),
                child: ListTile(
                  onTap: () {
                    if (task is Task) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TaskDetailPage(
                          task: task,
                          onTaskUpdated: (updatedTask) {
                            _editTask(updatedTask);
                          },
                        )),
                      );
                    }
                  },
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: Icon(task is Task ? _getCategoryIcon(task.category) : Icons.check_circle_outline),
                  ),
                  title: Text(task.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                  subtitle: Text(task.getDetails(), style: theme.textTheme.bodySmall),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        if (task is Task) _showEditTaskDialog(context, task);
                      } else if (value == 'delete') {
                        _showDeleteConfirmationDialog(context, task);
                      }
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      if (task is Task)
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                          ),
                        ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline, color: Colors.red),
                          title: Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                
                final TaskBase taskToMove = filteredWeeklyTasks.removeAt(oldIndex);
                filteredWeeklyTasks.insert(newIndex, taskToMove);

                if (taskToMove is Task) {
                  double newOrderIndex;
                  final reorderedTasks = filteredWeeklyTasks.whereType<Task>().toList();
                  final currentPositionInTasks = reorderedTasks.indexWhere((t) => t.id == taskToMove.id);

                  if (reorderedTasks.length <= 1) {
                    newOrderIndex = 1.0;
                  } else if (currentPositionInTasks == 0) {
                    newOrderIndex = reorderedTasks[1].orderIndex - 1.0;
                  } else if (currentPositionInTasks == reorderedTasks.length - 1) {
                    newOrderIndex = reorderedTasks[reorderedTasks.length - 2].orderIndex + 1.0;
                  } else {
                    final prevTask = reorderedTasks[currentPositionInTasks - 1];
                    final nextTask = reorderedTasks[currentPositionInTasks + 1];
                    newOrderIndex = (prevTask.orderIndex + nextTask.orderIndex) / 2.0;
                  }

                  final updatedTask = taskToMove.copyWith(orderIndex: newOrderIndex);
                  final originalTaskIndex = _tasks.indexWhere((t) => t.id == updatedTask.id);
                  if (originalTaskIndex != -1) {
                    _tasks[originalTaskIndex] = updatedTask;
                  }
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCalendarColumn() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withAlpha(13), spreadRadius: 1, blurRadius: 10)]),
      child: Column(
        children: [
          _buildCalendarHeader(),
          const SizedBox(height: 16),
          _buildDayOfWeekLabels(),
          const SizedBox(height: 8),
          _buildCalendarGrid(),
          const SizedBox(height: 16),
          const Divider(),
          Text("Acara pada ${DateFormat.yMMMd().format(_selectedDay!)}", style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          _buildEventList(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => _changeMonth(-1)),
        Text(DateFormat('MMMM yyyy').format(_displayedMonth), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => _changeMonth(1)),
      ],
    );
  }

  Widget _buildDayOfWeekLabels() {
    return Row(
      children: ['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day) => Expanded(
        child: Center(child: Text(day, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodySmall?.color))),
      )).toList(),
    );
  }

  Widget _buildCalendarGrid() {
    final theme = Theme.of(context);
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final dayOffset = (firstDayOfMonth.weekday % 7);
    final daysInMonth = DateUtils.getDaysInMonth(_displayedMonth.year, _displayedMonth.month);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
      itemCount: daysInMonth + dayOffset,
      itemBuilder: (context, index) {
        if (index < dayOffset) return Container();

        final dayNumber = index - dayOffset + 1;
        final currentDate = DateTime(_displayedMonth.year, _displayedMonth.month, dayNumber);
        final isSelected = _selectedDay != null && DateUtils.isSameDay(currentDate, _selectedDay!);
        final isToday = DateUtils.isSameDay(currentDate, DateTime.now());

        return GestureDetector(
          onTap: () => _onDaySelected(currentDate),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: isSelected ? theme.colorScheme.primary : (isToday ? theme.colorScheme.primary.withAlpha(51) : Colors.transparent),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$dayNumber',
                style: TextStyle(
                  color: isSelected ? Colors.white : (isToday ? theme.colorScheme.primary : theme.textTheme.bodyLarge?.color),
                  fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventList() {
    return Expanded(
      child: _selectedEvents.isEmpty
          ? Center(child: Text("Tidak ada acara.", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)))
          : ListView.builder(
        itemCount: _selectedEvents.length,
        itemBuilder: (context, index) {
          final event = _selectedEvents[index];
          if (event is Task) {
            return Card(
              elevation: 0,
              child: ListTile(
                leading: Icon(Icons.circle, color: _getCategoryColor(event.category), size: 12),
                title: Text(event.title),
                dense: true,
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedCategory;
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateInDialog) => AlertDialog(
          title: const Text('Add New Task'),
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
                const SizedBox(height: 16),
                ListTile(
                  title: Text(selectedDate == null ? 'Select Date' : DateFormat.yMMMd().format(selectedDate!)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
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
                  _addTask(Task(
                    title: titleController.text.trim(),
                    category: selectedCategory!,
                    date: selectedDate!,
                    description: descriptionController.text.trim(),
                  ));
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditTaskDialog(BuildContext context, Task task) {
    final titleController = TextEditingController(text: task.title);
    final descriptionController = TextEditingController(text: task.description);
    String? selectedCategory = task.category;
    DateTime? selectedDate = task.date;

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
                  final updatedTask = Task(
                    title: titleController.text.trim(),
                    category: selectedCategory!,
                    date: selectedDate!,
                    description: descriptionController.text.trim(),
                    id: task.id,
                    isCompleted: task.isCompleted,
                    orderIndex: task.orderIndex,
                  );
                  _editTask(updatedTask);
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

  void _showDeleteConfirmationDialog(BuildContext context, TaskBase task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _deleteTask(task);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task "${task.title}" deleted.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Development': return AppTheme.primaryColor;
      case 'Marketing': return AppTheme.accentRed;
      case 'Design': return AppTheme.accentGrey;
      default: return Colors.orange;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Development': return Icons.code;
      case 'Marketing': return Icons.campaign;
      case 'Design': return Icons.design_services;
      default: return Icons.task;
    }
  }
}
