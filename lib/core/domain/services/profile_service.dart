import 'dart:convert';

import 'package:calories/core/domain/models/user_profile.dart';
import 'package:calories/core/storage/hive_boxes.dart';

class ProfileService {
  ProfileService(this._boxes);

  static const String _defaultKey = 'default';
  final HiveBoxes _boxes;

  UserProfile? getProfile() {
    final dynamic raw = _boxes.profiles.get(_defaultKey);
    if (raw is String) {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _boxes.profiles.put(_defaultKey, jsonEncode(profile.toJson()));
  }
}
