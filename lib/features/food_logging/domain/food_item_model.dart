class FoodItemModel {
  final int foodId;
  final String name;
  final String brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double fatPer100g;
  final double carbsPer100g;
  final String servingUnit;
  final double servingSize;
  final String barcode;
  final int categoryId;
  final bool isShared;
  final String createdAt;
  final String updatedAt;

  const FoodItemModel({
    this.foodId = 0,
    this.name = '',
    this.brand = '',
    this.caloriesPer100g = 0.0,
    this.proteinPer100g = 0.0,
    this.fatPer100g = 0.0,
    this.carbsPer100g = 0.0,
    this.servingUnit = '',
    this.servingSize = 0.0,
    this.barcode = '',
    this.categoryId = 0,
    this.isShared = false,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory FoodItemModel.fromJson(Map<String, dynamic> json) {
    return FoodItemModel(
      foodId: json['foodId'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'] ?? '',
      caloriesPer100g: (json['caloriesPer100g'] ?? 0.0).toDouble(),
      proteinPer100g: (json['proteinPer100g'] ?? 0.0).toDouble(),
      fatPer100g: (json['fatPer100g'] ?? 0.0).toDouble(),
      carbsPer100g: (json['carbsPer100g'] ?? 0.0).toDouble(),
      servingUnit: json['servingUnit'] ?? '',
      servingSize: (json['servingSize'] ?? 0.0).toDouble(),
      barcode: json['barcode'] ?? '',
      categoryId: json['categoryId'] ?? 0,
      isShared: json['isShared'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'name': name,
      'brand': brand,
      'caloriesPer100g': caloriesPer100g,
      'proteinPer100g': proteinPer100g,
      'fatPer100g': fatPer100g,
      'carbsPer100g': carbsPer100g,
      'servingUnit': servingUnit,
      'servingSize': servingSize,
      'barcode': barcode,
      'categoryId': categoryId,
      'isShared': isShared,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Nutrition calculation methods
  double caloriesForQuantity(double quantity, String unit) {
    final gramsAmount = _convertToGrams(quantity, unit);
    return (caloriesPer100g * gramsAmount) / 100.0;
  }

  double proteinForQuantity(double quantity, String unit) {
    final gramsAmount = _convertToGrams(quantity, unit);
    return (proteinPer100g * gramsAmount) / 100.0;
  }

  double fatForQuantity(double quantity, String unit) {
    final gramsAmount = _convertToGrams(quantity, unit);
    return (fatPer100g * gramsAmount) / 100.0;
  }

  double carbsForQuantity(double quantity, String unit) {
    final gramsAmount = _convertToGrams(quantity, unit);
    return (carbsPer100g * gramsAmount) / 100.0;
  }

  double _convertToGrams(double quantity, String unit) {
    if (unit == 'g') {
      return quantity;
    } else if (unit == servingUnit && servingSize > 0) {
      return quantity * servingSize;
    } else {
      // Default to treating as grams if unknown unit
      return quantity;
    }
  }

  FoodItemModel copyWith({
    int? foodId,
    String? name,
    String? brand,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? fatPer100g,
    double? carbsPer100g,
    String? servingUnit,
    double? servingSize,
    String? barcode,
    int? categoryId,
    bool? isShared,
    String? createdAt,
    String? updatedAt,
  }) {
    return FoodItemModel(
      foodId: foodId ?? this.foodId,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      servingUnit: servingUnit ?? this.servingUnit,
      servingSize: servingSize ?? this.servingSize,
      barcode: barcode ?? this.barcode,
      categoryId: categoryId ?? this.categoryId,
      isShared: isShared ?? this.isShared,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItemModel && other.foodId == foodId;
  }

  @override
  int get hashCode => foodId.hashCode;
} 