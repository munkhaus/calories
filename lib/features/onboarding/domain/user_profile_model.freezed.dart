// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

UserProfileModel _$UserProfileModelFromJson(Map<String, dynamic> json) {
  return _UserProfileModel.fromJson(json);
}

/// @nodoc
mixin _$UserProfileModel {
  String get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  DateTime? get dateOfBirth => throw _privateConstructorUsedError;
  Gender? get gender => throw _privateConstructorUsedError;
  double get heightCm => throw _privateConstructorUsedError;
  double get currentWeightKg => throw _privateConstructorUsedError;
  double get targetWeightKg => throw _privateConstructorUsedError;
  GoalType? get goalType =>
      throw _privateConstructorUsedError; // New activity system
  WorkActivityLevel? get workActivityLevel =>
      throw _privateConstructorUsedError;
  LeisureActivityLevel? get leisureActivityLevel =>
      throw _privateConstructorUsedError;
  ActivityTrackingPreference get activityTrackingPreference =>
      throw _privateConstructorUsedError;
  bool get useAutomaticWeekdayDetection => throw _privateConstructorUsedError;
  bool get isCurrentlyWorkDay =>
      throw _privateConstructorUsedError; // Manual override for today
  bool get isLeisureActivityEnabledToday =>
      throw _privateConstructorUsedError; // Manual toggle for leisure activity today
  // Legacy activity level (for backwards compatibility)
  ActivityLevel? get activityLevel => throw _privateConstructorUsedError;
  double get weeklyGoalKg => throw _privateConstructorUsedError;
  int get targetCalories => throw _privateConstructorUsedError;
  double get targetProteinG => throw _privateConstructorUsedError;
  double get targetFatG => throw _privateConstructorUsedError;
  double get targetCarbsG => throw _privateConstructorUsedError;
  bool get isOnboardingCompleted => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this UserProfileModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserProfileModelCopyWith<UserProfileModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileModelCopyWith<$Res> {
  factory $UserProfileModelCopyWith(
    UserProfileModel value,
    $Res Function(UserProfileModel) then,
  ) = _$UserProfileModelCopyWithImpl<$Res, UserProfileModel>;
  @useResult
  $Res call({
    String id,
    String email,
    String name,
    DateTime? dateOfBirth,
    Gender? gender,
    double heightCm,
    double currentWeightKg,
    double targetWeightKg,
    GoalType? goalType,
    WorkActivityLevel? workActivityLevel,
    LeisureActivityLevel? leisureActivityLevel,
    ActivityTrackingPreference activityTrackingPreference,
    bool useAutomaticWeekdayDetection,
    bool isCurrentlyWorkDay,
    bool isLeisureActivityEnabledToday,
    ActivityLevel? activityLevel,
    double weeklyGoalKg,
    int targetCalories,
    double targetProteinG,
    double targetFatG,
    double targetCarbsG,
    bool isOnboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class _$UserProfileModelCopyWithImpl<$Res, $Val extends UserProfileModel>
    implements $UserProfileModelCopyWith<$Res> {
  _$UserProfileModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? heightCm = null,
    Object? currentWeightKg = null,
    Object? targetWeightKg = null,
    Object? goalType = freezed,
    Object? workActivityLevel = freezed,
    Object? leisureActivityLevel = freezed,
    Object? activityTrackingPreference = null,
    Object? useAutomaticWeekdayDetection = null,
    Object? isCurrentlyWorkDay = null,
    Object? isLeisureActivityEnabledToday = null,
    Object? activityLevel = freezed,
    Object? weeklyGoalKg = null,
    Object? targetCalories = null,
    Object? targetProteinG = null,
    Object? targetFatG = null,
    Object? targetCarbsG = null,
    Object? isOnboardingCompleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            dateOfBirth: freezed == dateOfBirth
                ? _value.dateOfBirth
                : dateOfBirth // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as Gender?,
            heightCm: null == heightCm
                ? _value.heightCm
                : heightCm // ignore: cast_nullable_to_non_nullable
                      as double,
            currentWeightKg: null == currentWeightKg
                ? _value.currentWeightKg
                : currentWeightKg // ignore: cast_nullable_to_non_nullable
                      as double,
            targetWeightKg: null == targetWeightKg
                ? _value.targetWeightKg
                : targetWeightKg // ignore: cast_nullable_to_non_nullable
                      as double,
            goalType: freezed == goalType
                ? _value.goalType
                : goalType // ignore: cast_nullable_to_non_nullable
                      as GoalType?,
            workActivityLevel: freezed == workActivityLevel
                ? _value.workActivityLevel
                : workActivityLevel // ignore: cast_nullable_to_non_nullable
                      as WorkActivityLevel?,
            leisureActivityLevel: freezed == leisureActivityLevel
                ? _value.leisureActivityLevel
                : leisureActivityLevel // ignore: cast_nullable_to_non_nullable
                      as LeisureActivityLevel?,
            activityTrackingPreference: null == activityTrackingPreference
                ? _value.activityTrackingPreference
                : activityTrackingPreference // ignore: cast_nullable_to_non_nullable
                      as ActivityTrackingPreference,
            useAutomaticWeekdayDetection: null == useAutomaticWeekdayDetection
                ? _value.useAutomaticWeekdayDetection
                : useAutomaticWeekdayDetection // ignore: cast_nullable_to_non_nullable
                      as bool,
            isCurrentlyWorkDay: null == isCurrentlyWorkDay
                ? _value.isCurrentlyWorkDay
                : isCurrentlyWorkDay // ignore: cast_nullable_to_non_nullable
                      as bool,
            isLeisureActivityEnabledToday: null == isLeisureActivityEnabledToday
                ? _value.isLeisureActivityEnabledToday
                : isLeisureActivityEnabledToday // ignore: cast_nullable_to_non_nullable
                      as bool,
            activityLevel: freezed == activityLevel
                ? _value.activityLevel
                : activityLevel // ignore: cast_nullable_to_non_nullable
                      as ActivityLevel?,
            weeklyGoalKg: null == weeklyGoalKg
                ? _value.weeklyGoalKg
                : weeklyGoalKg // ignore: cast_nullable_to_non_nullable
                      as double,
            targetCalories: null == targetCalories
                ? _value.targetCalories
                : targetCalories // ignore: cast_nullable_to_non_nullable
                      as int,
            targetProteinG: null == targetProteinG
                ? _value.targetProteinG
                : targetProteinG // ignore: cast_nullable_to_non_nullable
                      as double,
            targetFatG: null == targetFatG
                ? _value.targetFatG
                : targetFatG // ignore: cast_nullable_to_non_nullable
                      as double,
            targetCarbsG: null == targetCarbsG
                ? _value.targetCarbsG
                : targetCarbsG // ignore: cast_nullable_to_non_nullable
                      as double,
            isOnboardingCompleted: null == isOnboardingCompleted
                ? _value.isOnboardingCompleted
                : isOnboardingCompleted // ignore: cast_nullable_to_non_nullable
                      as bool,
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
abstract class _$$UserProfileModelImplCopyWith<$Res>
    implements $UserProfileModelCopyWith<$Res> {
  factory _$$UserProfileModelImplCopyWith(
    _$UserProfileModelImpl value,
    $Res Function(_$UserProfileModelImpl) then,
  ) = __$$UserProfileModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String email,
    String name,
    DateTime? dateOfBirth,
    Gender? gender,
    double heightCm,
    double currentWeightKg,
    double targetWeightKg,
    GoalType? goalType,
    WorkActivityLevel? workActivityLevel,
    LeisureActivityLevel? leisureActivityLevel,
    ActivityTrackingPreference activityTrackingPreference,
    bool useAutomaticWeekdayDetection,
    bool isCurrentlyWorkDay,
    bool isLeisureActivityEnabledToday,
    ActivityLevel? activityLevel,
    double weeklyGoalKg,
    int targetCalories,
    double targetProteinG,
    double targetFatG,
    double targetCarbsG,
    bool isOnboardingCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
}

/// @nodoc
class __$$UserProfileModelImplCopyWithImpl<$Res>
    extends _$UserProfileModelCopyWithImpl<$Res, _$UserProfileModelImpl>
    implements _$$UserProfileModelImplCopyWith<$Res> {
  __$$UserProfileModelImplCopyWithImpl(
    _$UserProfileModelImpl _value,
    $Res Function(_$UserProfileModelImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of UserProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = null,
    Object? name = null,
    Object? dateOfBirth = freezed,
    Object? gender = freezed,
    Object? heightCm = null,
    Object? currentWeightKg = null,
    Object? targetWeightKg = null,
    Object? goalType = freezed,
    Object? workActivityLevel = freezed,
    Object? leisureActivityLevel = freezed,
    Object? activityTrackingPreference = null,
    Object? useAutomaticWeekdayDetection = null,
    Object? isCurrentlyWorkDay = null,
    Object? isLeisureActivityEnabledToday = null,
    Object? activityLevel = freezed,
    Object? weeklyGoalKg = null,
    Object? targetCalories = null,
    Object? targetProteinG = null,
    Object? targetFatG = null,
    Object? targetCarbsG = null,
    Object? isOnboardingCompleted = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$UserProfileModelImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        dateOfBirth: freezed == dateOfBirth
            ? _value.dateOfBirth
            : dateOfBirth // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as Gender?,
        heightCm: null == heightCm
            ? _value.heightCm
            : heightCm // ignore: cast_nullable_to_non_nullable
                  as double,
        currentWeightKg: null == currentWeightKg
            ? _value.currentWeightKg
            : currentWeightKg // ignore: cast_nullable_to_non_nullable
                  as double,
        targetWeightKg: null == targetWeightKg
            ? _value.targetWeightKg
            : targetWeightKg // ignore: cast_nullable_to_non_nullable
                  as double,
        goalType: freezed == goalType
            ? _value.goalType
            : goalType // ignore: cast_nullable_to_non_nullable
                  as GoalType?,
        workActivityLevel: freezed == workActivityLevel
            ? _value.workActivityLevel
            : workActivityLevel // ignore: cast_nullable_to_non_nullable
                  as WorkActivityLevel?,
        leisureActivityLevel: freezed == leisureActivityLevel
            ? _value.leisureActivityLevel
            : leisureActivityLevel // ignore: cast_nullable_to_non_nullable
                  as LeisureActivityLevel?,
        activityTrackingPreference: null == activityTrackingPreference
            ? _value.activityTrackingPreference
            : activityTrackingPreference // ignore: cast_nullable_to_non_nullable
                  as ActivityTrackingPreference,
        useAutomaticWeekdayDetection: null == useAutomaticWeekdayDetection
            ? _value.useAutomaticWeekdayDetection
            : useAutomaticWeekdayDetection // ignore: cast_nullable_to_non_nullable
                  as bool,
        isCurrentlyWorkDay: null == isCurrentlyWorkDay
            ? _value.isCurrentlyWorkDay
            : isCurrentlyWorkDay // ignore: cast_nullable_to_non_nullable
                  as bool,
        isLeisureActivityEnabledToday: null == isLeisureActivityEnabledToday
            ? _value.isLeisureActivityEnabledToday
            : isLeisureActivityEnabledToday // ignore: cast_nullable_to_non_nullable
                  as bool,
        activityLevel: freezed == activityLevel
            ? _value.activityLevel
            : activityLevel // ignore: cast_nullable_to_non_nullable
                  as ActivityLevel?,
        weeklyGoalKg: null == weeklyGoalKg
            ? _value.weeklyGoalKg
            : weeklyGoalKg // ignore: cast_nullable_to_non_nullable
                  as double,
        targetCalories: null == targetCalories
            ? _value.targetCalories
            : targetCalories // ignore: cast_nullable_to_non_nullable
                  as int,
        targetProteinG: null == targetProteinG
            ? _value.targetProteinG
            : targetProteinG // ignore: cast_nullable_to_non_nullable
                  as double,
        targetFatG: null == targetFatG
            ? _value.targetFatG
            : targetFatG // ignore: cast_nullable_to_non_nullable
                  as double,
        targetCarbsG: null == targetCarbsG
            ? _value.targetCarbsG
            : targetCarbsG // ignore: cast_nullable_to_non_nullable
                  as double,
        isOnboardingCompleted: null == isOnboardingCompleted
            ? _value.isOnboardingCompleted
            : isOnboardingCompleted // ignore: cast_nullable_to_non_nullable
                  as bool,
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
class _$UserProfileModelImpl extends _UserProfileModel {
  const _$UserProfileModelImpl({
    this.id = '',
    this.email = '',
    this.name = '',
    this.dateOfBirth,
    this.gender,
    this.heightCm = 0.0,
    this.currentWeightKg = 0.0,
    this.targetWeightKg = 0.0,
    this.goalType,
    this.workActivityLevel,
    this.leisureActivityLevel,
    this.activityTrackingPreference = ActivityTrackingPreference.automatic,
    this.useAutomaticWeekdayDetection = true,
    this.isCurrentlyWorkDay = false,
    this.isLeisureActivityEnabledToday = true,
    this.activityLevel,
    this.weeklyGoalKg = 0.0,
    this.targetCalories = 0,
    this.targetProteinG = 0.0,
    this.targetFatG = 0.0,
    this.targetCarbsG = 0.0,
    this.isOnboardingCompleted = false,
    this.createdAt,
    this.updatedAt,
  }) : super._();

  factory _$UserProfileModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileModelImplFromJson(json);

  @override
  @JsonKey()
  final String id;
  @override
  @JsonKey()
  final String email;
  @override
  @JsonKey()
  final String name;
  @override
  final DateTime? dateOfBirth;
  @override
  final Gender? gender;
  @override
  @JsonKey()
  final double heightCm;
  @override
  @JsonKey()
  final double currentWeightKg;
  @override
  @JsonKey()
  final double targetWeightKg;
  @override
  final GoalType? goalType;
  // New activity system
  @override
  final WorkActivityLevel? workActivityLevel;
  @override
  final LeisureActivityLevel? leisureActivityLevel;
  @override
  @JsonKey()
  final ActivityTrackingPreference activityTrackingPreference;
  @override
  @JsonKey()
  final bool useAutomaticWeekdayDetection;
  @override
  @JsonKey()
  final bool isCurrentlyWorkDay;
  // Manual override for today
  @override
  @JsonKey()
  final bool isLeisureActivityEnabledToday;
  // Manual toggle for leisure activity today
  // Legacy activity level (for backwards compatibility)
  @override
  final ActivityLevel? activityLevel;
  @override
  @JsonKey()
  final double weeklyGoalKg;
  @override
  @JsonKey()
  final int targetCalories;
  @override
  @JsonKey()
  final double targetProteinG;
  @override
  @JsonKey()
  final double targetFatG;
  @override
  @JsonKey()
  final double targetCarbsG;
  @override
  @JsonKey()
  final bool isOnboardingCompleted;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserProfileModel(id: $id, email: $email, name: $name, dateOfBirth: $dateOfBirth, gender: $gender, heightCm: $heightCm, currentWeightKg: $currentWeightKg, targetWeightKg: $targetWeightKg, goalType: $goalType, workActivityLevel: $workActivityLevel, leisureActivityLevel: $leisureActivityLevel, activityTrackingPreference: $activityTrackingPreference, useAutomaticWeekdayDetection: $useAutomaticWeekdayDetection, isCurrentlyWorkDay: $isCurrentlyWorkDay, isLeisureActivityEnabledToday: $isLeisureActivityEnabledToday, activityLevel: $activityLevel, weeklyGoalKg: $weeklyGoalKg, targetCalories: $targetCalories, targetProteinG: $targetProteinG, targetFatG: $targetFatG, targetCarbsG: $targetCarbsG, isOnboardingCompleted: $isOnboardingCompleted, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.heightCm, heightCm) ||
                other.heightCm == heightCm) &&
            (identical(other.currentWeightKg, currentWeightKg) ||
                other.currentWeightKg == currentWeightKg) &&
            (identical(other.targetWeightKg, targetWeightKg) ||
                other.targetWeightKg == targetWeightKg) &&
            (identical(other.goalType, goalType) ||
                other.goalType == goalType) &&
            (identical(other.workActivityLevel, workActivityLevel) ||
                other.workActivityLevel == workActivityLevel) &&
            (identical(other.leisureActivityLevel, leisureActivityLevel) ||
                other.leisureActivityLevel == leisureActivityLevel) &&
            (identical(
                  other.activityTrackingPreference,
                  activityTrackingPreference,
                ) ||
                other.activityTrackingPreference ==
                    activityTrackingPreference) &&
            (identical(
                  other.useAutomaticWeekdayDetection,
                  useAutomaticWeekdayDetection,
                ) ||
                other.useAutomaticWeekdayDetection ==
                    useAutomaticWeekdayDetection) &&
            (identical(other.isCurrentlyWorkDay, isCurrentlyWorkDay) ||
                other.isCurrentlyWorkDay == isCurrentlyWorkDay) &&
            (identical(
                  other.isLeisureActivityEnabledToday,
                  isLeisureActivityEnabledToday,
                ) ||
                other.isLeisureActivityEnabledToday ==
                    isLeisureActivityEnabledToday) &&
            (identical(other.activityLevel, activityLevel) ||
                other.activityLevel == activityLevel) &&
            (identical(other.weeklyGoalKg, weeklyGoalKg) ||
                other.weeklyGoalKg == weeklyGoalKg) &&
            (identical(other.targetCalories, targetCalories) ||
                other.targetCalories == targetCalories) &&
            (identical(other.targetProteinG, targetProteinG) ||
                other.targetProteinG == targetProteinG) &&
            (identical(other.targetFatG, targetFatG) ||
                other.targetFatG == targetFatG) &&
            (identical(other.targetCarbsG, targetCarbsG) ||
                other.targetCarbsG == targetCarbsG) &&
            (identical(other.isOnboardingCompleted, isOnboardingCompleted) ||
                other.isOnboardingCompleted == isOnboardingCompleted) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    email,
    name,
    dateOfBirth,
    gender,
    heightCm,
    currentWeightKg,
    targetWeightKg,
    goalType,
    workActivityLevel,
    leisureActivityLevel,
    activityTrackingPreference,
    useAutomaticWeekdayDetection,
    isCurrentlyWorkDay,
    isLeisureActivityEnabledToday,
    activityLevel,
    weeklyGoalKg,
    targetCalories,
    targetProteinG,
    targetFatG,
    targetCarbsG,
    isOnboardingCompleted,
    createdAt,
    updatedAt,
  ]);

  /// Create a copy of UserProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileModelImplCopyWith<_$UserProfileModelImpl> get copyWith =>
      __$$UserProfileModelImplCopyWithImpl<_$UserProfileModelImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileModelImplToJson(this);
  }
}

abstract class _UserProfileModel extends UserProfileModel {
  const factory _UserProfileModel({
    final String id,
    final String email,
    final String name,
    final DateTime? dateOfBirth,
    final Gender? gender,
    final double heightCm,
    final double currentWeightKg,
    final double targetWeightKg,
    final GoalType? goalType,
    final WorkActivityLevel? workActivityLevel,
    final LeisureActivityLevel? leisureActivityLevel,
    final ActivityTrackingPreference activityTrackingPreference,
    final bool useAutomaticWeekdayDetection,
    final bool isCurrentlyWorkDay,
    final bool isLeisureActivityEnabledToday,
    final ActivityLevel? activityLevel,
    final double weeklyGoalKg,
    final int targetCalories,
    final double targetProteinG,
    final double targetFatG,
    final double targetCarbsG,
    final bool isOnboardingCompleted,
    final DateTime? createdAt,
    final DateTime? updatedAt,
  }) = _$UserProfileModelImpl;
  const _UserProfileModel._() : super._();

  factory _UserProfileModel.fromJson(Map<String, dynamic> json) =
      _$UserProfileModelImpl.fromJson;

  @override
  String get id;
  @override
  String get email;
  @override
  String get name;
  @override
  DateTime? get dateOfBirth;
  @override
  Gender? get gender;
  @override
  double get heightCm;
  @override
  double get currentWeightKg;
  @override
  double get targetWeightKg;
  @override
  GoalType? get goalType; // New activity system
  @override
  WorkActivityLevel? get workActivityLevel;
  @override
  LeisureActivityLevel? get leisureActivityLevel;
  @override
  ActivityTrackingPreference get activityTrackingPreference;
  @override
  bool get useAutomaticWeekdayDetection;
  @override
  bool get isCurrentlyWorkDay; // Manual override for today
  @override
  bool get isLeisureActivityEnabledToday; // Manual toggle for leisure activity today
  // Legacy activity level (for backwards compatibility)
  @override
  ActivityLevel? get activityLevel;
  @override
  double get weeklyGoalKg;
  @override
  int get targetCalories;
  @override
  double get targetProteinG;
  @override
  double get targetFatG;
  @override
  double get targetCarbsG;
  @override
  bool get isOnboardingCompleted;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;

  /// Create a copy of UserProfileModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserProfileModelImplCopyWith<_$UserProfileModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
