import 'package:get_it/get_it.dart';
import 'package:calories/core/storage/local_storage.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Configure core and feature dependencies.
Future<void> configureDependencies() async {
  // Register core singletons here.
  final LocalStorage storage = await LocalStorage.initialize();
  getIt.registerSingleton<LocalStorage>(storage);
}
