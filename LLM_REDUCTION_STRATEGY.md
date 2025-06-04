# LLM Reduction Strategy for Flutter Calorie Tracking App

## Executive Summary

Your Flutter app currently uses Google's Gemini AI for:
1. **Food Database Searches** - Converting natural language queries into structured food data
2. **Image Analysis** - Analyzing food photos to extract nutritional information

This document outlines strategies to reduce or eliminate LLM dependencies while maintaining app functionality and user experience, focusing on cost-effective alternatives.

## Current LLM Usage Analysis

### 1. Gemini API Usage
- **Service**: Google Gemini 1.5 Flash
- **API Key**: Hardcoded in `llm_food_service.dart`
- **Cost**: ~$0.075 per 1K input tokens, $0.30 per 1K output tokens
- **Rate Limit**: 30 requests/minute
- **Use Cases**: 
  - Natural language food search
  - Food image analysis with detailed nutritional extraction

### 2. Cost Implications
- Average food search: ~500-1000 tokens input + 2000-4000 tokens output
- Estimated cost per search: $0.60-1.20
- Image analysis: ~1000-2000 tokens input + 1000-3000 tokens output  
- Estimated cost per image: $0.38-0.90
- **Monthly cost for 1000 searches + 500 images: ~$790-1050**

## Strategy 1: Replace Food Database with Free/Low-Cost APIs

### Option A: Open Food Facts (Recommended)
```dart
// Implementation example
class OpenFoodFactsService implements IOnlineFoodService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  
  @override
  Future<Result<List<OnlineFoodResult>, OnlineFoodError>> searchFoods(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search?search_terms=$query&page_size=20&json=true'),
      headers: {'User-Agent': 'CaloriesApp-Flutter/1.0'},
    );
    
    // Parse and return structured food data
    // No LLM needed - direct API response parsing
  }
}
```

**Benefits:**
- ✅ **Free** - No API costs
- ✅ Large database (2.7M+ products)
- ✅ Multi-language support (Danish included)
- ✅ Barcode support (already implemented)
- ✅ Structured data - no LLM parsing needed

**Implementation:**
- Replace `LLMFoodService` with `OpenFoodFactsService`
- Use structured search parameters instead of natural language
- Cache responses locally for common searches

### Option B: USDA FoodData Central
```dart
class USDAFoodService implements IOnlineFoodService {
  static const String _baseUrl = 'https://api.nal.usda.gov/fdc/v1';
  static const String _apiKey = 'YOUR_FREE_API_KEY'; // Free registration
  
  @override
  Future<Result<List<OnlineFoodResult>, OnlineFoodError>> searchFoods(String query) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/foods/search?query=$query&api_key=$_apiKey'),
    );
    // Direct structured response - no LLM needed
  }
}
```

**Benefits:**
- ✅ **Free** with registration
- ✅ High-quality USDA nutritional data
- ✅ 1,000 requests/hour limit (generous)
- ✅ Structured JSON responses

## Strategy 2: Replace Image Analysis

### Option A: Remove Image Analysis (Recommended)
**Cost Savings**: $0.38-0.90 per image → $0

**Alternative UX:**
1. **Enhanced Manual Entry**
   ```dart
   // Quick portion selector
   Widget buildQuickPortionSelector() {
     return Row(
       children: [
         _buildPortionButton('Lille', 0.75),
         _buildPortionButton('Normal', 1.0),
         _buildPortionButton('Stor', 1.5),
         _buildPortionButton('XL', 2.0),
       ],
     );
   }
   ```

2. **Voice-to-Text Entry**
   ```dart
   dependencies:
     speech_to_text: ^6.3.0
   
   // Use device's built-in speech recognition (free)
   final SpeechToText _speech = SpeechToText();
   
   void startListening() async {
     await _speech.listen(
       onResult: (result) {
         setState(() {
           _searchController.text = result.recognizedWords;
         });
       },
     );
   }
   ```

3. **Smart Autocomplete**
   ```dart
   class SmartFoodAutocomplete extends StatelessWidget {
     final List<String> commonFoods = [
       'Æble', 'Banan', 'Rugbrød', 'Kylling', 'Pasta', 'Ris', 'Salat'
     ];
     
     @override
     Widget build(BuildContext context) {
       return Autocomplete<String>(
         optionsBuilder: (textEditingValue) {
           return commonFoods.where((food) =>
             food.toLowerCase().contains(textEditingValue.text.toLowerCase())
           );
         },
       );
     }
   }
   ```

### Option B: Local Image Classification (Advanced)
**Use TensorFlow Lite for on-device food classification:**

```yaml
dependencies:
  tflite_flutter: ^0.10.4
  image: ^4.0.17
```

```dart
class LocalFoodClassifier {
  late Interpreter _interpreter;
  
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset('food_classifier.tflite');
  }
  
  Future<String> classifyFood(String imagePath) async {
    // Load and preprocess image
    final imageFile = File(imagePath);
    final bytes = await imageFile.readAsBytes();
    final image = img.decodeImage(bytes)!;
    
    // Run inference
    final input = _preprocessImage(image);
    final output = List.filled(1000, 0.0).reshape([1, 1000]);
    
    _interpreter.run(input, output);
    
    // Return top prediction
    return _getTopPrediction(output[0]);
  }
}
```

