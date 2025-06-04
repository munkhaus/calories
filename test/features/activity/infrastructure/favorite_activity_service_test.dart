import 'package:flutter_test/flutter_test.dart';
import 'package:your_project_name/features/activity/domain/favorite_activity_model.dart'; // Placeholder
import 'package:your_project_name/features/activity/infrastructure/favorite_activity_service.dart'; // Placeholder
import 'package:your_project_name/core/domain/result.dart'; // Placeholder
import 'package:your_project_name/features/activity/domain/user_activity_log_model.dart'; // Placeholder
// Other necessary placeholder enums and models will be defined below

void main() {
  late FavoriteActivityService service;

  // Helper to create a FavoriteActivityModel with specific fields for testing
  FavoriteActivityModel createTestFavorite({
    String id = '',
    String activityName = 'Test Activity',
    ActivityInputType inputType = ActivityInputType.duration,
    ActivityIntensity intensity = ActivityIntensity.moderate,
    int calories = 100,
    int durationMinutes = 30,
    double? distanceKm,
    DateTime? lastUsed,
    int usageCount = 0,
    String activityId = 'test_act_id',
  }) {
    return FavoriteActivityModel(
      id: id.isEmpty ? DateTime.now().millisecondsSinceEpoch.toString() : id,
      activityId: activityId,
      activityName: activityName,
      emoji: '😊',
      inputType: inputType,
      durationMinutes: durationMinutes,
      distanceKm: distanceKm,
      calories: calories,
      intensity: intensity,
      notes: 'Test notes',
      createdAt: DateTime.now().subtract(Duration(days: 1)),
      lastUsed: lastUsed ?? DateTime.now(),
      usageCount: usageCount,
      activityMetValue: 5.0,
    );
  }

  setUp(() {
    service = FavoriteActivityService();
    FavoriteActivityService.clearAllFavoritesStatic(); // Clear static list before each test
  });

  group('FavoriteActivityService', () {
    group('getFavorites()', () {
      test('should return empty list when no favorites exist', () async {
        final result = await service.getFavorites();
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isEmpty);
      });

      test('should return added favorites, sorted by lastUsed descending', () async {
        final fav1 = createTestFavorite(activityName: 'Run', lastUsed: DateTime(2023, 1, 1));
        final fav2 = createTestFavorite(activityName: 'Walk', lastUsed: DateTime(2023, 1, 3));
        final fav3 = createTestFavorite(activityName: 'Swim', lastUsed: DateTime(2023, 1, 2));

        await service.addToFavorites(fav1);
        await service.addToFavorites(fav2);
        await service.addToFavorites(fav3);

        final result = await service.getFavorites();
        final favorites = result.getOrNull();

        expect(favorites, isNotNull);
        expect(favorites!.length, 3);
        expect(favorites[0].activityName, 'Walk'); // fav2 - most recent
        expect(favorites[1].activityName, 'Swim'); // fav3
        expect(favorites[2].activityName, 'Run');  // fav1 - oldest
      });
    });

    group('addToFavorites()', () {
      test('should add a new valid favorite and return Success', () async {
        final fav = createTestFavorite(activityName: 'Yoga');
        final result = await service.addToFavorites(fav);

        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()!.activityName, 'Yoga');
        expect(FavoriteActivityService.favoriteCount, 1);

        final retrieved = await service.getFavoriteById(result.getOrNull()!.id);
        expect(retrieved.isSuccess, isTrue);
        expect(retrieved.getOrNull()?.activityName, 'Yoga');
      });

      test('should return Failure(alreadyExists) if favorite with same name, type, intensity exists', () async {
        final fav1 = createTestFavorite(activityName: 'Cycling', inputType: ActivityInputType.distance, intensity: ActivityIntensity.moderate);
        await service.addToFavorites(fav1);

        final fav2 = createTestFavorite(activityName: 'Cycling', inputType: ActivityInputType.distance, intensity: ActivityIntensity.moderate, calories: 200); // Same identifying props
        final result = await service.addToFavorites(fav2);

        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), FavoriteActivityError.alreadyExists);
        expect(FavoriteActivityService.favoriteCount, 1);
      });

      test('should return Failure(validation) for favorite with empty name', () async {
        final fav = createTestFavorite(activityName: '');
        final result = await service.addToFavorites(fav);

        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), FavoriteActivityError.validation);
      });

       test('should return Failure(validation) for favorite with zero calories', () async {
        final fav = createTestFavorite(calories: 0);
        final result = await service.addToFavorites(fav);

        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), FavoriteActivityError.validation);
      });
    });

    group('removeFromFavorites()', () {
      test('should remove an existing favorite and return Success(true)', () async {
        final fav = createTestFavorite(activityName: 'Hiking');
        final addResult = await service.addToFavorites(fav);
        final favId = addResult.getOrNull()!.id;

        final removeResult = await service.removeFromFavorites(favId);
        expect(removeResult.isSuccess, isTrue);
        expect(removeResult.getOrNull(), isTrue);
        expect(FavoriteActivityService.favoriteCount, 0);

        final getResult = await service.getFavoriteById(favId);
        expect(getResult.isFailure, isTrue);
      });

      test('should return Failure(notFound) for non-existent ID', () async {
        final result = await service.removeFromFavorites('non_existent_id');
        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), FavoriteActivityError.notFound);
      });
    });

    group('updateFavorite()', () {
      test('should update an existing favorite and return Success', () async {
        final fav = createTestFavorite(activityName: 'Old Name');
        final addResult = await service.addToFavorites(fav);
        final addedFav = addResult.getOrNull()!;

        final updatedFav = addedFav.copyWith(activityName: 'New Name', calories: 500);
        final updateResult = await service.updateFavorite(updatedFav);

        expect(updateResult.isSuccess, isTrue);
        expect(updateResult.getOrNull()!.activityName, 'New Name');
        expect(updateResult.getOrNull()!.calories, 500);

        final retrieved = await service.getFavoriteById(addedFav.id);
        expect(retrieved.getOrNull()!.activityName, 'New Name');
      });

      test('should return Failure(notFound) for non-existent ID', () async {
        final fav = createTestFavorite(id: 'non_existent_id', activityName: 'Ghost');
        final result = await service.updateFavorite(fav);

        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), FavoriteActivityError.notFound);
      });
    });

    group('getFavoriteById()', () {
      test('should retrieve correct favorite for existing ID', async () {
        final fav = createTestFavorite(activityName: 'Specific Fav');
        final added = (await service.addToFavorites(fav)).getOrNull()!;

        final result = await service.getFavoriteById(added.id);
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull()!.activityName, 'Specific Fav');
      });

      test('should return Failure(notFound) for non-existent ID', async () {
        final result = await service.getFavoriteById('non_existent_id');
        expect(result.isFailure, isTrue);
        expect(result.getErrorOrNull(), FavoriteActivityError.notFound);
      });
    });

    group('getMostUsedFavorites()', () {
      test('should return top N favorites sorted by usageCount then lastUsed', () async {
        final favs = [
          createTestFavorite(activityName: 'F1', usageCount: 10, lastUsed: DateTime(2023, 1, 1)), // High usage, old
          createTestFavorite(activityName: 'F2', usageCount: 5, lastUsed: DateTime(2023, 1, 5)),  // Mid usage, recent
          createTestFavorite(activityName: 'F3', usageCount: 10, lastUsed: DateTime(2023, 1, 3)), // High usage, mid date
          createTestFavorite(activityName: 'F4', usageCount: 2, lastUsed: DateTime(2023, 1, 10)),// Low usage, most recent
          createTestFavorite(activityName: 'F5', usageCount: 5, lastUsed: DateTime(2023, 1, 2)),  // Mid usage, older
          createTestFavorite(activityName: 'F6', usageCount: 1, lastUsed: DateTime(2023, 1, 11)),// Lowest usage, very recent
        ];
        for (var fav in favs) {
          await service.addToFavorites(fav);
        }

        final result = await service.getMostUsedFavorites(limit: 5);
        final mostUsed = result.getOrNull();

        expect(mostUsed, isNotNull);
        expect(mostUsed!.length, 5);
        expect(mostUsed[0].activityName, 'F3'); // usage 10, lastUsed Jan 3
        expect(mostUsed[1].activityName, 'F1'); // usage 10, lastUsed Jan 1
        expect(mostUsed[2].activityName, 'F2'); // usage 5, lastUsed Jan 5
        expect(mostUsed[3].activityName, 'F5'); // usage 5, lastUsed Jan 2
        expect(mostUsed[4].activityName, 'F4'); // usage 2, lastUsed Jan 10
      });

      test('should return fewer than N if not enough favorites exist', async () {
         final fav1 = createTestFavorite(usageCount: 1);
         await service.addToFavorites(fav1);
         final result = await service.getMostUsedFavorites(limit: 5);
         expect(result.getOrNull()!.length, 1);
      });
    });

    group('searchFavorites()', () {
      setUp(() async {
        await service.addToFavorites(createTestFavorite(activityName: 'Morning Run', lastUsed: DateTime(2023,1,1)));
        await service.addToFavorites(createTestFavorite(activityName: 'Evening Walk', lastUsed: DateTime(2023,1,3)));
        await service.addToFavorites(createTestFavorite(activityName: 'Weekend Running Session', lastUsed: DateTime(2023,1,2)));
      });

      test('with matching query, returns sorted subset', () async {
        final result = await service.searchFavorites('Run');
        final found = result.getOrNull();
        expect(found, isNotNull);
        expect(found!.length, 2);
        expect(found[0].activityName, 'Weekend Running Session'); // Jan 2
        expect(found[1].activityName, 'Morning Run');           // Jan 1
      });

      test('with non-matching query, returns empty list', () async {
        final result = await service.searchFavorites('Cycling');
        expect(result.getOrNull(), isEmpty);
      });

      test('with empty query, returns all favorites sorted by lastUsed', () async {
        final result = await service.searchFavorites('');
        final all = result.getOrNull();
        expect(all!.length, 3);
        expect(all[0].activityName, 'Evening Walk');
        expect(all[1].activityName, 'Weekend Running Session');
        expect(all[2].activityName, 'Morning Run');
      });
    });

    group('clearAllFavorites() (instance method)', () {
      test('should clear all favorites and return Success(true)', () async {
        await service.addToFavorites(createTestFavorite(activityName: 'Temp Fav 1'));
        await service.addToFavorites(createTestFavorite(activityName: 'Temp Fav 2'));
        expect(FavoriteActivityService.favoriteCount, 2);

        final result = await service.clearAllFavorites();
        expect(result.isSuccess, isTrue);
        expect(result.getOrNull(), isTrue);
        expect(FavoriteActivityService.favoriteCount, 0);

        final getResult = await service.getFavorites();
        expect(getResult.getOrNull(), isEmpty);
      });
    });
  });
}


