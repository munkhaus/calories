import 'package:freezed_annotation/freezed_annotation.dart';
import 'food_record_model.dart';

part 'online_food_models.freezed.dart';
part 'online_food_models.g.dart';

// Search mode enum
enum SearchMode {
  dishes('Retter', '🍽️', 'Komplette retter og måltider'),
  ingredients('Ingredienser', '🥕', 'Enkelte fødevarer og ingredienser');

  const SearchMode(this.displayName, this.emoji, this.description);
  final String displayName;
  final String emoji;
  final String description;
}

// Enhanced food tag system
enum FoodType {
  fruit('Frugt', '🍎'),
  vegetable('Grøntsager', '🥕'),
  meat('Kød', '🥩'),
  fish('Fisk', '🐟'),
  dairy('Mejeriprodukter', '🥛'),
  grain('Korn & Brød', '🌾'),
  nuts('Nødder', '🥜'),
  legumes('Bælgfrugter', '🫘'),
  herbs('Krydderier', '🌿'),
  beverages('Drikkevarer', '🥤'),
  sweets('Søde sager', '🍰'),
  oils('Olier & Fedtstoffer', '🫒'),
  processed('Forarbejdede fødevarer', '🥫'),
  dishes('Retter', '🍽️');

  const FoodType(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

enum CuisineStyle {
  danish('Dansk', '🇩🇰'),
  italian('Italiensk', '🇮🇹'),
  asian('Asiatisk', '🥢'),
  mexican('Mexicansk', '🌮'),
  french('Fransk', '🇫🇷'),
  indian('Indisk', '🇮🇳'),
  middle_eastern('Mellemøstlig', '🫓'),
  american('Amerikansk', '🇺🇸'),
  greek('Græsk', '🇬🇷'),
  thai('Thai', '🇹🇭'),
  japanese('Japansk', '🍱'),
  international('International', '🌍');

  const CuisineStyle(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

enum DietaryTag {
  vegetarian('Vegetarisk', '🌱'),
  vegan('Vegansk', '🌿'),
  glutenFree('Glutenfri', '🚫🌾'),
  lactoseFree('Laktosefri', '🚫🥛'),
  keto('Keto', '🥑'),
  lowCarb('Lavt kulhydrat', '📉'),
  highProtein('Højt protein', '💪'),
  organic('Økologisk', '♻️'),
  raw('Rå', '🥗'),
  sugarFree('Sukkerfri', '🚫🍯');

  const DietaryTag(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

enum PreparationType {
  raw('Rå', '🥗'),
  boiled('Kogt', '💧'),
  grilled('Grillet', '🔥'),
  fried('Stegt', '🍳'),
  baked('Bagt', '🔥'),
  steamed('Dampet', '💨'),
  roasted('Ristet', '🔥'),
  fresh('Frisk', '✨');

  const PreparationType(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

// Enhanced food tags model
@freezed
class FoodTags with _$FoodTags {
  const factory FoodTags({
    @Default([]) List<FoodType> foodTypes,
    @Default([]) List<CuisineStyle> cuisineStyles,
    @Default([]) List<DietaryTag> dietaryTags,
    @Default([]) List<PreparationType> preparationTypes,
    @Default([]) List<String> customTags, // For flexible tagging
  }) = _FoodTags;

  factory FoodTags.fromJson(Map<String, dynamic> json) => _$FoodTagsFromJson(json);
}

// Search request with mode
@freezed
class OnlineFoodSearchRequest with _$OnlineFoodSearchRequest {
  const factory OnlineFoodSearchRequest({
    required String query,
    @Default(SearchMode.dishes) SearchMode searchMode,
    FoodTags? filterTags,
    @Default(25) int maxResults,
  }) = _OnlineFoodSearchRequest;

  factory OnlineFoodSearchRequest.fromJson(Map<String, dynamic> json) => 
      _$OnlineFoodSearchRequestFromJson(json);
}

/// Standardized result from online food search
@freezed
class OnlineFoodResult with _$OnlineFoodResult {
  const factory OnlineFoodResult({
    required String id,
    required String name,
    required String description,
    @Default('') String imageUrl,
    required String provider,
    required SearchMode searchMode, // Whether this is a dish or ingredient
    @Default(FoodTags()) FoodTags tags,
    @Default(0) double estimatedCalories, // Per 100g estimate for quick filtering
  }) = _OnlineFoodResult;

  factory OnlineFoodResult.fromJson(Map<String, dynamic> json) => 
      _$OnlineFoodResultFromJson(json);
}

/// Detailed nutrition information from online provider
@freezed
class OnlineFoodDetails with _$OnlineFoodDetails {
  const factory OnlineFoodDetails({
    required OnlineFoodResult basicInfo,
    required NutritionInfo nutrition,
    @Default([]) List<ServingInfo> servingSizes,
    @Default('') String ingredients,
    @Default('') String instructions,
  }) = _OnlineFoodDetails;

  factory OnlineFoodDetails.fromJson(Map<String, dynamic> json) => 
      _$OnlineFoodDetailsFromJson(json);
}

@freezed
class NutritionInfo with _$NutritionInfo {
  const factory NutritionInfo({
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    @Default(0.0) double fiber,
    @Default(0.0) double sugar,
    @Default(0.0) double sodium,
    String? unit, // Per 100g, per serving, etc.
  }) = _NutritionInfo;

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => 
      _$NutritionInfoFromJson(json);
}

@freezed
class ServingInfo with _$ServingInfo {
  const factory ServingInfo({
    required String name,
    required double grams,
    @Default(false) bool isDefault,
  }) = _ServingInfo;

  factory ServingInfo.fromJson(Map<String, dynamic> json) => 
      _$ServingInfoFromJson(json);
}

@freezed
class OnlineFoodSearchResults with _$OnlineFoodSearchResults {
  const factory OnlineFoodSearchResults({
    @Default([]) List<OnlineFoodResult> results,
    required String provider,
    required SearchMode searchMode,
    required String query,
    @Default(0) int totalFound,
  }) = _OnlineFoodSearchResults;

  factory OnlineFoodSearchResults.fromJson(Map<String, dynamic> json) => 
      _$OnlineFoodSearchResultsFromJson(json);
}

/// Serving size from online provider
@freezed
class OnlineServingSize with _$OnlineServingSize {
  const factory OnlineServingSize({
    @Default('') String name,
    @Default(0.0) double grams,
    @Default(false) bool isDefault,
    @Default('') String originalUnit, // "cup", "oz", etc.
    @Default(0.0) double originalAmount,
  }) = _OnlineServingSize;

  factory OnlineServingSize.fromJson(Map<String, dynamic> json) => 
      _$OnlineServingSizeFromJson(json);
}

/// Errors that can occur during online food operations
enum OnlineFoodError {
  networkError('Netværksfejl - tjek din internetforbindelse'),
  apiKeyMissing('API-nøgle mangler'),
  providerUnavailable('Tjenesten er ikke tilgængelig'),
  invalidResponse('Ugyldigt svar fra server'),
  noResults('Ingen resultater fundet'),
  unknown('Ukendt fejl opstod');

  const OnlineFoodError(this.message);
  final String message;
}

extension OnlineFoodErrorExtension on OnlineFoodError {
  String get message {
    switch (this) {
      case OnlineFoodError.networkError:
        return 'Netværksfejl - tjek din internetforbindelse';
      case OnlineFoodError.apiKeyMissing:
        return 'API nøgle mangler for denne tjeneste';
      case OnlineFoodError.providerUnavailable:
        return 'Tjenesten er ikke tilgængelig';
      case OnlineFoodError.invalidResponse:
        return 'Ugyldig svar fra tjenesten';
      case OnlineFoodError.noResults:
        return 'Ingen resultater fundet';
      case OnlineFoodError.unknown:
        return 'Ukendt fejl opstod';
    }
  }
}

// Food image helper
class FoodImageHelper {
  static String getFoodEmoji(String foodName) {
    final name = foodName.toLowerCase();
    
    // Frugt
    if (name.contains('æble')) return '🍎';
    if (name.contains('banan')) return '🍌';
    if (name.contains('appelsin') || name.contains('orange')) return '🍊';
    if (name.contains('jordbær')) return '🍓';
    if (name.contains('blåbær')) return '🫐';
    if (name.contains('pære')) return '🍐';
    if (name.contains('mango')) return '🥭';
    if (name.contains('ananas')) return '🍍';
    if (name.contains('citron')) return '🍋';
    if (name.contains('lime')) return '🟢';
    if (name.contains('fersken')) return '🍑';
    if (name.contains('kirsebær')) return '🍒';
    if (name.contains('melon')) return '🍈';
    if (name.contains('vandmelon')) return '🍉';
    if (name.contains('kiwi')) return '🥝';
    if (name.contains('avocado')) return '🥑';
    
    // Grøntsager
    if (name.contains('tomat')) return '🍅';
    if (name.contains('gulerod')) return '🥕';
    if (name.contains('broccoli')) return '🥦';
    if (name.contains('salat') || name.contains('iceberg')) return '🥬';
    if (name.contains('spinat')) return '🥬';
    if (name.contains('løg')) return '🧅';
    if (name.contains('hvidløg')) return '🧄';
    if (name.contains('kartoffel')) return '🥔';
    if (name.contains('peberfrugt') || name.contains('paprika')) return '🫑';
    if (name.contains('chili')) return '🌶️';
    if (name.contains('aubergine')) return '🍆';
    if (name.contains('squash') || name.contains('zucchini')) return '🥒';
    if (name.contains('agurk')) return '🥒';
    if (name.contains('majs')) return '🌽';
    if (name.contains('ært')) return '🟢';
    if (name.contains('bønne')) return '🫘';
    
    // Kød
    if (name.contains('kylling') || name.contains('høne')) return '🍗';
    if (name.contains('oksekød') || name.contains('bøf')) return '🥩';
    if (name.contains('svinekød') || name.contains('bacon')) return '🥓';
    if (name.contains('lam')) return '🐑';
    if (name.contains('pølse')) return '🌭';
    if (name.contains('hamburger')) return '🍔';
    
    // Fisk
    if (name.contains('laks')) return '🐟';
    if (name.contains('tuna') || name.contains('tunfisk')) return '🐟';
    if (name.contains('torsk')) return '🐟';
    if (name.contains('rejer')) return '🦐';
    if (name.contains('krabber')) return '🦀';
    if (name.contains('muslinger')) return '🦪';
    
    // Mejeriprodukter
    if (name.contains('mælk')) return '🥛';
    if (name.contains('ost')) return '🧀';
    if (name.contains('yoghurt') || name.contains('skyr')) return '🥛';
    if (name.contains('smør')) return '🧈';
    if (name.contains('fløde')) return '🥛';
    if (name.contains('is') && !name.contains('ris')) return '🍦';
    
    // Korn og brød
    if (name.contains('brød')) return '🍞';
    if (name.contains('pasta') || name.contains('spaghetti')) return '🍝';
    if (name.contains('ris')) return '🍚';
    if (name.contains('havre') || name.contains('müsli')) return '🥣';
    if (name.contains('quinoa')) return '🌾';
    if (name.contains('bulgur')) return '🌾';
    
    // Pizza og retter
    if (name.contains('pizza')) return '🍕';
    if (name.contains('burger')) return '🍔';
    if (name.contains('sandwich')) return '🥪';
    if (name.contains('taco')) return '🌮';
    if (name.contains('sushi')) return '🍣';
    if (name.contains('suppe')) return '🍲';
    if (name.contains('salat') && (name.contains('ret') || name.contains('blandet'))) return '🥗';
    
    // Nødder
    if (name.contains('mandel')) return '🥜';
    if (name.contains('valnød')) return '🥜';
    if (name.contains('hasselnød')) return '🥜';
    if (name.contains('peanut') || name.contains('jordnød')) return '🥜';
    
    // Drikkevarer
    if (name.contains('kaffe')) return '☕';
    if (name.contains('te')) return '🍵';
    if (name.contains('juice')) return '🧃';
    if (name.contains('øl')) return '🍺';
    if (name.contains('vin')) return '🍷';
    if (name.contains('vand')) return '💧';
    if (name.contains('sodavand') || name.contains('cola')) return '🥤';
    
    // Søde sager
    if (name.contains('chokolade')) return '🍫';
    if (name.contains('kage')) return '🍰';
    if (name.contains('cookie') || name.contains('småkage')) return '🍪';
    if (name.contains('is') && !name.contains('ris')) return '🍦';
    if (name.contains('slik')) return '🍬';
    
    // Default baseret på type
    if (name.contains('frugt')) return '🍎';
    if (name.contains('grønt') || name.contains('salat')) return '🥬';
    if (name.contains('kød')) return '🥩';
    if (name.contains('fisk')) return '🐟';
    if (name.contains('mælk')) return '🥛';
    if (name.contains('brød') || name.contains('korn')) return '🍞';
    
    // Fallback
    return '🍽️';
  }
  
  static FoodType getFoodType(String foodName) {
    final name = foodName.toLowerCase();
    
    // Frugt
    if (name.contains('æble') || name.contains('banan') || name.contains('appelsin') || 
        name.contains('jordbær') || name.contains('blåbær') || name.contains('pære') ||
        name.contains('mango') || name.contains('ananas') || name.contains('citron') ||
        name.contains('frugt')) {
      return FoodType.fruit;
    }
    
    // Grøntsager
    if (name.contains('tomat') || name.contains('gulerod') || name.contains('broccoli') ||
        name.contains('salat') || name.contains('spinat') || name.contains('løg') ||
        name.contains('kartoffel') || name.contains('grønt')) {
      return FoodType.vegetable;
    }
    
    // Kød
    if (name.contains('kylling') || name.contains('oksekød') || name.contains('svinekød') ||
        name.contains('lam') || name.contains('kød')) {
      return FoodType.meat;
    }
    
    // Fisk
    if (name.contains('laks') || name.contains('tuna') || name.contains('torsk') ||
        name.contains('rejer') || name.contains('fisk')) {
      return FoodType.fish;
    }
    
    // Mejeriprodukter
    if (name.contains('mælk') || name.contains('ost') || name.contains('yoghurt') ||
        name.contains('smør') || name.contains('fløde')) {
      return FoodType.dairy;
    }
    
    // Korn og brød
    if (name.contains('brød') || name.contains('pasta') || name.contains('ris') ||
        name.contains('havre') || name.contains('müsli') || name.contains('quinoa')) {
      return FoodType.grain;
    }
    
    // Nødder
    if (name.contains('mandel') || name.contains('valnød') || name.contains('hasselnød') ||
        name.contains('nød')) {
      return FoodType.nuts;
    }
    
    // Drikkevarer
    if (name.contains('kaffe') || name.contains('te') || name.contains('juice') ||
        name.contains('øl') || name.contains('vin') || name.contains('vand') ||
        name.contains('sodavand')) {
      return FoodType.beverages;
    }
    
    // Søde sager
    if (name.contains('chokolade') || name.contains('kage') || name.contains('cookie') ||
        name.contains('is') || name.contains('slik')) {
      return FoodType.sweets;
    }
    
    // Default til retter hvis det lyder som en komplet ret
    if (name.contains('ret') || name.contains('måltid') || name.contains('pizza') ||
        name.contains('burger') || name.contains('sandwich')) {
      return FoodType.dishes;
    }
    
    return FoodType.processed; // Default
  }
} 