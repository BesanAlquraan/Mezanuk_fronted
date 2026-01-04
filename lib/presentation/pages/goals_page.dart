// goals_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../state/goal_store.dart';
import '../state/settings_store.dart';
import '../../domain/models/goal_model.dart';
import '../../constants/colors.dart';

class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<GoalStore>();
    final settings = context.watch<SettingsStore>();
    final t = settings.translations;
    final currencySymbol = settings.currencySymbol;

    final goals = store.filteredGoals;

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: kAppBarColor,
        title: Text(t.of('my_goals')),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              final csv = store.goals
                  .map((g) => '${g.title},${g.description},${g.dueDate},$currencySymbol')
                  .join('\n');
              Share.share(csv, subject: t.of('my_goals'));
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: store.searchGoals,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: t.of('search_goals'),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _GoalsDashboard(store: store, t: t, currencySymbol: currencySymbol),
            const SizedBox(height: 12),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return isWide
                      ? ReorderableListView(
                          onReorder: store.reorderGoals,
                          children: goals
                              .map((g) => _GoalCard(
                                  goal: g,
                                  t: t,
                                  currencySymbol: currencySymbol,
                                  key: Key(g.id)))
                              .toList(),
                        )
                      : ListView.builder(
                          itemCount: goals.length,
                          itemBuilder: (context, index) => _GoalCard(
                              goal: goals[index],
                              t: t,
                              currencySymbol: currencySymbol),
                        );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimaryColor,
        onPressed: () => _showAddGoalDialog(context, t, store),
        child: const Icon(Icons.add, color: kTextLightColor),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, dynamic t, GoalStore store) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: kCardBackgroundColor,
          title: Text(t.of('add_goal'), style: TextStyle(color: kTextDarkColor)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: t.of('title'),
                    labelStyle: TextStyle(color: kTextDarkColor),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: t.of('description'),
                    labelStyle: TextStyle(color: kTextDarkColor),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('${t.of('due_date')}: ', style: TextStyle(color: kTextDarkColor)),
                    Text(
                      selectedDate != null
                          ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          : t.of('none'),
                      style: TextStyle(color: kTextSecondaryColor),
                    ),
                    IconButton(
                        icon: Icon(Icons.calendar_today, color: kPrimaryColor),
                        onPressed: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100));
                          if (date != null) setState(() => selectedDate = date);
                        }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(t.of('cancel'), style: TextStyle(color: kPrimaryColor))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  store.addGoal(Goal(
                    title: titleController.text,
                    description: descController.text,
                    dueDate: selectedDate,
                    subGoals: [],
                    tags: [],
                  ));
                  Navigator.pop(context);
                }
              },
              child: Text(t.of('add'), style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Goal Card ----------------
class _GoalCard extends StatelessWidget {
  final Goal goal;
  final dynamic t;
  final String currencySymbol;

  const _GoalCard({super.key, required this.goal, required this.t, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final store = context.read<GoalStore>();
    Color statusColor;
    String statusText;
    switch (goal.status) {
      case GoalStatus.notStarted:
        statusColor = kTextSecondaryColor;
        statusText = t.of('not_started');
        break;
      case GoalStatus.inProgress:
        statusColor = kCategoryOrange;
        statusText = t.of('in_progress');
        break;
      case GoalStatus.completed:
        statusColor = kCategoryGreen;
        statusText = t.of('completed');
        break;
    }

    return Card(
      color: kCardBackgroundColor,
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(goal.icon, color: statusColor, size: 30),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(goal.title,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kTextDarkColor)),
                ),
                IconButton(
                    icon: Icon(Icons.check_circle, color: statusColor),
                    onPressed: () => store.toggleStatus(goal.id))
              ],
            ),
            const SizedBox(height: 4),
            Text(goal.description, style: TextStyle(color: kTextSecondaryColor)),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: goal.progress,
              backgroundColor: kDividerColor,
              color: statusColor,
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

// ---------------- Dashboard ----------------
class _GoalsDashboard extends StatelessWidget {
  final GoalStore store;
  final dynamic t;
  final String currencySymbol;

  const _GoalsDashboard({super.key, required this.store, required this.t, required this.currencySymbol});

  @override
  Widget build(BuildContext context) {
    final total = store.goals.length;
    if (total == 0) return const SizedBox.shrink();

    final completed = store.goals.where((g) => g.status == GoalStatus.completed).length;
    final inProgress = store.goals.where((g) => g.status == GoalStatus.inProgress).length;
    final notStarted = total - completed - inProgress;

    final sections = [
      PieChartSectionData(
          value: completed.toDouble(),
          color: kCategoryGreen,
          title: t.of('completed'),
          radius: 50),
      PieChartSectionData(
          value: inProgress.toDouble(),
          color: kCategoryOrange,
          title: t.of('in_progress'),
          radius: 50),
      PieChartSectionData(
          value: notStarted.toDouble(),
          color: kTextSecondaryColor,
          title: t.of('not_started'),
          radius: 50),
    ];

    return SizedBox(
      height: 200,
      child: PieChart(PieChartData(
        sections: sections,
        pieTouchData: PieTouchData(
          touchCallback: (event, response) {
            if (response != null && response.touchedSection != null) {
              final index = response.touchedSection!.touchedSectionIndex;
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${t.of('tapped')} ${sections[index].title}')));
            }
          },
        ),
      )),
    );
  }
}
