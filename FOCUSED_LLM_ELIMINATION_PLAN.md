# Focused LLM Elimination Plan for Your Calorie Tracking App

## Current LLM Usage Analysis (Based on Real Implementation)

### 1. `LLMFoodService` - AI-Powered Food Search
**Location**: `lib/features/food_database/infrastructure/llm_food_service.dart`
**Current Provider**: `llmFoodServiceProvider` in multiple locations
**Usage Points**:
- `lib/features/food_logging/application/food_search_cubit.dart` (line 18)
- `lib/features/food_logging/presentation/pages/food_favorite_detail_page.dart` (line 575)
- `lib/features/food_database/application/online_food_cubit.dart` (line 23)

**Cost**: ~$0.60-1.20 per search (Gemini 1.5 Flash)
**API Key**: `AIzaSyCPB0qzhIAprF1kYNhfpG3SMnkNnu56qD8` (hardcoded in service)

### 2. `GeminiService` - Food Image Analysis
**Location**: `lib/features/food_logging/infrastructure/gemini_service.dart`
**Usage Points**:
- `lib/features/food_logging/presentation/pages/categorize_food_page.dart` (line 40)
- `lib/features/food_logging/presentation/pages/quick_photo_session_page.dart` (line 505)
- `lib/features/food_logging/infrastructure/pending_food_service.dart` (line 17)

**Cost**: ~$0.38-0.90 per image analysis
**Features**: Single/multi-image analysis, nutrition extraction, Danish language output

## **Phase 1: Replace Food Search Service (Week 1)**

### Current Implementation to Replace
```dart
// lib/features/food_logging/application/food_search_cubit.dart
final onlineFoodServiceProvider = Provider<IOnlineFoodService>((ref) {
  return LLMFoodService(); // ← Replace this
});
```

