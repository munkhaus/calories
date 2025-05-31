import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Generic storage service for persisting data using SharedPreferences
class StorageService {
  static late SharedPreferences _prefs;
  static bool _isInitialized = false;
  
  /// Initialize the storage service
  static Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }
  
  /// Save a list of objects as JSON
  static Future<bool> saveList<T>(String key, List<T> items, Map<String, dynamic> Function(T) toJson) async {
    await initialize();
    try {
      final jsonList = items.map((item) => toJson(item)).toList();
      final jsonString = jsonEncode(jsonList);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      print('❌ StorageService: Error saving list for key $key: $e');
      return false;
    }
  }
  
  /// Load a list of objects from JSON
  static Future<List<T>> loadList<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    await initialize();
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      print('❌ StorageService: Error loading list for key $key: $e');
      return [];
    }
  }
  
  /// Save a single object as JSON
  static Future<bool> saveObject<T>(String key, T item, Map<String, dynamic> Function(T) toJson) async {
    await initialize();
    try {
      final json = toJson(item);
      final jsonString = jsonEncode(json);
      return await _prefs.setString(key, jsonString);
    } catch (e) {
      print('❌ StorageService: Error saving object for key $key: $e');
      return false;
    }
  }
  
  /// Load a single object from JSON
  static Future<T?> loadObject<T>(String key, T Function(Map<String, dynamic>) fromJson) async {
    await initialize();
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null || jsonString.isEmpty) {
        return null;
      }
      
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      print('❌ StorageService: Error loading object for key $key: $e');
      return null;
    }
  }
  
  /// Delete data for a key
  static Future<bool> delete(String key) async {
    await initialize();
    try {
      return await _prefs.remove(key);
    } catch (e) {
      print('❌ StorageService: Error deleting key $key: $e');
      return false;
    }
  }
  
  /// Clear all stored data
  static Future<bool> clearAll() async {
    await initialize();
    try {
      return await _prefs.clear();
    } catch (e) {
      print('❌ StorageService: Error clearing all data: $e');
      return false;
    }
  }
  
  /// Storage keys for different data types
  static const String foodLogsKey = 'food_logs';
  static const String activityLogsKey = 'activity_logs';
  static const String weightEntriesKey = 'weight_entries';
  static const String pendingFoodsKey = 'pending_foods';
  static const String favoriteFoodsKey = 'favorite_foods';
  static const String favoriteActivitiesKey = 'favorite_activities';
} 