import 'package:result_type/result_type.dart';
import '../domain/i_favorite_activity_service.dart';
import '../domain/favorite_activity_model.dart';
import '../domain/user_activity_log_model.dart';

/// Implementation of favorite activity service with in-memory storage
class FavoriteActivityService implements IFavoriteActivityService {
  // Static list to simulate database storage
  static final List<FavoriteActivityModel> _favorites = [];

  @override
  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> getFavorites() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Sort by most recently used first
      final sortedFavorites = List<FavoriteActivityModel>.from(_favorites)
        ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      
      print('⭐ FavoriteActivityService: getFavorites() returning ${sortedFavorites.length} items');
      return Success(sortedFavorites);
    } catch (e) {
      print('⭐ FavoriteActivityService: Error in getFavorites: $e');
      return Failure(FavoriteActivityError.database);
    }
  }

  @override
  Future<Result<FavoriteActivityModel, FavoriteActivityError>> addToFavorites(FavoriteActivityModel favorite) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Check if already exists (by activity name and basic properties)
      final existingIndex = _favorites.indexWhere((f) => 
        f.activityName.toLowerCase() == favorite.activityName.toLowerCase() &&
        f.inputType == favorite.inputType &&
        f.intensity == favorite.intensity);
      
      if (existingIndex >= 0) {
        print('⭐ FavoriteActivityService: Activity already exists as favorite');
        return Failure(FavoriteActivityError.alreadyExists);
      }
      
      // Validate required fields
      if (favorite.activityName.trim().isEmpty || favorite.caloriesBurned <= 0) {
        print('⭐ FavoriteActivityService: Validation failed - missing required fields');
        return Failure(FavoriteActivityError.validation);
      }
      
      _favorites.add(favorite);
      print('⭐ FavoriteActivityService: Added activity to favorites: ${favorite.activityName}');
      print('⭐ FavoriteActivityService: Total favorites: ${_favorites.length}');
      
      return Success(favorite);
    } catch (e) {
      print('⭐ FavoriteActivityService: Error in addToFavorites: $e');
      return Failure(FavoriteActivityError.database);
    }
  }

  @override
  Future<Result<bool, FavoriteActivityError>> removeFromFavorites(String favoriteId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final index = _favorites.indexWhere((f) => f.id == favoriteId);
      if (index >= 0) {
        final removed = _favorites.removeAt(index);
        print('⭐ FavoriteActivityService: Removed activity from favorites: ${removed.activityName}');
        print('⭐ FavoriteActivityService: Total favorites: ${_favorites.length}');
        return Success(true);
      }
      
      print('⭐ FavoriteActivityService: Activity not found for removal: $favoriteId');
      return Failure(FavoriteActivityError.notFound);
    } catch (e) {
      print('⭐ FavoriteActivityService: Error in removeFromFavorites: $e');
      return Failure(FavoriteActivityError.database);
    }
  }

  @override
  Future<Result<FavoriteActivityModel, FavoriteActivityError>> updateFavorite(FavoriteActivityModel favorite) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final index = _favorites.indexWhere((f) => f.id == favorite.id);
      if (index >= 0) {
        _favorites[index] = favorite;
        print('⭐ FavoriteActivityService: Updated favorite: ${favorite.activityName}');
        return Success(favorite);
      }
      
      print('⭐ FavoriteActivityService: Favorite not found for update: ${favorite.id}');
      return Failure(FavoriteActivityError.notFound);
    } catch (e) {
      print('⭐ FavoriteActivityService: Error in updateFavorite: $e');
      return Failure(FavoriteActivityError.database);
    }
  }

  @override
  Future<Result<FavoriteActivityModel, FavoriteActivityError>> getFavoriteById(String favoriteId) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final favorite = _favorites.where((f) => f.id == favoriteId).firstOrNull;
      if (favorite != null) {
        return Success(favorite);
      }
      
      return Failure(FavoriteActivityError.notFound);
    } catch (e) {
      print('⭐ FavoriteActivityService: Error in getFavoriteById: $e');
      return Failure(FavoriteActivityError.database);
    }
  }

  @override
  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> getMostUsedFavorites() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Sort by usage count, then by last used
      final sortedFavorites = List<FavoriteActivityModel>.from(_favorites)
        ..sort((a, b) {
          final usageComparison = b.usageCount.compareTo(a.usageCount);
          if (usageComparison != 0) return usageComparison;
          return b.lastUsed.compareTo(a.lastUsed);
        });
      
      final mostUsed = sortedFavorites.take(5).toList();
      print('⭐ FavoriteActivityService: getMostUsedFavorites() returning ${mostUsed.length} items');
      
      return Success(mostUsed);
    } catch (e) {
      print('⭐ FavoriteActivityService: Error in getMostUsedFavorites: $e');
      return Failure(FavoriteActivityError.database);
    }
  }

  @override
  Future<Result<List<FavoriteActivityModel>, FavoriteActivityError>> searchFavorites(String query) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      if (query.trim().isEmpty) {
        return getFavorites();
      }
      
      final searchTerm = query.toLowerCase().trim();
      final results = _favorites
          .where((f) => f.activityName.toLowerCase().contains(searchTerm))
          .toList()
        ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
      
      print('⭐ FavoriteActivityService: searchFavorites("$query") returning ${results.length} items');
      return Success(results);
    } catch (e) {
      print('⭐ FavoriteActivityService: Error in searchFavorites: $e');
      return Failure(FavoriteActivityError.database);
    }
  }

  @override
  Future<Result<bool, FavoriteActivityError>> clearAllFavorites() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      
      final count = _favorites.length;
      _favorites.clear();
      print('⭐ FavoriteActivityService: Cleared $count favorites');
      
      return Success(true);
    } catch (e) {
      print('⭐ FavoriteActivityService: Error in clearAllFavorites: $e');
      return Failure(FavoriteActivityError.database);
    }
  }

  /// Clear all favorites (for testing)
  static void clearAllFavoritesStatic() {
    _favorites.clear();
    print('⭐ FavoriteActivityService: Cleared all favorites');
  }

  /// Add test favorites for demonstration
  static void addTestFavorites() {
    final testFavorites = [
      FavoriteActivityModel(
        id: 'activity_test_1',
        activityName: 'Morgenløb',
        inputType: ActivityInputType.varighed,
        durationMinutes: 30.0,
        distanceKm: 0.0,
        intensity: ActivityIntensity.moderat,
        caloriesBurned: 350,
        notes: 'Daglig morgenrution',
        createdAt: DateTime.now().subtract(Duration(days: 15)),
        lastUsed: DateTime.now().subtract(Duration(days: 1)),
        usageCount: 12,
      ),
      FavoriteActivityModel(
        id: 'activity_test_2',
        activityName: 'Cykeltur',
        inputType: ActivityInputType.distance,
        durationMinutes: 0.0,
        distanceKm: 10.0,
        intensity: ActivityIntensity.let,
        caloriesBurned: 280,
        notes: 'Weekendtur',
        createdAt: DateTime.now().subtract(Duration(days: 10)),
        lastUsed: DateTime.now().subtract(Duration(days: 2)),
        usageCount: 8,
      ),
      FavoriteActivityModel(
        id: 'activity_test_3',
        activityName: 'Styrketræning',
        inputType: ActivityInputType.varighed,
        durationMinutes: 45.0,
        distanceKm: 0.0,
        intensity: ActivityIntensity.haardt,
        caloriesBurned: 400,
        notes: 'Fuld krop workout',
        createdAt: DateTime.now().subtract(Duration(days: 20)),
        lastUsed: DateTime.now().subtract(Duration(days: 3)),
        usageCount: 15,
      ),
      FavoriteActivityModel(
        id: 'activity_test_4',
        activityName: 'Gåtur',
        inputType: ActivityInputType.varighed,
        durationMinutes: 20.0,
        distanceKm: 0.0,
        intensity: ActivityIntensity.let,
        caloriesBurned: 120,
        notes: 'Afslappende gåtur',
        createdAt: DateTime.now().subtract(Duration(days: 5)),
        lastUsed: DateTime.now(),
        usageCount: 22,
      ),
    ];
    
    _favorites.addAll(testFavorites);
    print('⭐ FavoriteActivityService: Added ${testFavorites.length} test favorites');
  }

  /// Get favorite count (for testing/debugging)
  static int get favoriteCount => _favorites.length;
} 