// --- Placeholder Definitions ---
// (These would typically be imported from your actual project structure)

// Enums (simplified)
enum ActivityInputType { duration, distance }
enum ActivityIntensity { light, moderate, vigorous }
enum ActivityCategory { loeb, gang, cykling, svoemning, styrketraening, dans, yoga, andet }
enum ActivityIntensityLevel { lav, moderat, hoej }

// FavoriteActivityError
enum FavoriteActivityError {
  unknown,
  notFound,
  alreadyExists,
  validation,
  storageError,
}

// FavoriteActivityModel (simplified from previous examples)
class FavoriteActivityModel {
  final String id;
  final String activityId;
  final String activityName;
  final String emoji;
  final ActivityInputType inputType;
  final int? durationMinutes;
  final double? distanceKm;
  final int calories;
  final ActivityIntensity intensity;
  final String notes;
  final DateTime createdAt;
  final DateTime lastUsed;
  final int usageCount;
  final double activityMetValue;

  FavoriteActivityModel({
    required this.id,
    required this.activityId,
    required this.activityName,
    this.emoji = '😊',
    required this.inputType,
    this.durationMinutes,
    this.distanceKm,
    required this.calories,
    required this.intensity,
    this.notes = '',
    required this.createdAt,
    required this.lastUsed,
    this.usageCount = 0,
    this.activityMetValue = 0.0,
  });

