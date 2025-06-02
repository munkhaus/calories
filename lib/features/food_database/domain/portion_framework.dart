import 'package:freezed_annotation/freezed_annotation.dart';

part 'portion_framework.freezed.dart';
part 'portion_framework.g.dart';

/// Framework for defining relevant portion sizes for different food types
/// This is used to provide intelligent portion suggestions based on the specific food item

/// Different types of portion measurements available
enum PortionUnit {
  gram('g', 'gram'),
  piece('stk', 'stykker'),
  slice('skive', 'skiver'),
  cup('kop', 'kopper'),
  spoon('ske', 'skefulde'),
  glass('glas', 'glas'),
  bottle('flaske', 'flasker'),
  can('dåse', 'dåser'),
  portion('portion', 'portioner'),
  handful('håndfuld', 'håndfulde'),
  milliliter('ml', 'milliliter'),
  deciliter('dl', 'deciliter'),
  liter('l', 'liter');

  const PortionUnit(this.shortName, this.displayName);
  
  final String shortName;
  final String displayName;
}

/// Size categories for portions
enum PortionSize {
  extraSmall('Mini', 0.5),
  small('Lille', 0.75),
  medium('Mellem', 1.0),
  large('Stor', 1.5),
  extraLarge('Ekstra stor', 2.0);

  const PortionSize(this.displayName, this.multiplier);
  
  final String displayName;
  final double multiplier;
}

/// Food categories that determine relevant portion types
enum FoodCategory {
  // Protein sources
  eggs,
  meat,
  fish,
  cheese,
  nuts,
  
  // Carbohydrates
  bread,
  pasta,
  rice,
  potatoes,
  cereals,
  
  // Fruits and vegetables
  fruits,
  vegetables,
  salad,
  
  // Beverages
  beverages,
  alcohol,
  coffee,
  
  // Sweets and snacks
  candy,
  chocolate,
  cookies,
  chips,
  
  // Dairy
  milk,
  yogurt,
  
  // Prepared meals
  soup,
  pizza,
  sandwich,
  dish,
  
  // Others
  oil,
  sauce,
  spices,
  general;
  
  /// Get relevant portion units for this food category
  List<PortionUnit> get relevantUnits {
    switch (this) {
      case FoodCategory.eggs:
        return [PortionUnit.piece, PortionUnit.gram];
      case FoodCategory.bread:
        return [PortionUnit.slice, PortionUnit.piece, PortionUnit.gram];
      case FoodCategory.fruits:
        return [PortionUnit.piece, PortionUnit.handful, PortionUnit.cup, PortionUnit.gram];
      case FoodCategory.vegetables:
        return [PortionUnit.piece, PortionUnit.cup, PortionUnit.handful, PortionUnit.gram];
      case FoodCategory.beverages:
        return [PortionUnit.glass, PortionUnit.cup, PortionUnit.bottle, PortionUnit.milliliter, PortionUnit.deciliter];
      case FoodCategory.milk:
        return [PortionUnit.glass, PortionUnit.cup, PortionUnit.milliliter, PortionUnit.deciliter];
      case FoodCategory.cheese:
        return [PortionUnit.slice, PortionUnit.piece, PortionUnit.gram];
      case FoodCategory.meat:
      case FoodCategory.fish:
        return [PortionUnit.piece, PortionUnit.portion, PortionUnit.gram];
      case FoodCategory.pasta:
      case FoodCategory.rice:
        return [PortionUnit.portion, PortionUnit.cup, PortionUnit.gram];
      case FoodCategory.nuts:
        return [PortionUnit.handful, PortionUnit.spoon, PortionUnit.gram];
      case FoodCategory.oil:
      case FoodCategory.sauce:
        return [PortionUnit.spoon, PortionUnit.milliliter, PortionUnit.gram];
      case FoodCategory.pizza:
        return [PortionUnit.slice, PortionUnit.piece, PortionUnit.gram];
      case FoodCategory.soup:
        return [PortionUnit.portion, PortionUnit.cup, PortionUnit.deciliter, PortionUnit.milliliter];
      case FoodCategory.candy:
      case FoodCategory.chocolate:
      case FoodCategory.cookies:
        return [PortionUnit.piece, PortionUnit.handful, PortionUnit.gram];
      case FoodCategory.coffee:
        return [PortionUnit.cup, PortionUnit.milliliter];
      case FoodCategory.alcohol:
        return [PortionUnit.glass, PortionUnit.bottle, PortionUnit.can, PortionUnit.milliliter];
      default:
        return [PortionUnit.gram, PortionUnit.piece, PortionUnit.portion];
    }
  }
}

/// Smart portion size suggestion for a specific food and unit
@freezed
class SmartPortionSize with _$SmartPortionSize {
  const factory SmartPortionSize({
    required String name,
    required double grams,
    required PortionUnit unit,
    required PortionSize size,
    @Default(false) bool isDefault,
    @Default('') String description,
  }) = _SmartPortionSize;

  factory SmartPortionSize.fromJson(Map<String, dynamic> json) => 
      _$SmartPortionSizeFromJson(json);
}

