import 'dart:convert';

import 'package:calories/core/domain/models/user_profile.dart';
import 'package:calories/core/storage/hive_boxes.dart';
import 'package:calories/profile/domain/i_profile_service.dart';

class ProfileService implements IProfileService {
  ProfileService(this._boxes);

  static const String _defaultKey = 'default';
  final HiveBoxes _boxes;

  @override
  UserProfile? getProfile() {
    final dynamic raw = _boxes.profiles.get(_defaultKey);
    if (raw is String) {
      return UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    await _boxes.profiles.put(_defaultKey, jsonEncode(profile.toJson()));
  }
}