### Step 1.1: Create OpenFoodFactsService
Create `lib/features/food_database/infrastructure/open_food_facts_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:result_type/result_type.dart';
import '../domain/i_online_food_service.dart';
import '../domain/online_food_models.dart';

class OpenFoodFactsService implements IOnlineFoodService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  static const String _searchUrl = '$_baseUrl/search';
  
  @override
  String get providerName => 'Open Food Facts';
  
  @override
  String get providerId => 'openfoodfacts';
  
  @override
  bool get requiresApiKey => false;
  
  @override
  bool get isAvailable => true;
  
  @override
  int get rateLimitPerMinute => 100;
  
  @override
  Future<Result<void, OnlineFoodError>> initialize() async {
    return Success(null);
  }
  
  @override
  Future<Result<List<OnlineFoodResult>, OnlineFoodError>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_searchUrl?search_terms=${Uri.encodeComponent(query)}&page_size=20&json=true'),
        headers: {
          'User-Agent': 'CaloriesApp-Flutter/1.0',
          'Accept': 'application/json',
        },
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode != 200) {
        return Failure(OnlineFoodError.networkError);
      }
      
      final data = json.decode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? [];
      
      final results = products
          .cast<Map<String, dynamic>>()
          .where((product) => _hasValidNutrition(product))
          .take(10)
          .map((product) => _mapToOnlineFoodResult(product))
          .toList();
      
      return Success(results);
    } catch (e) {
      return Failure(OnlineFoodError.networkError);
    }
  }
  
  @override
  Future<Result<OnlineFoodDetails, OnlineFoodError>> getFoodDetails(String externalId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/product/$externalId'),
        headers: {'User-Agent': 'CaloriesApp-Flutter/1.0'},
      );
      
      if (response.statusCode != 200) {
        return Failure(OnlineFoodError.notFound);
      }
      
      final data = json.decode(response.body) as Map<String, dynamic>;
      final product = data['product'] as Map<String, dynamic>?;
      
      if (product == null) {
        return Failure(OnlineFoodError.notFound);
      }
      
      return Success(_mapToOnlineFoodDetails(product));
    } catch (e) {
      return Failure(OnlineFoodError.networkError);
    }
  }
  
  bool _hasValidNutrition(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>?;
    return nutriments != null && 
           (nutriments['energy-kcal_100g'] != null || 
            nutriments['energy_100g'] != null);
  }
  
  OnlineFoodResult _mapToOnlineFoodResult(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    final calories = _extractCalories(nutriments);
    
    return OnlineFoodResult(
      id: product['_id'] as String? ?? '',
      name: product['product_name'] as String? ?? product['product_name_da'] as String? ?? 'Ukendt produkt',
      description: product['brands'] as String? ?? '',
      provider: providerId,
      estimatedCalories: calories.toDouble(),
      searchMode: _determineSearchMode(product['product_name'] as String? ?? ''),
    );
  }
  
  OnlineFoodDetails _mapToOnlineFoodDetails(Map<String, dynamic> product) {
    final nutriments = product['nutriments'] as Map<String, dynamic>? ?? {};
    
    return OnlineFoodDetails(
      basicInfo: _mapToOnlineFoodResult(product),
      nutrition: NutritionInfo(
        calories: _extractCalories(nutriments).toDouble(),
        protein: (nutriments['proteins_100g'] as num?)?.toDouble() ?? 0.0,
        carbs: (nutriments['carbohydrates_100g'] as num?)?.toDouble() ?? 0.0,
        fat: (nutriments['fat_100g'] as num?)?.toDouble() ?? 0.0,
        fiber: (nutriments['fiber_100g'] as num?)?.toDouble() ?? 0.0,
        sugar: (nutriments['sugars_100g'] as num?)?.toDouble() ?? 0.0,
        sodium: (nutriments['sodium_100g'] as num?)?.toDouble() ?? 0.0,
      ),
      servingSizes: _createServingSizes(product),
      ingredients: product['ingredients_text'] as String? ?? '',
    );
  }
  
  double _extractCalories(Map<String, dynamic> nutriments) {
    // Try different calorie fields
    final kcal100g = nutriments['energy-kcal_100g'] as num?;
    if (kcal100g != null) return kcal100g.toDouble();
    
    final energy100g = nutriments['energy_100g'] as num?;
    if (energy100g != null) return (energy100g / 4.184).toDouble(); // Convert kJ to kcal
    
    return 0.0;
  }
  
  SearchMode _determineSearchMode(String name) {
    // Same logic as LLMFoodService
    final nameWords = name.toLowerCase();
    
    final dishKeywords = [
      'ret', 'måltid', 'middag', 'morgenmad', 'frokost', 'aftensmad',
      'salat', 'suppe', 'steg', 'gryde', 'pizza', 'pasta', 'sandwich',
      'burger', 'sushi', 'curry', 'lasagne', 'risotto', 'omelet',
      'med', 'og', 'i', 'på', 'til',
    ];
    
    for (final keyword in dishKeywords) {
      if (nameWords.contains(keyword)) {
        return SearchMode.dishes;
      }
    }
    
    return SearchMode.ingredients;
  }
  
  List<OnlineServingSize> _createServingSizes(Map<String, dynamic> product) {
    final servingSizes = <OnlineServingSize>[];
    
    // Add default 100g serving
    servingSizes.add(OnlineServingSize(
      name: '100g',
      grams: 100.0,
      isDefault: true,
    ));
    
    // Add package serving if available
    final quantity = product['quantity'] as String?;
    if (quantity != null) {
      final match = RegExp(r'(\d+(?:\.\d+)?)\s*g').firstMatch(quantity);
      if (match != null) {
        final grams = double.tryParse(match.group(1)!);
        if (grams != null && grams != 100.0) {
          servingSizes.add(OnlineServingSize(
            name: 'Pakke ($quantity)',
            grams: grams,
            isDefault: false,
          ));
        }
      }
    }
    
    // Add common serving sizes
    servingSizes.addAll([
      OnlineServingSize(name: '1 portion', grams: 150.0, isDefault: false),
      OnlineServingSize(name: '1 lille portion', grams: 75.0, isDefault: false),
    ]);
    
    return servingSizes;
  }
}
```

### Step 1.2: Update Provider
```dart
// lib/features/food_logging/application/food_search_cubit.dart
import '../../food_database/infrastructure/open_food_facts_service.dart';

final onlineFoodServiceProvider = Provider<IOnlineFoodService>((ref) {
  return OpenFoodFactsService(); // ← Changed from LLMFoodService
});
```

### Step 1.3: Add HTTP Dependency
Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.1.0
```

## **Phase 2: Remove Image Analysis Service (Week 2)**

### Current Usage Points to Modify

1. **Remove AI Analysis Button from CategorizeFoodPage**
```dart
// lib/features/food_logging/presentation/pages/categorize_food_page.dart
// Remove lines 453-496 (the "Analyser Billede" button and AI analysis UI)
// Keep only the manual input fields
```

2. **Remove Background AI Analysis from PendingFoodService**
```dart
// lib/features/food_logging/infrastructure/pending_food_service.dart
// In _performBackgroundAiAnalysis method (line 248), comment out the AI analysis:

