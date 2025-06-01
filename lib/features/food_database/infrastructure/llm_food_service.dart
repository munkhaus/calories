import 'dart:convert';
import 'dart:math' as math;
import 'package:result_type/result_type.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/i_online_food_service.dart';
import '../domain/online_food_models.dart';
import 'constants/llm_prompts.dart';

// Provider for LLMFoodService
final llmFoodServiceProvider = Provider<LLMFoodService>((ref) {
  final service = LLMFoodService();
  service.initialize(); // Ensure service is initialized when provider is first read
  return service;
});

class LLMFoodService implements IOnlineFoodService {
  static const String _providerId = 'llm';
  static final String _apiKey = 'AIzaSyCPB0qzhIAprF1kYNhfpG3SMnkNnu56qD8';
  
  GenerativeModel? _model;
  bool _isInitialized = false;
  
  // Cache for storing complete food details from search
  final Map<String, OnlineFoodDetails> _detailsCache = {};

  @override
  String get providerName => 'Madvaresøgning';

  @override
  String get providerId => _providerId;

  @override
  bool get requiresApiKey => true;

  @override
  bool get isAvailable => _isInitialized && _model != null;

  @override
  int get rateLimitPerMinute => 30;

  @override
  Future<Result<void, OnlineFoodError>> initialize() async {
    try {
      print('🤖 LLMFoodService: Initializing Gemini API...');
      
      // Always try to create model if it's null, even if _isInitialized was true
      if (_model == null) {
        print('🤖 LLMFoodService: Model is null, proceeding with creation/re-creation.');
        if (LLMFoodService._apiKey.isEmpty) {
          print('❌ LLMFoodService: CRITICAL - No API key found. Cannot create model.');
          _isInitialized = false;
          _model = null;
          return Failure(OnlineFoodError.apiKeyMissing);
        }
        
        print('🤖 LLMFoodService: Hardcoded API key for model creation: ${LLMFoodService._apiKey.substring(0,10)}... (masked)');
        try {
          _model = GenerativeModel(
            model: 'gemini-1.5-flash',
            apiKey: LLMFoodService._apiKey,
            generationConfig: GenerationConfig(
              temperature: 0.1,
              maxOutputTokens: 8192,
            ),
          );
          print('✅ LLMFoodService: GenerativeModel created/re-created successfully!');
        } catch (e, stackTrace) {
          print('❌ LLMFoodService: CRITICAL - Failed to create/re-create GenerativeModel instance.');
          print('❌ LLMFoodService: Error: $e');
          print('❌ LLMFoodService: Stack trace: $stackTrace');
          _isInitialized = false;
          _model = null;
          if (e.toString().contains('API key not valid') || e.toString().contains('InvalidApiKey')) {
            return Failure(OnlineFoodError.apiKeyMissing);
          }
          return Failure(OnlineFoodError.providerUnavailable);
        }
      } else {
        print('🤖 LLMFoodService: GenerativeModel instance already exists, not re-creating.');
      }
      
      _isInitialized = _model != null; // Mark as initialized only if model exists
      if (_isInitialized) {
        print('✅ LLMFoodService: Initialization/Verification successful. Model is ready.');
      } else {
        print('❌ LLMFoodService: Initialization failed, model is null.');
        // Ensure we return a failure if model creation failed silently or was skipped but model is null
        return Failure(OnlineFoodError.providerUnavailable); 
      }
      return Success(null);
    } catch (e, stackTrace) {
      print('❌ LLMFoodService: Unexpected error during outer initialize() block: $e');
      print('❌ LLMFoodService: Stack trace: $stackTrace');
      _isInitialized = false;
      _model = null;
      return Failure(OnlineFoodError.providerUnavailable);
    }
  }

