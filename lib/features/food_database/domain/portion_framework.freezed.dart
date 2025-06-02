// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'portion_framework.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SmartPortionSize _$SmartPortionSizeFromJson(Map<String, dynamic> json) {
  return _SmartPortionSize.fromJson(json);
}

/// @nodoc
mixin _$SmartPortionSize {
  String get name => throw _privateConstructorUsedError;
  double get grams => throw _privateConstructorUsedError;
  PortionUnit get unit => throw _privateConstructorUsedError;
  PortionSize get size => throw _privateConstructorUsedError;
  bool get isDefault => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;

  /// Serializes this SmartPortionSize to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SmartPortionSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SmartPortionSizeCopyWith<SmartPortionSize> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SmartPortionSizeCopyWith<$Res> {
  factory $SmartPortionSizeCopyWith(
    SmartPortionSize value,
    $Res Function(SmartPortionSize) then,
  ) = _$SmartPortionSizeCopyWithImpl<$Res, SmartPortionSize>;
  @useResult
  $Res call({
    String name,
    double grams,
    PortionUnit unit,
    PortionSize size,
    bool isDefault,
    String description,
  });
}

/// @nodoc
class _$SmartPortionSizeCopyWithImpl<$Res, $Val extends SmartPortionSize>
    implements $SmartPortionSizeCopyWith<$Res> {
  _$SmartPortionSizeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SmartPortionSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grams = null,
    Object? unit = null,
    Object? size = null,
    Object? isDefault = null,
    Object? description = null,
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
            unit: null == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as PortionUnit,
            size: null == size
                ? _value.size
                : size // ignore: cast_nullable_to_non_nullable
                      as PortionSize,
            isDefault: null == isDefault
                ? _value.isDefault
                : isDefault // ignore: cast_nullable_to_non_nullable
                      as bool,
            description: null == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SmartPortionSizeImplCopyWith<$Res>
    implements $SmartPortionSizeCopyWith<$Res> {
  factory _$$SmartPortionSizeImplCopyWith(
    _$SmartPortionSizeImpl value,
    $Res Function(_$SmartPortionSizeImpl) then,
  ) = __$$SmartPortionSizeImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String name,
    double grams,
    PortionUnit unit,
    PortionSize size,
    bool isDefault,
    String description,
  });
}

/// @nodoc
class __$$SmartPortionSizeImplCopyWithImpl<$Res>
    extends _$SmartPortionSizeCopyWithImpl<$Res, _$SmartPortionSizeImpl>
    implements _$$SmartPortionSizeImplCopyWith<$Res> {
  __$$SmartPortionSizeImplCopyWithImpl(
    _$SmartPortionSizeImpl _value,
    $Res Function(_$SmartPortionSizeImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SmartPortionSize
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? grams = null,
    Object? unit = null,
    Object? size = null,
    Object? isDefault = null,
    Object? description = null,
  }) {
    return _then(
      _$SmartPortionSizeImpl(
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        grams: null == grams
            ? _value.grams
            : grams // ignore: cast_nullable_to_non_nullable
                  as double,
        unit: null == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as PortionUnit,
        size: null == size
            ? _value.size
            : size // ignore: cast_nullable_to_non_nullable
                  as PortionSize,
        isDefault: null == isDefault
            ? _value.isDefault
            : isDefault // ignore: cast_nullable_to_non_nullable
                  as bool,
        description: null == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SmartPortionSizeImpl implements _SmartPortionSize {
  const _$SmartPortionSizeImpl({
    required this.name,
    required this.grams,
    required this.unit,
    required this.size,
    this.isDefault = false,
    this.description = '',
  });

  factory _$SmartPortionSizeImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmartPortionSizeImplFromJson(json);

  @override
  final String name;
  @override
  final double grams;
  @override
  final PortionUnit unit;
  @override
  final PortionSize size;
  @override
  @JsonKey()
  final bool isDefault;
  @override
  @JsonKey()
  final String description;

  @override
  String toString() {
    return 'SmartPortionSize(name: $name, grams: $grams, unit: $unit, size: $size, isDefault: $isDefault, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmartPortionSizeImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.grams, grams) || other.grams == grams) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.isDefault, isDefault) ||
                other.isDefault == isDefault) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, grams, unit, size, isDefault, description);

  /// Create a copy of SmartPortionSize
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SmartPortionSizeImplCopyWith<_$SmartPortionSizeImpl> get copyWith =>
      __$$SmartPortionSizeImplCopyWithImpl<_$SmartPortionSizeImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$SmartPortionSizeImplToJson(this);
  }
}

abstract class _SmartPortionSize implements SmartPortionSize {
  const factory _SmartPortionSize({
    required final String name,
    required final double grams,
    required final PortionUnit unit,
    required final PortionSize size,
    final bool isDefault,
    final String description,
  }) = _$SmartPortionSizeImpl;

  factory _SmartPortionSize.fromJson(Map<String, dynamic> json) =
      _$SmartPortionSizeImpl.fromJson;

  @override
  String get name;
  @override
  double get grams;
  @override
  PortionUnit get unit;
  @override
  PortionSize get size;
  @override
  bool get isDefault;
  @override
  String get description;

  /// Create a copy of SmartPortionSize
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SmartPortionSizeImplCopyWith<_$SmartPortionSizeImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