**Benefits:**
- ✅ **Free** after initial model download
- ✅ Works offline
- ✅ Fast inference
- ❌ Requires food classification model training/sourcing
- ❌ Less accurate than Gemini for complex dishes

## Strategy 3: Implement Client-Side Intelligence

### Smart Favorites System
```dart
class SmartFavoritesService {
  // Learn from user patterns
  Future<List<FavoriteActivityModel>> getContextualSuggestions() async {
    final now = DateTime.now();
    final timeOfDay = now.hour;
    final dayOfWeek = now.weekday;
    
    // Rule-based suggestions
    if (timeOfDay >= 6 && timeOfDay <= 10) {
      return await getFavoritesByTag('Morgenmad');
    } else if (timeOfDay >= 11 && timeOfDay <= 14) {
      return await getFavoritesByTag('Frokost');
    } else if (timeOfDay >= 17 && timeOfDay <= 21) {
      return await getFavoritesByTag('Aftensmad');
    }
    
    return await getRecentFavorites();
  }
}
```

### Local Nutrition Database
```dart
class LocalNutritionDB {
  static const Map<String, NutritionInfo> commonFoods = {
    'æble': NutritionInfo(calories: 52, protein: 0.3, carbs: 14, fat: 0.2),
    'banan': NutritionInfo(calories: 89, protein: 1.1, carbs: 23, fat: 0.3),
    'rugbrød': NutritionInfo(calories: 259, protein: 8.5, carbs: 48, fat: 3.3),
    // ... add more common Danish foods
  };
  
  static Future<NutritionInfo?> getNutrition(String foodName) async {
    return commonFoods[foodName.toLowerCase()];
  }
}
```

## Strategy 4: Hybrid Approach (Recommended)

### Phase 1: Immediate Cost Reduction (Week 1-2)
1. **Replace LLMFoodService with OpenFoodFactsService**
   - Implement structured search
   - Remove natural language processing
   - Maintain existing UI with slight adjustments

2. **Remove Image Analysis Feature**
   - Replace with enhanced manual entry
   - Add voice-to-text support
   - Implement smart autocomplete

**Expected Savings**: 95% reduction in API costs

### Phase 2: Enhanced User Experience (Week 3-4)
1. **Implement Smart Favorites**
   - Context-aware suggestions
   - Usage pattern learning
   - Time-based recommendations

2. **Add Local Nutrition Database**
   - Bundle common Danish foods
   - Fallback for API failures
   - Faster search results

### Phase 3: Advanced Features (Month 2)
1. **Local Food Classification** (Optional)
   - Train or source food classification model
   - Implement TensorFlow Lite integration
   - Add as premium feature

2. **Enhanced Search**
   - Fuzzy matching algorithms
   - Category-based filtering
   - Multi-language support

## Implementation Plan

### Step 1: Create OpenFoodFacts Service
```bash
# Add required dependencies
flutter pub add http
```

### Step 2: Replace Service in DI Container
```dart
// In your service provider setup
final openFoodFactsServiceProvider = Provider<IOnlineFoodService>((ref) {
  return OpenFoodFactsService();
});

// Replace LLMFoodService references
```

### Step 3: Update UI Components
```dart
// Remove image analysis buttons
// Add voice-to-text button
// Enhance search autocomplete
```

### Step 4: Test and Deploy
- Unit tests for new service
- Integration tests for search functionality
- User acceptance testing

## Cost Comparison

| Approach | Setup Cost | Monthly Cost (1K searches) | Accuracy | Offline Support |
|----------|------------|---------------------------|----------|-----------------|
| Current Gemini | $0 | $600-1050 | Very High | No |
| Open Food Facts | $0 | $0 | High | With caching |
| USDA API | $0 | $0 | High | No |
| Local DB Only | Development time | $0 | Medium | Yes |
| Hybrid (Recommended) | Development time | $0-20 | High | Partial |

## Risk Mitigation

### Data Quality
- **Risk**: Lower accuracy than LLM
- **Mitigation**: Implement user feedback system, allow manual corrections

### User Experience
- **Risk**: Users expect natural language search
- **Mitigation**: Enhanced autocomplete, voice input, smart suggestions

### Development Time
- **Risk**: Significant refactoring required
- **Mitigation**: Phased implementation, maintain existing service as fallback

## Conclusion

**Recommended Approach**: Hybrid implementation starting with OpenFoodFacts API replacement, enhanced manual entry, and smart client-side features. This will:

- ✅ Reduce costs by 95%+ (from $600-1050/month to $0-20/month)
- ✅ Maintain core functionality
- ✅ Improve offline capability
- ✅ Provide better user control
- ✅ Enable faster development iteration

The key is to replace AI complexity with smart, rule-based systems and leverage free, high-quality food databases that already exist. 