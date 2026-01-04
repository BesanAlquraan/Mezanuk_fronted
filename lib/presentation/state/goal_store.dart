// goal_store.dart
import 'package:flutter/material.dart';
import '../../domain/models/goal_model.dart';

class GoalStore extends ChangeNotifier {
  List<Goal> _goals = [];

  List<Goal> get goals => _goals;

  List<Goal> get filteredGoals => _goals;

  void addGoal(Goal goal) {
    _goals.add(goal);
    notifyListeners();
  }

  void updateGoal(Goal updatedGoal) {
    final index = _goals.indexWhere((g) => g.id == updatedGoal.id);
    if (index != -1) {
      _goals[index] = updatedGoal;
      notifyListeners();
    }
  }

  void removeGoal(String id) {
    _goals.removeWhere((g) => g.id == id);
    notifyListeners();
  }

  void toggleStatus(String id) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final g = _goals[index];
      switch (g.status) {
        case GoalStatus.notStarted:
          g.status = GoalStatus.inProgress;
          break;
        case GoalStatus.inProgress:
          g.status = GoalStatus.completed;
          break;
        case GoalStatus.completed:
          g.status = GoalStatus.notStarted;
          break;
      }
      notifyListeners();
    }
  }

  void reorderGoals(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final goal = _goals.removeAt(oldIndex);
    _goals.insert(newIndex, goal);
    notifyListeners();
  }

  void searchGoals(String query) {
    // يمكن لاحقًا فلترة حسب النص
    notifyListeners();
  }
}
