// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'online_food_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnlineFoodState {
  bool get isLoading => throw _privateConstructorUsedError;
  bool get isLoadingDetails => throw _privateConstructorUsedError;
  bool get isAddingToDatabase => throw _privateConstructorUsedError;
  bool get isServiceAvailable => throw _privateConstructorUsedError;
  List<OnlineFoodResult> get searchResults =>
      throw _privateConstructorUsedError;
  OnlineFoodDetails? get selectedFoodDetails =>
      throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;
  bool get hasError =>
      throw _privateConstructorUsedError; // Multi-selection features
  bool get isSelectionMode => throw _privateConstructorUsedError;
  List<String> get selectedFoodIds => throw _privateConstructorUsedError;
  int get addedCount => throw _privateConstructorUsedError;

  /// Create a copy of OnlineFoodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnlineFoodStateCopyWith<OnlineFoodState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnlineFoodStateCopyWith<$Res> {
  factory $OnlineFoodStateCopyWith(
    OnlineFoodState value,
    $Res Function(OnlineFoodState) then,
  ) = _$OnlineFoodStateCopyWithImpl<$Res, OnlineFoodState>;
  @useResult
  $Res call({
    bool isLoading,
    bool isLoadingDetails,
    bool isAddingToDatabase,
    bool isServiceAvailable,
    List<OnlineFoodResult> searchResults,
    OnlineFoodDetails? selectedFoodDetails,
    String searchQuery,
    String errorMessage,
    bool hasError,
    bool isSelectionMode,
    List<String> selectedFoodIds,
    int addedCount,
  });

  $OnlineFoodDetailsCopyWith<$Res>? get selectedFoodDetails;
}

