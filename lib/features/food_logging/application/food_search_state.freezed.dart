// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_search_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FoodSearchState {
  // Loading states
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isSearchingFavorites => throw _privateConstructorUsedError;
  bool get isSearchingOnline => throw _privateConstructorUsedError;
  bool get isLoadingDetails =>
      throw _privateConstructorUsedError; // Search data
  String get searchQuery => throw _privateConstructorUsedError;
  List<FavoriteFoodModel> get favoriteResults =>
      throw _privateConstructorUsedError;
  List<OnlineFoodResult> get onlineResults =>
      throw _privateConstructorUsedError;
  List<FavoriteFoodModel> get recentFavorites =>
      throw _privateConstructorUsedError;
  List<FavoriteFoodModel> get quickSuggestions =>
      throw _privateConstructorUsedError; // Selected items
  FavoriteFoodModel? get selectedFood => throw _privateConstructorUsedError;
  OnlineFoodDetails? get selectedOnlineFoodDetails =>
      throw _privateConstructorUsedError; // Service availability
  bool get isOnlineServiceAvailable =>
      throw _privateConstructorUsedError; // Error handling
  bool get hasError => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of FoodSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FoodSearchStateCopyWith<FoodSearchState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodSearchStateCopyWith<$Res> {
  factory $FoodSearchStateCopyWith(
    FoodSearchState value,
    $Res Function(FoodSearchState) then,
  ) = _$FoodSearchStateCopyWithImpl<$Res, FoodSearchState>;
  @useResult
  $Res call({
    bool isLoading,
    bool isSearchingFavorites,
    bool isSearchingOnline,
    bool isLoadingDetails,
    String searchQuery,
    List<FavoriteFoodModel> favoriteResults,
    List<OnlineFoodResult> onlineResults,
    List<FavoriteFoodModel> recentFavorites,
    List<FavoriteFoodModel> quickSuggestions,
    FavoriteFoodModel? selectedFood,
    OnlineFoodDetails? selectedOnlineFoodDetails,
    bool isOnlineServiceAvailable,
    bool hasError,
    String errorMessage,
  });

  $FavoriteFoodModelCopyWith<$Res>? get selectedFood;
  $OnlineFoodDetailsCopyWith<$Res>? get selectedOnlineFoodDetails;
}

