import 'package:sqflite/sqflite.dart';
import '../domain/food_item_model.dart';
import '../domain/user_food_log_model.dart';

class FoodLoggingDatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = '$dbPath/calories.db';

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    // Food Categories
    await db.execute('''
      CREATE TABLE FoodCategories (
        category_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    // Food Items
    await db.execute('''
      CREATE TABLE FoodItems (
        food_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        brand TEXT,
        calories_per_100g REAL,
        protein_per_100g REAL,
        fat_per_100g REAL,
        carbs_per_100g REAL,
        category_id INTEGER,
        barcode TEXT UNIQUE,
        serving_unit TEXT,
        serving_size REAL,
        is_shared INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES FoodCategories(category_id)
      )
    ''');

    // User Food Log
    await db.execute('''
      CREATE TABLE UserFoodLog (
        log_entry_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        food_item_id INTEGER,
        custom_food_id INTEGER,
        recipe_id INTEGER,
        food_name TEXT NOT NULL,
        logged_at TEXT NOT NULL,
        meal_type TEXT,
        quantity REAL NOT NULL,
        serving_unit TEXT,
        calories INTEGER,
        protein REAL,
        fat REAL,
        carbs REAL,
        food_item_source_type TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (food_item_id) REFERENCES FoodItems(food_id)
      )
    ''');

    // Insert some sample food items
    await _insertSampleFoodItems(db);
  }

  static Future<void> _insertSampleFoodItems(Database db) async {
    final sampleFoods = [
      {
        'name': 'Bananer',
        'brand': '',
        'calories_per_100g': 89.0,
        'protein_per_100g': 1.1,
        'fat_per_100g': 0.3,
        'carbs_per_100g': 22.8,
        'serving_unit': 'stk',
        'serving_size': 120.0,
        'category_id': 1,
      },
      {
        'name': 'Æbler',
        'brand': '',
        'calories_per_100g': 52.0,
        'protein_per_100g': 0.3,
        'fat_per_100g': 0.2,
        'carbs_per_100g': 13.8,
        'serving_unit': 'stk',
        'serving_size': 150.0,
        'category_id': 1,
      },
      {
        'name': 'Havregryn',
        'brand': '',
        'calories_per_100g': 389.0,
        'protein_per_100g': 16.9,
        'fat_per_100g': 6.9,
        'carbs_per_100g': 66.3,
        'serving_unit': 'g',
        'serving_size': 40.0,
        'category_id': 2,
      },
      {
        'name': 'Kyllingbryst',
        'brand': '',
        'calories_per_100g': 165.0,
        'protein_per_100g': 31.0,
        'fat_per_100g': 3.6,
        'carbs_per_100g': 0.0,
        'serving_unit': 'g',
        'serving_size': 150.0,
        'category_id': 3,
      },
      {
        'name': 'Fuldkornsspaghetti',
        'brand': '',
        'calories_per_100g': 371.0,
        'protein_per_100g': 13.0,
        'fat_per_100g': 2.5,
        'carbs_per_100g': 72.0,
        'serving_unit': 'g',
        'serving_size': 80.0,
        'category_id': 2,
      },
    ];

    for (final food in sampleFoods) {
      await db.insert('FoodItems', food);
    }
  }

  // Food Item Operations
  static Future<List<FoodItemModel>> searchFoodItems(String query) async {
    final db = await database;
    final result = await db.query(
      'FoodItems',
      where: 'name LIKE ? OR brand LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      limit: 20,
    );

    return result.map((json) => FoodItemModel.fromJson(json)).toList();
  }

  static Future<FoodItemModel?> getFoodItemById(int id) async {
    final db = await database;
    final result = await db.query(
      'FoodItems',
      where: 'food_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return FoodItemModel.fromJson(result.first);
  }

  static Future<FoodItemModel?> getFoodItemByBarcode(String barcode) async {
    final db = await database;
    final result = await db.query(
      'FoodItems',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return FoodItemModel.fromJson(result.first);
  }

  static Future<List<FoodItemModel>> getRecentFoodItems({int limit = 10}) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT DISTINCT fi.* 
      FROM FoodItems fi
      INNER JOIN UserFoodLog ufl ON fi.food_id = ufl.food_item_id
      ORDER BY ufl.logged_at DESC
      LIMIT ?
    ''', [limit]);

    return result.map((json) => FoodItemModel.fromJson(json)).toList();
  }

  // Food Log Operations
  static Future<int> logFood(UserFoodLogModel foodLog) async {
    final db = await database;
    final data = foodLog.toJson();
    data['logged_at'] = DateTime.now().toIso8601String();
    data['created_at'] = DateTime.now().toIso8601String();
    data['updated_at'] = DateTime.now().toIso8601String();
    
    return await db.insert('UserFoodLog', data);
  }

  static Future<List<UserFoodLogModel>> getFoodLogsForDate(
    int userId, 
    DateTime date,
  ) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0]; // YYYY-MM-DD format
    
    final result = await db.query(
      'UserFoodLog',
      where: 'user_id = ? AND date(logged_at) = ?',
      whereArgs: [userId, dateString],
      orderBy: 'logged_at ASC',
    );

    return result.map((json) => UserFoodLogModel.fromJson(json)).toList();
  }

  static Future<List<UserFoodLogModel>> getFoodLogsForMeal(
    int userId,
    DateTime date,
    MealType mealType,
  ) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    final mealTypeString = UserFoodLogModel._mealTypeToString(mealType);
    
    final result = await db.query(
      'UserFoodLog',
      where: 'user_id = ? AND date(logged_at) = ? AND meal_type = ?',
      whereArgs: [userId, dateString, mealTypeString],
      orderBy: 'logged_at ASC',
    );

    return result.map((json) => UserFoodLogModel.fromJson(json)).toList();
  }

  static Future<Map<String, double>> getDailyNutritionSummary(
    int userId,
    DateTime date,
  ) async {
    final db = await database;
    final dateString = date.toIso8601String().split('T')[0];
    
    final result = await db.rawQuery('''
      SELECT 
        SUM(calories) as totalCalories,
        SUM(protein) as totalProtein,
        SUM(fat) as totalFat,
        SUM(carbs) as totalCarbs
      FROM UserFoodLog
      WHERE user_id = ? AND date(logged_at) = ?
    ''', [userId, dateString]);

    if (result.isEmpty) {
      return {
        'calories': 0.0,
        'protein': 0.0,
        'fat': 0.0,
        'carbs': 0.0,
      };
    }

    final data = result.first;
    return {
      'calories': (data['totalCalories'] ?? 0).toDouble(),
      'protein': (data['totalProtein'] ?? 0).toDouble(),
      'fat': (data['totalFat'] ?? 0).toDouble(),
      'carbs': (data['totalCarbs'] ?? 0).toDouble(),
    };
  }

  static Future<bool> deleteFoodLog(int logEntryId) async {
    final db = await database;
    final count = await db.delete(
      'UserFoodLog',
      where: 'log_entry_id = ?',
      whereArgs: [logEntryId],
    );
    return count > 0;
  }

  static Future<bool> updateFoodLog(UserFoodLogModel foodLog) async {
    final db = await database;
    final data = foodLog.toJson();
    data['updated_at'] = DateTime.now().toIso8601String();
    
    final count = await db.update(
      'UserFoodLog',
      data,
      where: 'log_entry_id = ?',
      whereArgs: [foodLog.logEntryId],
    );
    return count > 0;
  }
} 