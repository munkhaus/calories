import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for den aktuelt valgte dato i appen
/// Dette bruges til at vise data for en specifik dag på tværs af alle features
class SelectedDateNotifier extends StateNotifier<DateTime> {
  SelectedDateNotifier() : super(DateTime.now()) {
    // Standardisér til midnat for konsistent dato sammenligning
    state = DateTime(state.year, state.month, state.day);
  }

  /// Ændrer den valgte dato
  void selectDate(DateTime date) {
    // Standardisér til midnat for konsistent dato sammenligning
    state = DateTime(date.year, date.month, date.day);
  }

  /// Går til næste dag
  void nextDay() {
    state = state.add(const Duration(days: 1));
  }

  /// Går til forrige dag
  void previousDay() {
    state = state.subtract(const Duration(days: 1));
  }

  /// Går til i dag
  void goToToday() {
    final today = DateTime.now();
    state = DateTime(today.year, today.month, today.day);
  }

  /// Tjekker om den valgte dato er i dag
  bool get isToday {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return state.isAtSameMomentAs(todayDate);
  }

  /// Formatter den valgte dato som string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));

    if (state.isAtSameMomentAs(today)) {
      return 'I dag';
    } else if (state.isAtSameMomentAs(yesterday)) {
      return 'I går';
    } else if (state.isAtSameMomentAs(tomorrow)) {
      return 'I morgen';
    } else {
      // Format: Onsdag 15. jan
      final weekdays = ['Mandag', 'Tirsdag', 'Onsdag', 'Torsdag', 'Fredag', 'Lørdag', 'Søndag'];
      final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
      
      final weekday = weekdays[state.weekday - 1];
      final day = state.day;
      final month = months[state.month - 1];
      
      return '$weekday $day. $month';
    }
  }

  /// Formatter dato som kort string (f.eks. "15 jan")
  String get shortFormattedDate {
    final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    return '${state.day} ${months[state.month - 1]}';
  }
}

/// Provider for den valgte dato
final selectedDateProvider = StateNotifierProvider<SelectedDateNotifier, DateTime>((ref) {
  return SelectedDateNotifier();
}); 