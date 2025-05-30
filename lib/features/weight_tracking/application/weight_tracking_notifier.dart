import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/weight_entry_model.dart';
import '../infrastructure/weight_tracking_service.dart';

/// State klasse for weight tracking
class WeightTrackingState {
  final List<WeightEntryModel> entries;
  final WeightEntryModel? latestEntry;
  final bool isLoading;
  final String? error;
  final DateTime lastUpdate;

  const WeightTrackingState({
    this.entries = const [],
    this.latestEntry,
    this.isLoading = false,
    this.error,
    required this.lastUpdate,
  });

  WeightTrackingState copyWith({
    List<WeightEntryModel>? entries,
    WeightEntryModel? latestEntry,
    bool? isLoading,
    String? error,
    DateTime? lastUpdate,
  }) {
    return WeightTrackingState(
      entries: entries ?? this.entries,
      latestEntry: latestEntry ?? this.latestEntry,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

/// Notifier for weight tracking
class WeightTrackingNotifier extends StateNotifier<WeightTrackingState> {
  WeightTrackingNotifier() : super(WeightTrackingState(lastUpdate: DateTime.now())) {
    loadWeightEntries();
  }

  /// Indlæser alle vægt entries for brugeren
  Future<void> loadWeightEntries() async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      const userId = 1; // TODO: Get actual user ID
      final entries = await WeightTrackingService.getWeightEntries(userId);
      final latestEntry = entries.isNotEmpty ? entries.first : null;
      
      state = state.copyWith(
        entries: entries,
        latestEntry: latestEntry,
        isLoading: false,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        lastUpdate: DateTime.now(),
      );
    }
  }

  /// Tilføjer ny vægt entry
  Future<bool> addWeightEntry(WeightEntryModel entry) async {
    try {
      await WeightTrackingService.addWeightEntry(entry);
      await loadWeightEntries(); // Reload all entries
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Opdaterer eksisterende vægt entry
  Future<bool> updateWeightEntry(WeightEntryModel entry) async {
    try {
      final success = await WeightTrackingService.updateWeightEntry(entry);
      if (success) {
        await loadWeightEntries(); // Reload all entries
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Sletter vægt entry
  Future<bool> deleteWeightEntry(int entryId) async {
    try {
      final success = await WeightTrackingService.deleteWeightEntry(entryId);
      if (success) {
        await loadWeightEntries(); // Reload all entries
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// Beregner vægt ændring over en periode
  Future<double?> getWeightChangeForPeriod(DateTime startDate, DateTime endDate) async {
    try {
      const userId = 1; // TODO: Get actual user ID
      return await WeightTrackingService.getWeightChangeBetweenDates(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Henter vægt entries for en specifik periode
  Future<List<WeightEntryModel>> getEntriesForPeriod(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      const userId = 1; // TODO: Get actual user ID
      return await WeightTrackingService.getWeightEntriesForPeriod(
        userId,
        startDate,
        endDate,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return [];
    }
  }

  /// Rydder fejl state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Genindlæser data
  Future<void> refresh() async {
    await loadWeightEntries();
  }
}

/// Weight tracking provider
final weightTrackingProvider = StateNotifierProvider<WeightTrackingNotifier, WeightTrackingState>((ref) {
  return WeightTrackingNotifier();
});

/// Helper providers
final latestWeightProvider = Provider<WeightEntryModel?>((ref) {
  return ref.watch(weightTrackingProvider).latestEntry;
});

final weightEntriesProvider = Provider<List<WeightEntryModel>>((ref) {
  return ref.watch(weightTrackingProvider).entries;
});

final isLoadingWeightProvider = Provider<bool>((ref) {
  return ref.watch(weightTrackingProvider).isLoading;
});

final weightErrorProvider = Provider<String?>((ref) {
  return ref.watch(weightTrackingProvider).error;
}); 