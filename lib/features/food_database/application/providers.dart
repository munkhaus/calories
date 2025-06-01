import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/i_food_database_service.dart';
import '../domain/i_online_food_service.dart';
import '../infrastructure/food_database_service.dart';
import '../infrastructure/llm_food_service.dart';

// Shared provider for FoodDatabaseService
final foodDatabaseServiceProvider = Provider<IFoodDatabaseService>((ref) {
  return FoodDatabaseService();
});

// Provider for LLM service
final llmFoodServiceProvider = Provider<IOnlineFoodService>((ref) {
  return LLMFoodService();
}); 