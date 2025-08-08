import 'package:hive_flutter/hive_flutter.dart';

class HiveBoxes {
  HiveBoxes({
    required this.profiles,
    required this.goals,
    required this.foodEntries,
    required this.weights,
    required this.water,
  });

  final Box<dynamic> profiles;
  final Box<dynamic> goals;
  final Box<dynamic> foodEntries;
  final Box<dynamic> weights;
  final Box<dynamic> water;

  static Future<HiveBoxes> initialize() async {
    // Assume Hive.initFlutter() already called in LocalStorage.initialize
    final Box<dynamic> profiles = await Hive.openBox<dynamic>('profiles');
    final Box<dynamic> goals = await Hive.openBox<dynamic>('goals');
    final Box<dynamic> foodEntries = await Hive.openBox<dynamic>(
      'food_entries',
    );
    final Box<dynamic> weights = await Hive.openBox<dynamic>('weights');
    final Box<dynamic> water = await Hive.openBox<dynamic>('water');
    return HiveBoxes(
      profiles: profiles,
      goals: goals,
      foodEntries: foodEntries,
      weights: weights,
      water: water,
    );
  }
}
