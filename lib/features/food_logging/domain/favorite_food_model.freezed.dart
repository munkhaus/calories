// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'favorite_food_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FavoriteServingSize _$FavoriteServingSizeFromJson(Map<String, dynamic> json) {
  return _FavoriteServingSize.fromJson(json);
}

/// @nodoc
mixin _$FavoriteServingSize {
  String get name => throw _privateConstructorUsedError;
  double get grams => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this FavoriteServingSize to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FavoriteServingSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoriteServingSizeCopyWith<FavoriteServingSize> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoriteServingSizeCopyWith<$Res> {
  factory $FavoriteServingSizeCopyWith(
    FavoriteServingSize value,
    $Res Function(FavoriteServingSize) then,
  ) = _$FavoriteServingSizeCopyWithImpl<$Res, FavoriteServingSize>;
  @useResult
  $Res call({String name, double grams, bool isDefault});
}

/// @nodoc
class _$FavoriteServingSizeCopyWithImpl<$Res, $Val extends FavoriteServingSize>
    implements $FavoriteServingSizeCopyWith<$Res> {
  _$FavoriteServingSizeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoriteServingSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grams = null,
    Object? isDefault = null,
  }) {
    return _then(
      _value.copyWith(
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            grams: null == grams
                ? _value.grams
                : grams // ignore: cast_nullable_to_non_nullable
                      as double,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FavoriteServingSizeImplCopyWith<$Res>
    implements $FavoriteServingSizeCopyWith<$Res> {
  factory _$$FavoriteServingSizeImplCopyWith(
    _$FavoriteServingSizeImpl value,
    $Res Function(_$FavoriteServingSizeImpl) then,
  ) = __$$FavoriteServingSizeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double grams, bool isDefault});
}

/// @nodoc
class __$$FavoriteServingSizeImplCopyWithImpl<$Res>
    extends _$FavoriteServingSizeCopyWithImpl<$Res, _$FavoriteServingSizeImpl>
    implements _$$FavoriteServingSizeImplCopyWith<$Res> {
  __$$FavoriteServingSizeImplCopyWithImpl(
    _$FavoriteServingSizeImpl _value,
    $Res Function(_$FavoriteServingSizeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FavoriteServingSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grams = null,
    Object? isDefault = null,
  }) {
    return _then(
      _$FavoriteServingSizeImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        grams: null == grams
            ? _value.grams
            : grams // ignore: cast_nullable_to_non_nullable
                  as double,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FavoriteServingSizeImpl implements _FavoriteServingSize {
  const _$FavoriteServingSizeImpl({
    this.name = '',
    this.grams = 100.0,
    this.isDefault = false,
  });

  factory _$FavoriteServingSizeImpl.fromJson(Map<String, dynamic> json) =>
      _$$FavoriteServingSizeImplFromJson(json);

  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final double grams;
  @override
  @JsonKey()
  final bool isDefault;

  @override
  String toString() {
    return 'FavoriteServingSize(name: $name, grams: $grams, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoriteServingSizeImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.grams, grams) || other.grams == grams) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, grams, isDefault);

  /// Create a copy of FavoriteServingSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoriteServingSizeImplCopyWith<_$FavoriteServingSizeImpl> get copyWith =>
      __$$FavoriteServingSizeImplCopyWithImpl<_$FavoriteServingSizeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FavoriteServingSizeImplToJson(this);
  }
}

abstract class _FavoriteServingSize implements FavoriteServingSize {
  const factory _FavoriteServingSize({
    final String name,
    final double grams,
    final bool isDefault,
  }) = _$FavoriteServingSizeImpl;

  factory _FavoriteServingSize.fromJson(Map<String, dynamic> json) =
      _$FavoriteServingSizeImpl.fromJson;

  @override
  String get name;
  @override
  double get grams;
  @override
  bool get isDefault;

  /// Create a copy of FavoriteServingSize
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoriteServingSizeImplCopyWith<_$FavoriteServingSizeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FavoriteFoodModel _$FavoriteFoodModelFromJson(Map<String, dynamic> json) {
  return _FavoriteFoodModel.fromJson(json);
}

/// @nodoc
mixin _$FavoriteFoodModel {
  String get id => throw _privateConstructorUsedError;
  String get foodName => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  MealType get preferredMealType =>
      throw _privateConstructorUsedError; // Food type classification
  FoodType get foodType =>
      throw _privateConstructorUsedError; // Nutrition per 100g
  int get caloriesPer100g => throw _privateConstructorUsedError;
  double get proteinPer100g => throw _privateConstructorUsedError;
  double get fatPer100g => throw _privateConstructorUsedError;
  double get carbsPer100g => throw _privateConstructorUsedError;
  double get fiberPer100g => throw _privateConstructorUsedError;
  double get sugarPer100g =>
      throw _privateConstructorUsedError; // Default serving information (user's preferred portion)
  double get defaultQuantity =>
      throw _privateConstructorUsedError; // This is now effectively defaultServingGrams if unit is 'gram'
  String get defaultServingUnit =>
      throw _privateConstructorUsedError; // Defaulting to 'gram' more strongly
  double get defaultServingGrams =>
      throw _privateConstructorUsedError; // Total calories for the default serving (calculated)
  int get totalCaloriesForServing =>
      throw _privateConstructorUsedError; // Renamed from 'calories'
  // Available serving sizes
  List<FavoriteServingSize> get servingSizes =>
      throw _privateConstructorUsedError; // Source and metadata
  FoodSource get source => throw _privateConstructorUsedError;
  String get sourceProvider =>
      throw _privateConstructorUsedError; // Default to manual
  bool get isAiGenerated => throw _privateConstructorUsedError;
  String? get aiSearchQuery => throw _privateConstructorUsedError;
  String? get barcodeData =>
      throw _privateConstructorUsedError; // Store barcode if from barcode scan
  List<String> get tags => throw _privateConstructorUsedError;
  String get ingredients =>
      throw _privateConstructorUsedError; // Usage tracking
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastUsed => throw _privateConstructorUsedError;
  int get usageCount => throw _privateConstructorUsedError;

  /// Serializes this FavoriteFoodModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FavoriteFoodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FavoriteFoodModelCopyWith<FavoriteFoodModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FavoriteFoodModelCopyWith<$Res> {
  factory $FavoriteFoodModelCopyWith(
    FavoriteFoodModel value,
    $Res Function(FavoriteFoodModel) then,
  ) = _$FavoriteFoodModelCopyWithImpl<$Res, FavoriteFoodModel>;
  @useResult
  $Res call({
    String id,
    String foodName,
    String description,
    MealType preferredMealType,
    FoodType foodType,
    int caloriesPer100g,
    double proteinPer100g,
    double fatPer100g,
    double carbsPer100g,
    double fiberPer100g,
    double sugarPer100g,
    double defaultQuantity,
    String defaultServingUnit,
    double defaultServingGrams,
    int totalCaloriesForServing,
    List<FavoriteServingSize> servingSizes,
    FoodSource source,
    String sourceProvider,
    bool isAiGenerated,
    String? aiSearchQuery,
    String? barcodeData,
    List<String> tags,
    String ingredients,
    DateTime createdAt,
    DateTime lastUsed,
    int usageCount,
  });
}

/// @nodoc
class _$FavoriteFoodModelCopyWithImpl<$Res, $Val extends FavoriteFoodModel>
    implements $FavoriteFoodModelCopyWith<$Res> {
  _$FavoriteFoodModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FavoriteFoodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? foodName = null,
    Object? description = null,
    Object? preferredMealType = null,
    Object? foodType = null,
    Object? caloriesPer100g = null,
    Object? proteinPer100g = null,
    Object? fatPer100g = null,
    Object? carbsPer100g = null,
    Object? fiberPer100g = null,
    Object? sugarPer100g = null,
    Object? defaultQuantity = null,
    Object? defaultServingUnit = null,
    Object? defaultServingGrams = null,
    Object? totalCaloriesForServing = null,
    Object? servingSizes = null,
    Object? source = null,
    Object? sourceProvider = null,
    Object? isAiGenerated = null,
    Object? aiSearchQuery = freezed,
    Object? barcodeData = freezed,
    Object? tags = null,
    Object? ingredients = null,
    Object? createdAt = null,
    Object? lastUsed = null,
    Object? usageCount = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            foodName: null == foodName
                ? _value.foodName
                : foodName // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            preferredMealType: null == preferredMealType
                ? _value.preferredMealType
                : preferredMealType // ignore: cast_nullable_to_non_nullable
                      as MealType,
            foodType: null == foodType
                ? _value.foodType
                : foodType // ignore: cast_nullable_to_non_nullable
                      as FoodType,
            caloriesPer100g: null == caloriesPer100g
                ? _value.caloriesPer100g
                : caloriesPer100g // ignore: cast_nullable_to_non_nullable
                      as int,
            proteinPer100g: null == proteinPer100g
                ? _value.proteinPer100g
                : proteinPer100g // ignore: cast_nullable_to_non_nullable
                      as double,
            fatPer100g: null == fatPer100g
                ? _value.fatPer100g
                : fatPer100g // ignore: cast_nullable_to_non_nullable
                      as double,
            carbsPer100g: null == carbsPer100g
                ? _value.carbsPer100g
                : carbsPer100g // ignore: cast_nullable_to_non_nullable
                      as double,
            fiberPer100g: null == fiberPer100g
                ? _value.fiberPer100g
                : fiberPer100g // ignore: cast_nullable_to_non_nullable
                      as double,
            sugarPer100g: null == sugarPer100g
                ? _value.sugarPer100g
                : sugarPer100g // ignore: cast_nullable_to_non_nullable
                      as double,
            defaultQuantity: null == defaultQuantity
                ? _value.defaultQuantity
                : defaultQuantity // ignore: cast_nullable_to_non_nullable
                      as double,
            defaultServingUnit: null == defaultServingUnit
                ? _value.defaultServingUnit
                : defaultServingUnit // ignore: cast_nullable_to_non_nullable
                      as String,
            defaultServingGrams: null == defaultServingGrams
                ? _value.defaultServingGrams
                : defaultServingGrams // ignore: cast_nullable_to_non_nullable
                      as double,
            totalCaloriesForServing: null == totalCaloriesForServing
                ? _value.totalCaloriesForServing
                : totalCaloriesForServing // ignore: cast_nullable_to_non_nullable
                      as int,
            servingSizes: null == servingSizes
                ? _value.servingSizes
                : servingSizes // ignore: cast_nullable_to_non_nullable
                      as List<FavoriteServingSize>,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as FoodSource,
            sourceProvider: null == sourceProvider
                ? _value.sourceProvider
                : sourceProvider // ignore: cast_nullable_to_non_nullable
                      as String,
            isAiGenerated: null == isAiGenerated
                ? _value.isAiGenerated
                : isAiGenerated // ignore: cast_nullable_to_non_nullable
                      as bool,
            aiSearchQuery: freezed == aiSearchQuery
                ? _value.aiSearchQuery
                : aiSearchQuery // ignore: cast_nullable_to_non_nullable
                      as String?,
            barcodeData: freezed == barcodeData
                ? _value.barcodeData
                : barcodeData // ignore: cast_nullable_to_non_nullable
                      as String?,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            lastUsed: null == lastUsed
                ? _value.lastUsed
                : lastUsed // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            usageCount: null == usageCount
                ? _value.usageCount
                : usageCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FavoriteFoodModelImplCopyWith<$Res>
    implements $FavoriteFoodModelCopyWith<$Res> {
  factory _$$FavoriteFoodModelImplCopyWith(
    _$FavoriteFoodModelImpl value,
    $Res Function(_$FavoriteFoodModelImpl) then,
  ) = __$$FavoriteFoodModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String foodName,
    String description,
    MealType preferredMealType,
    FoodType foodType,
    int caloriesPer100g,
    double proteinPer100g,
    double fatPer100g,
    double carbsPer100g,
    double fiberPer100g,
    double sugarPer100g,
    double defaultQuantity,
    String defaultServingUnit,
    double defaultServingGrams,
    int totalCaloriesForServing,
    List<FavoriteServingSize> servingSizes,
    FoodSource source,
    String sourceProvider,
    bool isAiGenerated,
    String? aiSearchQuery,
    String? barcodeData,
    List<String> tags,
    String ingredients,
    DateTime createdAt,
    DateTime lastUsed,
    int usageCount,
  });
}

/// @nodoc
class __$$FavoriteFoodModelImplCopyWithImpl<$Res>
    extends _$FavoriteFoodModelCopyWithImpl<$Res, _$FavoriteFoodModelImpl>
    implements _$$FavoriteFoodModelImplCopyWith<$Res> {
  __$$FavoriteFoodModelImplCopyWithImpl(
    _$FavoriteFoodModelImpl _value,
    $Res Function(_$FavoriteFoodModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FavoriteFoodModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? foodName = null,
    Object? description = null,
    Object? preferredMealType = null,
    Object? foodType = null,
    Object? caloriesPer100g = null,
    Object? proteinPer100g = null,
    Object? fatPer100g = null,
    Object? carbsPer100g = null,
    Object? fiberPer100g = null,
    Object? sugarPer100g = null,
    Object? defaultQuantity = null,
    Object? defaultServingUnit = null,
    Object? defaultServingGrams = null,
    Object? totalCaloriesForServing = null,
    Object? servingSizes = null,
    Object? source = null,
    Object? sourceProvider = null,
    Object? isAiGenerated = null,
    Object? aiSearchQuery = freezed,
    Object? barcodeData = freezed,
    Object? tags = null,
    Object? ingredients = null,
    Object? createdAt = null,
    Object? lastUsed = null,
    Object? usageCount = null,
  }) {
    return _then(
      _$FavoriteFoodModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        foodName: null == foodName
            ? _value.foodName
            : foodName // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        preferredMealType: null == preferredMealType
            ? _value.preferredMealType
            : preferredMealType // ignore: cast_nullable_to_non_nullable
                  as MealType,
        foodType: null == foodType
            ? _value.foodType
            : foodType // ignore: cast_nullable_to_non_nullable
                  as FoodType,
        caloriesPer100g: null == caloriesPer100g
            ? _value.caloriesPer100g
            : caloriesPer100g // ignore: cast_nullable_to_non_nullable
                  as int,
        proteinPer100g: null == proteinPer100g
            ? _value.proteinPer100g
            : proteinPer100g // ignore: cast_nullable_to_non_nullable
                  as double,
        fatPer100g: null == fatPer100g
            ? _value.fatPer100g
            : fatPer100g // ignore: cast_nullable_to_non_nullable
                  as double,
        carbsPer100g: null == carbsPer100g
            ? _value.carbsPer100g
            : carbsPer100g // ignore: cast_nullable_to_non_nullable
                  as double,
        fiberPer100g: null == fiberPer100g
            ? _value.fiberPer100g
            : fiberPer100g // ignore: cast_nullable_to_non_nullable
                  as double,
        sugarPer100g: null == sugarPer100g
            ? _value.sugarPer100g
            : sugarPer100g // ignore: cast_nullable_to_non_nullable
                  as double,
        defaultQuantity: null == defaultQuantity
            ? _value.defaultQuantity
            : defaultQuantity // ignore: cast_nullable_to_non_nullable
                  as double,
        defaultServingUnit: null == defaultServingUnit
            ? _value.defaultServingUnit
            : defaultServingUnit // ignore: cast_nullable_to_non_nullable
                  as String,
        defaultServingGrams: null == defaultServingGrams
            ? _value.defaultServingGrams
            : defaultServingGrams // ignore: cast_nullable_to_non_nullable
                  as double,
        totalCaloriesForServing: null == totalCaloriesForServing
            ? _value.totalCaloriesForServing
            : totalCaloriesForServing // ignore: cast_nullable_to_non_nullable
                  as int,
        servingSizes: null == servingSizes
            ? _value._servingSizes
            : servingSizes // ignore: cast_nullable_to_non_nullable
                  as List<FavoriteServingSize>,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as FoodSource,
        sourceProvider: null == sourceProvider
            ? _value.sourceProvider
            : sourceProvider // ignore: cast_nullable_to_non_nullable
                  as String,
        isAiGenerated: null == isAiGenerated
            ? _value.isAiGenerated
            : isAiGenerated // ignore: cast_nullable_to_non_nullable
                  as bool,
        aiSearchQuery: freezed == aiSearchQuery
            ? _value.aiSearchQuery
            : aiSearchQuery // ignore: cast_nullable_to_non_nullable
                  as String?,
        barcodeData: freezed == barcodeData
            ? _value.barcodeData
            : barcodeData // ignore: cast_nullable_to_non_nullable
                  as String?,
        tags: null == tags
            ? _value._tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        ingredients: null == ingredients
            ? _value.ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        lastUsed: null == lastUsed
            ? _value.lastUsed
            : lastUsed // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        usageCount: null == usageCount
            ? _value.usageCount
            : usageCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FavoriteFoodModelImpl extends _FavoriteFoodModel {
  const _$FavoriteFoodModelImpl({
    this.id = '',
    this.foodName = '',
    this.description = '',
    this.preferredMealType = MealType.none,
    this.foodType = FoodType.meal,
    this.caloriesPer100g = 0,
    this.proteinPer100g = 0.0,
    this.fatPer100g = 0.0,
    this.carbsPer100g = 0.0,
    this.fiberPer100g = 0.0,
    this.sugarPer100g = 0.0,
    this.defaultQuantity = 1.0,
    this.defaultServingUnit = 'gram',
    this.defaultServingGrams = 100.0,
    this.totalCaloriesForServing = 0,
    final List<FavoriteServingSize> servingSizes = const [],
    this.source = FoodSource.userCreated,
    this.sourceProvider = FavoriteFoodModel.manualProvider,
    this.isAiGenerated = false,
    this.aiSearchQuery,
    this.barcodeData,
    final List<String> tags = const [],
    this.ingredients = '',
    required this.createdAt,
    required this.lastUsed,
    this.usageCount = 0,
  }) : _servingSizes = servingSizes,
       _tags = tags,
       super._();

  factory _$FavoriteFoodModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FavoriteFoodModelImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String foodName;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final MealType preferredMealType;
  // Food type classification
  @override
  @JsonKey()
  final FoodType foodType;
  // Nutrition per 100g
  @override
  @JsonKey()
  final int caloriesPer100g;
  @override
  @JsonKey()
  final double proteinPer100g;
  @override
  @JsonKey()
  final double fatPer100g;
  @override
  @JsonKey()
  final double carbsPer100g;
  @override
  @JsonKey()
  final double fiberPer100g;
  @override
  @JsonKey()
  final double sugarPer100g;
  // Default serving information (user's preferred portion)
  @override
  @JsonKey()
  final double defaultQuantity;
  // This is now effectively defaultServingGrams if unit is 'gram'
  @override
  @JsonKey()
  final String defaultServingUnit;
  // Defaulting to 'gram' more strongly
  @override
  @JsonKey()
  final double defaultServingGrams;
  // Total calories for the default serving (calculated)
  @override
  @JsonKey()
  final int totalCaloriesForServing;
  // Renamed from 'calories'
  // Available serving sizes
  final List<FavoriteServingSize> _servingSizes;
  // Renamed from 'calories'
  // Available serving sizes
  @override
  @JsonKey()
  List<FavoriteServingSize> get servingSizes {
    if (_servingSizes is EqualUnmodifiableListView) return _servingSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_servingSizes);
  }

  // Source and metadata
  @override
  @JsonKey()
  final FoodSource source;
  @override
  @JsonKey()
  final String sourceProvider;
  // Default to manual
  @override
  @JsonKey()
  final bool isAiGenerated;
  @override
  final String? aiSearchQuery;
  @override
  final String? barcodeData;
  // Store barcode if from barcode scan
  final List<String> _tags;
  // Store barcode if from barcode scan
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final String ingredients;
  // Usage tracking
  @override
  final DateTime createdAt;
  @override
  final DateTime lastUsed;
  @override
  @JsonKey()
  final int usageCount;

  @override
  String toString() {
    return 'FavoriteFoodModel(id: $id, foodName: $foodName, description: $description, preferredMealType: $preferredMealType, foodType: $foodType, caloriesPer100g: $caloriesPer100g, proteinPer100g: $proteinPer100g, fatPer100g: $fatPer100g, carbsPer100g: $carbsPer100g, fiberPer100g: $fiberPer100g, sugarPer100g: $sugarPer100g, defaultQuantity: $defaultQuantity, defaultServingUnit: $defaultServingUnit, defaultServingGrams: $defaultServingGrams, totalCaloriesForServing: $totalCaloriesForServing, servingSizes: $servingSizes, source: $source, sourceProvider: $sourceProvider, isAiGenerated: $isAiGenerated, aiSearchQuery: $aiSearchQuery, barcodeData: $barcodeData, tags: $tags, ingredients: $ingredients, createdAt: $createdAt, lastUsed: $lastUsed, usageCount: $usageCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FavoriteFoodModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.foodName, foodName) ||
                other.foodName == foodName) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.preferredMealType, preferredMealType) ||
                other.preferredMealType == preferredMealType) &&
            (identical(other.foodType, foodType) ||
                other.foodType == foodType) &&
            (identical(other.caloriesPer100g, caloriesPer100g) ||
                other.caloriesPer100g == caloriesPer100g) &&
            (identical(other.proteinPer100g, proteinPer100g) ||
                other.proteinPer100g == proteinPer100g) &&
            (identical(other.fatPer100g, fatPer100g) ||
                other.fatPer100g == fatPer100g) &&
            (identical(other.carbsPer100g, carbsPer100g) ||
                other.carbsPer100g == carbsPer100g) &&
            (identical(other.fiberPer100g, fiberPer100g) ||
                other.fiberPer100g == fiberPer100g) &&
            (identical(other.sugarPer100g, sugarPer100g) ||
                other.sugarPer100g == sugarPer100g) &&
            (identical(other.defaultQuantity, defaultQuantity) ||
                other.defaultQuantity == defaultQuantity) &&
            (identical(other.defaultServingUnit, defaultServingUnit) ||
                other.defaultServingUnit == defaultServingUnit) &&
            (identical(other.defaultServingGrams, defaultServingGrams) ||
                other.defaultServingGrams == defaultServingGrams) &&
            (identical(
                  other.totalCaloriesForServing,
                  totalCaloriesForServing,
                ) ||
                other.totalCaloriesForServing == totalCaloriesForServing) &&
            const DeepCollectionEquality().equals(
              other._servingSizes,
              _servingSizes,
            ) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.sourceProvider, sourceProvider) ||
                other.sourceProvider == sourceProvider) &&
            (identical(other.isAiGenerated, isAiGenerated) ||
                other.isAiGenerated == isAiGenerated) &&
            (identical(other.aiSearchQuery, aiSearchQuery) ||
                other.aiSearchQuery == aiSearchQuery) &&
            (identical(other.barcodeData, barcodeData) ||
                other.barcodeData == barcodeData) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.ingredients, ingredients) ||
                other.ingredients == ingredients) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUsed, lastUsed) ||
                other.lastUsed == lastUsed) &&
            (identical(other.usageCount, usageCount) ||
                other.usageCount == usageCount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    foodName,
    description,
    preferredMealType,
    foodType,
    caloriesPer100g,
    proteinPer100g,
    fatPer100g,
    carbsPer100g,
    fiberPer100g,
    sugarPer100g,
    defaultQuantity,
    defaultServingUnit,
    defaultServingGrams,
    totalCaloriesForServing,
    const DeepCollectionEquality().hash(_servingSizes),
    source,
    sourceProvider,
    isAiGenerated,
    aiSearchQuery,
    barcodeData,
    const DeepCollectionEquality().hash(_tags),
    ingredients,
    createdAt,
    lastUsed,
    usageCount,
  ]);

  /// Create a copy of FavoriteFoodModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FavoriteFoodModelImplCopyWith<_$FavoriteFoodModelImpl> get copyWith =>
      __$$FavoriteFoodModelImplCopyWithImpl<_$FavoriteFoodModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FavoriteFoodModelImplToJson(this);
  }
}

