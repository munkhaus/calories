/// Model for meal session that can contain multiple images of the same meal
class MealSessionModel {
  final String id;
  final List<String> imagePaths;
  final DateTime startedAt;
  final String notes;
  final bool isProcessed;
  final int estimatedCalories;
  final String mealName;

  const MealSessionModel({
    this.id = '',
    this.imagePaths = const [],
    required this.startedAt,
    this.notes = '',
    this.isProcessed = false,
    this.estimatedCalories = 0,
    this.mealName = '',
  });

  /// Create from JSON
  factory MealSessionModel.fromJson(Map<String, dynamic> json) {
    return MealSessionModel(
      id: json['id'] ?? '',
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      startedAt: DateTime.tryParse(json['startedAt'] ?? '') ?? DateTime.now(),
      notes: json['notes'] ?? '',
      isProcessed: json['isProcessed'] ?? false,
      estimatedCalories: json['estimatedCalories'] ?? 0,
      mealName: json['mealName'] ?? '',
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePaths': imagePaths,
      'startedAt': startedAt.toIso8601String(),
      'notes': notes,
      'isProcessed': isProcessed,
      'estimatedCalories': estimatedCalories,
      'mealName': mealName,
    };
  }

  /// Copy with new values
  MealSessionModel copyWith({
    String? id,
    List<String>? imagePaths,
    DateTime? startedAt,
    String? notes,
    bool? isProcessed,
    int? estimatedCalories,
    String? mealName,
  }) {
    return MealSessionModel(
      id: id ?? this.id,
      imagePaths: imagePaths ?? this.imagePaths,
      startedAt: startedAt ?? this.startedAt,
      notes: notes ?? this.notes,
      isProcessed: isProcessed ?? this.isProcessed,
      estimatedCalories: estimatedCalories ?? this.estimatedCalories,
      mealName: mealName ?? this.mealName,
    );
  }

  /// Check if the meal session has any valid images
  bool get hasImages => imagePaths.isNotEmpty;
  
  /// Get display time for the meal session
  String get displayTime {
    final now = DateTime.now();
    final diff = now.difference(startedAt);
    
    if (diff.inMinutes < 1) {
      return 'Lige nu';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min siden';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} timer siden';
    } else {
      return '${diff.inDays} dage siden';
    }
  }

  /// Get image count
  int get imageCount => imagePaths.length;

  /// Add a new image to the session
  MealSessionModel addImage(String imagePath) {
    final newImagePaths = List<String>.from(imagePaths)..add(imagePath);
    return copyWith(imagePaths: newImagePaths);
  }

  /// Remove an image from the session
  MealSessionModel removeImage(String imagePath) {
    final newImagePaths = List<String>.from(imagePaths)..remove(imagePath);
    return copyWith(imagePaths: newImagePaths);
  }
} 