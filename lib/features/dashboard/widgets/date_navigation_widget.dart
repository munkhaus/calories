import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../application/selected_date_provider.dart';

/// Widget for navigating between dates with arrow controls and date picker
class DateNavigationWidget extends ConsumerWidget {
  const DateNavigationWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);
    
    final isToday = _isToday(selectedDate);
    final dateText = isToday ? 'I dag' : _formatDate(selectedDate);
    
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: KSizes.margin4x),
      padding: EdgeInsets.symmetric(
        horizontal: KSizes.margin6x,
        vertical: KSizes.margin4x,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            AppColors.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous day button
          _buildNavigationButton(
            icon: MdiIcons.chevronLeft,
            onTap: selectedDateNotifier.previousDay,
            tooltip: 'Forrige dag',
          ),
          
          // Date display and picker
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(context, ref),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: KSizes.margin4x,
                  vertical: KSizes.margin3x,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      MdiIcons.calendar,
                      size: KSizes.iconS,
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                    ),
                    SizedBox(width: KSizes.margin2x),
                    Text(
                      dateText,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: isToday 
                            ? KSizes.fontWeightBold 
                            : KSizes.fontWeightSemiBold,
                        color: isToday ? AppColors.primary : AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: KSizes.margin2x),
                    Icon(
                      MdiIcons.menuDown,
                      size: KSizes.iconXS,
                      color: isToday ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Next day button
          _buildNavigationButton(
            icon: MdiIcons.chevronRight,
            onTap: selectedDateNotifier.nextDay,
            tooltip: 'Næste dag',
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin3x),
          child: Icon(
            icon,
            size: KSizes.iconM,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
           date.month == now.month &&
           date.day == now.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final tomorrow = now.add(const Duration(days: 1));
    
    // Special cases for nearby dates
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'I går';
    }
    
    if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return 'I morgen';
    }
    
    // Format for other dates
    final weekdays = [
      'Mandag', 'Tirsdag', 'Onsdag', 'Torsdag', 
      'Fredag', 'Lørdag', 'Søndag'
    ];
    
    final months = [
      'jan', 'feb', 'mar', 'apr', 'maj', 'jun',
      'jul', 'aug', 'sep', 'okt', 'nov', 'dec'
    ];
    
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    final month = months[date.month - 1];
    
    // Show year if not current year
    if (date.year != now.year) {
      return '$weekday $day. $month ${date.year}';
    }
    
    return '$weekday $day. $month';
  }

  void _showDatePicker(BuildContext context, WidgetRef ref) async {
    final selectedDate = ref.read(selectedDateProvider);
    final selectedDateNotifier = ref.read(selectedDateProvider.notifier);
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)), // 1 year back
      lastDate: DateTime.now().add(const Duration(days: 30)), // 30 days forward
      locale: const Locale('da', 'DK'),
      helpText: 'Vælg dato',
      cancelText: 'Annuller',
      confirmText: 'Vælg',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      selectedDateNotifier.selectDate(pickedDate);
    }
  }
} 