// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$OnboardingState {
  OnboardingStep get currentStep => throw _privateConstructorUsedError;
  UserProfileModel get userProfile => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasError => throw _privateConstructorUsedError;
  bool get isEditingFromSummary => throw _privateConstructorUsedError;
  String? get errorMessage => throw _privateConstructorUsedError;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OnboardingStateCopyWith<OnboardingState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OnboardingStateCopyWith<$Res> {
  factory $OnboardingStateCopyWith(
    OnboardingState value,
    $Res Function(OnboardingState) then,
  ) = _$OnboardingStateCopyWithImpl<$Res, OnboardingState>;
  @useResult
  $Res call({
    OnboardingStep currentStep,
    UserProfileModel userProfile,
    bool isLoading,
    bool hasError,
    bool isEditingFromSummary,
    String? errorMessage,
  });

  $UserProfileModelCopyWith<$Res> get userProfile;
}

/// @nodoc
class _$OnboardingStateCopyWithImpl<$Res, $Val extends OnboardingState>
    implements $OnboardingStateCopyWith<$Res> {
  _$OnboardingStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? userProfile = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? isEditingFromSummary = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _value.copyWith(
            currentStep: null == currentStep
                ? _value.currentStep
                : currentStep // ignore: cast_nullable_to_non_nullable
                      as OnboardingStep,
            userProfile: null == userProfile
                ? _value.userProfile
                : userProfile // ignore: cast_nullable_to_non_nullable
                      as UserProfileModel,
            isLoading: null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasError: null == hasError
                ? _value.hasError
                : hasError // ignore: cast_nullable_to_non_nullable
                      as bool,
            isEditingFromSummary: null == isEditingFromSummary
                ? _value.isEditingFromSummary
                : isEditingFromSummary // ignore: cast_nullable_to_non_nullable
                      as bool,
            errorMessage: freezed == errorMessage
                ? _value.errorMessage
                : errorMessage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserProfileModelCopyWith<$Res> get userProfile {
    return $UserProfileModelCopyWith<$Res>(_value.userProfile, (value) {
      return _then(_value.copyWith(userProfile: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$OnboardingStateImplCopyWith<$Res>
    implements $OnboardingStateCopyWith<$Res> {
  factory _$$OnboardingStateImplCopyWith(
    _$OnboardingStateImpl value,
    $Res Function(_$OnboardingStateImpl) then,
  ) = __$$OnboardingStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    OnboardingStep currentStep,
    UserProfileModel userProfile,
    bool isLoading,
    bool hasError,
    bool isEditingFromSummary,
    String? errorMessage,
  });

  @override
  $UserProfileModelCopyWith<$Res> get userProfile;
}

/// @nodoc
class __$$OnboardingStateImplCopyWithImpl<$Res>
    extends _$OnboardingStateCopyWithImpl<$Res, _$OnboardingStateImpl>
    implements _$$OnboardingStateImplCopyWith<$Res> {
  __$$OnboardingStateImplCopyWithImpl(
    _$OnboardingStateImpl _value,
    $Res Function(_$OnboardingStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentStep = null,
    Object? userProfile = null,
    Object? isLoading = null,
    Object? hasError = null,
    Object? isEditingFromSummary = null,
    Object? errorMessage = freezed,
  }) {
    return _then(
      _$OnboardingStateImpl(
        currentStep: null == currentStep
            ? _value.currentStep
            : currentStep // ignore: cast_nullable_to_non_nullable
                  as OnboardingStep,
        userProfile: null == userProfile
            ? _value.userProfile
            : userProfile // ignore: cast_nullable_to_non_nullable
                  as UserProfileModel,
        isLoading: null == isLoading
            ? _value.isLoading
            : isLoading // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasError: null == hasError
            ? _value.hasError
            : hasError // ignore: cast_nullable_to_non_nullable
                  as bool,
        isEditingFromSummary: null == isEditingFromSummary
            ? _value.isEditingFromSummary
            : isEditingFromSummary // ignore: cast_nullable_to_non_nullable
                  as bool,
        errorMessage: freezed == errorMessage
            ? _value.errorMessage
            : errorMessage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc

class _$OnboardingStateImpl extends _OnboardingState {
  const _$OnboardingStateImpl({
    this.currentStep = OnboardingStep.basicInfo,
    this.userProfile = const UserProfileModel(),
    this.isLoading = false,
    this.hasError = false,
    this.isEditingFromSummary = false,
    this.errorMessage,
  }) : super._();

  @override
  @JsonKey()
  final OnboardingStep currentStep;
  @override
  @JsonKey()
  final UserProfileModel userProfile;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasError;
  @override
  @JsonKey()
  final bool isEditingFromSummary;
  @override
  final String? errorMessage;

  @override
  String toString() {
    return 'OnboardingState(currentStep: $currentStep, userProfile: $userProfile, isLoading: $isLoading, hasError: $hasError, isEditingFromSummary: $isEditingFromSummary, errorMessage: $errorMessage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OnboardingStateImpl &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.userProfile, userProfile) ||
                other.userProfile == userProfile) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasError, hasError) ||
                other.hasError == hasError) &&
            (identical(other.isEditingFromSummary, isEditingFromSummary) ||
                other.isEditingFromSummary == isEditingFromSummary) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    currentStep,
    userProfile,
    isLoading,
    hasError,
    isEditingFromSummary,
    errorMessage,
  );

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      __$$OnboardingStateImplCopyWithImpl<_$OnboardingStateImpl>(
        this,
        _$identity,
      );
}

abstract class _OnboardingState extends OnboardingState {
  const factory _OnboardingState({
    final OnboardingStep currentStep,
    final UserProfileModel userProfile,
    final bool isLoading,
    final bool hasError,
    final bool isEditingFromSummary,
    final String? errorMessage,
  }) = _$OnboardingStateImpl;
  const _OnboardingState._() : super._();

  @override
  OnboardingStep get currentStep;
  @override
  UserProfileModel get userProfile;
  @override
  bool get isLoading;
  @override
  bool get hasError;
  @override
  bool get isEditingFromSummary;
  @override
  String? get errorMessage;

  /// Create a copy of OnboardingState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OnboardingStateImplCopyWith<_$OnboardingStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
