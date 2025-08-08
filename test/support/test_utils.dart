import 'package:calories/core/di/service_locator.dart';
import 'package:calories/core/storage/local_storage.dart';
import 'package:flutter/material.dart';

Future<void> registerTestLocalStorage({bool onboardingCompleted = true}) async {
  if (getIt.isRegistered<LocalStorage>()) return;
  // In widget tests we avoid Hive; use an in-memory stub
  final _MemoryLocalStorage storage = _MemoryLocalStorage(onboardingCompleted);
  getIt.registerSingleton<LocalStorage>(storage);
}

class _MemoryLocalStorage extends LocalStorage {
  _MemoryLocalStorage(this._completed) : super(_NoopBox());

  bool _completed;

  @override
  bool getOnboardingCompleted() => _completed;

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    _completed = value;
  }
}

class _NoopBox {
  dynamic get(String key, {dynamic defaultValue}) => defaultValue;
  Future<void> put(String key, dynamic value) async {}
}

Widget wrapWithMaterialApp(Widget child) => MaterialApp(home: child);
