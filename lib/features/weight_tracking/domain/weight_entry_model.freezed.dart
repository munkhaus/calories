// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight_entry_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WeightEntryModel _$WeightEntryModelFromJson(Map<String, dynamic> json) {
  return _WeightEntryModel.fromJson(json);
}

/// @nodoc
mixin _$WeightEntryModel {
  int get entryId => throw _privateConstructorUsedError;
  int get userId => throw _privateConstructorUsedError;
  double get weightKg => throw _privateConstructorUsedError;
  DateTime get recordedAt => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this WeightEntryModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WeightEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WeightEntryModelCopyWith<WeightEntryModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WeightEntryModelCopyWith<$Res> {
  factory $WeightEntryModelCopyWith(
    WeightEntryModel value,
    $Res Function(WeightEntryModel) then,
  ) = _$WeightEntryModelCopyWithImpl<$Res, WeightEntryModel>;
  @useResult
  $Res call({
    int entryId,
    int userId,
    double weightKg,
    DateTime recordedAt,
    String notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$WeightEntryModelCopyWithImpl<$Res, $Val extends WeightEntryModel>
    implements $WeightEntryModelCopyWith<$Res> {
  _$WeightEntryModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WeightEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entryId = null,
    Object? userId = null,
    Object? weightKg = null,
    Object? recordedAt = null,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            entryId: null == entryId
                ? _value.entryId
                : entryId // ignore: cast_nullable_to_non_nullable
                      as int,
            userId: null == userId
                ? _value.userId
                : userId // ignore: cast_nullable_to_non_nullable
                      as int,
            weightKg: null == weightKg
                ? _value.weightKg
                : weightKg // ignore: cast_nullable_to_non_nullable
                      as double,
            recordedAt: null == recordedAt
                ? _value.recordedAt
                : recordedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            notes: null == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
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
abstract class _$$WeightEntryModelImplCopyWith<$Res>
    implements $WeightEntryModelCopyWith<$Res> {
  factory _$$WeightEntryModelImplCopyWith(
    _$WeightEntryModelImpl value,
    $Res Function(_$WeightEntryModelImpl) then,
  ) = __$$WeightEntryModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int entryId,
    int userId,
    double weightKg,
    DateTime recordedAt,
    String notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$WeightEntryModelImplCopyWithImpl<$Res>
    extends _$WeightEntryModelCopyWithImpl<$Res, _$WeightEntryModelImpl>
    implements _$$WeightEntryModelImplCopyWith<$Res> {
  __$$WeightEntryModelImplCopyWithImpl(
    _$WeightEntryModelImpl _value,
    $Res Function(_$WeightEntryModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WeightEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? entryId = null,
    Object? userId = null,
    Object? weightKg = null,
    Object? recordedAt = null,
    Object? notes = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$WeightEntryModelImpl(
        entryId: null == entryId
            ? _value.entryId
            : entryId // ignore: cast_nullable_to_non_nullable
                  as int,
        userId: null == userId
            ? _value.userId
            : userId // ignore: cast_nullable_to_non_nullable
                  as int,
        weightKg: null == weightKg
            ? _value.weightKg
            : weightKg // ignore: cast_nullable_to_non_nullable
                  as double,
        recordedAt: null == recordedAt
            ? _value.recordedAt
            : recordedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        notes: null == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
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
class _$WeightEntryModelImpl extends _WeightEntryModel {
  const _$WeightEntryModelImpl({
    this.entryId = 0,
    this.userId = 0,
    this.weightKg = 0.0,
    required this.recordedAt,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$WeightEntryModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$WeightEntryModelImplFromJson(json);

  @override
  @JsonKey()
  final int entryId;
  @override
  @JsonKey()
  final int userId;
  @override
  @JsonKey()
  final double weightKg;
  @override
  final DateTime recordedAt;
  @override
  @JsonKey()
  final String notes;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'WeightEntryModel(entryId: $entryId, userId: $userId, weightKg: $weightKg, recordedAt: $recordedAt, notes: $notes, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WeightEntryModelImpl &&
            (identical(other.entryId, entryId) || other.entryId == entryId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.weightKg, weightKg) ||
                other.weightKg == weightKg) &&
            (identical(other.recordedAt, recordedAt) ||
                other.recordedAt == recordedAt) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    entryId,
    userId,
    weightKg,
    recordedAt,
    notes,
    createdAt,
    updatedAt,
  );

  /// Create a copy of WeightEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WeightEntryModelImplCopyWith<_$WeightEntryModelImpl> get copyWith =>
      __$$WeightEntryModelImplCopyWithImpl<_$WeightEntryModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$WeightEntryModelImplToJson(this);
  }
}

abstract class _WeightEntryModel extends WeightEntryModel {
  const factory _WeightEntryModel({
    final int entryId,
    final int userId,
    final double weightKg,
    required final DateTime recordedAt,
    final String notes,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$WeightEntryModelImpl;
  const _WeightEntryModel._() : super._();

  factory _WeightEntryModel.fromJson(Map<String, dynamic> json) =
      _$WeightEntryModelImpl.fromJson;

  @override
  int get entryId;
  @override
  int get userId;
  @override
  double get weightKg;
  @override
  DateTime get recordedAt;
  @override
  String get notes;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of WeightEntryModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WeightEntryModelImplCopyWith<_$WeightEntryModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