/// Framework for generating smart portion suggestions
class PortionFramework {
  /// Detect food category from food name using keywords
  static FoodCategory detectFoodCategory(String foodName) {
    final name = foodName.toLowerCase();
    
    // Eggs
    if (name.contains('æg') || name.contains('egg')) {
      return FoodCategory.eggs;
    }
    
    // Bread
    if (name.contains('brød') || name.contains('toast') || name.contains('bagel') || 
        name.contains('rugbrød') || name.contains('franskbrød')) {
      return FoodCategory.bread;
    }
    
    // Beverages
    if (name.contains('kaffe') || name.contains('te') || name.contains('vand') ||
        name.contains('juice') || name.contains('sodavand') || name.contains('cola') ||
        name.contains('øl') || name.contains('vin') || name.contains('drink')) {
      if (name.contains('øl') || name.contains('vin') || name.contains('spiritus')) {
        return FoodCategory.alcohol;
      } else if (name.contains('kaffe')) {
        return FoodCategory.coffee;
      } else {
        return FoodCategory.beverages;
      }
    }
    
    // Milk and dairy
    if (name.contains('mælk') || name.contains('milk')) {
      return FoodCategory.milk;
    }
    if (name.contains('ost') || name.contains('cheese') || name.contains('yoghurt') || name.contains('skyr')) {
      return name.contains('yoghurt') || name.contains('skyr') ? FoodCategory.yogurt : FoodCategory.cheese;
    }
    
    // Fruits
    if (name.contains('æble') || name.contains('banan') || name.contains('appelsin') ||
        name.contains('pære') || name.contains('frugt') || name.contains('bær') ||
        name.contains('citrus') || name.contains('melon') || name.contains('ananas')) {
      return FoodCategory.fruits;
    }
    
    // Vegetables
    if (name.contains('tomat') || name.contains('agurk') || name.contains('salat') ||
        name.contains('gulerod') || name.contains('broccoli') || name.contains('grøntsag') ||
        name.contains('spinat') || name.contains('kål') || name.contains('løg')) {
      return name.contains('salat') ? FoodCategory.salad : FoodCategory.vegetables;
    }
    
    // Meat and fish
    if (name.contains('kød') || name.contains('kylling') || name.contains('oksekød') ||
        name.contains('svinekød') || name.contains('lam') || name.contains('steak') ||
        name.contains('frikadelle') || name.contains('pølse')) {
      return FoodCategory.meat;
    }
    if (name.contains('fisk') || name.contains('laks') || name.contains('torsk') ||
        name.contains('tuna') || name.contains('makrel') || name.contains('rejer')) {
      return FoodCategory.fish;
    }
    
    // Pasta and rice
    if (name.contains('pasta') || name.contains('spaghetti') || name.contains('macaroni') ||
        name.contains('nudler') || name.contains('penne')) {
      return FoodCategory.pasta;
    }
    if (name.contains('ris') || name.contains('rice')) {
      return FoodCategory.rice;
    }
    
    // Pizza
    if (name.contains('pizza')) {
      return FoodCategory.pizza;
    }
    
    // Soup
    if (name.contains('suppe') || name.contains('soup')) {
      return FoodCategory.soup;
    }
    
    // Nuts
    if (name.contains('nød') || name.contains('mandel') || name.contains('mandler') || name.contains('nødder') ||
        name.contains('peanut') || name.contains('valnød') || name.contains('hasselnød') || 
        name.contains('cashew') || name.contains('paranød')) {
      return FoodCategory.nuts;
    }
    
    // Sweets
    if (name.contains('chokolade') || name.contains('slik') || name.contains('kage') ||
        name.contains('is') || name.contains('cookie') || name.contains('småkage')) {
      if (name.contains('chokolade')) {
        return FoodCategory.chocolate;
      } else if (name.contains('cookie') || name.contains('småkage')) {
        return FoodCategory.cookies;
      } else {
        return FoodCategory.candy;
      }
    }
    
    // Oil and sauce
    if (name.contains('olie') || name.contains('smør') || name.contains('margarine')) {
      return FoodCategory.oil;
    }
    if (name.contains('sauce') || name.contains('dressing') || name.contains('ketchup')) {
      return FoodCategory.sauce;
    }
    
    // Default to general
    return FoodCategory.general;
  }

