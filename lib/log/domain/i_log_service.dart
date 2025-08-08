import 'package:calories/core/domain/models/food_entry.dart';

abstract class ILogService {
  Future<void> addEntry(FoodEntry entry);
  List<FoodEntry> getEntriesByDate(String yyyyMmDd);
  Future<void> deleteEntry(String id);
}