abstract class _FavoriteFoodModel extends FavoriteFoodModel {
  const factory _FavoriteFoodModel({
    final String id,
    final String foodName,
    final String description,
    final MealType preferredMealType,
    final FoodType foodType,
    final int caloriesPer100g,
    final double proteinPer100g,
    final double fatPer100g,
    final double carbsPer100g,
    final double fiberPer100g,
    final double sugarPer100g,
    final double defaultQuantity,
    final String defaultServingUnit,
    final double defaultServingGrams,
    final int totalCaloriesForServing,
    final List<FavoriteServingSize> servingSizes,
    final FoodSource source,
    final String sourceProvider,
    final bool isAiGenerated,
    final String? aiSearchQuery,
    final String? barcodeData,
    final List<String> tags,
    final String ingredients,
    required final DateTime createdAt,
    required final DateTime lastUsed,
    final int usageCount,
  }) = _$FavoriteFoodModelImpl;
  const _FavoriteFoodModel._() : super._();

  factory _FavoriteFoodModel.fromJson(Map<String, dynamic> json) =
      _$FavoriteFoodModelImpl.fromJson;

  @override
  String get id;
  @override
  String get foodName;
  @override
  String get description;
  @override
  MealType get preferredMealType; // Food type classification
  @override
  FoodType get foodType; // Nutrition per 100g
  @override
  int get caloriesPer100g;
  @override
  double get proteinPer100g;
  @override
  double get fatPer100g;
  @override
  double get carbsPer100g;
  @override
  double get fiberPer100g;
  @override
  double get sugarPer100g; // Default serving information (user's preferred portion)
  @override
  double get defaultQuantity; // This is now effectively defaultServingGrams if unit is 'gram'
  @override
  String get defaultServingUnit; // Defaulting to 'gram' more strongly
  @override
  double get defaultServingGrams; // Total calories for the default serving (calculated)
  @override
  int get totalCaloriesForServing; // Renamed from 'calories'
  // Available serving sizes
  @override
  List<FavoriteServingSize> get servingSizes; // Source and metadata
  @override
  FoodSource get source;
  @override
  String get sourceProvider; // Default to manual
  @override
  bool get isAiGenerated;
  @override
  String? get aiSearchQuery;
  @override
  String? get barcodeData; // Store barcode if from barcode scan
  @override
  List<String> get tags;
  @override
  String get ingredients; // Usage tracking
  @override
  DateTime get createdAt;
  @override
  DateTime get lastUsed;
  @override
  int get usageCount;

  /// Create a copy of FavoriteFoodModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FavoriteFoodModelImplCopyWith<_$FavoriteFoodModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
