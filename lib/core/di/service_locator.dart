import 'package:get_it/get_it.dart';
import 'package:calories/core/storage/local_storage.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:calories/core/domain/services/profile_service.dart';
import 'package:calories/core/domain/services/goal_service.dart';
import 'package:calories/core/domain/services/log_service.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Configure core and feature dependencies.
Future<void> configureDependencies() async {
  // Register core singletons here.
  final LocalStorage storage = await LocalStorage.initialize();
  getIt.registerSingleton<LocalStorage>(storage);
  final HiveBoxes boxes = await HiveBoxes.initialize();
  getIt
    ..registerSingleton<HiveBoxes>(boxes)
    ..registerLazySingleton<ProfileService>(() => ProfileService(getIt()))
    ..registerLazySingleton<GoalService>(() => GoalService(getIt()))
    ..registerLazySingleton<LogService>(() => LogService(getIt()));
}
