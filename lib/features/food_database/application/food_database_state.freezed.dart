// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_database_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FoodDatabaseState {
  DataState<List<FoodRecordModel>> get foodsDataState =>
      throw _privateConstructorUsedError;
  String get searchQuery => throw _privateConstructorUsedError;
  FoodCategory? get selectedCategory => throw _privateConstructorUsedError;
  FoodRecordModel? get editingFood => throw _privateConstructorUsedError;
  bool get isAddingFood => throw _privateConstructorUsedError;
  String get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of FoodDatabaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FoodDatabaseStateCopyWith<FoodDatabaseState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodDatabaseStateCopyWith<$Res> {
  factory $FoodDatabaseStateCopyWith(
    FoodDatabaseState value,
    $Res Function(FoodDatabaseState) then,
  ) = _$FoodDatabaseStateCopyWithImpl<$Res, FoodDatabaseState>;
  @useResult
  $Res call({
    DataState<List<FoodRecordModel>> foodsDataState,
    String searchQuery,
    FoodCategory? selectedCategory,
    FoodRecordModel? editingFood,
    bool isAddingFood,
    String errorMessage,
  });

  $FoodRecordModelCopyWith<$Res>? get editingFood;
}

/// @nodoc
class _$FoodDatabaseStateCopyWithImpl<$Res, $Val extends FoodDatabaseState>
    implements $FoodDatabaseStateCopyWith<$Res> {
  _$FoodDatabaseStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FoodDatabaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodsDataState = null,
    Object? searchQuery = null,
    Object? selectedCategory = freezed,
    Object? editingFood = freezed,
    Object? isAddingFood = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _value.copyWith(
            foodsDataState: null == foodsDataState
                ? _value.foodsDataState
                : foodsDataState // ignore: cast_nullable_to_non_nullable
                      as DataState<List<FoodRecordModel>>,
            searchQuery: null == searchQuery
                ? _value.searchQuery
                : searchQuery // ignore: cast_nullable_to_non_nullable
                      as String,
            selectedCategory: freezed == selectedCategory
                ? _value.selectedCategory
                : selectedCategory // ignore: cast_nullable_to_non_nullable
                      as FoodCategory?,
            editingFood: freezed == editingFood
                ? _value.editingFood
                : editingFood // ignore: cast_nullable_to_non_nullable
                      as FoodRecordModel?,
            isAddingFood: null == isAddingFood
                ? _value.isAddingFood
                : isAddingFood // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: null == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }

  /// Create a copy of FoodDatabaseState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $FoodRecordModelCopyWith<$Res>? get editingFood {
    if (_value.editingFood == null) {
      return null;
    }

    return $FoodRecordModelCopyWith<$Res>(_value.editingFood!, (value) {
      return _then(_value.copyWith(editingFood: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$FoodDatabaseStateImplCopyWith<$Res>
    implements $FoodDatabaseStateCopyWith<$Res> {
  factory _$$FoodDatabaseStateImplCopyWith(
    _$FoodDatabaseStateImpl value,
    $Res Function(_$FoodDatabaseStateImpl) then,
  ) = __$$FoodDatabaseStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DataState<List<FoodRecordModel>> foodsDataState,
    String searchQuery,
    FoodCategory? selectedCategory,
    FoodRecordModel? editingFood,
    bool isAddingFood,
    String errorMessage,
  });

  @override
  $FoodRecordModelCopyWith<$Res>? get editingFood;
}

/// @nodoc
class __$$FoodDatabaseStateImplCopyWithImpl<$Res>
    extends _$FoodDatabaseStateCopyWithImpl<$Res, _$FoodDatabaseStateImpl>
    implements _$$FoodDatabaseStateImplCopyWith<$Res> {
  __$$FoodDatabaseStateImplCopyWithImpl(
    _$FoodDatabaseStateImpl _value,
    $Res Function(_$FoodDatabaseStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FoodDatabaseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? foodsDataState = null,
    Object? searchQuery = null,
    Object? selectedCategory = freezed,
    Object? editingFood = freezed,
    Object? isAddingFood = null,
    Object? errorMessage = null,
  }) {
    return _then(
      _$FoodDatabaseStateImpl(
        foodsDataState: null == foodsDataState
            ? _value.foodsDataState
            : foodsDataState // ignore: cast_nullable_to_non_nullable
                  as DataState<List<FoodRecordModel>>,
        searchQuery: null == searchQuery
            ? _value.searchQuery
            : searchQuery // ignore: cast_nullable_to_non_nullable
                  as String,
        selectedCategory: freezed == selectedCategory
            ? _value.selectedCategory
            : selectedCategory // ignore: cast_nullable_to_non_nullable
                  as FoodCategory?,
        editingFood: freezed == editingFood
            ? _value.editingFood
            : editingFood // ignore: cast_nullable_to_non_nullable
                  as FoodRecordModel?,
        isAddingFood: null == isAddingFood
            ? _value.isAddingFood
            : isAddingFood // ignore: cast_nullable_to_non_nullable
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

class _$FoodDatabaseStateImpl extends _FoodDatabaseState {
  const _$FoodDatabaseStateImpl({
    required this.foodsDataState,
    this.searchQuery = '',
    this.selectedCategory = null,
    this.editingFood = null,
    this.isAddingFood = false,
    this.errorMessage = '',
  }) : super._();

  @override
  final DataState<List<FoodRecordModel>> foodsDataState;
  @override
  @JsonKey()
  final String searchQuery;
  @override
  @JsonKey()
  final FoodCategory? selectedCategory;
  @override
  @JsonKey()
  final FoodRecordModel? editingFood;
  @override
  @JsonKey()
  final bool isAddingFood;
  @override
  @JsonKey()
  final String errorMessage;

  @override
  String toString() {
    return 'FoodDatabaseState(foodsDataState: $foodsDataState, searchQuery: $searchQuery, selectedCategory: $selectedCategory, editingFood: $editingFood, isAddingFood: $isAddingFood, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodDatabaseStateImpl &&
            (identical(other.foodsDataState, foodsDataState) ||
                other.foodsDataState == foodsDataState) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            (identical(other.selectedCategory, selectedCategory) ||
                other.selectedCategory == selectedCategory) &&
            (identical(other.editingFood, editingFood) ||
                other.editingFood == editingFood) &&
            (identical(other.isAddingFood, isAddingFood) ||
                other.isAddingFood == isAddingFood) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    foodsDataState,
    searchQuery,
    selectedCategory,
    editingFood,
    isAddingFood,
    errorMessage,
  );

  /// Create a copy of FoodDatabaseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodDatabaseStateImplCopyWith<_$FoodDatabaseStateImpl> get copyWith =>
      __$$FoodDatabaseStateImplCopyWithImpl<_$FoodDatabaseStateImpl>(
        this,
        _$identity,
      );
}

abstract class _FoodDatabaseState extends FoodDatabaseState {
  const factory _FoodDatabaseState({
    required final DataState<List<FoodRecordModel>> foodsDataState,
    final String searchQuery,
    final FoodCategory? selectedCategory,
    final FoodRecordModel? editingFood,
    final bool isAddingFood,
    final String errorMessage,
  }) = _$FoodDatabaseStateImpl;
  const _FoodDatabaseState._() : super._();

  @override
  DataState<List<FoodRecordModel>> get foodsDataState;
  @override
  String get searchQuery;
  @override
  FoodCategory? get selectedCategory;
  @override
  FoodRecordModel? get editingFood;
  @override
  bool get isAddingFood;
  @override
  String get errorMessage;

  /// Create a copy of FoodDatabaseState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FoodDatabaseStateImplCopyWith<_$FoodDatabaseStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
