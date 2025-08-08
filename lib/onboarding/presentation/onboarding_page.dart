import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/domain/calorie_calculator.dart';
import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/core/domain/models/goal.dart';
import 'package:calories/core/domain/models/user_profile.dart';
import 'package:calories/goals/domain/i_goal_service.dart';
import 'package:calories/profile/domain/i_profile_service.dart';
import 'package:calories/core/storage/local_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  // New: PageView-based wizard
  late final PageController _pageController;
  int _step = 0;

  // Step 1: units
  bool _metricUnits = true;

  // Step 2: demographics
  final TextEditingController _ageController = TextEditingController();
  Sex _sex = Sex.male;
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  // Step 3: activity
  ActivityLevel _activityLevel = ActivityLevel.light;

  // Step 4: goal
  GoalMode _goalMode = GoalMode.lose;
  final TextEditingController _paceController = TextEditingController(
    text: '500',
  ); // kcal/day

  String? _validationError;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _paceController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding(BuildContext context) async {
    final int age = int.tryParse(_ageController.text.trim()) ?? 0;
    final double height = double.tryParse(_heightController.text.trim()) ?? 0;
    final double weight = double.tryParse(_weightController.text.trim()) ?? 0;
    int pace = int.tryParse(_paceController.text.trim()) ?? 0;
    if (_goalMode == GoalMode.lose) pace = -pace.abs();
    if (_goalMode == GoalMode.gain) pace = pace.abs();
    if (_goalMode == GoalMode.maintain) pace = 0;

    final UserProfile profile = UserProfile(
      id: 'default',
      metricUnits: _metricUnits,
      ageYears: age,
      sex: _sex,
      heightCm: _metricUnits ? height : height * 2.54,
      weightKg: _metricUnits ? weight : weight * 0.45359237,
      activityLevel: _activityLevel,
    );

    final CalorieCalculator calculator = const CalorieCalculator();
    final int target = calculator.computeTargetCalories(
      profile: profile,
      goal: Goal(
        id: 'current',
        startDate: DateTime.now(),
        mode: _goalMode,
        targetCalories: 0, // replaced below
        paceKcalPerDay: pace,
      ),
    );

    final Goal goal = Goal(
      id: 'current',
      startDate: DateTime.now(),
      mode: _goalMode,
      targetCalories: target,
      paceKcalPerDay: pace,
    );

    await getIt<IProfileService>().saveProfile(profile);
    await getIt<IGoalService>().saveGoal(goal);
    await getIt<LocalStorage>().setOnboardingCompleted(true);
    if (mounted) context.go('/today');
  }

  bool _validateStep() {
    setState(() => _validationError = null);
    if (_step == 1) {
      final int? age = int.tryParse(_ageController.text.trim());
      final double? height = double.tryParse(_heightController.text.trim());
      final double? weight = double.tryParse(_weightController.text.trim());
      if (age == null || age < 10 || age > 100) {
        _validationError = 'Enter a valid age (10–100)';
      } else if (height == null || height < 80 || height > 250) {
        _validationError =
            'Enter a valid height (in ${_metricUnits ? 'cm' : 'in'})';
      } else if (weight == null || weight < 30 || weight > 300) {
        _validationError =
            'Enter a valid weight (in ${_metricUnits ? 'kg' : 'lb'})';
      }
    }
    if (_step == 3) {
      final int? pace = int.tryParse(_paceController.text.trim());
      if (_goalMode != GoalMode.maintain &&
          (pace == null || pace <= 0 || pace > 1000)) {
        _validationError = 'Enter a daily pace (kcal), e.g., 500';
      }
    }
    return _validationError == null;
  }

  @override
  Widget build(BuildContext context) {
    final List<Step> steps = <Step>[
      Step(
        title: const Text('Units'),
        isActive: _step >= 0,
        content: Row(
          children: <Widget>[
            Radio<bool>(
              value: true,
              groupValue: _metricUnits,
              onChanged: (bool? v) => setState(() => _metricUnits = v ?? true),
            ),
            const Text('Metric'),
            const SizedBox(width: 24),
            Radio<bool>(
              value: false,
              groupValue: _metricUnits,
              onChanged: (bool? v) => setState(() => _metricUnits = v ?? false),
            ),
            const Text('Imperial'),
          ],
        ),
      ),
      Step(
        title: const Text('Profile'),
        isActive: _step >= 1,
        content: Column(
          children: <Widget>[
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Age (years)'),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<Sex>(
              value: _sex,
              items: const <DropdownMenuItem<Sex>>[
                DropdownMenuItem(value: Sex.male, child: Text('Male')),
                DropdownMenuItem(value: Sex.female, child: Text('Female')),
              ],
              onChanged: (Sex? v) => setState(() => _sex = v ?? Sex.male),
              decoration: const InputDecoration(labelText: 'Sex'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Height (${_metricUnits ? 'cm' : 'in'})',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Weight (${_metricUnits ? 'kg' : 'lb'})',
              ),
            ),
          ],
        ),
      ),
      Step(
        title: const Text('Activity'),
        isActive: _step >= 2,
        content: DropdownButtonFormField<ActivityLevel>(
          value: _activityLevel,
          items: const <DropdownMenuItem<ActivityLevel>>[
            DropdownMenuItem(
              value: ActivityLevel.sedentary,
              child: Text('Sedentary'),
            ),
            DropdownMenuItem(
              value: ActivityLevel.light,
              child: Text('Light (1–3x/week)'),
            ),
            DropdownMenuItem(
              value: ActivityLevel.moderate,
              child: Text('Moderate (3–5x/week)'),
            ),
            DropdownMenuItem(
              value: ActivityLevel.active,
              child: Text('Active (6–7x/week)'),
            ),
            DropdownMenuItem(
              value: ActivityLevel.veryActive,
              child: Text('Very active'),
            ),
          ],
          onChanged: (ActivityLevel? v) =>
              setState(() => _activityLevel = v ?? ActivityLevel.light),
          decoration: const InputDecoration(labelText: 'Activity level'),
        ),
      ),
      Step(
        title: const Text('Goal'),
        isActive: _step >= 3,
        content: Column(
          children: <Widget>[
            DropdownButtonFormField<GoalMode>(
              value: _goalMode,
              items: const <DropdownMenuItem<GoalMode>>[
                DropdownMenuItem(
                  value: GoalMode.lose,
                  child: Text('Lose weight'),
                ),
                DropdownMenuItem(
                  value: GoalMode.maintain,
                  child: Text('Maintain'),
                ),
                DropdownMenuItem(
                  value: GoalMode.gain,
                  child: Text('Gain weight'),
                ),
              ],
              onChanged: (GoalMode? v) =>
                  setState(() => _goalMode = v ?? GoalMode.lose),
              decoration: const InputDecoration(labelText: 'Goal'),
            ),
            const SizedBox(height: 8),
            if (_goalMode != GoalMode.maintain)
              TextField(
                controller: _paceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Daily pace (kcal/day, e.g., 500)',
                ),
              ),
          ],
        ),
      ),
      Step(
        title: const Text('Review'),
        isActive: _step >= 4,
        content: _buildReview(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / steps.length,
            minHeight: 4,
          ),
        ),
      ),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: steps
            .map(
              (s) => Padding(
                padding: const EdgeInsets.all(16),
                child: s.content,
              ),
            )
            .toList(),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Row(
            children: [
              if (_step > 0)
                OutlinedButton(
                  onPressed: () {
                    setState(() => _step -= 1);
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    );
                  },
                  child: const Text('Back'),
                )
              else
                TextButton(
                  onPressed: () {
                    // Optional skip for first steps
                    setState(() => _step = steps.length - 1);
                    _pageController.jumpToPage(steps.length - 1);
                  },
                  child: const Text('Skip'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () async {
                  if (_step < steps.length - 1) {
                    if (_validateStep()) {
                      setState(() => _step += 1);
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                      );
                    }
                  } else {
                    if (_validateStep()) await _completeOnboarding(context);
                  }
                },
                child: Text(_step < steps.length - 1 ? 'Next' : 'Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReview() {
    final int age = int.tryParse(_ageController.text.trim()) ?? 0;
    final double height = double.tryParse(_heightController.text.trim()) ?? 0;
    final double weight = double.tryParse(_weightController.text.trim()) ?? 0;
    int pace = int.tryParse(_paceController.text.trim()) ?? 0;
    if (_goalMode == GoalMode.lose) pace = -pace.abs();
    if (_goalMode == GoalMode.gain) pace = pace.abs();
    if (_goalMode == GoalMode.maintain) pace = 0;

    final UserProfile profile = UserProfile(
      id: 'default',
      metricUnits: _metricUnits,
      ageYears: age,
      sex: _sex,
      heightCm: _metricUnits ? height : height * 2.54,
      weightKg: _metricUnits ? weight : weight * 0.45359237,
      activityLevel: _activityLevel,
    );
    final CalorieCalculator calculator = const CalorieCalculator();
    final int target = calculator.computeTargetCalories(
      profile: profile,
      goal: Goal(
        id: 'current',
        startDate: DateTime.now(),
        mode: _goalMode,
        targetCalories: 0,
        paceKcalPerDay: pace,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Units: ${_metricUnits ? 'Metric' : 'Imperial'}'),
        Text('Age: $age  Sex: ${_sex.name}'),
        Text(
          'Height: ${_metricUnits ? height.toStringAsFixed(0) + ' cm' : height.toStringAsFixed(0) + ' in'}',
        ),
        Text(
          'Weight: ${_metricUnits ? weight.toStringAsFixed(1) + ' kg' : weight.toStringAsFixed(1) + ' lb'}',
        ),
        Text('Activity: ${_activityLevel.name}'),
        Text(
          'Goal: ${_goalMode.name}  Pace: ${_goalMode == GoalMode.maintain ? 0 : pace.abs()} kcal/day',
        ),
        const SizedBox(height: 8),
        Text('Target calories: $target kcal/day'),
      ],
    );
  }
}
