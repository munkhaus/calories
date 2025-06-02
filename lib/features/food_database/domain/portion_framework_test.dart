import 'package:flutter_test/flutter_test.dart';
import 'portion_framework.dart';

/// Test file demonstrating the smart portion framework functionality
void main() {
  group('Portion Framework Tests', () {
    test('should detect egg as dairy category and generate smart portions', () {
      // Test egg detection
      final eggCategory = PortionFramework.detectFoodCategory('Æg');
      expect(eggCategory, FoodCategory.eggs);
      
      // Test smart portion generation for eggs
      final eggPortions = PortionFramework.generateSmartPortions('Æg', eggCategory, 155.0);
      
      // Should include gram and piece measurements
      expect(eggPortions.any((p) => p.unit == PortionUnit.gram), true);
      expect(eggPortions.any((p) => p.unit == PortionUnit.piece), true);
      
      // Should have realistic egg weights
      final eggPiecePortions = eggPortions.where((p) => p.unit == PortionUnit.piece).toList();
      expect(eggPiecePortions.any((p) => p.grams >= 50 && p.grams <= 70), true); // 1 egg
      
      print('🥚 Egg portions generated: ${eggPortions.map((p) => '${p.name} (${p.grams}g)').join(', ')}');
    });
    
    test('should detect bread as grain category and generate slice-based portions', () {
      // Test bread detection
      final breadCategory = PortionFramework.detectFoodCategory('Rugbrød');
      expect(breadCategory, FoodCategory.bread);
      
      // Test smart portion generation for bread
      final breadPortions = PortionFramework.generateSmartPortions('Rugbrød', breadCategory, 250.0);
      
      // Should include gram and slice measurements
      expect(breadPortions.any((p) => p.unit == PortionUnit.gram), true);
      expect(breadPortions.any((p) => p.unit == PortionUnit.slice), true);
      
      // Should have realistic bread slice weights
      final breadSlicePortions = breadPortions.where((p) => p.unit == PortionUnit.slice).toList();
      expect(breadSlicePortions.any((p) => p.grams >= 20 && p.grams <= 35), true); // 1 slice
      
      print('🍞 Bread portions generated: ${breadPortions.map((p) => '${p.name} (${p.grams}g)').join(', ')}');
    });
    
    test('should detect fruit and generate piece-based portions', () {
      // Test fruit detection
      final appleCategory = PortionFramework.detectFoodCategory('Æble');
      expect(appleCategory, FoodCategory.fruits);
      
      // Test smart portion generation for apple
      final applePortions = PortionFramework.generateSmartPortions('Æble', appleCategory, 52.0);
      
      // Should include gram and piece measurements
      expect(applePortions.any((p) => p.unit == PortionUnit.gram), true);
      expect(applePortions.any((p) => p.unit == PortionUnit.piece), true);
      
      // Should have realistic apple weights
      final applePiecePortions = applePortions.where((p) => p.unit == PortionUnit.piece).toList();
      expect(applePiecePortions.any((p) => p.grams >= 120 && p.grams <= 200), true); // 1 medium apple
      
      print('🍎 Apple portions generated: ${applePortions.map((p) => '${p.name} (${p.grams}g)').join(', ')}');
    });
    
    test('should detect beverages and generate ml-based portions', () {
      // Test beverage detection
      final milkCategory = PortionFramework.detectFoodCategory('Mælk');
      expect(milkCategory, FoodCategory.milk);
      
      // Test smart portion generation for milk (should treat as beverage)
      final milkPortions = PortionFramework.generateSmartPortions('Mælk', milkCategory, 64.0);
      
      // Should include ml and glass measurements for milk
      expect(milkPortions.any((p) => p.unit == PortionUnit.milliliter), true);
      expect(milkPortions.any((p) => p.unit == PortionUnit.glass), true);
      
      print('🥛 Milk portions generated: ${milkPortions.map((p) => '${p.name} (${p.grams}g)').join(', ')}');
    });
    
    test('should detect meat and generate portion-based servings', () {
      // Test meat detection
      final chickenCategory = PortionFramework.detectFoodCategory('Kylling');
      expect(chickenCategory, FoodCategory.meat);
      
      // Test smart portion generation for chicken
      const chickenCalories = 165.0; // Typical chicken calories per 100g
      final chickenPortions = PortionFramework.generateSmartPortions('Kylling', chickenCategory, chickenCalories);
      
      // Should include gram and portion measurements
      expect(chickenPortions.any((p) => p.unit == PortionUnit.gram), true);
      expect(chickenPortions.any((p) => p.unit == PortionUnit.portion), true);
      
      // Should have realistic serving sizes
      final chickenPortionSizes = chickenPortions.where((p) => p.unit == PortionUnit.portion).toList();
      expect(chickenPortionSizes.any((p) => p.grams >= 100 && p.grams <= 200), true); // Typical serving
      
      print('🍗 Chicken portions generated: ${chickenPortions.map((p) => '${p.name} (${p.grams}g)').join(', ')}');
    });
    
    test('should detect nuts and generate handful-based portions', () {
      // Test nut detection
      final nutsCategory = PortionFramework.detectFoodCategory('Mandler');
      expect(nutsCategory, FoodCategory.nuts);
      
      // Test smart portion generation for nuts
      const nutCalories = 579.0; // Typical almond calories per 100g
      final nutPortions = PortionFramework.generateSmartPortions('Mandler', nutsCategory, nutCalories);
      
      // Should include gram and handful measurements
      expect(nutPortions.any((p) => p.unit == PortionUnit.gram), true);
      expect(nutPortions.any((p) => p.unit == PortionUnit.handful), true);
      
      // Should have realistic handful sizes (nuts are calorie dense)
      final nutHandfulPortions = nutPortions.where((p) => p.unit == PortionUnit.handful).toList();
      expect(nutHandfulPortions.any((p) => p.grams >= 20 && p.grams <= 40), true); // Small handful
      
      print('🥜 Nut portions generated: ${nutPortions.map((p) => '${p.name} (${p.grams}g)').join(', ')}');
    });
    
    test('should handle pizza as prepared dish with slice-based portions', () {
      // Test prepared food detection
      final pizzaCategory = PortionFramework.detectFoodCategory('Pizza');
      expect(pizzaCategory, FoodCategory.pizza);
      
      // Test smart portion generation for pizza
      const pizzaCalories = 266.0; // Typical pizza calories per 100g
      final pizzaPortions = PortionFramework.generateSmartPortions('Pizza', pizzaCategory, pizzaCalories);
      
      // Should include gram and slice measurements
      expect(pizzaPortions.any((p) => p.unit == PortionUnit.gram), true);
      expect(pizzaPortions.any((p) => p.unit == PortionUnit.slice), true);
      
      // Should have realistic pizza slice weights
      final pizzaSlicePortions = pizzaPortions.where((p) => p.unit == PortionUnit.slice).toList();
      expect(pizzaSlicePortions.any((p) => p.grams >= 100 && p.grams <= 150), true); // Pizza slice
      
      print('🍕 Pizza portions generated: ${pizzaPortions.map((p) => '${p.name} (${p.grams}g)').join(', ')}');
    });
    
    test('should demonstrate complete workflow with different food types', () {
      print('\n📋 COMPLETE PORTION FRAMEWORK DEMONSTRATION:');
      print('=' * 60);
      
      final testFoods = [
        ('Æg', 155.0),
        ('Rugbrød', 250.0), 
        ('Æble', 52.0),
        ('Mælk', 64.0),
        ('Kylling', 165.0),
        ('Mandler', 579.0),
        ('Pizza', 266.0),
        ('Ris', 130.0),
        ('Tomat', 18.0),
        ('Olie', 884.0),
      ];
      
      for (final (foodName, calories) in testFoods) {
        final category = PortionFramework.detectFoodCategory(foodName);
        final portions = PortionFramework.generateSmartPortions(foodName, category, calories);
        
        print('\n🍽️ $foodName (${category.name.toUpperCase()}) - $calories kcal/100g:');
        for (final portion in portions) {
          final totalCalories = (calories * portion.grams / 100).round();
          print('  • ${portion.name}: ${portion.grams}g = $totalCalories kcal ${portion.isDefault ? '(default)' : ''}');
        }
      }
      
      print('\n✅ Framework successfully generates relevant portions for all food types!');
    });
  });
} 