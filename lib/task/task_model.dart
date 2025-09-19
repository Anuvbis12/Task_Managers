// File: task_model.dart
import 'package:flutter/material.dart';

// Enum untuk mendefinisikan tingkat prioritas
enum TaskPriority {
  Low,
  Medium,
  High,
}

// --- INHERITANCE & POLYMORPHISM ---
// Kelas dasar abstrak untuk semua jenis tugas.
abstract class TaskBase {
  final String _id;
  final String _title;
  bool _isCompleted;

  TaskBase(this._id, this._title, this._isCompleted);

  // Getter untuk enkapsulasi
  String get id => _id;
  String get title => _title;
  bool get isCompleted => _isCompleted;

  set isCompleted(bool value) {
    _isCompleted = value;
  }

  // Metode abstrak untuk polimorfisme
  String getDetails();

  void toggleComplete() {
    _isCompleted = !_isCompleted;
  }
}

// --- ENCAPSULATION & INHERITANCE ---
class Task extends TaskBase {
  final String? _description;
  final String _category;
  final DateTime _date;
  final String? _duration;
  final TaskPriority _priority;
  final double _orderIndex; // Properti untuk sorting manual

  Task({
    required String title,
    String? description,
    required String category,
    required DateTime date,
    String? duration,
    bool isCompleted = false,
    TaskPriority priority = TaskPriority.Medium,
    double? orderIndex,
    String? id,
    //setter
  }) : _description = description,
       _category = category,
       _date = date,
       _duration = duration,
       _priority = priority,
       _orderIndex = orderIndex ?? DateTime.now().millisecondsSinceEpoch.toDouble(),
       super(id ?? UniqueKey().toString(), title, isCompleted);

  // Getter untuk enkapsulasi
  String? get description => _description;
  String get category => _category;
  DateTime get date => _date;
  String? get duration => _duration;
  TaskPriority get priority => _priority;
  double get orderIndex => _orderIndex;

  // --- POLYMORPHISM ---
  // Override metode dari kelas dasar
  @override
  String getDetails() {
    return 'Task: $title\nCategory: $category\nDate: $date';
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? date,
    String? duration,
    bool? isCompleted,
    TaskPriority? priority,
    double? orderIndex,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? _description,
      category: category ?? _category,
      date: date ?? _date,
      duration: duration ?? _duration,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? _priority,
      orderIndex: orderIndex ?? _orderIndex,
    );
  }
}

// Contoh lain untuk menunjukkan polimorfisme
class SimpleTask extends TaskBase {
  SimpleTask({required String title, bool isCompleted = false, String? id})
      : super(id ?? UniqueKey().toString(), title, isCompleted);

  @override
  String getDetails() {
    return 'Simple Task: $title';
  }
}

// Fungsi untuk menunjukkan polimorfisme dalam aksi
void printTaskDetails(TaskBase task) {
  print(task.getDetails());
}
