import 'package:hive_flutter/hive_flutter.dart';

/// LocalStorage provides simple key-value persistence using Hive.
class LocalStorage {
  LocalStorage(this._box);

  static const String onboardingKey = 'onboardingCompleted';

  final Box<dynamic> _box;

  static Future<LocalStorage> initialize() async {
    await Hive.initFlutter();
    final Box<dynamic> box = await Hive.openBox<dynamic>('app');
    return LocalStorage(box);
  }

  bool getOnboardingCompleted() {
    return _box.get(onboardingKey, defaultValue: false) as bool;
  }

  Future<void> setOnboardingCompleted(bool value) async {
    await _box.put(onboardingKey, value);
  }
}