/// @nodoc
class _$OnlineFoodStateCopyWithImpl<$Res, $Val extends OnlineFoodState>
    implements $OnlineFoodStateCopyWith<$Res> {
  _$OnlineFoodStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnlineFoodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoadingDetails = null,
    Object? isAddingToDatabase = null,
    Object? isServiceAvailable = null,
    Object? searchResults = null,
    Object? selectedFoodDetails = freezed,
    Object? searchQuery = null,
    Object? errorMessage = null,
    Object? hasError = null,
    Object? isSelectionMode = null,
    Object? selectedFoodIds = null,
    Object? addedCount = null,
  }) {
    return _then(
      _value.copyWith(
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLoadingDetails: null == isLoadingDetails
                ? _value.isLoadingDetails
                : isLoadingDetails // ignore: cast_nullable_to_non_nullable
                      as bool,
            isAddingToDatabase: null == isAddingToDatabase
                ? _value.isAddingToDatabase
                : isAddingToDatabase // ignore: cast_nullable_to_non_nullable
                      as bool,
            isServiceAvailable: null == isServiceAvailable
                ? _value.isServiceAvailable
                : isServiceAvailable // ignore: cast_nullable_to_non_nullable
                      as bool,
            searchResults: null == searchResults
                ? _value.searchResults
                : searchResults // ignore: cast_nullable_to_non_nullable
                      as List<OnlineFoodResult>,
            selectedFoodDetails: freezed == selectedFoodDetails
                ? _value.selectedFoodDetails
                : selectedFoodDetails // ignore: cast_nullable_to_non_nullable
                      as OnlineFoodDetails?,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
            hasError: null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                      as bool,
            isSelectionMode: null == isSelectionMode
                ? _value.isSelectionMode
                : isSelectionMode // ignore: cast_nullable_to_non_nullable
                      as bool,
            selectedFoodIds: null == selectedFoodIds
                ? _value.selectedFoodIds
                : selectedFoodIds // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            addedCount: null == addedCount
                ? _value.addedCount
                : addedCount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }

  /// Create a copy of OnlineFoodState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $OnlineFoodDetailsCopyWith<$Res>? get selectedFoodDetails {
    if (_value.selectedFoodDetails == null) {
      return null;
    }

    return $OnlineFoodDetailsCopyWith<$Res>(_value.selectedFoodDetails!, (
      value,
    ) {
      return _then(_value.copyWith(selectedFoodDetails: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OnlineFoodStateImplCopyWith<$Res>
    implements $OnlineFoodStateCopyWith<$Res> {
  factory _$$OnlineFoodStateImplCopyWith(
    _$OnlineFoodStateImpl value,
    $Res Function(_$OnlineFoodStateImpl) then,
  ) = __$$OnlineFoodStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    bool isLoading,
    bool isLoadingDetails,
    bool isAddingToDatabase,
    bool isServiceAvailable,
    List<OnlineFoodResult> searchResults,
    OnlineFoodDetails? selectedFoodDetails,
    String searchQuery,
    String errorMessage,
    bool hasError,
    bool isSelectionMode,
    List<String> selectedFoodIds,
    int addedCount,
  });

  @override
  $OnlineFoodDetailsCopyWith<$Res>? get selectedFoodDetails;
}

/// @nodoc
class __$$OnlineFoodStateImplCopyWithImpl<$Res>
    extends _$OnlineFoodStateCopyWithImpl<$Res, _$OnlineFoodStateImpl>
    implements _$$OnlineFoodStateImplCopyWith<$Res> {
  __$$OnlineFoodStateImplCopyWithImpl(
    _$OnlineFoodStateImpl _value,
    $Res Function(_$OnlineFoodStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnlineFoodState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? isLoadingDetails = null,
    Object? isAddingToDatabase = null,
    Object? isServiceAvailable = null,
    Object? searchResults = null,
    Object? selectedFoodDetails = freezed,
    Object? searchQuery = null,
    Object? errorMessage = null,
    Object? hasError = null,
    Object? isSelectionMode = null,
    Object? selectedFoodIds = null,
    Object? addedCount = null,
  }) {
    return _then(
      _$OnlineFoodStateImpl(
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLoadingDetails: null == isLoadingDetails
            ? _value.isLoadingDetails
            : isLoadingDetails // ignore: cast_nullable_to_non_nullable
                  as bool,
        isAddingToDatabase: null == isAddingToDatabase
            ? _value.isAddingToDatabase
            : isAddingToDatabase // ignore: cast_nullable_to_non_nullable
                  as bool,
        isServiceAvailable: null == isServiceAvailable
            ? _value.isServiceAvailable
            : isServiceAvailable // ignore: cast_nullable_to_non_nullable
                  as bool,
        searchResults: null == searchResults
            ? _value._searchResults
            : searchResults // ignore: cast_nullable_to_non_nullable
                  as List<OnlineFoodResult>,
        selectedFoodDetails: freezed == selectedFoodDetails
            ? _value.selectedFoodDetails
            : selectedFoodDetails // ignore: cast_nullable_to_non_nullable
                  as OnlineFoodDetails?,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        errorMessage: null == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String,
        hasError: null == hasError
            ? _value.hasError
            : hasError // ignore: cast_nullable_to_non_nullable
                  as bool,
        isSelectionMode: null == isSelectionMode
            ? _value.isSelectionMode
            : isSelectionMode // ignore: cast_nullable_to_non_nullable
                  as bool,
        selectedFoodIds: null == selectedFoodIds
            ? _value._selectedFoodIds
            : selectedFoodIds // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        addedCount: null == addedCount
            ? _value.addedCount
            : addedCount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$OnlineFoodStateImpl extends _OnlineFoodState {
  const _$OnlineFoodStateImpl({
    this.isLoading = false,
    this.isLoadingDetails = false,
    this.isAddingToDatabase = false,
    this.isServiceAvailable = false,
    final List<OnlineFoodResult> searchResults = const [],
    this.selectedFoodDetails,
    this.searchQuery = '',
    this.errorMessage = '',
    this.hasError = false,
    this.isSelectionMode = false,
    final List<String> selectedFoodIds = const [],
    this.addedCount = 0,
  }) : _searchResults = searchResults,
       _selectedFoodIds = selectedFoodIds,
       super._();

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isLoadingDetails;
  @override
  @JsonKey()
  final bool isAddingToDatabase;
  @override
  @JsonKey()
  final bool isServiceAvailable;
  final List<OnlineFoodResult> _searchResults;
  @override
  @JsonKey()
  List<OnlineFoodResult> get searchResults {
    if (_searchResults is EqualUnmodifiableListView) return _searchResults;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_searchResults);
  }

  @override
  final OnlineFoodDetails? selectedFoodDetails;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final String errorMessage;
  @override
  @JsonKey()
  final bool hasError;
  // Multi-selection features
  @override
  @JsonKey()
  final bool isSelectionMode;
  final List<String> _selectedFoodIds;
  @override
  @JsonKey()
  List<String> get selectedFoodIds {
    if (_selectedFoodIds is EqualUnmodifiableListView) return _selectedFoodIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedFoodIds);
  }

  @override
  @JsonKey()
  final int addedCount;

  @override
  String toString() {
    return 'OnlineFoodState(isLoading: $isLoading, isLoadingDetails: $isLoadingDetails, isAddingToDatabase: $isAddingToDatabase, isServiceAvailable: $isServiceAvailable, searchResults: $searchResults, selectedFoodDetails: $selectedFoodDetails, searchQuery: $searchQuery, errorMessage: $errorMessage, hasError: $hasError, isSelectionMode: $isSelectionMode, selectedFoodIds: $selectedFoodIds, addedCount: $addedCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnlineFoodStateImpl &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isLoadingDetails, isLoadingDetails) ||
                other.isLoadingDetails == isLoadingDetails) &&
            (identical(other.isAddingToDatabase, isAddingToDatabase) ||
                other.isAddingToDatabase == isAddingToDatabase) &&
            (identical(other.isServiceAvailable, isServiceAvailable) ||
                other.isServiceAvailable == isServiceAvailable) &&
            const DeepCollectionEquality().equals(
              other._searchResults,
              _searchResults,
            ) &&
            (identical(other.selectedFoodDetails, selectedFoodDetails) ||
                other.selectedFoodDetails == selectedFoodDetails) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.isSelectionMode, isSelectionMode) ||
                other.isSelectionMode == isSelectionMode) &&
            const DeepCollectionEquality().equals(
              other._selectedFoodIds,
              _selectedFoodIds,
            ) &&
            (identical(other.addedCount, addedCount) ||
                other.addedCount == addedCount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    isLoading,
    isLoadingDetails,
    isAddingToDatabase,
    isServiceAvailable,
    const DeepCollectionEquality().hash(_searchResults),
    selectedFoodDetails,
    searchQuery,
    errorMessage,
    hasError,
    isSelectionMode,
    const DeepCollectionEquality().hash(_selectedFoodIds),
    addedCount,
  );

  /// Create a copy of OnlineFoodState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnlineFoodStateImplCopyWith<_$OnlineFoodStateImpl> get copyWith =>
      __$$OnlineFoodStateImplCopyWithImpl<_$OnlineFoodStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OnlineFoodState extends OnlineFoodState {
  const factory _OnlineFoodState({
    final bool isLoading,
    final bool isLoadingDetails,
    final bool isAddingToDatabase,
    final bool isServiceAvailable,
    final List<OnlineFoodResult> searchResults,
    final OnlineFoodDetails? selectedFoodDetails,
    final String searchQuery,
    final String errorMessage,
    final bool hasError,
    final bool isSelectionMode,
    final List<String> selectedFoodIds,
    final int addedCount,
  }) = _$OnlineFoodStateImpl;
  const _OnlineFoodState._() : super._();

  @override
  bool get isLoading;
  @override
  bool get isLoadingDetails;
  @override
  bool get isAddingToDatabase;
  @override
  bool get isServiceAvailable;
  @override
  List<OnlineFoodResult> get searchResults;
  @override
  OnlineFoodDetails? get selectedFoodDetails;
  @override
  String get searchQuery;
  @override
  String get errorMessage;
  @override
  bool get hasError; // Multi-selection features
  @override
  bool get isSelectionMode;
  @override
  List<String> get selectedFoodIds;
  @override
  int get addedCount;

  /// Create a copy of OnlineFoodState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnlineFoodStateImplCopyWith<_$OnlineFoodStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
