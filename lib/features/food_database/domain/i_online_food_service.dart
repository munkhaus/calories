import 'package:result_type/result_type.dart';
import 'online_food_models.dart';

/// Generic interface for all online food data providers
abstract class IOnlineFoodService {
  /// Search for foods by query string
  /// 
  /// Returns [Result.failure] with [OnlineFoodError] if search fails.
  Future<Result<List<OnlineFoodResult>, OnlineFoodError>> searchFoods(String query);

  /// Get detailed nutrition information for a specific food
  /// 
  /// Returns [Result.failure] with [OnlineFoodError.notFound] if food doesn't exist.
  Future<Result<OnlineFoodDetails, OnlineFoodError>> getFoodDetails(String externalId);

  /// Human readable name of this provider
  String get providerName;

  /// Unique identifier for this provider
  String get providerId;

  /// Whether this provider requires an API key to function
  bool get requiresApiKey;

  /// Whether this provider is currently available/configured
  bool get isAvailable;

  /// Maximum number of requests per minute (for rate limiting)
  int get rateLimitPerMinute;

  /// Initialize the service (load API keys, test connection, etc.)
  Future<Result<void, OnlineFoodError>> initialize();
} 