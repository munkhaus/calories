import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../infrastructure/activity_service.dart';
import '../domain/i_activity_service.dart';

/// Provider for activity service
final activityServiceProvider = Provider<IActivityService>((ref) {
  return ActivityService();
});

/// State provider for activity calories that can be refreshed
final activityCaloriesStateProvider = StateProvider<int>((ref) => 0);

/// Provider that fetches actual activity calories from service
final activityCaloriesProvider = FutureProvider<int>((ref) async {
  final service = ref.read(activityServiceProvider);
  final result = await service.getTodaysCaloriesBurned(1); // TODO: Get real user ID
  
  if (result.isSuccess) {
    return result.success;
  } else {
    return 0;
  }
});

/// Function to refresh activity calories - call this when activities are logged
void refreshActivityCalories(WidgetRef ref) {
  ref.invalidate(activityCaloriesProvider);
} 