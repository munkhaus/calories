/// Biological sex for BMR calculation.
enum Sex {
  male,
  female,
}

/// Activity level multiplier categories.
enum ActivityLevel {
  sedentary, // little or no exercise
  light, // light exercise/sports 1–3 days/week
  moderate, // moderate exercise/sports 3–5 days/week
  active, // hard exercise/sports 6–7 days/week
  veryActive, // very hard exercise/physical job
}

/// Goal mode for calorie target.
enum GoalMode {
  lose,
  maintain,
  gain,
}

/// Meal types used in daily logging.
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack,
}
