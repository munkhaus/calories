import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:calories/log/domain/quick_item.dart';
import 'package:calories/log/domain/i_log_service.dart';
import 'package:flutter/material.dart';
import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/core/domain/models/enums.dart';
import 'package:calories/core/utils/date_utils.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  late final ILogService _logService;
  List<QuickItem> _recents = <QuickItem>[];
  List<QuickItem> _favorites = <QuickItem>[];
  Set<String> _favoriteNames = <String>{};

  @override
  void initState() {
    super.initState();
    _logService = getIt<ILogService>();
    _refresh();
  }

  void _refresh() {
    setState(() {
      _recents = _logService.getRecents();
      _favorites = _logService.getFavorites();
      _favoriteNames = _favorites.map((e) => e.name).toSet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: ListView(
        padding: const EdgeInsets.all(KSizes.margin4x),
        children: <Widget>[
          const AppCard(child: Text('Search field (placeholder)')),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('Favorites'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _favorites
                      .map(
                        (q) => FilterChip(
                          label: Text('${q.name} • ${q.calories} kcal'),
                          selected: true,
                          onSelected: (_) async {
                            await _logService.toggleFavorite(q);
                            _refresh();
                          },
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 12),
                const Text('Recents'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _recents
                      .map<Widget>((q) {
                        final bool isFavorite = _favoriteNames.contains(q.name);
                        final Widget chip = ActionChip(
                          avatar: isFavorite
                              ? const Icon(Icons.star_rounded, size: 18)
                              : null,
                          label: Text('${q.name} • ${q.calories} kcal'),
                          onPressed: () async {
                            final DateTime now = DateTime.now();
                            final FoodEntry entry = FoodEntry(
                              id: 'qa_${now.microsecondsSinceEpoch}',
                              date: isoDateFromDateTime(now),
                              dateTime: now,
                              mealType: MealType.snack,
                              name: q.name,
                              calories: q.calories,
                            );
                            await _logService.addEntry(entry);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${q.name} to today.')),
                            );
                          },
                        );
                        return GestureDetector(
                          onLongPress: () async {
                            await _logService.toggleFavorite(q);
                            if (!mounted) return;
                            _refresh();
                            final bool nowFav = !_favoriteNames.contains(q.name);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  nowFav ? 'Pinned ${q.name} to Favorites' : 'Unpinned ${q.name}',
                                ),
                              ),
                            );
                          },
                          child: chip,
                        );
                      })
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
