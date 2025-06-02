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
enum OnlineFoodType {
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

  const OnlineFoodType(this.displayName, this.emoji);
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

// Helper function for case-insensitive enum list parsing
List<T> _enumListFromStringList<T>(List<String> stringList, Map<Object?, T> enumMap) {
  final List<T> result = [];
  // Create a reverse map from lowercase string to enum value
  final Map<String, T> reverseEnumMap = enumMap.map((k, v) => MapEntry(k.toString().split('.').last.toLowerCase(), v as T));
  final Map<String, T> reverseEnumMapOriginalCase = enumMap.map((k, v) => MapEntry(k.toString().split('.').last, v as T));


  for (final s in stringList) {
    // Try original case first, then lowercase
    T? enumValue = reverseEnumMapOriginalCase[s];
    enumValue ??= reverseEnumMap[s.toLowerCase()];
    
    if (enumValue != null) {
      result.add(enumValue);
    } else {
      print('⚠️ _enumListFromStringList: Could not parse enum value: "$s" for type $T');
    }
  }
  return result;
}

// Enhanced food tags model
@freezed
class FoodTags with _$FoodTags {
  const factory FoodTags({
    @JsonKey(fromJson: _foodTypesFromJsonLenient) @Default([]) List<OnlineFoodType> foodTypes,
    @JsonKey(fromJson: _cuisineStylesFromJsonLenient) @Default([]) List<CuisineStyle> cuisineStyles,
    @Default([]) List<DietaryTag> dietaryTags,
    @JsonKey(fromJson: _preparationTypesFromJsonLenient) @Default([]) List<PreparationType> preparationTypes,
    @Default([]) List<String> customTags,
  }) = _FoodTags;

  factory FoodTags.fromJson(Map<String, dynamic> json) => _$FoodTagsFromJson(json);
}

// Custom lenient fromJson for foodTypes
List<OnlineFoodType> _foodTypesFromJsonLenient(List<dynamic> jsonList) {
  if (jsonList.isEmpty) return [];
  return jsonList
      .map((e) {
        final val = e as String?;
        if (val == null || val.trim().isEmpty) return null;

        OnlineFoodType? type = $enumDecodeNullable(_$OnlineFoodTypeEnumMap, val);
        type ??= $enumDecodeNullable(_$OnlineFoodTypeEnumMap, val.toLowerCase());

        if (type == null) {
          for (final enumValue in OnlineFoodType.values) {
            if (enumValue.displayName.toLowerCase() == val.toLowerCase()) {
              type = enumValue;
              break;
            }
          }
        }
            
        if (type == null) {
          print('⚠️ _foodTypesFromJsonLenient: Could not parse OnlineFoodType value: "$val", defaulting to processed.');
          type = OnlineFoodType.processed; 
        }
        return type;
      })
      .where((element) => element != null)
      .cast<OnlineFoodType>()
      .toList();
}

// Custom lenient fromJson for cuisineStyles
List<CuisineStyle> _cuisineStylesFromJsonLenient(List<dynamic> jsonList) {
  if (jsonList.isEmpty) return [];
  return jsonList
      .map((e) {
        final val = e as String?;
        if (val == null || val.trim().isEmpty) return null;

        CuisineStyle? style = $enumDecodeNullable(_$CuisineStyleEnumMap, val);
        style ??= $enumDecodeNullable(_$CuisineStyleEnumMap, val.toLowerCase());
        
        if (style == null) {
          for (final enumValue in CuisineStyle.values) {
            if (enumValue.displayName.toLowerCase() == val.toLowerCase()) {
              style = enumValue;
              break;
            }
          }
        }

        if (style == null) {
          print('⚠️ _cuisineStylesFromJsonLenient: Could not parse CuisineStyle value: "$val", defaulting to international.');
          style = CuisineStyle.international;
        }
        return style;
      })
      .where((element) => element != null)
      .cast<CuisineStyle>()
      .toList();
}

// Custom lenient fromJson for preparationTypes
List<PreparationType> _preparationTypesFromJsonLenient(List<dynamic> jsonList) {
  if (jsonList.isEmpty) return [];
  return jsonList
      .map((e) {
        final val = e as String?;
        if (val == null || val.trim().isEmpty) return null;

        PreparationType? type = $enumDecodeNullable(_$PreparationTypeEnumMap, val);
        type ??= $enumDecodeNullable(_$PreparationTypeEnumMap, val.toLowerCase());

        if (type == null) {
          for (final enumValue in PreparationType.values) {
            if (enumValue.displayName.toLowerCase() == val.toLowerCase()) {
              type = enumValue;
              break;
            }
          }
        }
            
        if (type == null) {
          print('⚠️ _preparationTypesFromJsonLenient: Could not parse PreparationType value: "$val", defaulting to raw.');
          type = PreparationType.raw;
        }
        return type;
      })
      .where((element) => element != null)
      .cast<PreparationType>()
      .toList();
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
    @JsonKey(fromJson: _searchModeFromJsonLenient) required SearchMode searchMode,
    @Default(FoodTags()) FoodTags tags,
    @Default(0) double estimatedCalories,
  }) = _OnlineFoodResult;

  factory OnlineFoodResult.fromJson(Map<String, dynamic> json) => 
      _$OnlineFoodResultFromJson(json);
}