  FavoriteActivityModel copyWith({
    String? id,
    String? activityId,
    String? activityName,
    String? emoji,
    ActivityInputType? inputType,
    int? durationMinutes,
    bool clearDurationMinutes = false,
    double? distanceKm,
    bool clearDistanceKm = false,
    int? calories,
    ActivityIntensity? intensity,
    String? notes,
    DateTime? createdAt,
    DateTime? lastUsed,
    int? usageCount,
    double? activityMetValue,
  }) {
    return FavoriteActivityModel(
      id: id ?? this.id,
      activityId: activityId ?? this.activityId,
      activityName: activityName ?? this.activityName,
      emoji: emoji ?? this.emoji,
      inputType: inputType ?? this.inputType,
      durationMinutes: clearDurationMinutes ? null : durationMinutes ?? this.durationMinutes,
      distanceKm: clearDistanceKm ? null : distanceKm ?? this.distanceKm,
      calories: calories ?? this.calories,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
      activityMetValue: activityMetValue ?? this.activityMetValue,
    );
  }
}

// UserActivityLogModel (very simplified, only if needed by FavoriteActivityModel conversion if that was part of service)
class UserActivityLogModel {
  // Basic fields...
}


// FavoriteActivityService (Placeholder Implementation)
// This uses a static list for in-memory storage, as implied by the test requirements.
class FavoriteActivityService {
  static List<FavoriteActivityModel> _favorites = [];

