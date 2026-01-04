// goal_model.dart
import 'package:flutter/material.dart';

enum GoalStatus { notStarted, inProgress, completed }
enum GoalPriority { low, medium, high }

class SubGoal {
  String id;
  String title;
  bool isDone;

  SubGoal({required this.id, required this.title, this.isDone = false});
}

class Goal {
  String id;
  String title;
  String description;
  DateTime? dueDate;
  String category;
  GoalPriority priority;
  GoalStatus status;
  double progress;
  List<SubGoal> subGoals;
  IconData icon;
  List<String> tags;
  List<String> comments;
  List<String> history;
  String? recurrence;

  Goal({
    required this.title,
    this.description = '',
    this.dueDate,
    this.category = 'General',
    this.priority = GoalPriority.medium,
    this.status = GoalStatus.notStarted,
    this.progress = 0.0,
    this.subGoals = const [],
    this.icon = Icons.flag,
    this.tags = const [],
    this.comments = const [],
    this.history = const [],
    this.recurrence,
  }) : id = UniqueKey().toString();

  Goal copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    String? category,
    GoalPriority? priority,
    GoalStatus? status,
    double? progress,
    List<SubGoal>? subGoals,
    IconData? icon,
    List<String>? tags,
    List<String>? comments,
    List<String>? history,
    String? recurrence,
  }) {
    return Goal(
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      subGoals: subGoals ?? this.subGoals,
      icon: icon ?? this.icon,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      history: history ?? this.history,
      recurrence: recurrence ?? this.recurrence,
    )..id = this.id;
  }
}