  @override
  Future<Result<List<OnlineFoodResult>, OnlineFoodError>> searchFoods(String query) async {
    print('🤖 LLMFoodService: searchFoods initiated for query: "$query"');
    if (!_isInitialized || _model == null) {
      print('🤖 LLMFoodService: Not initialized or model is null. Attempting to initialize...');
      final initResult = await initialize();
      if (initResult.isFailure) {
        print('❌ LLMFoodService: Initialization failed in searchFoods. Error: ${initResult.failure}');
        return Failure(initResult.failure);
      }
      if (_model == null) {
          print('❌ LLMFoodService: CRITICAL - Initialization reported success but model is STILL null!');
          _isInitialized = false; // Force re-init next time
          return Failure(OnlineFoodError.unknown); 
      }
      print('🤖 LLMFoodService: Initialization successful in searchFoods.');
    } else {
      print('🤖 LLMFoodService: Already initialized and model exists.');
    }

    if (LLMFoodService._apiKey.isEmpty) {
        print('❌ LLMFoodService: API key is empty before API call!');
        return Failure(OnlineFoodError.apiKeyMissing);
    }
    
    print('🤖 LLMFoodService: Pre-API call check: Model: gemini-1.5-flash, API Key (masked): ${LLMFoodService._apiKey.substring(0,10)}...');

    try {
      print('🤖 LLMFoodService: USING CURRENT DETAILED PROMPT GENERATOR - v2');
      final prompt = LLMPrompts.getFoodSearchPrompt(query);
      
      // Log the full request
      print('🤖 LLMFoodService: === REQUEST START ===');
      print('🤖 LLMFoodService: Query: "$query"');
      print('🤖 LLMFoodService: Prompt length: ${prompt.length} characters');
      print('🤖 LLMFoodService: Prompt preview: ${prompt.substring(0, math.min(200, prompt.length))}...');
      print('🤖 LLMFoodService: === REQUEST END ===');
      
      print('🤖 LLMFoodService: About to call _model!.generateContent with API Key (masked): ${LLMFoodService._apiKey.substring(0,10)}...');
      final response = await _model!.generateContent([Content.text(prompt)]);
      final responseText = response.text ?? '';
      
      // Log the full response
      print('🤖 LLMFoodService: === RESPONSE START ===');
      print('🤖 LLMFoodService: Response length: ${responseText.length} characters');
      print('🤖 LLMFoodService: Full response: $responseText');
      print('🤖 LLMFoodService: === RESPONSE END ===');

      if (responseText.isEmpty) {
        print('❌ LLMFoodService: Empty response received');
        return Failure(OnlineFoodError.invalidResponse);
      }

      // Clean the response text
      final cleanedResponse = responseText
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      print('🤖 LLMFoodService: Cleaned response: $cleanedResponse');

      // Try to parse JSON
      Map<String, dynamic> jsonData;
      try {
        jsonData = json.decode(cleanedResponse);
        print('🤖 LLMFoodService: JSON parsed successfully');
      } catch (e) {
        print('❌ LLMFoodService: JSON parse error: $e');
        print('❌ LLMFoodService: Problematic text: $cleanedResponse');
        
        // Try to fix common JSON issues
        String potentialJson = cleanedResponse;
        int lastBrace = potentialJson.lastIndexOf('}');
        int lastBracket = potentialJson.lastIndexOf(']');
        
        // Smartly try to complete the JSON structure
        if (lastBrace > lastBracket) { // Likely an object was being written
          if (potentialJson.lastIndexOf('{') > potentialJson.lastIndexOf('[')) {
            potentialJson += '}'; // Close the object
          } else {
            potentialJson += ']}'; // Close array then object - common in {"foods": [...]}
          }
        } else if (lastBracket > lastBrace) { // Likely an array was being written
          potentialJson += ']';
        } else { // No clear last structure, attempt to close based on counts (less reliable)
          int openBraces = '{'.allMatches(cleanedResponse).length - '}'.allMatches(cleanedResponse).length;
          int openBrackets = '['.allMatches(cleanedResponse).length - ']'.allMatches(cleanedResponse).length;
          
          for (int i = 0; i < openBrackets; i++) {
            potentialJson += ']';
          }
          for (int i = 0; i < openBraces; i++) {
            potentialJson += '}';
          }
        }
        // If the main structure is a list of foods, ensure the outer list is closed
        if (cleanedResponse.trim().startsWith('{\n  "foods": [' ) && !potentialJson.endsWith(']}')) {
          if (potentialJson.endsWith('}')) { // if a food object was closed
            potentialJson += ']'; // close the foods list
          }
          if (!potentialJson.endsWith('}')) { // if the foods list was closed
            potentialJson += '}'; // close the main object
          }
        }

        print('🔧 LLMFoodService: Attempting to parse fixed response with: $potentialJson');
        try {
          jsonData = json.decode(potentialJson);
          print('✅ LLMFoodService: Fixed JSON parsed successfully');
        } catch (e2) {
          print('❌ LLMFoodService: Fixed JSON also failed: $e2');
          return Failure(OnlineFoodError.invalidResponse);
        }
      }

      // Check for error in response
      if (jsonData.containsKey('error')) {
        print('❌ LLMFoodService: LLM returned error: ${jsonData['error']}');
        return Failure(OnlineFoodError.noResults);
      }

      // Parse foods array
      if (!jsonData.containsKey('foods') || jsonData['foods'] is! List) {
        print('❌ LLMFoodService: Invalid response structure - no foods array');
        return Failure(OnlineFoodError.invalidResponse);
      }

      final foodsArray = jsonData['foods'] as List;
      print('🤖 LLMFoodService: Found ${foodsArray.length} foods in response');

      if (foodsArray.isEmpty) {
        print('🤖 LLMFoodService: No foods found for query: $query');
        return Success([]);
      }

      final results = foodsArray.map((food) {
        final foodMap = food as Map<String, dynamic>;
        final name = foodMap['name'] as String? ?? '';
        final description = foodMap['description'] as String? ?? '';
        final type = foodMap['type'] as String? ?? '';
        
        // Parse meal tags from response
        final mealTagsList = foodMap['mealTags'] as List<dynamic>? ?? [];
        final mealTags = mealTagsList.cast<String>();
        
        // Parse category tags from response
        final categoryTagsList = foodMap['categoryTags'] as List<dynamic>? ?? [];
        final categoryTags = categoryTagsList.cast<String>();
        
        // Parse nutrition information from response
        final nutritionMap = foodMap['nutrition'] as Map<String, dynamic>? ?? {};
        final calories = (nutritionMap['calories'] as num?)?.toDouble() ?? 0.0;
        final protein = (nutritionMap['protein'] as num?)?.toDouble() ?? 0.0;
        final carbs = (nutritionMap['carbs'] as num?)?.toDouble() ?? 0.0;
        final fat = (nutritionMap['fat'] as num?)?.toDouble() ?? 0.0;
        final fiber = (nutritionMap['fiber'] as num?)?.toDouble() ?? 0.0;
        final sugar = (nutritionMap['sugar'] as num?)?.toDouble() ?? 0.0;
        
        // Parse serving sizes from response
        final servingSizesList = foodMap['servingSizes'] as List<dynamic>? ?? [];
        final servingSizes = servingSizesList.map((serving) {
          final servingMap = serving as Map<String, dynamic>;
          return OnlineServingSize(
            name: servingMap['name'] as String? ?? 'Standard portion',
            grams: (servingMap['weight'] as num?)?.toDouble() ?? 100.0,
            isDefault: servingMap['isDefault'] as bool? ?? false,
            originalUnit: servingMap['originalUnit'] as String? ?? '',
            originalAmount: (servingMap['originalAmount'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList();
        
        // If no serving sizes provided, add default ones
        if (servingSizes.isEmpty) {
          servingSizes.addAll([
            const OnlineServingSize(name: 'Standard portion', grams: 100.0, isDefault: true),
            const OnlineServingSize(name: 'Lille portion', grams: 75.0, isDefault: false),
            const OnlineServingSize(name: 'Stor portion', grams: 150.0, isDefault: false),
          ]);
        }
        
        // Combine both meal and category tags
        final allTags = <String>[...mealTags, ...categoryTags];
        
        print('🤖 LLMFoodService: Food "$name" has nutrition: ${calories}kcal, serving sizes: ${servingSizes.length}');
        
        // Use the type from JSON response if available, otherwise determine automatically
        SearchMode resultSearchMode;
        if (type == 'dish') {
          resultSearchMode = SearchMode.dishes;
        } else if (type == 'ingredient') {
          resultSearchMode = SearchMode.ingredients;
        } else {
          resultSearchMode = _determineSearchMode(name);
        }

        final foodResult = OnlineFoodResult(
          id: name,
          name: name,
          description: description,
          provider: _providerId,
          estimatedCalories: calories, // Now we have real calories
          tags: FoodTags(
            customTags: allTags, // Use combined tags as custom tags
          ),
          searchMode: resultSearchMode,
        );
        
        // Cache complete details for immediate access
        _detailsCache[name] = OnlineFoodDetails(
          basicInfo: foodResult,
          nutrition: NutritionInfo(
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            fiber: fiber,
            sugar: sugar,
            unit: '100g',
          ),
          servingSizes: servingSizes,
          ingredients: foodMap['ingredients'] as String? ?? '',
          instructions: foodMap['instructions'] as String? ?? '',
        );
        
        return foodResult;
      }).toList();

      print('🤖 LLMFoodService: Generated ${results.length} food results for "$query"');
      return Success(results);
    } catch (e, stackTrace) { // Added stackTrace
      print('❌ LLMFoodService: Search error: $e');
      print('❌ LLMFoodService: Search error stack trace: $stackTrace'); // Log stack trace

      // Try to interpret the error more specifically
      if (e is InvalidApiKey) { // Catching specific SDK error
        print('❌ LLMFoodService: Detected InvalidApiKey from SDK.');
        return Failure(OnlineFoodError.apiKeyMissing);
      }
      if (e.toString().contains('API key not valid')) {
        print('❌ LLMFoodService: Error string indicates invalid API key.');
        return Failure(OnlineFoodError.apiKeyMissing);
      }
      if (e is GenerativeAIException) { // Catching general SDK exception
         print('❌ LLMFoodService: Detected GenerativeAIException: ${e.message}');
         if (e.message.contains('timed out')) {
           return Failure(OnlineFoodError.networkError); // Or a new timeout error
         }
         // Check for other specific messages if needed
      }
      return Failure(OnlineFoodError.networkError); // Default to network error for others
    }
  }

  @override
  Future<Result<OnlineFoodDetails, OnlineFoodError>> getFoodDetails(String externalId) async {
    try {
      print('🤖 LLMFoodService: getFoodDetails called for ID: $externalId');
      if (_detailsCache.containsKey(externalId)) {
        final cachedDetails = _detailsCache[externalId]!;
        print('✅ LLMFoodService: Returning cached details for: ${cachedDetails.basicInfo.name}');
        return Success(cachedDetails);
      } else {
        // If not in cache, it means the initial search didn't populate it,
        // or the ID is genuinely not one we've processed.
        print('⚠️ LLMFoodService: Details not found in cache for ID: $externalId. This might indicate an issue if the ID was expected from a previous LLM search.');
        return Failure(OnlineFoodError.noResults); 
      }
    } catch (e, stackTrace) {
      print('❌ LLMFoodService: Unexpected error in getFoodDetails for ID: $externalId. Exception: $e');
      print('❌ LLMFoodService: StackTrace: $stackTrace');
      return Failure(OnlineFoodError.unknown);
    }
  }

  List<OnlineFoodResult> _parseSearchResponse(String response, String originalQuery) {
    try {
      // Clean response and extract food names
      final lines = response.split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty && !line.startsWith('Du er') && !line.startsWith('Hvis'))
          .take(8) // Max 8 results
          .toList();

      if (lines.isEmpty) {
        return _createFallbackResults(originalQuery);
      }

      return lines.map((foodName) {
        // Clean the food name
        final cleanName = foodName
            .replaceAll(RegExp(r'^[-*•]\s*'), '') // Remove bullet points
            .replaceAll(RegExp(r'^\d+\.\s*'), '') // Remove numbers
            .trim();

        if (cleanName.isEmpty) return null;

        return OnlineFoodResult(
          id: 'llm_$cleanName',
          name: cleanName,
          description: 'AI-genereret madprodukt',
          imageUrl: _generateFoodImageUrl(cleanName),
          provider: _providerId,
          searchMode: _determineSearchMode(cleanName),
          estimatedCalories: _estimateCalories(cleanName).toDouble(),
        );
      })
      .where((result) => result != null)
      .cast<OnlineFoodResult>()
      .toList();
    } catch (e) {
      print('🤖 LLMFoodService: Error parsing search response: $e');
      return _createFallbackResults(originalQuery);
    }
  }

  List<OnlineFoodResult> _createFallbackResults(String query) {
    // Create some fallback results based on common Danish foods
    final fallbackFoods = [
      'Æble', 'Banan', 'Rugbrød', 'Kylling', 'Ris'
    ];

    return fallbackFoods.map((name) => OnlineFoodResult(
      id: 'llm_fallback_$name',
      name: name,
      description: 'Almindelig dansk mad',
      imageUrl: _generateFoodImageUrl(name),
      provider: _providerId,
      searchMode: _determineSearchMode(name),
      estimatedCalories: _estimateCalories(name).toDouble(),
    )).toList();
  }

  OnlineFoodDetails _parseDetailsResponse(String response, String foodName) {
    try {
      // Try to parse JSON response
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        final jsonString = response.substring(jsonStart, jsonEnd);
        final data = jsonDecode(jsonString);
        
        return OnlineFoodDetails(
          basicInfo: OnlineFoodResult(
            id: 'llm_details_$foodName',
            name: data['name'] ?? foodName,
            description: 'AI-genereret mad detaljer',
            imageUrl: _generateFoodImageUrl(foodName),
            provider: _providerId,
            searchMode: _determineSearchMode(foodName),
            estimatedCalories: (data['caloriesPer100g'] ?? 200).toDouble(),
          ),
          nutrition: NutritionInfo(
            calories: (data['caloriesPer100g'] ?? 200).toDouble(),
            protein: (data['proteinPer100g'] ?? 10).toDouble(),
            carbs: (data['carbsPer100g'] ?? 20).toDouble(),
            fat: (data['fatPer100g'] ?? 5).toDouble(),
          ),
          servingSizes: [
            const OnlineServingSize(name: '1 portion', grams: 100, isDefault: true),
            const OnlineServingSize(name: '1 stor portion', grams: 150, isDefault: false),
          ],
        );
      }
    } catch (e) {
      print('🤖 LLMFoodService: Error parsing details response: $e');
    }
    
    // Fallback details
    return OnlineFoodDetails(
      basicInfo: OnlineFoodResult(
        id: 'llm_details_$foodName',
        name: foodName,
        description: 'AI-genereret mad detaljer',
        imageUrl: _generateFoodImageUrl(foodName),
        provider: _providerId,
        searchMode: _determineSearchMode(foodName),
        estimatedCalories: _estimateCalories(foodName).toDouble(),
      ),
      nutrition: NutritionInfo(
        calories: _estimateCalories(foodName).toDouble(),
        protein: 10.0,
        carbs: 20.0,
        fat: 5.0,
      ),
      servingSizes: [
        const OnlineServingSize(name: '1 portion', grams: 100, isDefault: true),
        const OnlineServingSize(name: '1 stor portion', grams: 150, isDefault: false),
      ],
    );
  }

  /// Generate a food image URL using a food image API
  String _generateFoodImageUrl(String foodName) {
    // Clean and format the food name for URL
    final cleanFoodName = foodName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')  // Remove special chars
        .replaceAll(RegExp(r'\s+'), '+');        // Replace spaces with +
    
    // Try multiple image sources for better food images
    final imageServices = [
      // Use Unsplash with new API format
      'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=400&h=300&fit=crop&auto=format&q=60', // Generic food image
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400&h=300&fit=crop&auto=format&q=60', // Generic healthy food
      'https://images.unsplash.com/photo-1498837167922-ddd27525d352?w=400&h=300&fit=crop&auto=format&q=60', // Generic fresh food
    ];
    
    // Map specific food types to better images
    final foodImageMap = {
      'apple': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400&h=300&fit=crop&auto=format&q=60',
      'banana': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400&h=300&fit=crop&auto=format&q=60',
      'pizza': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=400&h=300&fit=crop&auto=format&q=60',
      'pasta': 'https://images.unsplash.com/photo-1551183053-bf91a1d81141?w=400&h=300&fit=crop&auto=format&q=60',
      'bread': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400&h=300&fit=crop&auto=format&q=60',
      'salad': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop&auto=format&q=60',
      'chicken': 'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400&h=300&fit=crop&auto=format&q=60',
      'fish': 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=400&h=300&fit=crop&auto=format&q=60',
      'fruit': 'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400&h=300&fit=crop&auto=format&q=60',
      'vegetable': 'https://images.unsplash.com/photo-1540420773420-3366772f4999?w=400&h=300&fit=crop&auto=format&q=60',
      'dairy': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400&h=300&fit=crop&auto=format&q=60',
      'egg': 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400&h=300&fit=crop&auto=format&q=60',
      'cheese': 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400&h=300&fit=crop&auto=format&q=60',
      'meat': 'https://images.unsplash.com/photo-1588168333986-5078d3ae3976?w=400&h=300&fit=crop&auto=format&q=60',
    };
    
    // Check if we have a specific image for this food type
    for (final entry in foodImageMap.entries) {
      if (cleanFoodName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Danish food mappings
    final danishFoodMap = {
      'æble': foodImageMap['apple']!,
      'banan': foodImageMap['banana']!,
      'pizza': foodImageMap['pizza']!,
      'pasta': foodImageMap['pasta']!,
      'brød': foodImageMap['bread']!,
      'salat': foodImageMap['salad']!,
      'kylling': foodImageMap['chicken']!,
      'fisk': foodImageMap['fish']!,
      'frugt': foodImageMap['fruit']!,
      'grøntsag': foodImageMap['vegetable']!,
      'mælk': foodImageMap['dairy']!,
      'æg': foodImageMap['egg']!,
      'ost': foodImageMap['cheese']!,
      'kød': foodImageMap['meat']!,
    };
    
    // Check Danish words
    for (final entry in danishFoodMap.entries) {
      if (cleanFoodName.contains(entry.key)) {
        return entry.value;
      }
    }
    
    // Return a generic food image
    return imageServices[0];
  }

  int _estimateCalories(String foodName) {
    final name = foodName.toLowerCase();
    
    // Fruit - generally low calorie
    if (name.contains('æble') || name.contains('apple') || 
        name.contains('appelsin') || name.contains('orange') ||
        name.contains('pære') || name.contains('pear')) {
      return 50;
    }
    if (name.contains('banan') || name.contains('banana')) return 90;
    if (name.contains('mango')) return 60;
    if (name.contains('jordbær') || name.contains('strawberry')) return 30;
    if (name.contains('blåbær') || name.contains('blueberry')) return 60;
    
    // Vegetables - very low calorie
    if (name.contains('salat') || name.contains('lettuce') ||
        name.contains('tomat') || name.contains('tomato') ||
        name.contains('gulerod') || name.contains('carrot') ||
        name.contains('broccoli') || name.contains('spinat')) {
      return 25;
    }
    
    // Grains and carbs - medium-high calorie
    if (name.contains('brød') || name.contains('bread')) return 250;
    if (name.contains('pasta') || name.contains('spaghetti')) return 350;
    if (name.contains('ris') || name.contains('rice')) return 130;
    if (name.contains('havre') || name.contains('oats') || name.contains('müsli')) return 380;
    if (name.contains('pizza')) return 270;
    
    // Proteins - medium-high calorie
    if (name.contains('kylling') || name.contains('chicken')) return 165;
    if (name.contains('oksekød') || name.contains('beef')) return 250;
    if (name.contains('laks') || name.contains('salmon')) return 200;
    if (name.contains('fisk') || name.contains('fish')) return 180;
    if (name.contains('æg') || name.contains('egg')) return 155;
    
    // Dairy - medium calorie
    if (name.contains('mælk') || name.contains('milk')) return 60;
    if (name.contains('yoghurt') || name.contains('yogurt')) return 80;
    if (name.contains('ost') || name.contains('cheese')) return 350;
    
    // Nuts and oils - very high calorie
    if (name.contains('nød') || name.contains('nut') ||
        name.contains('olie') || name.contains('oil')) {
      return 600;
    }
    
    // Default for unknown foods
    return 150;
  }

  /// Clean JSON response by removing markdown code blocks
  String _cleanJsonResponse(String response) {
    String cleaned = response.trim();
    
    // Remove markdown code blocks
    if (cleaned.startsWith('```json')) {
      cleaned = cleaned.substring(7); // Remove ```json
    }
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.substring(3); // Remove ```
    }
    if (cleaned.endsWith('```')) {
      cleaned = cleaned.substring(0, cleaned.length - 3); // Remove ```
    }
    
    return cleaned.trim();
  }

  SearchMode _determineSearchMode(String name) {
    final nameWords = name.toLowerCase();
    
    // Keywords that indicate a complete dish/meal
    final dishKeywords = [
      'ret', 'måltid', 'middag', 'morgenmad', 'frokost', 'aftensmad',
      'salat', 'suppe', 'steg', 'gryde', 'pizza', 'pasta', 'sandwich',
      'burger', 'sushi', 'curry', 'lasagne', 'risotto', 'omelet',
      'med', 'og', 'i', 'på', 'til', // Prepositions often indicate prepared dishes
      'serveret', 'tilberedt', 'kogt', 'stegt', 'bagt', 'grillet'
    ];
    
    // Keywords that indicate single ingredients
    final ingredientKeywords = [
      'frugt', 'grøntsag', 'kød', 'fisk', 'mejeriproduk', 'korn', 'nød',
      'olie', 'krydderi', 'æg', 'mælk', 'ost', 'smør', 'mel',
      'rå', 'frisk', 'tør', 'pulver', 'juice'
    ];
    
    // Check for dish indicators
    for (final keyword in dishKeywords) {
      if (nameWords.contains(keyword)) {
        return SearchMode.dishes;
      }
    }
    
    // Check for ingredient indicators
    for (final keyword in ingredientKeywords) {
      if (nameWords.contains(keyword)) {
        return SearchMode.ingredients;
      }
    }
    
    // If the name has multiple words or contains common dish patterns, likely a dish
    if (nameWords.split(' ').length > 2 || 
        nameWords.contains(' med ') || 
        nameWords.contains(' og ') ||
        nameWords.contains(' i ') ||
        nameWords.contains(' på ')) {
      return SearchMode.dishes;
    }
    
    // Single word items are more likely ingredients unless they're clearly dishes
    final commonDishes = ['pizza', 'pasta', 'salat', 'suppe', 'burger', 'sandwich'];
    if (commonDishes.any((dish) => nameWords.contains(dish))) {
      return SearchMode.dishes;
    }
    
    // Default to ingredients for single words
    return SearchMode.ingredients;
  }

  OnlineFoodDetails _createFoodDetailsFromMap(Map<String, dynamic> foodMap, String externalId) {
    print('🤖 LLMFoodService: _createFoodDetailsFromMap called for ID: $externalId, Data: $foodMap');
    try {
      final basicInfo = _createFoodResultFromMap(foodMap, externalId);
      final nutritionMap = foodMap['nutrition'] as Map<String, dynamic>? ?? {};
      final calories = (nutritionMap['calories'] as num?)?.toDouble() ?? 0.0;
      final protein = (nutritionMap['protein'] as num?)?.toDouble() ?? 0.0;
      final carbs = (nutritionMap['carbs'] as num?)?.toDouble() ?? 0.0;
      final fat = (nutritionMap['fat'] as num?)?.toDouble() ?? 0.0;
      final fiber = (nutritionMap['fiber'] as num?)?.toDouble() ?? 0.0;
      final sugar = (nutritionMap['sugar'] as num?)?.toDouble() ?? 0.0;
      final servingSizes = foodMap['servingSizes'] as List<dynamic>? ?? [];
      final foodDetails = OnlineFoodDetails(
        basicInfo: basicInfo,
        nutrition: NutritionInfo(
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          fiber: fiber,
          sugar: sugar,
          unit: '100g',
        ),
        servingSizes: servingSizes.map((serving) {
          final servingMap = serving as Map<String, dynamic>;
          return OnlineServingSize(
            name: servingMap['name'] as String? ?? 'Standard portion',
            grams: (servingMap['weight'] as num?)?.toDouble() ?? 100.0,
            isDefault: servingMap['isDefault'] as bool? ?? false,
            originalUnit: servingMap['originalUnit'] as String? ?? '',
            originalAmount: (servingMap['originalAmount'] as num?)?.toDouble() ?? 0.0,
          );
        }).toList(),
        ingredients: foodMap['ingredients'] as String? ?? '',
        instructions: foodMap['instructions'] as String? ?? '',
      );
      print('✅ LLMFoodService: Successfully created FoodDetails for $externalId');
      return foodDetails;
    } catch (e, stacktrace) {
      print('❌ LLMFoodService: Failed to create FoodDetails from map for ID: $externalId. Error: $e');
      print('❌ LLMFoodService: Data causing error: $foodMap');
      print('❌ LLMFoodService: Stacktrace: $stacktrace');
      rethrow; // Rethrow to be caught by the caller, which can then return a specific error
    }
  }

  OnlineFoodResult _createFoodResultFromMap(Map<String, dynamic> foodMap, String externalId) {
    print('🤖 LLMFoodService: _createFoodResultFromMap called for ID: $externalId, Data: $foodMap');
    try {
      final tagsMap = foodMap['tags'] as Map<String, dynamic>?;
      final foodTags = tagsMap != null ? FoodTags.fromJson(tagsMap) : const FoodTags();
      final name = foodMap['name'] as String? ?? '';
      final description = foodMap['description'] as String? ?? '';
      final type = foodMap['type'] as String? ?? '';
      final calories = (foodMap['nutrition'] as Map<String, dynamic>?)?['calories'] as num? ?? 0;
      final protein = (foodMap['nutrition'] as Map<String, dynamic>?)?['protein'] as num? ?? 0;
      final carbs = (foodMap['nutrition'] as Map<String, dynamic>?)?['carbs'] as num? ?? 0;
      final fat = (foodMap['nutrition'] as Map<String, dynamic>?)?['fat'] as num? ?? 0;
      final fiber = (foodMap['nutrition'] as Map<String, dynamic>?)?['fiber'] as num? ?? 0;
      final sugar = (foodMap['nutrition'] as Map<String, dynamic>?)?['sugar'] as num? ?? 0;
      final servingSizes = foodMap['servingSizes'] as List<dynamic>? ?? [];
      final searchMode = _determineSearchMode(name);
      final foodResult = OnlineFoodResult(
        id: name,
        name: name,
        description: description,
        provider: _providerId,
        estimatedCalories: calories.toDouble(),
        tags: foodTags,
        searchMode: searchMode,
      );
      print('✅ LLMFoodService: Successfully created FoodResult for $externalId');
      return foodResult;
    } catch (e, stacktrace) {
      print('❌ LLMFoodService: Failed to create FoodResult from map for ID: $externalId. Error: $e');
      print('❌ LLMFoodService: Data causing error: $foodMap');
      print('❌ LLMFoodService: Stacktrace: $stacktrace');
      rethrow; // Rethrow to allow specific error handling if needed
    }
  }
} 