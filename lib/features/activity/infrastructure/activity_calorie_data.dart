/// Activity calorie calculation data using MET (Metabolic Equivalent of Task) values
/// Based on Compendium of Physical Activities

enum ActivityCategory {
  loeb('Løb', '🏃‍♂️'),
  gang('Gang', '🚶‍♂️'),
  cykling('Cykling', '🚴‍♂️'),
  svoemning('Svømning', '🏊‍♂️'),
  styrketraening('Styrketræning', '💪'),
  yoga('Yoga', '🧘‍♀️'),
  dans('Dans', '💃'),
  fodbold('Fodbold', '⚽'),
  basketball('Basketball', '🏀'),
  tennis('Tennis', '🎾'),
  badminton('Badminton', '🏸'),
  volleyball('Volleyball', '🏐'),
  golf('Golf', '⛳'),
  vandring('Vandring', '🥾'),
  rengoring('Rengøring', '🧹'),
  havearbejde('Havearbejde', '🌱'),
  traeklatring('Trappeløb', '🪜'),
  roning('Roning', '🚣‍♂️'),
  skiloeb('Skiløb', '⛷️'),
  snowboard('Snowboard', '🏂'),
  pilates('Pilates', '🤸‍♀️'),
  crossfit('CrossFit', '🏋️‍♂️'),
  martial_arts('Kampsport', '🥋'),
  climbing('Klatring', '🧗‍♂️'),
  skating('Skøjteløb', '⛸️'),
  anden('Anden aktivitet', '🎯');