  /// Generate smart portion suggestions for a food item
  static List<SmartPortionSize> generateSmartPortions(
    String foodName, 
    FoodCategory category,
    double caloriesPer100g,
  ) {
    final portions = <SmartPortionSize>[];
    final relevantUnits = category.relevantUnits;
    
    // Always include gram as a base unit
    if (!relevantUnits.contains(PortionUnit.gram)) {
      relevantUnits.add(PortionUnit.gram);
    }
    
    // Special handling for liquid categories - only generate liquid portions once
    bool hasLiquidPortions = false;
    
    for (final unit in relevantUnits) {
      // For liquid units, only generate once to avoid duplicates
      if (unit == PortionUnit.milliliter || unit == PortionUnit.deciliter || unit == PortionUnit.liter) {
        if (!hasLiquidPortions) {
          final liquidPortions = _generateLiquidPortions(category, caloriesPer100g);
          portions.addAll(liquidPortions);
          hasLiquidPortions = true;
        }
      } else {
        final unitPortions = _generatePortionsForUnit(unit, category, caloriesPer100g);
        portions.addAll(unitPortions);
      }
    }
    
    // Set default portion (usually medium size of the most relevant unit)
    if (portions.isNotEmpty) {
      final defaultUnit = relevantUnits.first;
      final defaultPortion = portions
          .where((p) => p.unit == defaultUnit && p.size == PortionSize.medium)
          .firstOrNull;
      
      if (defaultPortion != null) {
        final index = portions.indexOf(defaultPortion);
        portions[index] = defaultPortion.copyWith(isDefault: true);
      } else {
        // If no medium found, make first one default
        portions[0] = portions[0].copyWith(isDefault: true);
      }
    }
    
    return portions;
  }
  
  static List<SmartPortionSize> _generatePortionsForUnit(
    PortionUnit unit, 
    FoodCategory category,
    double caloriesPer100g,
  ) {
    final portions = <SmartPortionSize>[];
    
    // Special handling for liquid measurements
    if (unit == PortionUnit.milliliter || unit == PortionUnit.deciliter || unit == PortionUnit.liter) {
      return _generateLiquidPortions(category, caloriesPer100g);
    }
    
    // Get base weight for this unit and category
    final baseGrams = _getBaseWeightForUnit(unit, category);
    
    // Generate different sizes
    for (final size in [PortionSize.small, PortionSize.medium, PortionSize.large]) {
      final grams = baseGrams * size.multiplier;
      final name = _generatePortionName(unit, size, category);
      
      portions.add(SmartPortionSize(
        name: name,
        grams: grams,
        unit: unit,
        size: size,
        description: '${grams.round()}g',
      ));
    }
    
    return portions;
  }
  
  static List<SmartPortionSize> _generateLiquidPortions(
    FoodCategory category,
    double caloriesPer100g,
  ) {
    final portions = <SmartPortionSize>[];
    
    // Realistic liquid measurements that people actually use
    final liquidMeasurements = [
      (150, '150 ml', PortionUnit.milliliter, PortionSize.small),
      (200, '200 ml', PortionUnit.milliliter, PortionSize.small),
      (250, '250 ml', PortionUnit.milliliter, PortionSize.medium),
      (330, '330 ml', PortionUnit.milliliter, PortionSize.medium), // Standard bottle
      (500, '1/2 liter', PortionUnit.liter, PortionSize.medium),
      (1000, '1 liter', PortionUnit.liter, PortionSize.large),
    ];
    
    for (final measurement in liquidMeasurements) {
      final (grams, name, unit, size) = measurement;
      
      portions.add(SmartPortionSize(
        name: name,
        grams: grams.toDouble(),
        unit: unit,
        size: size,
        description: '${grams}g',
      ));
    }
    
    return portions;
  }
  
  static double _getBaseWeightForUnit(PortionUnit unit, FoodCategory category) {
    switch (unit) {
      case PortionUnit.piece:
        switch (category) {
          case FoodCategory.eggs: return 60.0; // 1 medium egg
          case FoodCategory.bread: return 30.0; // 1 slice
          case FoodCategory.fruits: return 150.0; // 1 medium apple
          case FoodCategory.cheese: return 20.0; // 1 slice cheese
          default: return 100.0;
        }
      case PortionUnit.slice:
        switch (category) {
          case FoodCategory.bread: return 25.0; // Thin slice
          case FoodCategory.cheese: return 15.0;
          case FoodCategory.pizza: return 120.0; // Pizza slice
          default: return 30.0;
        }
      case PortionUnit.cup:
        return 200.0; // Standard cup
      case PortionUnit.glass:
        return 200.0; // Standard glass
      case PortionUnit.spoon:
        return 15.0; // Tablespoon
      case PortionUnit.handful:
        return 30.0; // Handful of nuts/berries
      case PortionUnit.portion:
        return 150.0; // Standard portion
      case PortionUnit.bottle:
        return 330.0; // Standard bottle
      case PortionUnit.can:
        return 330.0; // Standard can
      case PortionUnit.milliliter:
      case PortionUnit.deciliter:
      case PortionUnit.liter:
        return 100.0; // Base ml amount
      case PortionUnit.gram:
        return 100.0; // Default 100g
    }
  }
  
  static String _generatePortionName(PortionUnit unit, PortionSize size, FoodCategory category) {
    if (unit == PortionUnit.gram) {
      return '${(100 * size.multiplier).round()} ${unit.shortName}';
    }
    
    if (size == PortionSize.medium) {
      return '1 ${unit.displayName.split(' ').first}'; // "1 stykke", "1 skive"
    }
    
    return '${size.displayName} ${unit.displayName.split(' ').first}'; // "Lille skive", "Stor portion"
  }
} 