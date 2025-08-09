import 'package:calories/core/domain/models/daily_totals.dart';

abstract class ITrendsService {
  List<DailyTotals> getDailyTotals({required int days});
  double getAdherencePercent({required int days, int tolerancePercent = 10});
  int getAdherenceStreak({int tolerancePercent = 10});
}


