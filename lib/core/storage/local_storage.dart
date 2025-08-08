import 'package:hive_flutter/hive_flutter.dart';

/// LocalStorage provides simple key-value persistence using Hive.
class LocalStorage {
  LocalStorage(this._box);

  static const String onboardingKey = 'onboardingCompleted';
  static const String onboardingDraftKey = 'onboardingDraft';

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

  Map<String, dynamic>? getOnboardingDraft() {
    final dynamic raw = _box.get(onboardingDraftKey);
    if (raw is Map) {
      return Map<String, dynamic>.from(raw as Map<dynamic, dynamic>);
    }
    return null;
  }

  Future<void> setOnboardingDraft(Map<String, dynamic> value) async {
    await _box.put(onboardingDraftKey, value);
  }

  Future<void> clearOnboardingDraft() async {
    await _box.delete(onboardingDraftKey);
  }
}
