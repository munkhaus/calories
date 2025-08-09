import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/domain/models/goal.dart';
import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:calories/goals/domain/i_goal_service.dart';
import 'package:flutter/material.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  late final IGoalService _goals;
  final TextEditingController _targetCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _goals = getIt<IGoalService>();
    final Goal? g = _goals.getGoal();
    if (g != null) _targetCtrl.text = g.targetCalories.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ListView(
        padding: const EdgeInsets.all(KSizes.margin4x),
        children: <Widget>[
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Daily target (kcal)'),
                const SizedBox(height: 8),
                TextField(
                  controller: _targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: FilledButton(
                    onPressed: () async {
                      final int? kcal = int.tryParse(_targetCtrl.text.trim());
                      if (kcal == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Enter a number')),
                        );
                        return;
                      }
                      final Goal? existing = _goals.getGoal();
                      final Goal g = Goal(
                        id: existing?.id ?? 'g1',
                        startDate: existing?.startDate ?? DateTime.now(),
                        mode: existing?.mode ?? GoalMode.maintain,
                        targetCalories: kcal,
                      );
                      await _goals.saveGoal(g);
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Saved goal')),
                      );
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