  // Static getter for tests to check count
  static int get favoriteCount => _favorites.length;

  // Static method to clear for test setup
  static void clearAllFavoritesStatic() {
    _favorites.clear();
  }

  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> getFavorites() async {
    // Sort by lastUsed descending
    final sortedList = List<FavoriteActivityModel>.from(_favorites)
      ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return Result.success(sortedList);
  }

  Future<Result<FavoriteActivityModel, FavoriteActivityError>> addToFavorites(FavoriteActivityModel favorite) async {
    if (favorite.activityName.isEmpty || favorite.calories <= 0) {
      return Result.failure(FavoriteActivityError.validation);
    }
    // Check for duplicates (simplified: by name, input type, and intensity)
    if (_favorites.any((f) => f.activityName == favorite.activityName && f.inputType == favorite.inputType && f.intensity == favorite.intensity)) {
      return Result.failure(FavoriteActivityError.alreadyExists);
    }
    _favorites.add(favorite);
    return Result.success(favorite);
  }

  Future<Result<bool, FavoriteActivityError>> removeFromFavorites(String id) async {
    final initialLength = _favorites.length;
    _favorites.removeWhere((fav) => fav.id == id);
    if (_favorites.length < initialLength) {
      return Result.success(true);
    }
    return Result.failure(FavoriteActivityError.notFound);
  }

  Future<Result<FavoriteActivityModel, FavoriteActivityError>> updateFavorite(FavoriteActivityModel favorite) async {
    final index = _favorites.indexWhere((fav) => fav.id == favorite.id);
    if (index != -1) {
      _favorites[index] = favorite;
      return Result.success(favorite);
    }
    return Result.failure(FavoriteActivityError.notFound);
  }

  Future<Result<FavoriteActivityModel, FavoriteActivityError>> getFavoriteById(String id) async {
    try {
      final favorite = _favorites.firstWhere((fav) => fav.id == id);
      return Result.success(favorite);
    } catch (e) {
      return Result.failure(FavoriteActivityError.notFound);
    }
  }

  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> getMostUsedFavorites({int limit = 5}) async {
    final sorted = List<FavoriteActivityModel>.from(_favorites)
      ..sort((a, b) {
        int usageCompare = b.usageCount.compareTo(a.usageCount);
        if (usageCompare != 0) return usageCompare;
        return b.lastUsed.compareTo(a.lastUsed);
      });
    return Result.success(sorted.take(limit).toList());
  }

  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> searchFavorites(String query) async {
    final lowerQuery = query.toLowerCase();
    List<FavoriteActivityModel> results;
    if (query.isEmpty) {
      results = List.from(_favorites);
    } else {
      results = _favorites.where((fav) => fav.activityName.toLowerCase().contains(lowerQuery)).toList();
    }
    results.sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    return Result.success(results);
  }

  Future<Result<bool, FavoriteActivityError>> clearAllFavorites() async {
    _favorites.clear();
    return Result.success(true);
  }
}

// Result class (simplified placeholder)
class Result<S, E> {
  final S? _value;
  final E? _error;
  final bool isSuccess;

  Result.success(this._value) : _error = null, isSuccess = true;
  Result.failure(this._error) : _value = null, isSuccess = false;

  bool get isFailure => !isSuccess;
  S? getOrNull() => _value;
  E? getErrorOrNull() => _error;
}
