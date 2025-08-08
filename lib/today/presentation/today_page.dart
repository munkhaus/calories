import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/goals/domain/i_goal_service.dart';
import 'package:calories/log/domain/i_log_service.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:calories/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

class TodayPage extends StatefulWidget {
  const TodayPage({super.key});

  @override
  State<TodayPage> createState() => _TodayPageState();
}

class _TodayPageState extends State<TodayPage> {
  late final ILogService _logService;
  late final IGoalService _goalService;
  late String _today;
  List<FoodEntry> _entries = <FoodEntry>[];

  @override
  void initState() {
    super.initState();
    _logService = getIt<ILogService>();
    _goalService = getIt<IGoalService>();
    _today = isoDateFromDateTime(DateTime.now());
    _refresh();
  }

  void _refresh() {
    setState(() {
      _entries = _logService.getEntriesByDate(_today);
    });
  }

  int get _totalKcal =>
      _entries.fold<int>(0, (int s, FoodEntry e) => s + e.calories);

  @override
  Widget build(BuildContext context) {
    final int? target = _goalService.getGoal()?.targetCalories;
    final int remaining = target != null ? (target - _totalKcal) : 0;
    return ListView(
      padding: const EdgeInsets.all(KSizes.margin4x),
      children: <Widget>[
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Today: $_today'),
              const SizedBox(height: 8),
              Text('Total kcal: $_totalKcal'),
              if (target != null)
                Text('Target: $target  Remaining: $remaining'),
            ],
          ),
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('Meals'),
              const SizedBox(height: 8),
              if (_entries.isEmpty) const Text('No entries yet'),
              for (final FoodEntry e in _entries)
                ListTile(
                  title: Text(e.name),
                  subtitle: Text('${e.mealType.name} • ${e.calories} kcal'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await _logService.deleteEntry(e.id);
                      _refresh();
                    },
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    // Quick add demo entry
                    final DateTime now = DateTime.now();
                    final FoodEntry entry = FoodEntry(
                      id: 'quick_${now.microsecondsSinceEpoch}',
                      date: _today,
                      dateTime: now,
                      mealType: MealType.snack,
                      name: 'Quick snack',
                      calories: 150,
                    );
                    await _logService.addEntry(entry);
                    _refresh();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Quick add 150 kcal snack'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