// Custom lenient fromJson for SearchMode
SearchMode _searchModeFromJsonLenient(String? val) {
  if (val == null || val.trim().isEmpty) {
    print('⚠️ _searchModeFromJsonLenient: Received null or empty value, defaulting to SearchMode.dishes');
    return SearchMode.dishes;
  }

  SearchMode? mode = $enumDecodeNullable(_$SearchModeEnumMap, val);
  mode ??= $enumDecodeNullable(_$SearchModeEnumMap, val.toLowerCase());

  if (mode == null) {
    for (final enumValue in SearchMode.values) {
      if (enumValue.displayName.toLowerCase() == val.toLowerCase()) {
        mode = enumValue;
        break;
      }
    }
  }

  if (mode == null) {
    print('⚠️ _searchModeFromJsonLenient: Could not parse SearchMode value: "$val", defaulting to SearchMode.dishes');
    mode = SearchMode.dishes; 
  }
  return mode;
}

/// Detailed nutrition information from online provider
@freezed
class OnlineFoodDetails with _$OnlineFoodDetails {
  const factory OnlineFoodDetails({
    required OnlineFoodResult basicInfo,
    required NutritionInfo nutrition,
    @Default([]) List<OnlineServingSize> servingSizes,
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
    return '��️';
  }
  
  static OnlineFoodType getFoodType(String foodName) {
    final name = foodName.toLowerCase();
    
    // Frugt
    if (name.contains('æble') || name.contains('banan') || name.contains('appelsin') || 
        name.contains('jordbær') || name.contains('blåbær') || name.contains('pære') ||
        name.contains('mango') || name.contains('ananas') || name.contains('citron') ||
        name.contains('frugt')) {
      return OnlineFoodType.fruit;
    }
    
    // Grøntsager
    if (name.contains('tomat') || name.contains('gulerod') || name.contains('broccoli') ||
        name.contains('salat') || name.contains('spinat') || name.contains('løg') ||
        name.contains('kartoffel') || name.contains('grønt')) {
      return OnlineFoodType.vegetable;
    }
    
    // Kød
    if (name.contains('kylling') || name.contains('oksekød') || name.contains('svinekød') ||
        name.contains('lam') || name.contains('kød')) {
      return OnlineFoodType.meat;
    }
    
    // Fisk
    if (name.contains('laks') || name.contains('tuna') || name.contains('torsk') ||
        name.contains('rejer') || name.contains('fisk')) {
      return OnlineFoodType.fish;
    }
    
    // Mejeriprodukter
    if (name.contains('mælk') || name.contains('ost') || name.contains('yoghurt') ||
        name.contains('smør') || name.contains('fløde')) {
      return OnlineFoodType.dairy;
    }
    
    // Korn og brød
    if (name.contains('brød') || name.contains('pasta') || name.contains('ris') ||
        name.contains('havre') || name.contains('müsli') || name.contains('quinoa')) {
      return OnlineFoodType.grain;
    }
    
    // Nødder
    if (name.contains('mandel') || name.contains('valnød') || name.contains('hasselnød') ||
        name.contains('nød')) {
      return OnlineFoodType.nuts;
    }
    
    // Drikkevarer
    if (name.contains('kaffe') || name.contains('te') || name.contains('juice') ||
        name.contains('øl') || name.contains('vin') || name.contains('vand') ||
        name.contains('sodavand')) {
      return OnlineFoodType.beverages;
    }
    
    // Søde sager
    if (name.contains('chokolade') || name.contains('kage') || name.contains('cookie') ||
        name.contains('is') || name.contains('slik')) {
      return OnlineFoodType.sweets;
    }
    
    // Default til retter hvis det lyder som en komplet ret
    if (name.contains('ret') || name.contains('måltid') || name.contains('pizza') ||
        name.contains('burger') || name.contains('sandwich')) {
      return OnlineFoodType.dishes;
    }
    
    return OnlineFoodType.processed; // Default
  }
} 