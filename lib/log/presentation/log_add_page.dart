import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/log/domain/i_log_service.dart';
import 'package:calories/core/utils/date_utils.dart';
import 'package:flutter/material.dart';

class LogAddPage extends StatefulWidget {
  const LogAddPage({super.key, this.entryId});

  final String? entryId;

  @override
  State<LogAddPage> createState() => _LogAddPageState();
}

class _LogAddPageState extends State<LogAddPage> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _kcalCtrl = TextEditingController();
  MealType _meal = MealType.snack;
  late final ILogService _logService;

  @override
  void initState() {
    super.initState();
    _logService = getIt<ILogService>();
    if (widget.entryId != null) {
      final FoodEntry? e = _logService.getEntryById(widget.entryId!);
      if (e != null) {
        _nameCtrl.text = e.name;
        _kcalCtrl.text = e.calories.toString();
        _meal = e.mealType;
      }
    }
  }

  Future<void> _save() async {
    final String name = _nameCtrl.text.trim();
    final int? kcal = int.tryParse(_kcalCtrl.text.trim());
    if (name.isEmpty || kcal == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter name and kcal')));
      return;
    }
    final DateTime now = DateTime.now();
    final FoodEntry entry = FoodEntry(
      id: widget.entryId ?? 'add_${now.microsecondsSinceEpoch}',
      date: isoDateFromDateTime(now),
      dateTime: now,
      mealType: _meal,
      name: name,
      calories: kcal,
    );
    await _logService.addEntry(entry);
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.entryId == null ? 'Add food' : 'Edit food')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Item name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _kcalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Calories (kcal)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<MealType>(
              value: _meal,
              items: MealType.values
                  .map(
                    (m) => DropdownMenuItem<MealType>(
                      value: m,
                      child: Text(m.name),
                    ),
                  )
                  .toList(),
              onChanged: (m) => setState(() => _meal = m ?? MealType.snack),
              decoration: const InputDecoration(
                labelText: 'Meal',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _save,
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
