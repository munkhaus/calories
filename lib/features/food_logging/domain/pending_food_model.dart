import '../infrastructure/gemini_service.dart';

/// Model for food items that are pending categorization after photo capture
class PendingFoodModel {
  final String id;
  final List<String> imagePaths;
  final String imageUrl;
  final DateTime capturedAt;
  final String notes;
  final bool isProcessed;
  final FoodAnalysisResult? aiResult;

  const PendingFoodModel({
    this.id = '',
    this.imagePaths = const [],
    this.imageUrl = '',
    required this.capturedAt,
    this.notes = '',
    this.isProcessed = false,
    this.aiResult,
  });

  /// Create from JSON
  factory PendingFoodModel.fromJson(Map<String, dynamic> json) {
    return PendingFoodModel(
      id: json['id'] ?? '',
      imagePaths: List<String>.from(json['imagePaths'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      capturedAt: DateTime.tryParse(json['capturedAt'] ?? '') ?? DateTime.now(),
      notes: json['notes'] ?? '',
      isProcessed: json['isProcessed'] ?? false,
      aiResult: json['aiResult'] != null ? _foodAnalysisResultFromJson(json['aiResult']) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePaths': imagePaths,
      'imageUrl': imageUrl,
      'capturedAt': capturedAt.toIso8601String(),
      'notes': notes,
      'isProcessed': isProcessed,
      'aiResult': aiResult != null ? _foodAnalysisResultToJson(aiResult!) : null,
    };
  }

  /// Copy with new values
  PendingFoodModel copyWith({
    String? id,
    List<String>? imagePaths,
    String? imageUrl,
    DateTime? capturedAt,
    String? notes,
    bool? isProcessed,
    FoodAnalysisResult? aiResult,
  }) {
    return PendingFoodModel(
      id: id ?? this.id,
      imagePaths: imagePaths ?? this.imagePaths,
      imageUrl: imageUrl ?? this.imageUrl,
      capturedAt: capturedAt ?? this.capturedAt,
      notes: notes ?? this.notes,
      isProcessed: isProcessed ?? this.isProcessed,
      aiResult: aiResult ?? this.aiResult,
    );
  }

  /// Check if the pending food item has a valid image
  bool get hasValidImage => imagePaths.isNotEmpty || imageUrl.isNotEmpty;
  
  /// Get the primary image path (first image)
  String get primaryImagePath => imagePaths.isNotEmpty ? imagePaths.first : '';
  
  /// Get number of images
  int get imageCount => imagePaths.length;
  
  /// Get display time for the pending food item
  String get displayTime {
    final now = DateTime.now();
    final difference = now.difference(capturedAt);
    
    if (difference.inMinutes < 1) {
      return 'Lige nu';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min siden';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} timer siden';
    } else {
      return '${difference.inDays} dage siden';
    }
  }
}

/// Helper function to convert FoodAnalysisResult to JSON
Map<String, dynamic> _foodAnalysisResultToJson(FoodAnalysisResult result) {
  return {
    'foodName': result.foodName,
    'description': result.description,
    'portionSize': result.portionSize,
    'estimatedCalories': result.estimatedCalories,
    'confidence': result.confidence,
    'quantity': result.quantity,
    'servingUnit': result.servingUnit,
    'protein': result.protein,
    'fat': result.fat,
    'carbs': result.carbs,
  };
}

/// Helper function to convert JSON to FoodAnalysisResult
FoodAnalysisResult _foodAnalysisResultFromJson(Map<String, dynamic> json) {
  return FoodAnalysisResult(
    foodName: json['foodName'] ?? '',
    description: json['description'] ?? '',
    portionSize: json['portionSize'] ?? '',
    estimatedCalories: json['estimatedCalories'] ?? 0,
    confidence: (json['confidence'] ?? 0.0).toDouble(),
    quantity: (json['quantity'] ?? 1.0).toDouble(),
    servingUnit: json['servingUnit'] ?? 'portion',
    protein: (json['protein'] ?? 0.0).toDouble(),
    fat: (json['fat'] ?? 0.0).toDouble(),
    carbs: (json['carbs'] ?? 0.0).toDouble(),
  );
} 