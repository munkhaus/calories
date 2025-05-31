// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_food_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FoodTags _$FoodTagsFromJson(Map<String, dynamic> json) {
  return _FoodTags.fromJson(json);
}

/// @nodoc
mixin _$FoodTags {
  List<FoodType> get foodTypes => throw _privateConstructorUsedError;
  List<CuisineStyle> get cuisineStyles => throw _privateConstructorUsedError;
  List<DietaryTag> get dietaryTags => throw _privateConstructorUsedError;
  List<PreparationType> get preparationTypes =>
      throw _privateConstructorUsedError;
  List<String> get customTags => throw _privateConstructorUsedError;

  /// Serializes this FoodTags to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FoodTags
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FoodTagsCopyWith<FoodTags> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodTagsCopyWith<$Res> {
  factory $FoodTagsCopyWith(FoodTags value, $Res Function(FoodTags) then) =
      _$FoodTagsCopyWithImpl<$Res, FoodTags>;
  @useResult
  $Res call({
    List<FoodType> foodTypes,
    List<CuisineStyle> cuisineStyles,
    List<DietaryTag> dietaryTags,
    List<PreparationType> preparationTypes,
    List<String> customTags,
  });
}

/// @nodoc
class _$FoodTagsCopyWithImpl<$Res, $Val extends FoodTags>
    implements $FoodTagsCopyWith<$Res> {
  _$FoodTagsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FoodTags
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodTypes = null,
    Object? cuisineStyles = null,
    Object? dietaryTags = null,
    Object? preparationTypes = null,
    Object? customTags = null,
  }) {
    return _then(
      _value.copyWith(
            foodTypes: null == foodTypes
                ? _value.foodTypes
                : foodTypes // ignore: cast_nullable_to_non_nullable
                      as List<FoodType>,
            cuisineStyles: null == cuisineStyles
                ? _value.cuisineStyles
                : cuisineStyles // ignore: cast_nullable_to_non_nullable
                      as List<CuisineStyle>,
            dietaryTags: null == dietaryTags
                ? _value.dietaryTags
                : dietaryTags // ignore: cast_nullable_to_non_nullable
                      as List<DietaryTag>,
            preparationTypes: null == preparationTypes
                ? _value.preparationTypes
                : preparationTypes // ignore: cast_nullable_to_non_nullable
                      as List<PreparationType>,
            customTags: null == customTags
                ? _value.customTags
                : customTags // ignore: cast_nullable_to_non_nullable
                      as List<String>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FoodTagsImplCopyWith<$Res>
    implements $FoodTagsCopyWith<$Res> {
  factory _$$FoodTagsImplCopyWith(
    _$FoodTagsImpl value,
    $Res Function(_$FoodTagsImpl) then,
  ) = __$$FoodTagsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<FoodType> foodTypes,
    List<CuisineStyle> cuisineStyles,
    List<DietaryTag> dietaryTags,
    List<PreparationType> preparationTypes,
    List<String> customTags,
  });
}

/// @nodoc
class __$$FoodTagsImplCopyWithImpl<$Res>
    extends _$FoodTagsCopyWithImpl<$Res, _$FoodTagsImpl>
    implements _$$FoodTagsImplCopyWith<$Res> {
  __$$FoodTagsImplCopyWithImpl(
    _$FoodTagsImpl _value,
    $Res Function(_$FoodTagsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FoodTags
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodTypes = null,
    Object? cuisineStyles = null,
    Object? dietaryTags = null,
    Object? preparationTypes = null,
    Object? customTags = null,
  }) {
    return _then(
      _$FoodTagsImpl(
        foodTypes: null == foodTypes
            ? _value._foodTypes
            : foodTypes // ignore: cast_nullable_to_non_nullable
                  as List<FoodType>,
        cuisineStyles: null == cuisineStyles
            ? _value._cuisineStyles
            : cuisineStyles // ignore: cast_nullable_to_non_nullable
                  as List<CuisineStyle>,
        dietaryTags: null == dietaryTags
            ? _value._dietaryTags
            : dietaryTags // ignore: cast_nullable_to_non_nullable
                  as List<DietaryTag>,
        preparationTypes: null == preparationTypes
            ? _value._preparationTypes
            : preparationTypes // ignore: cast_nullable_to_non_nullable
                  as List<PreparationType>,
        customTags: null == customTags
            ? _value._customTags
            : customTags // ignore: cast_nullable_to_non_nullable
                  as List<String>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FoodTagsImpl implements _FoodTags {
  const _$FoodTagsImpl({
    final List<FoodType> foodTypes = const [],
    final List<CuisineStyle> cuisineStyles = const [],
    final List<DietaryTag> dietaryTags = const [],
    final List<PreparationType> preparationTypes = const [],
    final List<String> customTags = const [],
  }) : _foodTypes = foodTypes,
       _cuisineStyles = cuisineStyles,
       _dietaryTags = dietaryTags,
       _preparationTypes = preparationTypes,
       _customTags = customTags;

  factory _$FoodTagsImpl.fromJson(Map<String, dynamic> json) =>
      _$$FoodTagsImplFromJson(json);

  final List<FoodType> _foodTypes;
  @override
  @JsonKey()
  List<FoodType> get foodTypes {
    if (_foodTypes is EqualUnmodifiableListView) return _foodTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_foodTypes);
  }

  final List<CuisineStyle> _cuisineStyles;
  @override
  @JsonKey()
  List<CuisineStyle> get cuisineStyles {
    if (_cuisineStyles is EqualUnmodifiableListView) return _cuisineStyles;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cuisineStyles);
  }

  final List<DietaryTag> _dietaryTags;
  @override
  @JsonKey()
  List<DietaryTag> get dietaryTags {
    if (_dietaryTags is EqualUnmodifiableListView) return _dietaryTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_dietaryTags);
  }

  final List<PreparationType> _preparationTypes;
  @override
  @JsonKey()
  List<PreparationType> get preparationTypes {
    if (_preparationTypes is EqualUnmodifiableListView)
      return _preparationTypes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preparationTypes);
  }

  final List<String> _customTags;
  @override
  @JsonKey()
  List<String> get customTags {
    if (_customTags is EqualUnmodifiableListView) return _customTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customTags);
  }

  @override
  String toString() {
    return 'FoodTags(foodTypes: $foodTypes, cuisineStyles: $cuisineStyles, dietaryTags: $dietaryTags, preparationTypes: $preparationTypes, customTags: $customTags)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodTagsImpl &&
            const DeepCollectionEquality().equals(
              other._foodTypes,
              _foodTypes,
            ) &&
            const DeepCollectionEquality().equals(
              other._cuisineStyles,
              _cuisineStyles,
            ) &&
            const DeepCollectionEquality().equals(
              other._dietaryTags,
              _dietaryTags,
            ) &&
            const DeepCollectionEquality().equals(
              other._preparationTypes,
              _preparationTypes,
            ) &&
            const DeepCollectionEquality().equals(
              other._customTags,
              _customTags,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_foodTypes),
    const DeepCollectionEquality().hash(_cuisineStyles),
    const DeepCollectionEquality().hash(_dietaryTags),
    const DeepCollectionEquality().hash(_preparationTypes),
    const DeepCollectionEquality().hash(_customTags),
  );

  /// Create a copy of FoodTags
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodTagsImplCopyWith<_$FoodTagsImpl> get copyWith =>
      __$$FoodTagsImplCopyWithImpl<_$FoodTagsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FoodTagsImplToJson(this);
  }
}

