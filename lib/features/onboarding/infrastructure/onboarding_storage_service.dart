import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/user_profile_model.dart';

/// Service for storing and retrieving onboarding data
class OnboardingStorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  /// Save user profile to local storage
  static Future<bool> saveUserProfile(UserProfileModel profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      await prefs.setString(_userProfileKey, profileJson);
      await prefs.setBool(_onboardingCompletedKey, profile.isOnboardingCompleted);
      return true;
    } catch (e) {
      print('Error saving user profile: $e');
      return false;
    }
  }

  /// Load user profile from local storage
  static Future<UserProfileModel?> loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString(_userProfileKey);
      
      if (profileJson != null) {
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      }
      
      return null;
    } catch (e) {
      print('Error loading user profile: $e');
      return null;
    }
  }

  /// Check if onboarding is completed
  static Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingCompletedKey) ?? false;
    } catch (e) {
      print('Error checking onboarding status: $e');
      return false;
    }
  }

  /// Clear all onboarding data
  static Future<bool> clearOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userProfileKey);
      await prefs.remove(_onboardingCompletedKey);
      return true;
    } catch (e) {
      print('Error clearing onboarding data: $e');
      return false;
    }
  }

  /// Save partial progress during onboarding
  static Future<bool> savePartialProgress(UserProfileModel profile) async {
    try {
      print('💾 Saving partial progress to SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final profileJson = jsonEncode(profile.toJson());
      print('📄 Profile JSON: ${profileJson.substring(0, 100)}...');
      await prefs.setString('${_userProfileKey}_partial', profileJson);
      print('✅ Partial progress saved successfully');
      return true;
    } catch (e) {
      print('❌ Error saving partial progress: $e');
      return false;
    }
  }

  /// Load partial progress
  static Future<UserProfileModel?> loadPartialProgress() async {
    try {
      print('🔍 Loading partial progress from SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('${_userProfileKey}_partial');
      
      if (profileJson != null) {
        print('📄 Found saved JSON: ${profileJson.substring(0, 100)}...');
        final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
        final profile = UserProfileModel.fromJson(profileMap);
        print('✅ Loaded partial progress successfully');
        return profile;
      } else {
        print('ℹ️ No partial progress found in SharedPreferences');
      }
      
      return null;
    } catch (e) {
      print('❌ Error loading partial progress: $e');
      return null;
    }
  }

  /// Clear partial progress
  static Future<bool> clearPartialProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('${_userProfileKey}_partial');
      return true;
    } catch (e) {
      print('Error clearing partial progress: $e');
      return false;
    }
  }
} 