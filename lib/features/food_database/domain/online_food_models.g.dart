// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'online_food_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FoodTagsImpl _$$FoodTagsImplFromJson(Map<String, dynamic> json) =>
    _$FoodTagsImpl(
      foodTypes: json['foodTypes'] == null
          ? const []
          : _foodTypesFromJsonLenient(json['foodTypes'] as List),
      cuisineStyles: json['cuisineStyles'] == null
          ? const []
          : _cuisineStylesFromJsonLenient(json['cuisineStyles'] as List),
      dietaryTags:
          (json['dietaryTags'] as List<dynamic>?)
              ?.map((e) => $enumDecode(_$DietaryTagEnumMap, e))
              .toList() ??
          const [],
      preparationTypes: json['preparationTypes'] == null
          ? const []
          : _preparationTypesFromJsonLenient(json['preparationTypes'] as List),
      customTags:
          (json['customTags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$FoodTagsImplToJson(_$FoodTagsImpl instance) =>
    <String, dynamic>{
      'foodTypes': instance.foodTypes
          .map((e) => _$OnlineFoodTypeEnumMap[e]!)
          .toList(),
      'cuisineStyles': instance.cuisineStyles
          .map((e) => _$CuisineStyleEnumMap[e]!)
          .toList(),
      'dietaryTags': instance.dietaryTags
          .map((e) => _$DietaryTagEnumMap[e]!)
          .toList(),
      'preparationTypes': instance.preparationTypes
          .map((e) => _$PreparationTypeEnumMap[e]!)
          .toList(),
      'customTags': instance.customTags,
    };

const _$DietaryTagEnumMap = {
  DietaryTag.vegetarian: 'vegetarian',
  DietaryTag.vegan: 'vegan',
  DietaryTag.glutenFree: 'glutenFree',
  DietaryTag.lactoseFree: 'lactoseFree',
  DietaryTag.keto: 'keto',
  DietaryTag.lowCarb: 'lowCarb',
  DietaryTag.highProtein: 'highProtein',
  DietaryTag.organic: 'organic',
  DietaryTag.raw: 'raw',
  DietaryTag.sugarFree: 'sugarFree',
};

const _$OnlineFoodTypeEnumMap = {
  OnlineFoodType.fruit: 'fruit',
  OnlineFoodType.vegetable: 'vegetable',
  OnlineFoodType.meat: 'meat',
  OnlineFoodType.fish: 'fish',
  OnlineFoodType.dairy: 'dairy',
  OnlineFoodType.grain: 'grain',
  OnlineFoodType.nuts: 'nuts',
  OnlineFoodType.legumes: 'legumes',
  OnlineFoodType.herbs: 'herbs',
  OnlineFoodType.beverages: 'beverages',
  OnlineFoodType.sweets: 'sweets',
  OnlineFoodType.oils: 'oils',
  OnlineFoodType.processed: 'processed',
  OnlineFoodType.dishes: 'dishes',
};

const _$CuisineStyleEnumMap = {
  CuisineStyle.danish: 'danish',
  CuisineStyle.italian: 'italian',
  CuisineStyle.asian: 'asian',
  CuisineStyle.mexican: 'mexican',
  CuisineStyle.french: 'french',
  CuisineStyle.indian: 'indian',
  CuisineStyle.middle_eastern: 'middle_eastern',
  CuisineStyle.american: 'american',
  CuisineStyle.greek: 'greek',
  CuisineStyle.thai: 'thai',
  CuisineStyle.japanese: 'japanese',
  CuisineStyle.international: 'international',
};

const _$PreparationTypeEnumMap = {
  PreparationType.raw: 'raw',
  PreparationType.boiled: 'boiled',
  PreparationType.grilled: 'grilled',
  PreparationType.fried: 'fried',
  PreparationType.baked: 'baked',
  PreparationType.steamed: 'steamed',
  PreparationType.roasted: 'roasted',
  PreparationType.fresh: 'fresh',
};

_$OnlineFoodSearchRequestImpl _$$OnlineFoodSearchRequestImplFromJson(
  Map<String, dynamic> json,
) => _$OnlineFoodSearchRequestImpl(
  query: json['query'] as String,
  searchMode:
      $enumDecodeNullable(_$SearchModeEnumMap, json['searchMode']) ??
      SearchMode.dishes,
  filterTags: json['filterTags'] == null
      ? null
      : FoodTags.fromJson(json['filterTags'] as Map<String, dynamic>),
  maxResults: (json['maxResults'] as num?)?.toInt() ?? 25,
);

Map<String, dynamic> _$$OnlineFoodSearchRequestImplToJson(
  _$OnlineFoodSearchRequestImpl instance,
) => <String, dynamic>{
  'query': instance.query,
  'searchMode': _$SearchModeEnumMap[instance.searchMode]!,
  'filterTags': instance.filterTags,
  'maxResults': instance.maxResults,
};

const _$SearchModeEnumMap = {
  SearchMode.dishes: 'dishes',
  SearchMode.ingredients: 'ingredients',
};

_$OnlineFoodResultImpl _$$OnlineFoodResultImplFromJson(
  Map<String, dynamic> json,
) => _$OnlineFoodResultImpl(
  id: json['id'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  imageUrl: json['imageUrl'] as String? ?? '',
  provider: json['provider'] as String,
  searchMode: _searchModeFromJsonLenient(json['searchMode'] as String?),
  tags: json['tags'] == null
      ? const FoodTags()
      : FoodTags.fromJson(json['tags'] as Map<String, dynamic>),
  estimatedCalories: (json['estimatedCalories'] as num?)?.toDouble() ?? 0,
);

Map<String, dynamic> _$$OnlineFoodResultImplToJson(
  _$OnlineFoodResultImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'description': instance.description,
  'imageUrl': instance.imageUrl,
  'provider': instance.provider,
  'searchMode': _$SearchModeEnumMap[instance.searchMode]!,
  'tags': instance.tags,
  'estimatedCalories': instance.estimatedCalories,
};

_$OnlineFoodDetailsImpl _$$OnlineFoodDetailsImplFromJson(
  Map<String, dynamic> json,
) => _$OnlineFoodDetailsImpl(
  basicInfo: OnlineFoodResult.fromJson(
    json['basicInfo'] as Map<String, dynamic>,
  ),
  nutrition: NutritionInfo.fromJson(json['nutrition'] as Map<String, dynamic>),
  servingSizes:
      (json['servingSizes'] as List<dynamic>?)
          ?.map((e) => OnlineServingSize.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  ingredients: json['ingredients'] as String? ?? '',
  instructions: json['instructions'] as String? ?? '',
);

Map<String, dynamic> _$$OnlineFoodDetailsImplToJson(
  _$OnlineFoodDetailsImpl instance,
) => <String, dynamic>{
  'basicInfo': instance.basicInfo,
  'nutrition': instance.nutrition,
  'servingSizes': instance.servingSizes,
  'ingredients': instance.ingredients,
  'instructions': instance.instructions,
};

_$NutritionInfoImpl _$$NutritionInfoImplFromJson(Map<String, dynamic> json) =>
    _$NutritionInfoImpl(
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(),
      fiber: (json['fiber'] as num?)?.toDouble() ?? 0.0,
      sugar: (json['sugar'] as num?)?.toDouble() ?? 0.0,
      sodium: (json['sodium'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$$NutritionInfoImplToJson(_$NutritionInfoImpl instance) =>
    <String, dynamic>{
      'calories': instance.calories,
      'protein': instance.protein,
      'carbs': instance.carbs,
      'fat': instance.fat,
      'fiber': instance.fiber,
      'sugar': instance.sugar,
      'sodium': instance.sodium,
      'unit': instance.unit,
    };

_$ServingInfoImpl _$$ServingInfoImplFromJson(Map<String, dynamic> json) =>
    _$ServingInfoImpl(
      name: json['name'] as String,
      grams: (json['grams'] as num).toDouble(),
      isDefault: json['isDefault'] as bool? ?? false,
    );

Map<String, dynamic> _$$ServingInfoImplToJson(_$ServingInfoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'grams': instance.grams,
      'isDefault': instance.isDefault,
    };

_$OnlineFoodSearchResultsImpl _$$OnlineFoodSearchResultsImplFromJson(
  Map<String, dynamic> json,
) => _$OnlineFoodSearchResultsImpl(
  results:
      (json['results'] as List<dynamic>?)
          ?.map((e) => OnlineFoodResult.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  provider: json['provider'] as String,
  searchMode: $enumDecode(_$SearchModeEnumMap, json['searchMode']),
  query: json['query'] as String,
  totalFound: (json['totalFound'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$$OnlineFoodSearchResultsImplToJson(
  _$OnlineFoodSearchResultsImpl instance,
) => <String, dynamic>{
  'results': instance.results,
  'provider': instance.provider,
  'searchMode': _$SearchModeEnumMap[instance.searchMode]!,
  'query': instance.query,
  'totalFound': instance.totalFound,
};

_$OnlineServingSizeImpl _$$OnlineServingSizeImplFromJson(
  Map<String, dynamic> json,
) => _$OnlineServingSizeImpl(
  name: json['name'] as String? ?? '',
  grams: (json['grams'] as num?)?.toDouble() ?? 0.0,
  isDefault: json['isDefault'] as bool? ?? false,
  originalUnit: json['originalUnit'] as String? ?? '',
  originalAmount: (json['originalAmount'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$$OnlineServingSizeImplToJson(
  _$OnlineServingSizeImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'grams': instance.grams,
  'isDefault': instance.isDefault,
  'originalUnit': instance.originalUnit,
  'originalAmount': instance.originalAmount,
};
