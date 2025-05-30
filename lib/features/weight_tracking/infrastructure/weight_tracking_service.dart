import '../domain/weight_entry_model.dart';

/// Service til håndtering af vægt tracking data
class WeightTrackingService {
  // Mock data for demonstration - i rigtig app ville dette bruge SQLite
  static final List<WeightEntryModel> _weightEntries = <WeightEntryModel>[];

  /// Tilføjer ny vægt entry
  static Future<int> addWeightEntry(WeightEntryModel entry) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final newId = _weightEntries.length + 1;
    final entryWithId = entry.copyWith(
      entryId: newId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _weightEntries.add(entryWithId);
    
    // Sort by date (newest first)
    _weightEntries.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    return newId;
  }

  /// Henter alle vægt entries for en bruger
  static Future<List<WeightEntryModel>> getWeightEntries(int userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    return _weightEntries
        .where((entry) => entry.userId == userId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt)); // Newest first
  }

  /// Henter vægt entries for en specifik periode
  static Future<List<WeightEntryModel>> getWeightEntriesForPeriod(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    return _weightEntries.where((entry) {
      if (entry.userId != userId) return false;
      
      final entryDate = DateTime(
        entry.recordedAt.year,
        entry.recordedAt.month,
        entry.recordedAt.day,
      );
      
      return entryDate.isAfter(startDate.subtract(const Duration(days: 1))) &&
             entryDate.isBefore(endDate.add(const Duration(days: 1)));
    }).toList()
      ..sort((a, b) => a.recordedAt.compareTo(b.recordedAt)); // Oldest first for charts
  }

  /// Henter seneste vægt entry for en bruger
  static Future<WeightEntryModel?> getLatestWeightEntry(int userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final entries = _weightEntries
        .where((entry) => entry.userId == userId)
        .toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    return entries.isNotEmpty ? entries.first : null;
  }

  /// Henter vægt entry for en specifik dato
  static Future<WeightEntryModel?> getWeightEntryForDate(
    int userId,
    DateTime date,
  ) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final targetDate = DateTime(date.year, date.month, date.day);
    
    return _weightEntries.firstWhere(
      (entry) {
        if (entry.userId != userId) return false;
        
        final entryDate = DateTime(
          entry.recordedAt.year,
          entry.recordedAt.month,
          entry.recordedAt.day,
        );
        
        return entryDate.isAtSameMomentAs(targetDate);
      },
      orElse: () => throw StateError('No weight entry found for date'),
    );
  }

  /// Opdaterer en vægt entry
  static Future<bool> updateWeightEntry(WeightEntryModel entry) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final index = _weightEntries.indexWhere((e) => e.entryId == entry.entryId);
    if (index >= 0) {
      _weightEntries[index] = entry.copyWith(updatedAt: DateTime.now());
      return true;
    }
    return false;
  }

  /// Sletter en vægt entry
  static Future<bool> deleteWeightEntry(int entryId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final index = _weightEntries.indexWhere((e) => e.entryId == entryId);
    if (index >= 0) {
      _weightEntries.removeAt(index);
      return true;
    }
    return false;
  }

  /// Beregner vægt forskel fra startdato til slutdato
  static Future<double?> getWeightChangeBetweenDates(
    int userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await getWeightEntriesForPeriod(userId, startDate, endDate);
    
    if (entries.length < 2) return null;
    
    final startWeight = entries.first.weightKg; // Oldest
    final endWeight = entries.last.weightKg; // Newest
    
    return endWeight - startWeight;
  }

  /// Rydder alle data (til test/demo)
  static void clearAllData() {
    _weightEntries.clear();
  }

  /// Getter til alle entries (til debugging)
  static List<WeightEntryModel> get allEntries => List.unmodifiable(_weightEntries);
} 