Future<void> _performBackgroundAiAnalysis(PendingFoodModel pendingFood) async {
  // Comment out AI analysis to eliminate LLM dependency
  print('🤖 PendingFoodService: AI analysis disabled to reduce costs');
  // TODO: Could implement simple image recognition using device ML in future
}
```

3. **Remove AI Analysis from QuickPhotoSession**
```dart
// lib/features/food_logging/presentation/pages/quick_photo_session_page.dart
// In _goDirectToCategorizeFoods method (line 535), remove AI analysis:

// Comment out lines 535-540 (AI analysis call)
print('🤖 QuickPhotoSession: AI analysis disabled to reduce costs');
// Continue directly to categorization without AI
```

### Enhanced Manual Entry Features to Add

1. **Smart Food Name Suggestions**
```dart
// Create lib/shared/data/common_danish_foods.dart
class CommonDanishFoods {
  static const List<String> foods = [
    // Common breakfast foods
    'Havregrød', 'Yogurt med müsli', 'Rugbrød med smør', 'Æg og bacon',
    
    // Common lunch foods  
    'Smørrebrød', 'Salat', 'Sandwich', 'Suppe',
    
    // Common dinner foods
    'Kylling med ris', 'Pasta med kød', 'Fisk med kartofler', 'Pizza',
    
    // Common snacks
    'Frugt', 'Nødder', 'Chokolade', 'Kage',
  ];
  
  static List<String> getSuggestions(String query) {
    if (query.length < 2) return [];
    
    return foods
        .where((food) => food.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }
}
```

2. **Quick Calorie Estimation**
```dart
// Add to CategorizeFoodPage
void _estimateCalories() {
  final foodName = _foodNameController.text.toLowerCase();
  int estimated = 200; // Default
  
  if (foodName.contains('salat')) estimated = 100;
  else if (foodName.contains('pizza')) estimated = 300;
  else if (foodName.contains('pasta')) estimated = 250;
  else if (foodName.contains('frugt')) estimated = 80;
  
  _caloriesController.text = estimated.toString();
}
```

## **Implementation Timeline**

### Week 1 (Food Search Replacement)
- **Day 1-2**: Create OpenFoodFactsService
- **Day 3**: Update providers and test food search
- **Day 4-5**: Test with real Danish food searches
- **Day 6-7**: Bug fixes and optimization

### Week 2 (Image Analysis Removal)
- **Day 1-2**: Remove AI analysis from all three locations
- **Day 3-4**: Implement enhanced manual entry features
- **Day 5-6**: Test complete workflow without AI
- **Day 7**: User testing and refinements

## **Cost Impact Analysis**

### Before (Monthly with 1000 searches + 500 images):
- Food search: 1000 × $0.90 = **$900**
- Image analysis: 500 × $0.64 = **$320**
- **Total: $1,220/month**

### After (Free alternatives):
- Open Food Facts: **$0**
- Manual entry: **$0**
- **Total: $0/month**
- **Savings: 100% ($1,220/month)**

## **Benefits Beyond Cost Savings**

1. **Faster Performance**: No API calls = instant results
2. **Offline Capability**: Works without internet for manual entry
3. **More Reliable**: No API rate limits or downtime
4. **Better Privacy**: No image data sent to external services
5. **Larger Database**: Open Food Facts has 2.7M+ products vs AI's generated results

## **Risk Mitigation**

1. **User Experience**: Enhanced UI with smart suggestions compensates for lack of AI
2. **Accuracy**: Open Food Facts provides verified nutrition data vs AI estimates
3. **Danish Content**: Open Food Facts has good Danish product coverage
4. **Fallback**: Keep favorites system for frequently used items

## **Testing Strategy**

1. **A/B Testing**: Keep LLM service available for 1 week while testing new system
2. **User Feedback**: Monitor user satisfaction during transition
3. **Performance Testing**: Ensure Open Food Facts API performance is acceptable
4. **Data Validation**: Compare nutrition accuracy between systems

This plan eliminates **100% of LLM costs** while maintaining core functionality through proven alternatives and enhanced manual workflows. 