import 'package:freezed_annotation/freezed_annotation.dart';

part 'weight_entry_model.freezed.dart';
part 'weight_entry_model.g.dart';

/// Model for vægt indgange med dato
@freezed
class WeightEntryModel with _$WeightEntryModel {
  const WeightEntryModel._();

  const factory WeightEntryModel({
    @Default(0) int entryId,
    @Default(0) int userId,
    @Default(0.0) double weightKg,
    required DateTime recordedAt,
    @Default('') String notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _WeightEntryModel;

  factory WeightEntryModel.fromJson(Map<String, dynamic> json) =>
      _$WeightEntryModelFromJson(json);

  /// Formatter vægt med 1 decimal
  String get formattedWeight {
    return '${weightKg.toStringAsFixed(1)} kg';
  }

  /// Formatter dato
  String get formattedDate {
    final months = ['jan', 'feb', 'mar', 'apr', 'maj', 'jun', 'jul', 'aug', 'sep', 'okt', 'nov', 'dec'];
    return '${recordedAt.day}. ${months[recordedAt.month - 1]} ${recordedAt.year}';
  }

  /// Checker om entry er fra i dag
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(recordedAt.year, recordedAt.month, recordedAt.day);
    return entryDate.isAtSameMomentAs(today);
  }
} 