/// @nodoc
class _$FoodSearchStateCopyWithImpl<$Res, $Val extends FoodSearchState>
    implements $FoodSearchStateCopyWith<$Res> {
  _$FoodSearchStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FoodSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isSearchingFavorites = null,
    Object? isSearchingOnline = null,
    Object? isLoadingDetails = null,
    Object? searchQuery = null,
    Object? favoriteResults = null,
    Object? onlineResults = null,
    Object? recentFavorites = null,
    Object? quickSuggestions = null,
    Object? selectedFood = freezed,
    Object? selectedOnlineFoodDetails = freezed,
    Object? isOnlineServiceAvailable = null,
    Object? hasError = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSearchingFavorites: null == isSearchingFavorites
                ? _value.isSearchingFavorites
                : isSearchingFavorites // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSearchingOnline: null == isSearchingOnline
                ? _value.isSearchingOnline
                : isSearchingOnline // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingDetails: null == isLoadingDetails
                ? _value.isLoadingDetails
                : isLoadingDetails // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            favoriteResults: null == favoriteResults
                ? _value.favoriteResults
                : favoriteResults // ignore: cast_nullable_to_non_nullable
                      as List<FavoriteFoodModel>,
            onlineResults: null == onlineResults
                ? _value.onlineResults
                : onlineResults // ignore: cast_nullable_to_non_nullable
                      as List<OnlineFoodResult>,
            recentFavorites: null == recentFavorites
                ? _value.recentFavorites
                : recentFavorites // ignore: cast_nullable_to_non_nullable
                      as List<FavoriteFoodModel>,
            quickSuggestions: null == quickSuggestions
                ? _value.quickSuggestions
                : quickSuggestions // ignore: cast_nullable_to_non_nullable
                      as List<FavoriteFoodModel>,
            selectedFood: freezed == selectedFood
                ? _value.selectedFood
                : selectedFood // ignore: cast_nullable_to_non_nullable
                      as FavoriteFoodModel?,
            selectedOnlineFoodDetails: freezed == selectedOnlineFoodDetails
                ? _value.selectedOnlineFoodDetails
                : selectedOnlineFoodDetails // ignore: cast_nullable_to_non_nullable
                      as OnlineFoodDetails?,
            isOnlineServiceAvailable: null == isOnlineServiceAvailable
                ? _value.isOnlineServiceAvailable
                : isOnlineServiceAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasError: null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of FoodSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FavoriteFoodModelCopyWith<$Res>? get selectedFood {
    if (_value.selectedFood == null) {
      return null;
    }

    return $FavoriteFoodModelCopyWith<$Res>(_value.selectedFood!, (value) {
      return _then(_value.copyWith(selectedFood: value) as $Val);
    });
  }

  /// Create a copy of FoodSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnlineFoodDetailsCopyWith<$Res>? get selectedOnlineFoodDetails {
    if (_value.selectedOnlineFoodDetails == null) {
      return null;
    }

    return $OnlineFoodDetailsCopyWith<$Res>(_value.selectedOnlineFoodDetails!, (
      value,
    ) {
      return _then(_value.copyWith(selectedOnlineFoodDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FoodSearchStateImplCopyWith<$Res>
    implements $FoodSearchStateCopyWith<$Res> {
  factory _$$FoodSearchStateImplCopyWith(
    _$FoodSearchStateImpl value,
    $Res Function(_$FoodSearchStateImpl) then,
  ) = __$$FoodSearchStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    bool isSearchingFavorites,
    bool isSearchingOnline,
    bool isLoadingDetails,
    String searchQuery,
    List<FavoriteFoodModel> favoriteResults,
    List<OnlineFoodResult> onlineResults,
    List<FavoriteFoodModel> recentFavorites,
    List<FavoriteFoodModel> quickSuggestions,
    FavoriteFoodModel? selectedFood,
    OnlineFoodDetails? selectedOnlineFoodDetails,
    bool isOnlineServiceAvailable,
    bool hasError,
    String errorMessage,
  });

  @override
  $FavoriteFoodModelCopyWith<$Res>? get selectedFood;
  @override
  $OnlineFoodDetailsCopyWith<$Res>? get selectedOnlineFoodDetails;
}

/// @nodoc
class __$$FoodSearchStateImplCopyWithImpl<$Res>
    extends _$FoodSearchStateCopyWithImpl<$Res, _$FoodSearchStateImpl>
    implements _$$FoodSearchStateImplCopyWith<$Res> {
  __$$FoodSearchStateImplCopyWithImpl(
    _$FoodSearchStateImpl _value,
    $Res Function(_$FoodSearchStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FoodSearchState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isSearchingFavorites = null,
    Object? isSearchingOnline = null,
    Object? isLoadingDetails = null,
    Object? searchQuery = null,
    Object? favoriteResults = null,
    Object? onlineResults = null,
    Object? recentFavorites = null,
    Object? quickSuggestions = null,
    Object? selectedFood = freezed,
    Object? selectedOnlineFoodDetails = freezed,
    Object? isOnlineServiceAvailable = null,
    Object? hasError = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _$FoodSearchStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSearchingFavorites: null == isSearchingFavorites
            ? _value.isSearchingFavorites
            : isSearchingFavorites // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSearchingOnline: null == isSearchingOnline
            ? _value.isSearchingOnline
            : isSearchingOnline // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingDetails: null == isLoadingDetails
            ? _value.isLoadingDetails
            : isLoadingDetails // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        favoriteResults: null == favoriteResults
            ? _value._favoriteResults
            : favoriteResults // ignore: cast_nullable_to_non_nullable
                  as List<FavoriteFoodModel>,
        onlineResults: null == onlineResults
            ? _value._onlineResults
            : onlineResults // ignore: cast_nullable_to_non_nullable
                  as List<OnlineFoodResult>,
        recentFavorites: null == recentFavorites
            ? _value._recentFavorites
            : recentFavorites // ignore: cast_nullable_to_non_nullable
                  as List<FavoriteFoodModel>,
        quickSuggestions: null == quickSuggestions
            ? _value._quickSuggestions
            : quickSuggestions // ignore: cast_nullable_to_non_nullable
                  as List<FavoriteFoodModel>,
        selectedFood: freezed == selectedFood
            ? _value.selectedFood
            : selectedFood // ignore: cast_nullable_to_non_nullable
                  as FavoriteFoodModel?,
        selectedOnlineFoodDetails: freezed == selectedOnlineFoodDetails
            ? _value.selectedOnlineFoodDetails
            : selectedOnlineFoodDetails // ignore: cast_nullable_to_non_nullable
                  as OnlineFoodDetails?,
        isOnlineServiceAvailable: null == isOnlineServiceAvailable
            ? _value.isOnlineServiceAvailable
            : isOnlineServiceAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasError: null == hasError
            ? _value.hasError
            : hasError // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc

class _$FoodSearchStateImpl extends _FoodSearchState {
  const _$FoodSearchStateImpl({
    this.isLoading = false,
    this.isSearchingFavorites = false,
    this.isSearchingOnline = false,
    this.isLoadingDetails = false,
    this.searchQuery = '',
    final List<FavoriteFoodModel> favoriteResults = const [],
    final List<OnlineFoodResult> onlineResults = const [],
    final List<FavoriteFoodModel> recentFavorites = const [],
    final List<FavoriteFoodModel> quickSuggestions = const [],
    this.selectedFood,
    this.selectedOnlineFoodDetails,
    this.isOnlineServiceAvailable = false,
    this.hasError = false,
    this.errorMessage = '',
  }) : _favoriteResults = favoriteResults,
       _onlineResults = onlineResults,
       _recentFavorites = recentFavorites,
       _quickSuggestions = quickSuggestions,
       super._();

  // Loading states
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isSearchingFavorites;
  @override
  @JsonKey()
  final bool isSearchingOnline;
  @override
  @JsonKey()
  final bool isLoadingDetails;
  // Search data
  @override
  @JsonKey()
  final String searchQuery;
  final List<FavoriteFoodModel> _favoriteResults;
  @override
  @JsonKey()
  List<FavoriteFoodModel> get favoriteResults {
    if (_favoriteResults is EqualUnmodifiableListView) return _favoriteResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_favoriteResults);
  }

  final List<OnlineFoodResult> _onlineResults;
  @override
  @JsonKey()
  List<OnlineFoodResult> get onlineResults {
    if (_onlineResults is EqualUnmodifiableListView) return _onlineResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_onlineResults);
  }

  final List<FavoriteFoodModel> _recentFavorites;
  @override
  @JsonKey()
  List<FavoriteFoodModel> get recentFavorites {
    if (_recentFavorites is EqualUnmodifiableListView) return _recentFavorites;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recentFavorites);
  }

  final List<FavoriteFoodModel> _quickSuggestions;
  @override
  @JsonKey()
  List<FavoriteFoodModel> get quickSuggestions {
    if (_quickSuggestions is EqualUnmodifiableListView)
      return _quickSuggestions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_quickSuggestions);
  }

  // Selected items
  @override
  final FavoriteFoodModel? selectedFood;
  @override
  final OnlineFoodDetails? selectedOnlineFoodDetails;
  // Service availability
  @override
  @JsonKey()
  final bool isOnlineServiceAvailable;
  // Error handling
  @override
  @JsonKey()
  final bool hasError;
  @override
  @JsonKey()
  final String errorMessage;

  @override
  String toString() {
    return 'FoodSearchState(isLoading: $isLoading, isSearchingFavorites: $isSearchingFavorites, isSearchingOnline: $isSearchingOnline, isLoadingDetails: $isLoadingDetails, searchQuery: $searchQuery, favoriteResults: $favoriteResults, onlineResults: $onlineResults, recentFavorites: $recentFavorites, quickSuggestions: $quickSuggestions, selectedFood: $selectedFood, selectedOnlineFoodDetails: $selectedOnlineFoodDetails, isOnlineServiceAvailable: $isOnlineServiceAvailable, hasError: $hasError, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodSearchStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isSearchingFavorites, isSearchingFavorites) ||
                other.isSearchingFavorites == isSearchingFavorites) &&
            (identical(other.isSearchingOnline, isSearchingOnline) ||
                other.isSearchingOnline == isSearchingOnline) &&
            (identical(other.isLoadingDetails, isLoadingDetails) ||
                other.isLoadingDetails == isLoadingDetails) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality().equals(
              other._favoriteResults,
              _favoriteResults,
            ) &&
            const DeepCollectionEquality().equals(
              other._onlineResults,
              _onlineResults,
            ) &&
            const DeepCollectionEquality().equals(
              other._recentFavorites,
              _recentFavorites,
            ) &&
            const DeepCollectionEquality().equals(
              other._quickSuggestions,
              _quickSuggestions,
            ) &&
            (identical(other.selectedFood, selectedFood) ||
                other.selectedFood == selectedFood) &&
            (identical(
                  other.selectedOnlineFoodDetails,
                  selectedOnlineFoodDetails,
                ) ||
                other.selectedOnlineFoodDetails == selectedOnlineFoodDetails) &&
            (identical(
                  other.isOnlineServiceAvailable,
                  isOnlineServiceAvailable,
                ) ||
                other.isOnlineServiceAvailable == isOnlineServiceAvailable) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    isSearchingFavorites,
    isSearchingOnline,
    isLoadingDetails,
    searchQuery,
    const DeepCollectionEquality().hash(_favoriteResults),
    const DeepCollectionEquality().hash(_onlineResults),
    const DeepCollectionEquality().hash(_recentFavorites),
    const DeepCollectionEquality().hash(_quickSuggestions),
    selectedFood,
    selectedOnlineFoodDetails,
    isOnlineServiceAvailable,
    hasError,
    errorMessage,
  );

  /// Create a copy of FoodSearchState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodSearchStateImplCopyWith<_$FoodSearchStateImpl> get copyWith =>
      __$$FoodSearchStateImplCopyWithImpl<_$FoodSearchStateImpl>(
        this,
        _$identity,
      );
}

abstract class _FoodSearchState extends FoodSearchState {
  const factory _FoodSearchState({
    final bool isLoading,
    final bool isSearchingFavorites,
    final bool isSearchingOnline,
    final bool isLoadingDetails,
    final String searchQuery,
    final List<FavoriteFoodModel> favoriteResults,
    final List<OnlineFoodResult> onlineResults,
    final List<FavoriteFoodModel> recentFavorites,
    final List<FavoriteFoodModel> quickSuggestions,
    final FavoriteFoodModel? selectedFood,
    final OnlineFoodDetails? selectedOnlineFoodDetails,
    final bool isOnlineServiceAvailable,
    final bool hasError,
    final String errorMessage,
  }) = _$FoodSearchStateImpl;
  const _FoodSearchState._() : super._();

  // Loading states
  @override
  bool get isLoading;
  @override
  bool get isSearchingFavorites;
  @override
  bool get isSearchingOnline;
  @override
  bool get isLoadingDetails; // Search data
  @override
  String get searchQuery;
  @override
  List<FavoriteFoodModel> get favoriteResults;
  @override
  List<OnlineFoodResult> get onlineResults;
  @override
  List<FavoriteFoodModel> get recentFavorites;
  @override
  List<FavoriteFoodModel> get quickSuggestions; // Selected items
  @override
  FavoriteFoodModel? get selectedFood;
  @override
  OnlineFoodDetails? get selectedOnlineFoodDetails; // Service availability
  @override
  bool get isOnlineServiceAvailable; // Error handling
  @override
  bool get hasError;
  @override
  String get errorMessage;

  /// Create a copy of FoodSearchState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FoodSearchStateImplCopyWith<_$FoodSearchStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
