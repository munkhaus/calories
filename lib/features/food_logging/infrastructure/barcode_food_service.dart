import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:result_type/result_type.dart';
import '../domain/favorite_food_model.dart';

/// Error types for barcode food operations
enum BarcodeFoodError {
  notFound,
  network,
  parsing,
  invalidBarcode,
  insufficientData,
  unknown,
}

extension BarcodeFoodErrorExtension on BarcodeFoodError {
  String get message {
    switch (this) {
      case BarcodeFoodError.notFound:
        return 'Produkt ikke fundet i database';
      case BarcodeFoodError.network:
        return 'Netværksfejl - tjek din internetforbindelse';
      case BarcodeFoodError.parsing:
        return 'Fejl ved behandling af produktdata';
      case BarcodeFoodError.invalidBarcode:
        return 'Ugyldig stregkode';
      case BarcodeFoodError.insufficientData:
        return 'Utilstrækkelige ernæringsdata';
      case BarcodeFoodError.unknown:
        return 'Ukendt fejl';
    }
  }
}

/// Service for fetching food data from barcodes using Open Food Facts API
class BarcodeFoodService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';
  static const String _userAgent = 'CaloriesApp-Flutter/1.0';
  
  /// Fetch food data from barcode using Open Food Facts API
  static Future<Result<FavoriteFoodModel, BarcodeFoodError>> fetchFoodFromBarcode(String barcode) async {
    try {
      // Validate barcode
      if (!_isValidBarcode(barcode)) {
        return Failure(BarcodeFoodError.invalidBarcode);
      }

      // Make API request
      final response = await http.get(
        Uri.parse('$_baseUrl/$barcode'),
        headers: {
          'User-Agent': _userAgent,
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode != 200) {
        return Failure(BarcodeFoodError.network);
      }

      // Parse response
      final data = json.decode(response.body) as Map<String, dynamic>;
      
      // Check if product was found
      if (data['status'] != 1) {
        return Failure(BarcodeFoodError.notFound);
      }

      final product = data['product'] as Map<String, dynamic>?;
      if (product == null) {
        return Failure(BarcodeFoodError.notFound);
      }

      // Extract nutrition data
      final nutriments = product['nutriments'] as Map<String, dynamic>?;
      if (nutriments == null) {
        return Failure(BarcodeFoodError.insufficientData);
      }

      // Get calories per 100g
      final caloriesPer100g = _extractCalories(nutriments);
      if (caloriesPer100g == null || caloriesPer100g <= 0) {
        return Failure(BarcodeFoodError.insufficientData);
      }

      // Extract basic product info
      final productName = product['product_name'] as String? ?? 
                         product['product_name_en'] as String? ?? 
                         product['product_name_da'] as String? ??
                         'Ukendt produkt';
                         
      final brand = product['brands'] as String?;
      final description = _buildDescription(product);
      
      // Extract detailed nutrition
      final proteinPer100g = _extractNutrient(nutriments, 'proteins');
      final fatPer100g = _extractNutrient(nutriments, 'fat');
      final carbsPer100g = _extractNutrient(nutriments, 'carbohydrates');
      final fiberPer100g = _extractNutrient(nutriments, 'fiber');
      final sugarPer100g = _extractNutrient(nutriments, 'sugars');
      
      // Extract ingredients
      final ingredientsText = product['ingredients_text'] as String? ?? 
                             product['ingredients_text_da'] as String? ??
                             product['ingredients_text_en'] as String?;
      final ingredients = ingredientsText?.split(',').map((e) => e.trim()).toList();

      // Create favorite food model
      final favorite = FavoriteFoodModel.fromBarcodeData(
        barcode: barcode,
        foodName: productName,
        brand: brand,
        description: description,
        caloriesPer100g: caloriesPer100g,
        proteinPer100g: proteinPer100g,
        fatPer100g: fatPer100g,
        carbsPer100g: carbsPer100g,
        fiberPer100g: fiberPer100g,
        sugarPer100g: sugarPer100g,
        ingredients: ingredients,
      );

      return Success(favorite);
      
    } catch (e) {
      print('BarcodeFoodService: Error fetching barcode data: $e');
      return Failure(BarcodeFoodError.unknown);
    }
  }

  /// Validate barcode format
  static bool _isValidBarcode(String barcode) {
    if (barcode.isEmpty) return false;
    
    // Remove any whitespace
    barcode = barcode.trim();
    
    // Check if it's all digits
    if (!RegExp(r'^\d+$').hasMatch(barcode)) return false;
    
    // Common barcode lengths: EAN-8 (8), UPC-A (12), EAN-13 (13), ITF-14 (14)
    final length = barcode.length;
    return length >= 8 && length <= 14;
  }

  /// Extract calories from nutriments data
  static int? _extractCalories(Map<String, dynamic> nutriments) {
    // Try different energy fields
    final energyKj = nutriments['energy_100g'] as num?;
    final energyKcal = nutriments['energy-kcal_100g'] as num?;
    
    if (energyKcal != null && energyKcal > 0) {
      return energyKcal.round();
    }
    
    if (energyKj != null && energyKj > 0) {
      // Convert kJ to kcal (1 kcal = 4.184 kJ)
      return (energyKj / 4.184).round();
    }
    
    return null;
  }

  /// Extract nutrient value per 100g
  static double? _extractNutrient(Map<String, dynamic> nutriments, String nutrientName) {
    final value = nutriments['${nutrientName}_100g'] as num?;
    return value?.toDouble();
  }

  /// Build description from product data
  static String _buildDescription(Map<String, dynamic> product) {
    final parts = <String>[];
    
    final brand = product['brands'] as String?;
    if (brand != null && brand.isNotEmpty) {
      parts.add(brand);
    }
    
    final categories = product['categories'] as String?;
    if (categories != null && categories.isNotEmpty) {
      final categoryList = categories.split(',').take(2).map((e) => e.trim()).toList();
      parts.addAll(categoryList);
    }
    
    final quantity = product['quantity'] as String?;
    if (quantity != null && quantity.isNotEmpty) {
      parts.add(quantity);
    }
    
    return parts.join(' • ');
  }

  /// Test barcode scanner with a known Danish product
  static Future<Result<FavoriteFoodModel, BarcodeFoodError>> testDanishProduct() async {
    // Test with Nutella (available in Denmark): 3017624010701
    return await fetchFoodFromBarcode('3017624010701');
  }
} 