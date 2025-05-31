// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'food_record_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ServingSize _$ServingSizeFromJson(Map<String, dynamic> json) {
  return _ServingSize.fromJson(json);
}

/// @nodoc
mixin _$ServingSize {
  String get name => throw _privateConstructorUsedError;
  double get grams => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;

  /// Serializes this ServingSize to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ServingSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ServingSizeCopyWith<ServingSize> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServingSizeCopyWith<$Res> {
  factory $ServingSizeCopyWith(
    ServingSize value,
    $Res Function(ServingSize) then,
  ) = _$ServingSizeCopyWithImpl<$Res, ServingSize>;
  @useResult
  $Res call({String name, double grams, bool isDefault});
}

/// @nodoc
class _$ServingSizeCopyWithImpl<$Res, $Val extends ServingSize>
    implements $ServingSizeCopyWith<$Res> {
  _$ServingSizeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ServingSize
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
abstract class _$$ServingSizeImplCopyWith<$Res>
    implements $ServingSizeCopyWith<$Res> {
  factory _$$ServingSizeImplCopyWith(
    _$ServingSizeImpl value,
    $Res Function(_$ServingSizeImpl) then,
  ) = __$$ServingSizeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String name, double grams, bool isDefault});
}

/// @nodoc
class __$$ServingSizeImplCopyWithImpl<$Res>
    extends _$ServingSizeCopyWithImpl<$Res, _$ServingSizeImpl>
    implements _$$ServingSizeImplCopyWith<$Res> {
  __$$ServingSizeImplCopyWithImpl(
    _$ServingSizeImpl _value,
    $Res Function(_$ServingSizeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ServingSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grams = null,
    Object? isDefault = null,
  }) {
    return _then(
      _$ServingSizeImpl(
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
class _$ServingSizeImpl implements _ServingSize {
  const _$ServingSizeImpl({
    this.name = '',
    this.grams = 100.0,
    this.isDefault = false,
  });

  factory _$ServingSizeImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServingSizeImplFromJson(json);

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
    return 'ServingSize(name: $name, grams: $grams, isDefault: $isDefault)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServingSizeImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.grams, grams) || other.grams == grams) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, grams, isDefault);

  /// Create a copy of ServingSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ServingSizeImplCopyWith<_$ServingSizeImpl> get copyWith =>
      __$$ServingSizeImplCopyWithImpl<_$ServingSizeImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServingSizeImplToJson(this);
  }
}

abstract class _ServingSize implements ServingSize {
  const factory _ServingSize({
    final String name,
    final double grams,
    final bool isDefault,
  }) = _$ServingSizeImpl;

  factory _ServingSize.fromJson(Map<String, dynamic> json) =
      _$ServingSizeImpl.fromJson;

  @override
  String get name;
  @override
  double get grams;
  @override
  bool get isDefault;

  /// Create a copy of ServingSize
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ServingSizeImplCopyWith<_$ServingSizeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

FoodRecordModel _$FoodRecordModelFromJson(Map<String, dynamic> json) {
  return _FoodRecordModel.fromJson(json);
}

/// @nodoc
mixin _$FoodRecordModel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  int get caloriesPer100g => throw _privateConstructorUsedError;
  double get proteinPer100g => throw _privateConstructorUsedError;
  double get carbsPer100g => throw _privateConstructorUsedError;
  double get fatPer100g => throw _privateConstructorUsedError;
  FoodCategory get category => throw _privateConstructorUsedError;
  List<ServingSize> get servingSizes => throw _privateConstructorUsedError;
  bool get isCustom => throw _privateConstructorUsedError;
  String get createdBy => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this FoodRecordModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FoodRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FoodRecordModelCopyWith<FoodRecordModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FoodRecordModelCopyWith<$Res> {
  factory $FoodRecordModelCopyWith(
    FoodRecordModel value,
    $Res Function(FoodRecordModel) then,
  ) = _$FoodRecordModelCopyWithImpl<$Res, FoodRecordModel>;
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int caloriesPer100g,
    double proteinPer100g,
    double carbsPer100g,
    double fatPer100g,
    FoodCategory category,
    List<ServingSize> servingSizes,
    bool isCustom,
    String createdBy,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$FoodRecordModelCopyWithImpl<$Res, $Val extends FoodRecordModel>
    implements $FoodRecordModelCopyWith<$Res> {
  _$FoodRecordModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FoodRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? caloriesPer100g = null,
    Object? proteinPer100g = null,
    Object? carbsPer100g = null,
    Object? fatPer100g = null,
    Object? category = null,
    Object? servingSizes = null,
    Object? isCustom = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
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
            caloriesPer100g: null == caloriesPer100g
                ? _value.caloriesPer100g
                : caloriesPer100g // ignore: cast_nullable_to_non_nullable
                      as int,
            proteinPer100g: null == proteinPer100g
                ? _value.proteinPer100g
                : proteinPer100g // ignore: cast_nullable_to_non_nullable
                      as double,
            carbsPer100g: null == carbsPer100g
                ? _value.carbsPer100g
                : carbsPer100g // ignore: cast_nullable_to_non_nullable
                      as double,
            fatPer100g: null == fatPer100g
                ? _value.fatPer100g
                : fatPer100g // ignore: cast_nullable_to_non_nullable
                      as double,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as FoodCategory,
            servingSizes: null == servingSizes
                ? _value.servingSizes
                : servingSizes // ignore: cast_nullable_to_non_nullable
                      as List<ServingSize>,
            isCustom: null == isCustom
                ? _value.isCustom
                : isCustom // ignore: cast_nullable_to_non_nullable
                      as bool,
            createdBy: null == createdBy
                ? _value.createdBy
                : createdBy // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FoodRecordModelImplCopyWith<$Res>
    implements $FoodRecordModelCopyWith<$Res> {
  factory _$$FoodRecordModelImplCopyWith(
    _$FoodRecordModelImpl value,
    $Res Function(_$FoodRecordModelImpl) then,
  ) = __$$FoodRecordModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String description,
    int caloriesPer100g,
    double proteinPer100g,
    double carbsPer100g,
    double fatPer100g,
    FoodCategory category,
    List<ServingSize> servingSizes,
    bool isCustom,
    String createdBy,
    DateTime createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$FoodRecordModelImplCopyWithImpl<$Res>
    extends _$FoodRecordModelCopyWithImpl<$Res, _$FoodRecordModelImpl>
    implements _$$FoodRecordModelImplCopyWith<$Res> {
  __$$FoodRecordModelImplCopyWithImpl(
    _$FoodRecordModelImpl _value,
    $Res Function(_$FoodRecordModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FoodRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? caloriesPer100g = null,
    Object? proteinPer100g = null,
    Object? carbsPer100g = null,
    Object? fatPer100g = null,
    Object? category = null,
    Object? servingSizes = null,
    Object? isCustom = null,
    Object? createdBy = null,
    Object? createdAt = null,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$FoodRecordModelImpl(
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
        caloriesPer100g: null == caloriesPer100g
            ? _value.caloriesPer100g
            : caloriesPer100g // ignore: cast_nullable_to_non_nullable
                  as int,
        proteinPer100g: null == proteinPer100g
            ? _value.proteinPer100g
            : proteinPer100g // ignore: cast_nullable_to_non_nullable
                  as double,
        carbsPer100g: null == carbsPer100g
            ? _value.carbsPer100g
            : carbsPer100g // ignore: cast_nullable_to_non_nullable
                  as double,
        fatPer100g: null == fatPer100g
            ? _value.fatPer100g
            : fatPer100g // ignore: cast_nullable_to_non_nullable
                  as double,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as FoodCategory,
        servingSizes: null == servingSizes
            ? _value._servingSizes
            : servingSizes // ignore: cast_nullable_to_non_nullable
                  as List<ServingSize>,
        isCustom: null == isCustom
            ? _value.isCustom
            : isCustom // ignore: cast_nullable_to_non_nullable
                  as bool,
        createdBy: null == createdBy
            ? _value.createdBy
            : createdBy // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FoodRecordModelImpl extends _FoodRecordModel {
  const _$FoodRecordModelImpl({
    this.id = '',
    this.name = '',
    this.description = '',
    this.caloriesPer100g = 0,
    this.proteinPer100g = 0.0,
    this.carbsPer100g = 0.0,
    this.fatPer100g = 0.0,
    this.category = FoodCategory.other,
    final List<ServingSize> servingSizes = const [],
    this.isCustom = false,
    this.createdBy = '',
    required this.createdAt,
    this.updatedAt,
  }) : _servingSizes = servingSizes,
       super._();

  factory _$FoodRecordModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FoodRecordModelImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final int caloriesPer100g;
  @override
  @JsonKey()
  final double proteinPer100g;
  @override
  @JsonKey()
  final double carbsPer100g;
  @override
  @JsonKey()
  final double fatPer100g;
  @override
  @JsonKey()
  final FoodCategory category;
  final List<ServingSize> _servingSizes;
  @override
  @JsonKey()
  List<ServingSize> get servingSizes {
    if (_servingSizes is EqualUnmodifiableListView) return _servingSizes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_servingSizes);
  }

  @override
  @JsonKey()
  final bool isCustom;
  @override
  @JsonKey()
  final String createdBy;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'FoodRecordModel(id: $id, name: $name, description: $description, caloriesPer100g: $caloriesPer100g, proteinPer100g: $proteinPer100g, carbsPer100g: $carbsPer100g, fatPer100g: $fatPer100g, category: $category, servingSizes: $servingSizes, isCustom: $isCustom, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FoodRecordModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.caloriesPer100g, caloriesPer100g) ||
                other.caloriesPer100g == caloriesPer100g) &&
            (identical(other.proteinPer100g, proteinPer100g) ||
                other.proteinPer100g == proteinPer100g) &&
            (identical(other.carbsPer100g, carbsPer100g) ||
                other.carbsPer100g == carbsPer100g) &&
            (identical(other.fatPer100g, fatPer100g) ||
                other.fatPer100g == fatPer100g) &&
            (identical(other.category, category) ||
                other.category == category) &&
            const DeepCollectionEquality().equals(
              other._servingSizes,
              _servingSizes,
            ) &&
            (identical(other.isCustom, isCustom) ||
                other.isCustom == isCustom) &&
            (identical(other.createdBy, createdBy) ||
                other.createdBy == createdBy) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    caloriesPer100g,
    proteinPer100g,
    carbsPer100g,
    fatPer100g,
    category,
    const DeepCollectionEquality().hash(_servingSizes),
    isCustom,
    createdBy,
    createdAt,
    updatedAt,
  );

  /// Create a copy of FoodRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FoodRecordModelImplCopyWith<_$FoodRecordModelImpl> get copyWith =>
      __$$FoodRecordModelImplCopyWithImpl<_$FoodRecordModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$FoodRecordModelImplToJson(this);
  }
}

abstract class _FoodRecordModel extends FoodRecordModel {
  const factory _FoodRecordModel({
    final String id,
    final String name,
    final String description,
    final int caloriesPer100g,
    final double proteinPer100g,
    final double carbsPer100g,
    final double fatPer100g,
    final FoodCategory category,
    final List<ServingSize> servingSizes,
    final bool isCustom,
    final String createdBy,
    required final DateTime createdAt,
    final DateTime? updatedAt,
  }) = _$FoodRecordModelImpl;
  const _FoodRecordModel._() : super._();

  factory _FoodRecordModel.fromJson(Map<String, dynamic> json) =
      _$FoodRecordModelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  int get caloriesPer100g;
  @override
  double get proteinPer100g;
  @override
  double get carbsPer100g;
  @override
  double get fatPer100g;
  @override
  FoodCategory get category;
  @override
  List<ServingSize> get servingSizes;
  @override
  bool get isCustom;
  @override
  String get createdBy;
  @override
  DateTime get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of FoodRecordModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FoodRecordModelImplCopyWith<_$FoodRecordModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