  const ActivityCategory(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

/// Activity intensity levels with 4 levels as requested
enum ActivityIntensityLevel {
  let('Let', 1),
  moderat('Moderat', 2),
  haard('Hård', 3),
  ekstremt('Ekstremt hård', 4);

  const ActivityIntensityLevel(this.displayName, this.level);
  final String displayName;
  final int level;
}

/// Activity MET data for different categories and intensities
class ActivityMetData {
  final ActivityCategory category;
  final ActivityIntensityLevel intensity;
  final double metValue;
  final String description;

  const ActivityMetData({
    required this.category,
    required this.intensity,
    required this.metValue,
    required this.description,
  });
}

/// Comprehensive activity MET database
class ActivityCalorieDatabase {
  static const List<ActivityMetData> _metDatabase = [
    // Løb
    ActivityMetData(
      category: ActivityCategory.loeb,
      intensity: ActivityIntensityLevel.let,
      metValue: 6.0,
      description: 'Jogging, generelt',
    ),
    ActivityMetData(
      category: ActivityCategory.loeb,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 8.3,
      description: 'Løb, 8 km/t (7.5 min/km)',
    ),
    ActivityMetData(
      category: ActivityCategory.loeb,
      intensity: ActivityIntensityLevel.haard,
      metValue: 11.0,
      description: 'Løb, 11 km/t (5.5 min/km)',
    ),
    ActivityMetData(
      category: ActivityCategory.loeb,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 16.0,
      description: 'Løb, 16+ km/t (<3.75 min/km)',
    ),

    // Gang
    ActivityMetData(
      category: ActivityCategory.gang,
      intensity: ActivityIntensityLevel.let,
      metValue: 2.8,
      description: 'Gang, rolig, 3 km/t',
    ),
    ActivityMetData(
      category: ActivityCategory.gang,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 3.8,
      description: 'Gang, normal, 5 km/t',
    ),
    ActivityMetData(
      category: ActivityCategory.gang,
      intensity: ActivityIntensityLevel.haard,
      metValue: 5.0,
      description: 'Gang, hurtig, 6.5 km/t',
    ),
    ActivityMetData(
      category: ActivityCategory.gang,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 6.3,
      description: 'Power walking, 8+ km/t',
    ),

    // Cykling
    ActivityMetData(
      category: ActivityCategory.cykling,
      intensity: ActivityIntensityLevel.let,
      metValue: 4.0,
      description: 'Cykling, rolig, <16 km/t',
    ),
    ActivityMetData(
      category: ActivityCategory.cykling,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 6.8,
      description: 'Cykling, moderat, 19-22 km/t',
    ),
    ActivityMetData(
      category: ActivityCategory.cykling,
      intensity: ActivityIntensityLevel.haard,
      metValue: 8.5,
      description: 'Cykling, hurtig, 22-25 km/t',
    ),
    ActivityMetData(
      category: ActivityCategory.cykling,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 12.0,
      description: 'Cykling, racing, 25+ km/t',
    ),

    // Svømning
    ActivityMetData(
      category: ActivityCategory.svoemning,
      intensity: ActivityIntensityLevel.let,
      metValue: 4.5,
      description: 'Svømning, rolig tempo',
    ),
    ActivityMetData(
      category: ActivityCategory.svoemning,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 6.0,
      description: 'Svømning, moderat tempo',
    ),
    ActivityMetData(
      category: ActivityCategory.svoemning,
      intensity: ActivityIntensityLevel.haard,
      metValue: 8.3,
      description: 'Svømning, hurtig tempo',
    ),
    ActivityMetData(
      category: ActivityCategory.svoemning,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 13.8,
      description: 'Svømning, konkurrence tempo',
    ),

    // Styrketræning
    ActivityMetData(
      category: ActivityCategory.styrketraening,
      intensity: ActivityIntensityLevel.let,
      metValue: 3.0,
      description: 'Styrketræning, let vægte',
    ),
    ActivityMetData(
      category: ActivityCategory.styrketraening,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 5.0,
      description: 'Styrketræning, moderate vægte',
    ),
    ActivityMetData(
      category: ActivityCategory.styrketraening,
      intensity: ActivityIntensityLevel.haard,
      metValue: 6.0,
      description: 'Styrketræning, tunge vægte',
    ),
    ActivityMetData(
      category: ActivityCategory.styrketraening,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 8.0,
      description: 'Powerlifting, maksimal intensitet',
    ),

    // Yoga
    ActivityMetData(
      category: ActivityCategory.yoga,
      intensity: ActivityIntensityLevel.let,
      metValue: 2.5,
      description: 'Hatha yoga, rolig',
    ),
    ActivityMetData(
      category: ActivityCategory.yoga,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 3.0,
      description: 'Vinyasa yoga',
    ),
    ActivityMetData(
      category: ActivityCategory.yoga,
      intensity: ActivityIntensityLevel.haard,
      metValue: 4.0,
      description: 'Power yoga',
    ),
    ActivityMetData(
      category: ActivityCategory.yoga,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 5.0,
      description: 'Hot yoga, Bikram',
    ),

    // Dans
    ActivityMetData(
      category: ActivityCategory.dans,
      intensity: ActivityIntensityLevel.let,
      metValue: 3.0,
      description: 'Dans, sociale danse',
    ),
    ActivityMetData(
      category: ActivityCategory.dans,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 4.8,
      description: 'Dans, aerobic dans',
    ),
    ActivityMetData(
      category: ActivityCategory.dans,
      intensity: ActivityIntensityLevel.haard,
      metValue: 6.0,
      description: 'Dans, Zumba',
    ),
    ActivityMetData(
      category: ActivityCategory.dans,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 8.0,
      description: 'Dans, konkurrence/ballet',
    ),

    // Fodbold
    ActivityMetData(
      category: ActivityCategory.fodbold,
      intensity: ActivityIntensityLevel.let,
      metValue: 5.0,
      description: 'Fodbold, casual spil',
    ),
    ActivityMetData(
      category: ActivityCategory.fodbold,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 7.0,
      description: 'Fodbold, generel kamp',
    ),
    ActivityMetData(
      category: ActivityCategory.fodbold,
      intensity: ActivityIntensityLevel.haard,
      metValue: 10.0,
      description: 'Fodbold, konkurrence',
    ),
    ActivityMetData(
      category: ActivityCategory.fodbold,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 12.0,
      description: 'Fodbold, professionelt niveau',
    ),

    // Basketball
    ActivityMetData(
      category: ActivityCategory.basketball,
      intensity: ActivityIntensityLevel.let,
      metValue: 4.5,
      description: 'Basketball, skydning, ikke-spil',
    ),
    ActivityMetData(
      category: ActivityCategory.basketball,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 6.5,
      description: 'Basketball, general kamp',
    ),
    ActivityMetData(
      category: ActivityCategory.basketball,
      intensity: ActivityIntensityLevel.haard,
      metValue: 8.0,
      description: 'Basketball, konkurrence',
    ),
    ActivityMetData(
      category: ActivityCategory.basketball,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 10.0,
      description: 'Basketball, turnering',
    ),

    // Tennis
    ActivityMetData(
      category: ActivityCategory.tennis,
      intensity: ActivityIntensityLevel.let,
      metValue: 4.5,
      description: 'Tennis, doubles',
    ),
    ActivityMetData(
      category: ActivityCategory.tennis,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 6.0,
      description: 'Tennis, generel singles',
    ),
    ActivityMetData(
      category: ActivityCategory.tennis,
      intensity: ActivityIntensityLevel.haard,
      metValue: 8.0,
      description: 'Tennis, konkurrence',
    ),
    ActivityMetData(
      category: ActivityCategory.tennis,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 10.0,
      description: 'Tennis, professionelt niveau',
    ),

    // Badminton
    ActivityMetData(
      category: ActivityCategory.badminton,
      intensity: ActivityIntensityLevel.let,
      metValue: 4.5,
      description: 'Badminton, social spil',
    ),
    ActivityMetData(
      category: ActivityCategory.badminton,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 5.5,
      description: 'Badminton, generel kamp',
    ),
    ActivityMetData(
      category: ActivityCategory.badminton,
      intensity: ActivityIntensityLevel.haard,
      metValue: 7.0,
      description: 'Badminton, konkurrence',
    ),
    ActivityMetData(
      category: ActivityCategory.badminton,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 9.0,
      description: 'Badminton, turnering',
    ),

    // Volleyball
    ActivityMetData(
      category: ActivityCategory.volleyball,
      intensity: ActivityIntensityLevel.let,
      metValue: 3.0,
      description: 'Volleyball, non-konkurrence',
    ),
    ActivityMetData(
      category: ActivityCategory.volleyball,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 4.0,
      description: 'Volleyball, generel kamp',
    ),
    ActivityMetData(
      category: ActivityCategory.volleyball,
      intensity: ActivityIntensityLevel.haard,
      metValue: 6.0,
      description: 'Volleyball, konkurrence',
    ),
    ActivityMetData(
      category: ActivityCategory.volleyball,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 8.0,
      description: 'Volleyball, beach/professionelt',
    ),

    // Golf
    ActivityMetData(
      category: ActivityCategory.golf,
      intensity: ActivityIntensityLevel.let,
      metValue: 3.5,
      description: 'Golf, med golfvogn',
    ),
    ActivityMetData(
      category: ActivityCategory.golf,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 4.3,
      description: 'Golf, bære klubber',
    ),
    ActivityMetData(
      category: ActivityCategory.golf,
      intensity: ActivityIntensityLevel.haard,
      metValue: 5.5,
      description: 'Golf, trække trolley',
    ),
    ActivityMetData(
      category: ActivityCategory.golf,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 6.0,
      description: 'Golf, bane med bakker',
    ),

    // Vandring
    ActivityMetData(
      category: ActivityCategory.vandring,
      intensity: ActivityIntensityLevel.let,
      metValue: 3.5,
      description: 'Vandring, fladt terræn',
    ),
    ActivityMetData(
      category: ActivityCategory.vandring,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 6.0,
      description: 'Vandring, bakket terræn',
    ),
    ActivityMetData(
      category: ActivityCategory.vandring,
      intensity: ActivityIntensityLevel.haard,
      metValue: 7.5,
      description: 'Vandring, stejlt terræn med rygsæk',
    ),
    ActivityMetData(
      category: ActivityCategory.vandring,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 9.0,
      description: 'Bjergbestigning med udstyr',
    ),

    // Rengøring
    ActivityMetData(
      category: ActivityCategory.rengoring,
      intensity: ActivityIntensityLevel.let,
      metValue: 2.5,
      description: 'Let rengøring, støvsugning',
    ),
    ActivityMetData(
      category: ActivityCategory.rengoring,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 3.3,
      description: 'Generel rengøring',
    ),
    ActivityMetData(
      category: ActivityCategory.rengoring,
      intensity: ActivityIntensityLevel.haard,
      metValue: 4.0,
      description: 'Tung rengøring, skrubning',
    ),
    ActivityMetData(
      category: ActivityCategory.rengoring,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 5.0,
      description: 'Hovedrengøring, flytning af møbler',
    ),

    // Havearbejde
    ActivityMetData(
      category: ActivityCategory.havearbejde,
      intensity: ActivityIntensityLevel.let,
      metValue: 3.0,
      description: 'Let havearbejde, plante',
    ),
    ActivityMetData(
      category: ActivityCategory.havearbejde,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 4.0,
      description: 'Generel havearbejde',
    ),
    ActivityMetData(
      category: ActivityCategory.havearbejde,
      intensity: ActivityIntensityLevel.haard,
      metValue: 5.5,
      description: 'Tung havearbejde, grave',
    ),
    ActivityMetData(
      category: ActivityCategory.havearbejde,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 7.0,
      description: 'Meget tungt havearbejde, skovle',
    ),

    // Trappeløb
    ActivityMetData(
      category: ActivityCategory.traeklatring,
      intensity: ActivityIntensityLevel.let,
      metValue: 4.0,
      description: 'Gå op ad trapper, langsomt',
    ),
    ActivityMetData(
      category: ActivityCategory.traeklatring,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 8.0,
      description: 'Gå op ad trapper, normalt tempo',
    ),
    ActivityMetData(
      category: ActivityCategory.traeklatring,
      intensity: ActivityIntensityLevel.haard,
      metValue: 12.0,
      description: 'Løb op ad trapper',
    ),
    ActivityMetData(
      category: ActivityCategory.traeklatring,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 15.0,
      description: 'Sprint op ad trapper',
    ),

    // Roning
    ActivityMetData(
      category: ActivityCategory.roning,
      intensity: ActivityIntensityLevel.let,
      metValue: 3.5,
      description: 'Roning, roligt tempo',
    ),
    ActivityMetData(
      category: ActivityCategory.roning,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 7.0,
      description: 'Roning, moderat tempo',
    ),
    ActivityMetData(
      category: ActivityCategory.roning,
      intensity: ActivityIntensityLevel.haard,
      metValue: 8.5,
      description: 'Roning, kraftfuldt',
    ),
    ActivityMetData(
      category: ActivityCategory.roning,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 12.0,
      description: 'Roning, konkurrence',
    ),

    // Skiløb
    ActivityMetData(
      category: ActivityCategory.skiloeb,
      intensity: ActivityIntensityLevel.let,
      metValue: 5.0,
      description: 'Alpint ski, let tempo',
    ),
    ActivityMetData(
      category: ActivityCategory.skiloeb,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 6.0,
      description: 'Alpint ski, moderat',
    ),
    ActivityMetData(
      category: ActivityCategory.skiloeb,
      intensity: ActivityIntensityLevel.haard,
      metValue: 8.0,
      description: 'Alpint ski, hurtigt',
    ),
    ActivityMetData(
      category: ActivityCategory.skiloeb,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 15.0,
      description: 'Langrend ski, konkurrence',
    ),

    // Snowboard
    ActivityMetData(
      category: ActivityCategory.snowboard,
      intensity: ActivityIntensityLevel.let,
      metValue: 4.0,
      description: 'Snowboard, let tempo',
    ),
    ActivityMetData(
      category: ActivityCategory.snowboard,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 5.3,
      description: 'Snowboard, moderat',
    ),
    ActivityMetData(
      category: ActivityCategory.snowboard,
      intensity: ActivityIntensityLevel.haard,
      metValue: 7.0,
      description: 'Snowboard, hurtigt',
    ),
    ActivityMetData(
      category: ActivityCategory.snowboard,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 8.0,
      description: 'Snowboard, konkurrence',
    ),

    // Pilates
    ActivityMetData(
      category: ActivityCategory.pilates,
      intensity: ActivityIntensityLevel.let,
      metValue: 2.5,
      description: 'Pilates, begynder',
    ),
    ActivityMetData(
      category: ActivityCategory.pilates,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 3.0,
      description: 'Pilates, intermediate',
    ),
    ActivityMetData(
      category: ActivityCategory.pilates,
      intensity: ActivityIntensityLevel.haard,
      metValue: 4.0,
      description: 'Pilates, avanceret',
    ),
    ActivityMetData(
      category: ActivityCategory.pilates,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 5.0,
      description: 'Pilates, med maskiner',
    ),

    // CrossFit
    ActivityMetData(
      category: ActivityCategory.crossfit,
      intensity: ActivityIntensityLevel.let,
      metValue: 5.0,
      description: 'CrossFit, begynder',
    ),
    ActivityMetData(
      category: ActivityCategory.crossfit,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 8.0,
      description: 'CrossFit, moderat',
    ),
    ActivityMetData(
      category: ActivityCategory.crossfit,
      intensity: ActivityIntensityLevel.haard,
      metValue: 12.0,
      description: 'CrossFit, høj intensitet',
    ),
    ActivityMetData(
      category: ActivityCategory.crossfit,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 15.0,
      description: 'CrossFit, konkurrence WOD',
    ),

    // Kampsport
    ActivityMetData(
      category: ActivityCategory.martial_arts,
      intensity: ActivityIntensityLevel.let,
      metValue: 4.0,
      description: 'Kampsport, teknik træning',
    ),
    ActivityMetData(
      category: ActivityCategory.martial_arts,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 6.0,
      description: 'Kampsport, sparring',
    ),
    ActivityMetData(
      category: ActivityCategory.martial_arts,
      intensity: ActivityIntensityLevel.haard,
      metValue: 10.0,
      description: 'Kampsport, intensiv sparring',
    ),
    ActivityMetData(
      category: ActivityCategory.martial_arts,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 12.0,
      description: 'Kampsport, konkurrence',
    ),

    // Klatring
    ActivityMetData(
      category: ActivityCategory.climbing,
      intensity: ActivityIntensityLevel.let,
      metValue: 5.0,
      description: 'Indoor klatring, let',
    ),
    ActivityMetData(
      category: ActivityCategory.climbing,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 8.0,
      description: 'Klatring, moderat',
    ),
    ActivityMetData(
      category: ActivityCategory.climbing,
      intensity: ActivityIntensityLevel.haard,
      metValue: 11.0,
      description: 'Klatring, udfordrende ruter',
    ),
    ActivityMetData(
      category: ActivityCategory.climbing,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 15.0,
      description: 'Bjergklatring, extreme ruter',
    ),

    // Skøjteløb
    ActivityMetData(
      category: ActivityCategory.skating,
      intensity: ActivityIntensityLevel.let,
      metValue: 5.0,
      description: 'Skøjteløb, roligt',
    ),
    ActivityMetData(
      category: ActivityCategory.skating,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 7.0,
      description: 'Skøjteløb, moderat hastighed',
    ),
    ActivityMetData(
      category: ActivityCategory.skating,
      intensity: ActivityIntensityLevel.haard,
      metValue: 9.0,
      description: 'Skøjteløb, hurtig hastighed',
    ),
    ActivityMetData(
      category: ActivityCategory.skating,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 13.0,
      description: 'Speed skating, konkurrence',
    ),

    // Anden aktivitet - generiske værdier
    ActivityMetData(
      category: ActivityCategory.anden,
      intensity: ActivityIntensityLevel.let,
      metValue: 3.0,
      description: 'Let physical aktivitet',
    ),
    ActivityMetData(
      category: ActivityCategory.anden,
      intensity: ActivityIntensityLevel.moderat,
      metValue: 5.0,
      description: 'Moderat physical aktivitet',
    ),
    ActivityMetData(
      category: ActivityCategory.anden,
      intensity: ActivityIntensityLevel.haard,
      metValue: 8.0,
      description: 'Hård physical aktivitet',
    ),
    ActivityMetData(
      category: ActivityCategory.anden,
      intensity: ActivityIntensityLevel.ekstremt,
      metValue: 12.0,
      description: 'Ekstremt hård physical aktivitet',
    ),
  ];

  /// Get MET value for specific activity and intensity
  static double? getMetValue(ActivityCategory category, ActivityIntensityLevel intensity) {
    final metData = _metDatabase.firstWhere(
      (data) => data.category == category && data.intensity == intensity,
      orElse: () => const ActivityMetData(
        category: ActivityCategory.anden,
        intensity: ActivityIntensityLevel.moderat,
        metValue: 5.0,
        description: 'Default aktivitet',
      ),
    );
    return metData.metValue;
  }

  /// Get description for specific activity and intensity
  static String getDescription(ActivityCategory category, ActivityIntensityLevel intensity) {
    final metData = _metDatabase.firstWhere(
      (data) => data.category == category && data.intensity == intensity,
      orElse: () => const ActivityMetData(
        category: ActivityCategory.anden,
        intensity: ActivityIntensityLevel.moderat,
        metValue: 5.0,
        description: 'Generel aktivitet',
      ),
    );
    return metData.description;
  }

  /// Get all activities for a specific category
  static List<ActivityMetData> getActivitiesForCategory(ActivityCategory category) {
    return _metDatabase.where((data) => data.category == category).toList();
  }

  /// Calculate calories burned using MET formula
  /// Calories = MET × weight (kg) × duration (hours)
  static int calculateCalories({
    required ActivityCategory category,
    required ActivityIntensityLevel intensity,
    required double weightKg,
    required double durationMinutes,
  }) {
    final metValue = getMetValue(category, intensity) ?? 5.0;
    final durationHours = durationMinutes / 60.0;
    final calories = metValue * weightKg * durationHours;
    return calories.round();
  }

  /// Calculate calories for distance-based activities (running/walking/cycling)
  static int calculateCaloriesFromDistance({
    required ActivityCategory category,
    required ActivityIntensityLevel intensity,
    required double weightKg,
    required double distanceKm,
    double? averageSpeedKmh,
  }) {
    final metValue = getMetValue(category, intensity) ?? 5.0;
    
    // Estimate duration if not provided
    double durationHours;
    if (averageSpeedKmh != null) {
      durationHours = distanceKm / averageSpeedKmh;
    } else {
      // Use default speeds based on category and intensity
      double defaultSpeed = getDefaultSpeed(category, intensity);
      durationHours = distanceKm / defaultSpeed;
    }
    
    final calories = metValue * weightKg * durationHours;
    return calories.round();
  }

  /// Get default speed for distance-based activities
  static double getDefaultSpeed(ActivityCategory category, ActivityIntensityLevel intensity) {
    switch (category) {
      case ActivityCategory.loeb:
        switch (intensity) {
          case ActivityIntensityLevel.let: return 6.0; // 6 km/h
          case ActivityIntensityLevel.moderat: return 8.0; // 8 km/h
          case ActivityIntensityLevel.haard: return 11.0; // 11 km/h
          case ActivityIntensityLevel.ekstremt: return 16.0; // 16 km/h
        }
      case ActivityCategory.gang:
        switch (intensity) {
          case ActivityIntensityLevel.let: return 3.0; // 3 km/h
          case ActivityIntensityLevel.moderat: return 5.0; // 5 km/h
          case ActivityIntensityLevel.haard: return 6.5; // 6.5 km/h
          case ActivityIntensityLevel.ekstremt: return 8.0; // 8 km/h
        }
      case ActivityCategory.cykling:
        switch (intensity) {
          case ActivityIntensityLevel.let: return 16.0; // 16 km/h
          case ActivityIntensityLevel.moderat: return 20.0; // 20 km/h
          case ActivityIntensityLevel.haard: return 25.0; // 25 km/h
          case ActivityIntensityLevel.ekstremt: return 30.0; // 30 km/h
        }
      default:
        return 5.0; // Default 5 km/h
    }
  }
} 