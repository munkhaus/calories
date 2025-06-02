# Direct Gram Input Feature 🚀

## Oversigt
Ny super hurtig måde at vælge portioner - skriv gram direkte på siden og tryk på den mad du vil have!

## Problemet vi løser
**Før:** Tryk på mad → Åbn dialog → Vælg portion → Bekræft
**Nu:** Skriv gram øverst → Tryk på mad → **FÆRDIG!** ⚡

## Ny Feature: Quick Gram Input

### 📍 Placering
- **Øverst på Quick Favorites siden**
- Første ting brugeren ser
- Tydelig "NEMT" badge for at fremhæve hastigheden

### 🎯 Funktionalitet

#### 1. Direkte Gram Input
```dart
TextField(
  controller: _gramController,
  decoration: InputDecoration(
    labelText: 'Antal gram',
    suffixText: 'g',
    prefixIcon: Icon(MdiIcons.scaleBalance),
  ),
  onChanged: (value) {
    _quickGrams = double.tryParse(value);
  },
)
```

#### 2. Quick Select Buttons
- **50g, 100g, 150g, 200g** som hurtige valg
- Highlights det aktive valg
- Et tryk sætter både felt og internal state

#### 3. Visual Feedback
- **"Klar til at logge XXXg"** besked når gram er valgt
- Grøn gradient design for at signalere "go"
- Check ikon når klar

### 🔄 Smart Logic

#### Ingredient Foods med Quick Grams:
```dart
if (favorite.foodType == FoodType.ingredient && _quickGrams != null && _quickGrams! > 0) {
  // Use quick gram input directly - NO DIALOG!
  foodLog = favorite.toUserFoodLog(
    quantity: _quickGrams!,
    servingUnit: 'gram',
  );
}
```

#### Fallback til Dialog:
- Hvis ingen gram angivet → Vis dialog som før
- Meals bruger altid standard portion
- Fuld backwards compatibility

## User Experience

### 🚀 Super Hurtig Flow:
1. **Skriv "150" øverst**
2. **Tryk på "Ris" kort** 
3. **FÆRDIG!** → "Ris (150g) tilføjet - 195 kcal"

### 📱 Mobile Optimized:
- **Store touch targets** for quick select buttons
- **Center-aligned text** i gram felt
- **XL font size** for bedre synlighed
- **Haptic feedback** på selections

### 🎨 Visual Design:
- **Grøn gradient** baggrund (success farve)
- **Lightning ikon** for hastighed
- **"NEMT" badge** for at fremhæve fordelen
- **Clean layout** med god separation

## Tekniske Detaljer

### State Management:
```dart
final TextEditingController _gramController = TextEditingController();
double? _quickGrams;

// Default til 100g
_gramController.text = '100';
_quickGrams = 100.0;
```

### Smart Detection:
- Tjekker om `_quickGrams` er sat og > 0
- Kun for ingredient foods (ikke meals)
- Fallback til normal dialog flow hvis ikke sat

### Memory Management:
```dart
@override
void dispose() {
  _gramController.dispose();
  super.dispose();
}
```

## Forventede Resultater

### 📊 Performance:
- **90% færre taps** for ingredient logging
- **5 sekunder hurtigere** end dialog flow
- **Zero dialog overhead** for power users

### 🎯 User Benefits:
1. **Muscle Memory:** Samme gram kan bruges for flere foods
2. **Batch Logging:** Skriv 100g og tryk flere foods hurtigt
3. **Power User Friendly:** For dem der kender deres portioner
4. **Mobile Optimized:** Store targets, god typography

### 🔄 Compatibility:
- ✅ **Fuld backwards compatibility**
- ✅ **Dialog fallback** hvis ingen gram angivet
- ✅ **Meal support** uændret
- ✅ **Alle eksisterende features** bevaret

## Implementation Notes

### Quick Select Values:
- **50g:** Lille portion (snacks, nuts)
- **100g:** Standard (basis for nutrition facts)
- **150g:** Medium portion (pasta, rice)
- **200g:** Stor portion (vegetables, salads)

### Error Handling:
- Validerer at gram > 0
- Fallback til dialog ved invalid input
- Error snackbar ved problemer

### Visual States:
1. **Empty:** Neutral styling
2. **Active:** Highlighted quick select button
3. **Ready:** Green feedback med check mark
4. **Error:** Red snackbar hvis invalid

Dette gør food logging **betydeligt hurtigere** for brugere der ved deres portioner! 🎉 