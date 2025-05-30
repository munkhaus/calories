/// Model for food items that are pending categorization after photo capture
class PendingFoodModel {
  final String id;
  final String imagePath;
  final String imageUrl;
  final DateTime capturedAt;
  final String notes;
  final bool isProcessed;

  const PendingFoodModel({
    this.id = '',
    this.imagePath = '',
    this.imageUrl = '',
    required this.capturedAt,
    this.notes = '',
    this.isProcessed = false,
  });

  /// Create from JSON
  factory PendingFoodModel.fromJson(Map<String, dynamic> json) {
    return PendingFoodModel(
      id: json['id'] ?? '',
      imagePath: json['imagePath'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      capturedAt: DateTime.tryParse(json['capturedAt'] ?? '') ?? DateTime.now(),
      notes: json['notes'] ?? '',
      isProcessed: json['isProcessed'] ?? false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'imageUrl': imageUrl,
      'capturedAt': capturedAt.toIso8601String(),
      'notes': notes,
      'isProcessed': isProcessed,
    };
  }

  /// Copy with new values
  PendingFoodModel copyWith({
    String? id,
    String? imagePath,
    String? imageUrl,
    DateTime? capturedAt,
    String? notes,
    bool? isProcessed,
  }) {
    return PendingFoodModel(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      capturedAt: capturedAt ?? this.capturedAt,
      notes: notes ?? this.notes,
      isProcessed: isProcessed ?? this.isProcessed,
    );
  }

  /// Check if the pending food item has a valid image
  bool get hasValidImage => imagePath.isNotEmpty || imageUrl.isNotEmpty;
  
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