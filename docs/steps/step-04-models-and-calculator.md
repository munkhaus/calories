# Step 04 — Domain models and calorie calculator

## Context & scope
Introduce core domain models using `json_serializable` and add a Mifflin–St Jeor based calorie calculator utility. This enables persistence (Step 5) and onboarding goal computation (Step 6).

## Implement
- Enums
  - `Sex`, `ActivityLevel`, `GoalMode`, `MealType` in `lib/core/domain/models/enums.dart`.
- Models (json)
  - `UserProfile`: id, metricUnits, ageYears, sex, heightCm, weightKg, activityLevel.
  - `Goal`: id, startDate, mode, targetCalories, macro percents, paceKcalPerDay.
  - `FoodEntry`: id, date (yyyy-mm-dd), dateTime, mealType, name, calories, macros, portion, source.
  - `DailyTotals`: date, totals (kcal/macros), deltaFromGoal.
  - Place files under `lib/core/domain/models/` and run codegen.
- Calorie calculator
  - Utility in `lib/core/domain/calorie_calculator.dart` implementing:
    - BMR (Mifflin–St Jeor):
      - male: 10×weightKg + 6.25×heightCm − 5×age + 5
      - female: 10×weightKg + 6.25×heightCm − 5×age − 161
    - TDEE: BMR × activity multiplier (sedentary 1.2, light 1.375, moderate 1.55, active 1.725, veryActive 1.9).
    - Target kcal: TDEE + paceKcalPerDay (negative for deficit).

## Verify
- Commands
  - `flutter pub run build_runner build -d`
  - `flutter analyze`
  - `flutter test`
- Manual checks
  - JSON roundtrip for models (unit tests).
  - Calculator outputs expected ranges for sample inputs.

## Acceptance criteria
- Enums and models exist with generated code and pass analyzer.
- Calorie calculator returns TDEE and target consistent with formulas.
- Unit tests added for calculator and at least one model JSON roundtrip.
