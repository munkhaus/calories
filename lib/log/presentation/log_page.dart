import 'package:calories/core/constants/ksizes.dart';
import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/ui/app_card.dart';
import 'package:calories/log/domain/quick_item.dart';
import 'package:calories/log/domain/i_log_service.dart';
import 'package:flutter/material.dart';

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  late final ILogService _logService;
  List<QuickItem> _recents = <QuickItem>[];
  List<QuickItem> _favorites = <QuickItem>[];

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
                      .map(
                        (q) => ActionChip(
                          label: Text('${q.name} • ${q.calories} kcal'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Quick-add ${q.name} (stub)'),
                              ),
                            );
                          },
                          onPressedLabel: 'Add',
                        ),
                      )
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