abstract class _FoodTags implements FoodTags {
  const factory _FoodTags({
    final List<FoodType> foodTypes,
    final List<CuisineStyle> cuisineStyles,
    final List<DietaryTag> dietaryTags,
    final List<PreparationType> preparationTypes,
    final List<String> customTags,
  }) = _$FoodTagsImpl;

  factory _FoodTags.fromJson(Map<String, dynamic> json) =
      _$FoodTagsImpl.fromJson;

  @override
  List<FoodType> get foodTypes;
  @override
  List<CuisineStyle> get cuisineStyles;
  @override
  List<DietaryTag> get dietaryTags;
  @override
  List<PreparationType> get preparationTypes;
  @override
  List<String> get customTags;

  /// Create a copy of FoodTags
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FoodTagsImplCopyWith<_$FoodTagsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OnlineFoodSearchRequest _$OnlineFoodSearchRequestFromJson(
  Map<String, dynamic> json,
) {
  return _OnlineFoodSearchRequest.fromJson(json);
}

/// @nodoc
mixin _$OnlineFoodSearchRequest {
  String get query => throw _privateConstructorUsedError;
  SearchMode get searchMode => throw _privateConstructorUsedError;
  FoodTags? get filterTags => throw _privateConstructorUsedError;
  int get maxResults => throw _privateConstructorUsedError;

  /// Serializes this OnlineFoodSearchRequest to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnlineFoodSearchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnlineFoodSearchRequestCopyWith<OnlineFoodSearchRequest> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnlineFoodSearchRequestCopyWith<$Res> {
  factory $OnlineFoodSearchRequestCopyWith(
    OnlineFoodSearchRequest value,
    $Res Function(OnlineFoodSearchRequest) then,
  ) = _$OnlineFoodSearchRequestCopyWithImpl<$Res, OnlineFoodSearchRequest>;
  @useResult
  $Res call({
    String query,
    SearchMode searchMode,
    FoodTags? filterTags,
    int maxResults,
  });

  $FoodTagsCopyWith<$Res>? get filterTags;
}

/// @nodoc
class _$OnlineFoodSearchRequestCopyWithImpl<
  $Res,
  $Val extends OnlineFoodSearchRequest
>
    implements $OnlineFoodSearchRequestCopyWith<$Res> {
  _$OnlineFoodSearchRequestCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnlineFoodSearchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? searchMode = null,
    Object? filterTags = freezed,
    Object? maxResults = null,
  }) {
    return _then(
      _value.copyWith(
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            searchMode: null == searchMode
                ? _value.searchMode
                : searchMode // ignore: cast_nullable_to_non_nullable
                      as SearchMode,
            filterTags: freezed == filterTags
                ? _value.filterTags
                : filterTags // ignore: cast_nullable_to_non_nullable
                      as FoodTags?,
            maxResults: null == maxResults
                ? _value.maxResults
                : maxResults // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of OnlineFoodSearchRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FoodTagsCopyWith<$Res>? get filterTags {
    if (_value.filterTags == null) {
      return null;
    }

    return $FoodTagsCopyWith<$Res>(_value.filterTags!, (value) {
      return _then(_value.copyWith(filterTags: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OnlineFoodSearchRequestImplCopyWith<$Res>
    implements $OnlineFoodSearchRequestCopyWith<$Res> {
  factory _$$OnlineFoodSearchRequestImplCopyWith(
    _$OnlineFoodSearchRequestImpl value,
    $Res Function(_$OnlineFoodSearchRequestImpl) then,
  ) = __$$OnlineFoodSearchRequestImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String query,
    SearchMode searchMode,
    FoodTags? filterTags,
    int maxResults,
  });

  @override
  $FoodTagsCopyWith<$Res>? get filterTags;
}

/// @nodoc
class __$$OnlineFoodSearchRequestImplCopyWithImpl<$Res>
    extends
        _$OnlineFoodSearchRequestCopyWithImpl<
          $Res,
          _$OnlineFoodSearchRequestImpl
        >
    implements _$$OnlineFoodSearchRequestImplCopyWith<$Res> {
  __$$OnlineFoodSearchRequestImplCopyWithImpl(
    _$OnlineFoodSearchRequestImpl _value,
    $Res Function(_$OnlineFoodSearchRequestImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnlineFoodSearchRequest
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? query = null,
    Object? searchMode = null,
    Object? filterTags = freezed,
    Object? maxResults = null,
  }) {
    return _then(
      _$OnlineFoodSearchRequestImpl(
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        searchMode: null == searchMode
            ? _value.searchMode
            : searchMode // ignore: cast_nullable_to_non_nullable
                  as SearchMode,
        filterTags: freezed == filterTags
            ? _value.filterTags
            : filterTags // ignore: cast_nullable_to_non_nullable
                  as FoodTags?,
        maxResults: null == maxResults
            ? _value.maxResults
            : maxResults // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OnlineFoodSearchRequestImpl implements _OnlineFoodSearchRequest {
  const _$OnlineFoodSearchRequestImpl({
    required this.query,
    this.searchMode = SearchMode.dishes,
    this.filterTags,
    this.maxResults = 25,
  });

  factory _$OnlineFoodSearchRequestImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnlineFoodSearchRequestImplFromJson(json);

  @override
  final String query;
  @override
  @JsonKey()
  final SearchMode searchMode;
  @override
  final FoodTags? filterTags;
  @override
  @JsonKey()
  final int maxResults;

  @override
  String toString() {
    return 'OnlineFoodSearchRequest(query: $query, searchMode: $searchMode, filterTags: $filterTags, maxResults: $maxResults)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnlineFoodSearchRequestImpl &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.searchMode, searchMode) ||
                other.searchMode == searchMode) &&
            (identical(other.filterTags, filterTags) ||
                other.filterTags == filterTags) &&
            (identical(other.maxResults, maxResults) ||
                other.maxResults == maxResults));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, query, searchMode, filterTags, maxResults);

  /// Create a copy of OnlineFoodSearchRequest
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnlineFoodSearchRequestImplCopyWith<_$OnlineFoodSearchRequestImpl>
  get copyWith =>
      __$$OnlineFoodSearchRequestImplCopyWithImpl<
        _$OnlineFoodSearchRequestImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OnlineFoodSearchRequestImplToJson(this);
  }
}

abstract class _OnlineFoodSearchRequest implements OnlineFoodSearchRequest {
  const factory _OnlineFoodSearchRequest({
    required final String query,
    final SearchMode searchMode,
    final FoodTags? filterTags,
    final int maxResults,
  }) = _$OnlineFoodSearchRequestImpl;

  factory _OnlineFoodSearchRequest.fromJson(Map<String, dynamic> json) =
      _$OnlineFoodSearchRequestImpl.fromJson;

  @override
  String get query;
  @override
  SearchMode get searchMode;
  @override
  FoodTags? get filterTags;
  @override
  int get maxResults;

  /// Create a copy of OnlineFoodSearchRequest
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnlineFoodSearchRequestImplCopyWith<_$OnlineFoodSearchRequestImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OnlineFoodResult _$OnlineFoodResultFromJson(Map<String, dynamic> json) {
  return _OnlineFoodResult.fromJson(json);
}

/// @nodoc
mixin _$OnlineFoodResult {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get imageUrl => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  SearchMode get searchMode =>
      throw _privateConstructorUsedError; // Whether this is a dish or ingredient
  FoodTags get tags => throw _privateConstructorUsedError;
  double get estimatedCalories => throw _privateConstructorUsedError;

  /// Serializes this OnlineFoodResult to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnlineFoodResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnlineFoodResultCopyWith<OnlineFoodResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnlineFoodResultCopyWith<$Res> {
  factory $OnlineFoodResultCopyWith(
    OnlineFoodResult value,
    $Res Function(OnlineFoodResult) then,
  ) = _$OnlineFoodResultCopyWithImpl<$Res, OnlineFoodResult>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String imageUrl,
    String provider,
    SearchMode searchMode,
    FoodTags tags,
    double estimatedCalories,
  });

  $FoodTagsCopyWith<$Res> get tags;
}

/// @nodoc
class _$OnlineFoodResultCopyWithImpl<$Res, $Val extends OnlineFoodResult>
    implements $OnlineFoodResultCopyWith<$Res> {
  _$OnlineFoodResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnlineFoodResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? provider = null,
    Object? searchMode = null,
    Object? tags = null,
    Object? estimatedCalories = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
            imageUrl: null == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            searchMode: null == searchMode
                ? _value.searchMode
                : searchMode // ignore: cast_nullable_to_non_nullable
                      as SearchMode,
            tags: null == tags
                ? _value.tags
                : tags // ignore: cast_nullable_to_non_nullable
                      as FoodTags,
            estimatedCalories: null == estimatedCalories
                ? _value.estimatedCalories
                : estimatedCalories // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }

  /// Create a copy of OnlineFoodResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FoodTagsCopyWith<$Res> get tags {
    return $FoodTagsCopyWith<$Res>(_value.tags, (value) {
      return _then(_value.copyWith(tags: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OnlineFoodResultImplCopyWith<$Res>
    implements $OnlineFoodResultCopyWith<$Res> {
  factory _$$OnlineFoodResultImplCopyWith(
    _$OnlineFoodResultImpl value,
    $Res Function(_$OnlineFoodResultImpl) then,
  ) = __$$OnlineFoodResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    String imageUrl,
    String provider,
    SearchMode searchMode,
    FoodTags tags,
    double estimatedCalories,
  });

  @override
  $FoodTagsCopyWith<$Res> get tags;
}

/// @nodoc
class __$$OnlineFoodResultImplCopyWithImpl<$Res>
    extends _$OnlineFoodResultCopyWithImpl<$Res, _$OnlineFoodResultImpl>
    implements _$$OnlineFoodResultImplCopyWith<$Res> {
  __$$OnlineFoodResultImplCopyWithImpl(
    _$OnlineFoodResultImpl _value,
    $Res Function(_$OnlineFoodResultImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnlineFoodResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? imageUrl = null,
    Object? provider = null,
    Object? searchMode = null,
    Object? tags = null,
    Object? estimatedCalories = null,
  }) {
    return _then(
      _$OnlineFoodResultImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
        imageUrl: null == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        searchMode: null == searchMode
            ? _value.searchMode
            : searchMode // ignore: cast_nullable_to_non_nullable
                  as SearchMode,
        tags: null == tags
            ? _value.tags
            : tags // ignore: cast_nullable_to_non_nullable
                  as FoodTags,
        estimatedCalories: null == estimatedCalories
            ? _value.estimatedCalories
            : estimatedCalories // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OnlineFoodResultImpl implements _OnlineFoodResult {
  const _$OnlineFoodResultImpl({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl = '',
    required this.provider,
    required this.searchMode,
    this.tags = const FoodTags(),
    this.estimatedCalories = 0,
  });

  factory _$OnlineFoodResultImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnlineFoodResultImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey()
  final String imageUrl;
  @override
  final String provider;
  @override
  final SearchMode searchMode;
  // Whether this is a dish or ingredient
  @override
  @JsonKey()
  final FoodTags tags;
  @override
  @JsonKey()
  final double estimatedCalories;

  @override
  String toString() {
    return 'OnlineFoodResult(id: $id, name: $name, description: $description, imageUrl: $imageUrl, provider: $provider, searchMode: $searchMode, tags: $tags, estimatedCalories: $estimatedCalories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnlineFoodResultImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.searchMode, searchMode) ||
                other.searchMode == searchMode) &&
            (identical(other.tags, tags) || other.tags == tags) &&
            (identical(other.estimatedCalories, estimatedCalories) ||
                other.estimatedCalories == estimatedCalories));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    imageUrl,
    provider,
    searchMode,
    tags,
    estimatedCalories,
  );

  /// Create a copy of OnlineFoodResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnlineFoodResultImplCopyWith<_$OnlineFoodResultImpl> get copyWith =>
      __$$OnlineFoodResultImplCopyWithImpl<_$OnlineFoodResultImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OnlineFoodResultImplToJson(this);
  }
}

abstract class _OnlineFoodResult implements OnlineFoodResult {
  const factory _OnlineFoodResult({
    required final String id,
    required final String name,
    required final String description,
    final String imageUrl,
    required final String provider,
    required final SearchMode searchMode,
    final FoodTags tags,
    final double estimatedCalories,
  }) = _$OnlineFoodResultImpl;

  factory _OnlineFoodResult.fromJson(Map<String, dynamic> json) =
      _$OnlineFoodResultImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  String get imageUrl;
  @override
  String get provider;
  @override
  SearchMode get searchMode; // Whether this is a dish or ingredient
  @override
  FoodTags get tags;
  @override
  double get estimatedCalories;

  /// Create a copy of OnlineFoodResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnlineFoodResultImplCopyWith<_$OnlineFoodResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OnlineFoodDetails _$OnlineFoodDetailsFromJson(Map<String, dynamic> json) {
  return _OnlineFoodDetails.fromJson(json);
}

/// @nodoc
mixin _$OnlineFoodDetails {
  OnlineFoodResult get basicInfo => throw _privateConstructorUsedError;
  NutritionInfo get nutrition => throw _privateConstructorUsedError;
  List<ServingInfo> get servingSizes => throw _privateConstructorUsedError;
  String get ingredients => throw _privateConstructorUsedError;
  String get instructions => throw _privateConstructorUsedError;

  /// Serializes this OnlineFoodDetails to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnlineFoodDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnlineFoodDetailsCopyWith<OnlineFoodDetails> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnlineFoodDetailsCopyWith<$Res> {
  factory $OnlineFoodDetailsCopyWith(
    OnlineFoodDetails value,
    $Res Function(OnlineFoodDetails) then,
  ) = _$OnlineFoodDetailsCopyWithImpl<$Res, OnlineFoodDetails>;
  @useResult
  $Res call({
    OnlineFoodResult basicInfo,
    NutritionInfo nutrition,
    List<ServingInfo> servingSizes,
    String ingredients,
    String instructions,
  });

  $OnlineFoodResultCopyWith<$Res> get basicInfo;
  $NutritionInfoCopyWith<$Res> get nutrition;
}

/// @nodoc
class _$OnlineFoodDetailsCopyWithImpl<$Res, $Val extends OnlineFoodDetails>
    implements $OnlineFoodDetailsCopyWith<$Res> {
  _$OnlineFoodDetailsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnlineFoodDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? basicInfo = null,
    Object? nutrition = null,
    Object? servingSizes = null,
    Object? ingredients = null,
    Object? instructions = null,
  }) {
    return _then(
      _value.copyWith(
            basicInfo: null == basicInfo
                ? _value.basicInfo
                : basicInfo // ignore: cast_nullable_to_non_nullable
                      as OnlineFoodResult,
            nutrition: null == nutrition
                ? _value.nutrition
                : nutrition // ignore: cast_nullable_to_non_nullable
                      as NutritionInfo,
            servingSizes: null == servingSizes
                ? _value.servingSizes
                : servingSizes // ignore: cast_nullable_to_non_nullable
                      as List<ServingInfo>,
            ingredients: null == ingredients
                ? _value.ingredients
                : ingredients // ignore: cast_nullable_to_non_nullable
                      as String,
            instructions: null == instructions
                ? _value.instructions
                : instructions // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of OnlineFoodDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnlineFoodResultCopyWith<$Res> get basicInfo {
    return $OnlineFoodResultCopyWith<$Res>(_value.basicInfo, (value) {
      return _then(_value.copyWith(basicInfo: value) as $Val);
    });
  }

  /// Create a copy of OnlineFoodDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NutritionInfoCopyWith<$Res> get nutrition {
    return $NutritionInfoCopyWith<$Res>(_value.nutrition, (value) {
      return _then(_value.copyWith(nutrition: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OnlineFoodDetailsImplCopyWith<$Res>
    implements $OnlineFoodDetailsCopyWith<$Res> {
  factory _$$OnlineFoodDetailsImplCopyWith(
    _$OnlineFoodDetailsImpl value,
    $Res Function(_$OnlineFoodDetailsImpl) then,
  ) = __$$OnlineFoodDetailsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    OnlineFoodResult basicInfo,
    NutritionInfo nutrition,
    List<ServingInfo> servingSizes,
    String ingredients,
    String instructions,
  });

  @override
  $OnlineFoodResultCopyWith<$Res> get basicInfo;
  @override
  $NutritionInfoCopyWith<$Res> get nutrition;
}

/// @nodoc
class __$$OnlineFoodDetailsImplCopyWithImpl<$Res>
    extends _$OnlineFoodDetailsCopyWithImpl<$Res, _$OnlineFoodDetailsImpl>
    implements _$$OnlineFoodDetailsImplCopyWith<$Res> {
  __$$OnlineFoodDetailsImplCopyWithImpl(
    _$OnlineFoodDetailsImpl _value,
    $Res Function(_$OnlineFoodDetailsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnlineFoodDetails
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? basicInfo = null,
    Object? nutrition = null,
    Object? servingSizes = null,
    Object? ingredients = null,
    Object? instructions = null,
  }) {
    return _then(
      _$OnlineFoodDetailsImpl(
        basicInfo: null == basicInfo
            ? _value.basicInfo
            : basicInfo // ignore: cast_nullable_to_non_nullable
                  as OnlineFoodResult,
        nutrition: null == nutrition
            ? _value.nutrition
            : nutrition // ignore: cast_nullable_to_non_nullable
                  as NutritionInfo,
        servingSizes: null == servingSizes
            ? _value._servingSizes
            : servingSizes // ignore: cast_nullable_to_non_nullable
                  as List<ServingInfo>,
        ingredients: null == ingredients
            ? _value.ingredients
            : ingredients // ignore: cast_nullable_to_non_nullable
                  as String,
        instructions: null == instructions
            ? _value.instructions
            : instructions // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OnlineFoodDetailsImpl implements _OnlineFoodDetails {
  const _$OnlineFoodDetailsImpl({
    required this.basicInfo,
    required this.nutrition,
    final List<ServingInfo> servingSizes = const [],
    this.ingredients = '',
    this.instructions = '',
  }) : _servingSizes = servingSizes;

  factory _$OnlineFoodDetailsImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnlineFoodDetailsImplFromJson(json);

  @override
  final OnlineFoodResult basicInfo;
  @override
  final NutritionInfo nutrition;
  final List<ServingInfo> _servingSizes;
  @override
  @JsonKey()
  List<ServingInfo> get servingSizes {
    if (_servingSizes is EqualUnmodifiableListView) return _servingSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_servingSizes);
  }

  @override
  @JsonKey()
  final String ingredients;
  @override
  @JsonKey()
  final String instructions;

  @override
  String toString() {
    return 'OnlineFoodDetails(basicInfo: $basicInfo, nutrition: $nutrition, servingSizes: $servingSizes, ingredients: $ingredients, instructions: $instructions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnlineFoodDetailsImpl &&
            (identical(other.basicInfo, basicInfo) ||
                other.basicInfo == basicInfo) &&
            (identical(other.nutrition, nutrition) ||
                other.nutrition == nutrition) &&
            const DeepCollectionEquality().equals(
              other._servingSizes,
              _servingSizes,
            ) &&
            (identical(other.ingredients, ingredients) ||
                other.ingredients == ingredients) &&
            (identical(other.instructions, instructions) ||
                other.instructions == instructions));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    basicInfo,
    nutrition,
    const DeepCollectionEquality().hash(_servingSizes),
    ingredients,
    instructions,
  );

  /// Create a copy of OnlineFoodDetails
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnlineFoodDetailsImplCopyWith<_$OnlineFoodDetailsImpl> get copyWith =>
      __$$OnlineFoodDetailsImplCopyWithImpl<_$OnlineFoodDetailsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OnlineFoodDetailsImplToJson(this);
  }
}

abstract class _OnlineFoodDetails implements OnlineFoodDetails {
  const factory _OnlineFoodDetails({
    required final OnlineFoodResult basicInfo,
    required final NutritionInfo nutrition,
    final List<ServingInfo> servingSizes,
    final String ingredients,
    final String instructions,
  }) = _$OnlineFoodDetailsImpl;

  factory _OnlineFoodDetails.fromJson(Map<String, dynamic> json) =
      _$OnlineFoodDetailsImpl.fromJson;

  @override
  OnlineFoodResult get basicInfo;
  @override
  NutritionInfo get nutrition;
  @override
  List<ServingInfo> get servingSizes;
  @override
  String get ingredients;
  @override
  String get instructions;

  /// Create a copy of OnlineFoodDetails
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnlineFoodDetailsImplCopyWith<_$OnlineFoodDetailsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

NutritionInfo _$NutritionInfoFromJson(Map<String, dynamic> json) {
  return _NutritionInfo.fromJson(json);
}

/// @nodoc
mixin _$NutritionInfo {
  double get calories => throw _privateConstructorUsedError;
  double get protein => throw _privateConstructorUsedError;
  double get carbs => throw _privateConstructorUsedError;
  double get fat => throw _privateConstructorUsedError;
  double get fiber => throw _privateConstructorUsedError;
  double get sugar => throw _privateConstructorUsedError;
  double get sodium => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;

  /// Serializes this NutritionInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of NutritionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NutritionInfoCopyWith<NutritionInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NutritionInfoCopyWith<$Res> {
  factory $NutritionInfoCopyWith(
    NutritionInfo value,
    $Res Function(NutritionInfo) then,
  ) = _$NutritionInfoCopyWithImpl<$Res, NutritionInfo>;
  @useResult
  $Res call({
    double calories,
    double protein,
    double carbs,
    double fat,
    double fiber,
    double sugar,
    double sodium,
    String? unit,
  });
}

/// @nodoc
class _$NutritionInfoCopyWithImpl<$Res, $Val extends NutritionInfo>
    implements $NutritionInfoCopyWith<$Res> {
  _$NutritionInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of NutritionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calories = null,
    Object? protein = null,
    Object? carbs = null,
    Object? fat = null,
    Object? fiber = null,
    Object? sugar = null,
    Object? sodium = null,
    Object? unit = freezed,
  }) {
    return _then(
      _value.copyWith(
            calories: null == calories
                ? _value.calories
                : calories // ignore: cast_nullable_to_non_nullable
                      as double,
            protein: null == protein
                ? _value.protein
                : protein // ignore: cast_nullable_to_non_nullable
                      as double,
            carbs: null == carbs
                ? _value.carbs
                : carbs // ignore: cast_nullable_to_non_nullable
                      as double,
            fat: null == fat
                ? _value.fat
                : fat // ignore: cast_nullable_to_non_nullable
                      as double,
            fiber: null == fiber
                ? _value.fiber
                : fiber // ignore: cast_nullable_to_non_nullable
                      as double,
            sugar: null == sugar
                ? _value.sugar
                : sugar // ignore: cast_nullable_to_non_nullable
                      as double,
            sodium: null == sodium
                ? _value.sodium
                : sodium // ignore: cast_nullable_to_non_nullable
                      as double,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$NutritionInfoImplCopyWith<$Res>
    implements $NutritionInfoCopyWith<$Res> {
  factory _$$NutritionInfoImplCopyWith(
    _$NutritionInfoImpl value,
    $Res Function(_$NutritionInfoImpl) then,
  ) = __$$NutritionInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double calories,
    double protein,
    double carbs,
    double fat,
    double fiber,
    double sugar,
    double sodium,
    String? unit,
  });
}

/// @nodoc
class __$$NutritionInfoImplCopyWithImpl<$Res>
    extends _$NutritionInfoCopyWithImpl<$Res, _$NutritionInfoImpl>
    implements _$$NutritionInfoImplCopyWith<$Res> {
  __$$NutritionInfoImplCopyWithImpl(
    _$NutritionInfoImpl _value,
    $Res Function(_$NutritionInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of NutritionInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? calories = null,
    Object? protein = null,
    Object? carbs = null,
    Object? fat = null,
    Object? fiber = null,
    Object? sugar = null,
    Object? sodium = null,
    Object? unit = freezed,
  }) {
    return _then(
      _$NutritionInfoImpl(
        calories: null == calories
            ? _value.calories
            : calories // ignore: cast_nullable_to_non_nullable
                  as double,
        protein: null == protein
            ? _value.protein
            : protein // ignore: cast_nullable_to_non_nullable
                  as double,
        carbs: null == carbs
            ? _value.carbs
            : carbs // ignore: cast_nullable_to_non_nullable
                  as double,
        fat: null == fat
            ? _value.fat
            : fat // ignore: cast_nullable_to_non_nullable
                  as double,
        fiber: null == fiber
            ? _value.fiber
            : fiber // ignore: cast_nullable_to_non_nullable
                  as double,
        sugar: null == sugar
            ? _value.sugar
            : sugar // ignore: cast_nullable_to_non_nullable
                  as double,
        sodium: null == sodium
            ? _value.sodium
            : sodium // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$NutritionInfoImpl implements _NutritionInfo {
  const _$NutritionInfoImpl({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0.0,
    this.sugar = 0.0,
    this.sodium = 0.0,
    this.unit,
  });

  factory _$NutritionInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$NutritionInfoImplFromJson(json);

  @override
  final double calories;
  @override
  final double protein;
  @override
  final double carbs;
  @override
  final double fat;
  @override
  @JsonKey()
  final double fiber;
  @override
  @JsonKey()
  final double sugar;
  @override
  @JsonKey()
  final double sodium;
  @override
  final String? unit;

  @override
  String toString() {
    return 'NutritionInfo(calories: $calories, protein: $protein, carbs: $carbs, fat: $fat, fiber: $fiber, sugar: $sugar, sodium: $sodium, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NutritionInfoImpl &&
            (identical(other.calories, calories) ||
                other.calories == calories) &&
            (identical(other.protein, protein) || other.protein == protein) &&
            (identical(other.carbs, carbs) || other.carbs == carbs) &&
            (identical(other.fat, fat) || other.fat == fat) &&
            (identical(other.fiber, fiber) || other.fiber == fiber) &&
            (identical(other.sugar, sugar) || other.sugar == sugar) &&
            (identical(other.sodium, sodium) || other.sodium == sodium) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    calories,
    protein,
    carbs,
    fat,
    fiber,
    sugar,
    sodium,
    unit,
  );

  /// Create a copy of NutritionInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$NutritionInfoImplCopyWith<_$NutritionInfoImpl> get copyWith =>
      __$$NutritionInfoImplCopyWithImpl<_$NutritionInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NutritionInfoImplToJson(this);
  }
}

abstract class _NutritionInfo implements NutritionInfo {
  const factory _NutritionInfo({
    required final double calories,
    required final double protein,
    required final double carbs,
    required final double fat,
    final double fiber,
    final double sugar,
    final double sodium,
    final String? unit,
  }) = _$NutritionInfoImpl;

  factory _NutritionInfo.fromJson(Map<String, dynamic> json) =
      _$NutritionInfoImpl.fromJson;

  @override
  double get calories;
  @override
  double get protein;
  @override
  double get carbs;
  @override
  double get fat;
  @override
  double get fiber;
  @override
  double get sugar;
  @override
  double get sodium;
  @override
  String? get unit;

  /// Create a copy of NutritionInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NutritionInfoImplCopyWith<_$NutritionInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ServingInfo _$ServingInfoFromJson(Map<String, dynamic> json) {
  return _ServingInfo.fromJson(json);
}

/// @nodoc
mixin _$ServingInfo {
  String get name => throw _privateConstructorUsedError;
  double get grams => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this ServingInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServingInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServingInfoCopyWith<ServingInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServingInfoCopyWith<$Res> {
  factory $ServingInfoCopyWith(
    ServingInfo value,
    $Res Function(ServingInfo) then,
  ) = _$ServingInfoCopyWithImpl<$Res, ServingInfo>;
  @useResult
  $Res call({String name, double grams, bool isDefault});
}

/// @nodoc
class _$ServingInfoCopyWithImpl<$Res, $Val extends ServingInfo>
    implements $ServingInfoCopyWith<$Res> {
  _$ServingInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServingInfo
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
abstract class _$$ServingInfoImplCopyWith<$Res>
    implements $ServingInfoCopyWith<$Res> {
  factory _$$ServingInfoImplCopyWith(
    _$ServingInfoImpl value,
    $Res Function(_$ServingInfoImpl) then,
  ) = __$$ServingInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double grams, bool isDefault});
}

/// @nodoc
class __$$ServingInfoImplCopyWithImpl<$Res>
    extends _$ServingInfoCopyWithImpl<$Res, _$ServingInfoImpl>
    implements _$$ServingInfoImplCopyWith<$Res> {
  __$$ServingInfoImplCopyWithImpl(
    _$ServingInfoImpl _value,
    $Res Function(_$ServingInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServingInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grams = null,
    Object? isDefault = null,
  }) {
    return _then(
      _$ServingInfoImpl(
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
class _$ServingInfoImpl implements _ServingInfo {
  const _$ServingInfoImpl({
    required this.name,
    required this.grams,
    this.isDefault = false,
  });

  factory _$ServingInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServingInfoImplFromJson(json);

  @override
  final String name;
  @override
  final double grams;
  @override
  @JsonKey()
  final bool isDefault;

  @override
  String toString() {
    return 'ServingInfo(name: $name, grams: $grams, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServingInfoImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.grams, grams) || other.grams == grams) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, grams, isDefault);

  /// Create a copy of ServingInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServingInfoImplCopyWith<_$ServingInfoImpl> get copyWith =>
      __$$ServingInfoImplCopyWithImpl<_$ServingInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServingInfoImplToJson(this);
  }
}

abstract class _ServingInfo implements ServingInfo {
  const factory _ServingInfo({
    required final String name,
    required final double grams,
    final bool isDefault,
  }) = _$ServingInfoImpl;

  factory _ServingInfo.fromJson(Map<String, dynamic> json) =
      _$ServingInfoImpl.fromJson;

  @override
  String get name;
  @override
  double get grams;
  @override
  bool get isDefault;

  /// Create a copy of ServingInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServingInfoImplCopyWith<_$ServingInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

OnlineFoodSearchResults _$OnlineFoodSearchResultsFromJson(
  Map<String, dynamic> json,
) {
  return _OnlineFoodSearchResults.fromJson(json);
}

/// @nodoc
mixin _$OnlineFoodSearchResults {
  List<OnlineFoodResult> get results => throw _privateConstructorUsedError;
  String get provider => throw _privateConstructorUsedError;
  SearchMode get searchMode => throw _privateConstructorUsedError;
  String get query => throw _privateConstructorUsedError;
  int get totalFound => throw _privateConstructorUsedError;

  /// Serializes this OnlineFoodSearchResults to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnlineFoodSearchResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnlineFoodSearchResultsCopyWith<OnlineFoodSearchResults> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnlineFoodSearchResultsCopyWith<$Res> {
  factory $OnlineFoodSearchResultsCopyWith(
    OnlineFoodSearchResults value,
    $Res Function(OnlineFoodSearchResults) then,
  ) = _$OnlineFoodSearchResultsCopyWithImpl<$Res, OnlineFoodSearchResults>;
  @useResult
  $Res call({
    List<OnlineFoodResult> results,
    String provider,
    SearchMode searchMode,
    String query,
    int totalFound,
  });
}

/// @nodoc
class _$OnlineFoodSearchResultsCopyWithImpl<
  $Res,
  $Val extends OnlineFoodSearchResults
>
    implements $OnlineFoodSearchResultsCopyWith<$Res> {
  _$OnlineFoodSearchResultsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnlineFoodSearchResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
    Object? provider = null,
    Object? searchMode = null,
    Object? query = null,
    Object? totalFound = null,
  }) {
    return _then(
      _value.copyWith(
            results: null == results
                ? _value.results
                : results // ignore: cast_nullable_to_non_nullable
                      as List<OnlineFoodResult>,
            provider: null == provider
                ? _value.provider
                : provider // ignore: cast_nullable_to_non_nullable
                      as String,
            searchMode: null == searchMode
                ? _value.searchMode
                : searchMode // ignore: cast_nullable_to_non_nullable
                      as SearchMode,
            query: null == query
                ? _value.query
                : query // ignore: cast_nullable_to_non_nullable
                      as String,
            totalFound: null == totalFound
                ? _value.totalFound
                : totalFound // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnlineFoodSearchResultsImplCopyWith<$Res>
    implements $OnlineFoodSearchResultsCopyWith<$Res> {
  factory _$$OnlineFoodSearchResultsImplCopyWith(
    _$OnlineFoodSearchResultsImpl value,
    $Res Function(_$OnlineFoodSearchResultsImpl) then,
  ) = __$$OnlineFoodSearchResultsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<OnlineFoodResult> results,
    String provider,
    SearchMode searchMode,
    String query,
    int totalFound,
  });
}

/// @nodoc
class __$$OnlineFoodSearchResultsImplCopyWithImpl<$Res>
    extends
        _$OnlineFoodSearchResultsCopyWithImpl<
          $Res,
          _$OnlineFoodSearchResultsImpl
        >
    implements _$$OnlineFoodSearchResultsImplCopyWith<$Res> {
  __$$OnlineFoodSearchResultsImplCopyWithImpl(
    _$OnlineFoodSearchResultsImpl _value,
    $Res Function(_$OnlineFoodSearchResultsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnlineFoodSearchResults
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? results = null,
    Object? provider = null,
    Object? searchMode = null,
    Object? query = null,
    Object? totalFound = null,
  }) {
    return _then(
      _$OnlineFoodSearchResultsImpl(
        results: null == results
            ? _value._results
            : results // ignore: cast_nullable_to_non_nullable
                  as List<OnlineFoodResult>,
        provider: null == provider
            ? _value.provider
            : provider // ignore: cast_nullable_to_non_nullable
                  as String,
        searchMode: null == searchMode
            ? _value.searchMode
            : searchMode // ignore: cast_nullable_to_non_nullable
                  as SearchMode,
        query: null == query
            ? _value.query
            : query // ignore: cast_nullable_to_non_nullable
                  as String,
        totalFound: null == totalFound
            ? _value.totalFound
            : totalFound // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OnlineFoodSearchResultsImpl implements _OnlineFoodSearchResults {
  const _$OnlineFoodSearchResultsImpl({
    final List<OnlineFoodResult> results = const [],
    required this.provider,
    required this.searchMode,
    required this.query,
    this.totalFound = 0,
  }) : _results = results;

  factory _$OnlineFoodSearchResultsImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnlineFoodSearchResultsImplFromJson(json);

  final List<OnlineFoodResult> _results;
  @override
  @JsonKey()
  List<OnlineFoodResult> get results {
    if (_results is EqualUnmodifiableListView) return _results;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_results);
  }

  @override
  final String provider;
  @override
  final SearchMode searchMode;
  @override
  final String query;
  @override
  @JsonKey()
  final int totalFound;

  @override
  String toString() {
    return 'OnlineFoodSearchResults(results: $results, provider: $provider, searchMode: $searchMode, query: $query, totalFound: $totalFound)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnlineFoodSearchResultsImpl &&
            const DeepCollectionEquality().equals(other._results, _results) &&
            (identical(other.provider, provider) ||
                other.provider == provider) &&
            (identical(other.searchMode, searchMode) ||
                other.searchMode == searchMode) &&
            (identical(other.query, query) || other.query == query) &&
            (identical(other.totalFound, totalFound) ||
                other.totalFound == totalFound));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_results),
    provider,
    searchMode,
    query,
    totalFound,
  );

  /// Create a copy of OnlineFoodSearchResults
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnlineFoodSearchResultsImplCopyWith<_$OnlineFoodSearchResultsImpl>
  get copyWith =>
      __$$OnlineFoodSearchResultsImplCopyWithImpl<
        _$OnlineFoodSearchResultsImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OnlineFoodSearchResultsImplToJson(this);
  }
}

abstract class _OnlineFoodSearchResults implements OnlineFoodSearchResults {
  const factory _OnlineFoodSearchResults({
    final List<OnlineFoodResult> results,
    required final String provider,
    required final SearchMode searchMode,
    required final String query,
    final int totalFound,
  }) = _$OnlineFoodSearchResultsImpl;

  factory _OnlineFoodSearchResults.fromJson(Map<String, dynamic> json) =
      _$OnlineFoodSearchResultsImpl.fromJson;

  @override
  List<OnlineFoodResult> get results;
  @override
  String get provider;
  @override
  SearchMode get searchMode;
  @override
  String get query;
  @override
  int get totalFound;

  /// Create a copy of OnlineFoodSearchResults
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnlineFoodSearchResultsImplCopyWith<_$OnlineFoodSearchResultsImpl>
  get copyWith => throw _privateConstructorUsedError;
}

OnlineServingSize _$OnlineServingSizeFromJson(Map<String, dynamic> json) {
  return _OnlineServingSize.fromJson(json);
}

/// @nodoc
mixin _$OnlineServingSize {
  String get name => throw _privateConstructorUsedError;
  double get grams => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  String get originalUnit =>
      throw _privateConstructorUsedError; // "cup", "oz", etc.
  double get originalAmount => throw _privateConstructorUsedError;

  /// Serializes this OnlineServingSize to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of OnlineServingSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnlineServingSizeCopyWith<OnlineServingSize> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnlineServingSizeCopyWith<$Res> {
  factory $OnlineServingSizeCopyWith(
    OnlineServingSize value,
    $Res Function(OnlineServingSize) then,
  ) = _$OnlineServingSizeCopyWithImpl<$Res, OnlineServingSize>;
  @useResult
  $Res call({
    String name,
    double grams,
    bool isDefault,
    String originalUnit,
    double originalAmount,
  });
}

/// @nodoc
class _$OnlineServingSizeCopyWithImpl<$Res, $Val extends OnlineServingSize>
    implements $OnlineServingSizeCopyWith<$Res> {
  _$OnlineServingSizeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnlineServingSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grams = null,
    Object? isDefault = null,
    Object? originalUnit = null,
    Object? originalAmount = null,
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
            originalUnit: null == originalUnit
                ? _value.originalUnit
                : originalUnit // ignore: cast_nullable_to_non_nullable
                      as String,
            originalAmount: null == originalAmount
                ? _value.originalAmount
                : originalAmount // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$OnlineServingSizeImplCopyWith<$Res>
    implements $OnlineServingSizeCopyWith<$Res> {
  factory _$$OnlineServingSizeImplCopyWith(
    _$OnlineServingSizeImpl value,
    $Res Function(_$OnlineServingSizeImpl) then,
  ) = __$$OnlineServingSizeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    double grams,
    bool isDefault,
    String originalUnit,
    double originalAmount,
  });
}

/// @nodoc
class __$$OnlineServingSizeImplCopyWithImpl<$Res>
    extends _$OnlineServingSizeCopyWithImpl<$Res, _$OnlineServingSizeImpl>
    implements _$$OnlineServingSizeImplCopyWith<$Res> {
  __$$OnlineServingSizeImplCopyWithImpl(
    _$OnlineServingSizeImpl _value,
    $Res Function(_$OnlineServingSizeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnlineServingSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grams = null,
    Object? isDefault = null,
    Object? originalUnit = null,
    Object? originalAmount = null,
  }) {
    return _then(
      _$OnlineServingSizeImpl(
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
        originalUnit: null == originalUnit
            ? _value.originalUnit
            : originalUnit // ignore: cast_nullable_to_non_nullable
                  as String,
        originalAmount: null == originalAmount
            ? _value.originalAmount
            : originalAmount // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$OnlineServingSizeImpl implements _OnlineServingSize {
  const _$OnlineServingSizeImpl({
    this.name = '',
    this.grams = 0.0,
    this.isDefault = false,
    this.originalUnit = '',
    this.originalAmount = 0.0,
  });

  factory _$OnlineServingSizeImpl.fromJson(Map<String, dynamic> json) =>
      _$$OnlineServingSizeImplFromJson(json);

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
  @JsonKey()
  final String originalUnit;
  // "cup", "oz", etc.
  @override
  @JsonKey()
  final double originalAmount;

  @override
  String toString() {
    return 'OnlineServingSize(name: $name, grams: $grams, isDefault: $isDefault, originalUnit: $originalUnit, originalAmount: $originalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnlineServingSizeImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.grams, grams) || other.grams == grams) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.originalUnit, originalUnit) ||
                other.originalUnit == originalUnit) &&
            (identical(other.originalAmount, originalAmount) ||
                other.originalAmount == originalAmount));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    name,
    grams,
    isDefault,
    originalUnit,
    originalAmount,
  );

  /// Create a copy of OnlineServingSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnlineServingSizeImplCopyWith<_$OnlineServingSizeImpl> get copyWith =>
      __$$OnlineServingSizeImplCopyWithImpl<_$OnlineServingSizeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$OnlineServingSizeImplToJson(this);
  }
}

abstract class _OnlineServingSize implements OnlineServingSize {
  const factory _OnlineServingSize({
    final String name,
    final double grams,
    final bool isDefault,
    final String originalUnit,
    final double originalAmount,
  }) = _$OnlineServingSizeImpl;

  factory _OnlineServingSize.fromJson(Map<String, dynamic> json) =
      _$OnlineServingSizeImpl.fromJson;

  @override
  String get name;
  @override
  double get grams;
  @override
  bool get isDefault;
  @override
  String get originalUnit; // "cup", "oz", etc.
  @override
  double get originalAmount;

  /// Create a copy of OnlineServingSize
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnlineServingSizeImplCopyWith<_$OnlineServingSizeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
