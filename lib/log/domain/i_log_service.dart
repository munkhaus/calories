import 'package:calories/core/domain/models/food_entry.dart';
import 'package:calories/log/domain/quick_item.dart';

abstract class ILogService {
  Future<void> addEntry(FoodEntry entry);
  List<FoodEntry> getEntriesByDate(String yyyyMmDd);
  Future<void> deleteEntry(String id);
  FoodEntry? getEntryById(String id);
  List<QuickItem> getRecents();
  List<QuickItem> getFavorites();
  Future<void> toggleFavorite(QuickItem item);
}
