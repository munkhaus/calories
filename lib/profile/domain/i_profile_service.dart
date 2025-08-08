import 'package:calories/core/domain/models/user_profile.dart';

abstract class IProfileService {
  UserProfile? getProfile();
  Future<void> saveProfile(UserProfile profile);
}
