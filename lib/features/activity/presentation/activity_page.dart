import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_page_header.dart';
import '../../../shared/widgets/app_option_card.dart';
import '../application/activity_notifier.dart';
import '../application/activity_calories_notifier.dart';
import '../domain/activity_item_model.dart';
import '../domain/user_activity_log_model.dart';
import '../../onboarding/domain/user_profile_model.dart';
import 'widgets/activity_search_widget.dart';
import 'widgets/common_activities_widget.dart';
import 'widgets/todays_activities_widget.dart';
import '../../info/presentation/info_page.dart';
import 'widgets/manual_calorie_entry_widget.dart';
import 'pages/activity_details_page.dart';
import 'pages/manual_activity_page.dart';

/// Main activity logging page with full functionality
class ActivityPage extends ConsumerStatefulWidget {
  const ActivityPage({super.key});

  @override
  ConsumerState<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends ConsumerState<ActivityPage> {
  late ActivityNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = ActivityNotifier(
      onActivityChanged: () {
        // Refresh activity calories when activities are logged
        if (mounted) {
          refreshActivityCalories(ref);
        }
      },
    );
    // Initialize data after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    try {
      await _notifier.initialize();
    } catch (e) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Kunne ikke indlæse aktivitetsdata'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(KSizes.margin4x),
              child: Column(
                children: [
                  // Header with new design
                  StandardPageHeader(
                    title: 'Tid til aktivitet! 🏃‍♂️',
                    subtitle: 'Log dine aktiviteter og hold styr på dit energiforbrug',
                    icon: MdiIcons.runFast,
                    iconColor: AppColors.secondary,
                    onInfoTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const InfoPage(),
                        ),
                      );
                    },
                  ),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Search section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(KSizes.margin4x),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(KSizes.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: KSizes.blurRadiusL,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Søg aktiviteter',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeXL,
                            fontWeight: KSizes.fontWeightBold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        
                        const SizedBox(height: KSizes.margin2x),
                        
                        Text(
                          'Find aktiviteter og log dit træning',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            color: AppColors.textSecondary,
                            height: 1.3,
                          ),
                        ),
                        
                        const SizedBox(height: KSizes.margin4x),
                        
                        // Activity search widget
                        ActivitySearchWidget(
                          notifier: _notifier,
                          onActivitySelected: _onActivitySelected,
                        ),
                      ],
                    ),
                  ),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Common activities section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(KSizes.margin4x),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(KSizes.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: KSizes.blurRadiusL,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(KSizes.margin3x),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.secondary,
                                    AppColors.secondary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(KSizes.radiusM),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.secondary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                MdiIcons.fire,
                                color: Colors.white,
                                size: KSizes.iconL,
                              ),
                            ),
                            const SizedBox(width: KSizes.margin4x),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Populære aktiviteter',
                                    style: TextStyle(
                                      fontSize: KSizes.fontSizeXL,
                                      fontWeight: KSizes.fontWeightBold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Hurtig adgang til almindelige aktiviteter',
                                    style: TextStyle(
                                      fontSize: KSizes.fontSizeM,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: KSizes.margin4x),
                        
                        CommonActivitiesWidget(
                          notifier: _notifier,
                          onActivitySelected: _onActivitySelected,
                        ),
                      ],
                    ),
                  ),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Manual entry section with improved design
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(KSizes.margin4x),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(KSizes.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.08),
                          blurRadius: KSizes.blurRadiusL,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(KSizes.margin3x),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primary.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(KSizes.radiusM),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                MdiIcons.pencilPlus,
                                color: Colors.white,
                                size: KSizes.iconL,
                              ),
                            ),
                            const SizedBox(width: KSizes.margin4x),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manuel registrering',
                                    style: TextStyle(
                                      fontSize: KSizes.fontSizeXL,
                                      fontWeight: KSizes.fontWeightBold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    'Registrer aktivitet manuelt eller kalorier direkte',
                                    style: TextStyle(
                                      fontSize: KSizes.fontSizeM,
                                      color: AppColors.textSecondary,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: KSizes.margin6x),
                        
                        // Manual options
                        ActivityOptionCard(
                          title: 'Manuel aktivitet',
                          subtitle: 'Registrer træning med varighed og intensitet',
                          icon: MdiIcons.runFast,
                          onTap: _onManualActivityTap,
                        ),
                        
                        ActivityOptionCard(
                          title: 'Direkte kalorier',
                          subtitle: 'Indtast forbrændte kalorier direkte',
                          icon: MdiIcons.fire,
                          onTap: _onManualCaloriesTap,
                        ),
                      ],
                    ),
                  ),
                  
                  KSizes.spacingVerticalXL,
                  
                  // Today's activities section
                  TodaysActivitiesWidget(
                    notifier: _notifier,
                    onDeleteActivity: _onDeleteActivity,
                    activityTrackingPreference: ActivityTrackingPreference.manual,
                  ),
                  
                  // Bottom padding
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onActivitySelected(ActivityItemModel activity) async {
    print('🏃 Activity selected: ${activity.name}');
    
    try {
      final result = await Navigator.of(context).push<UserActivityLogModel>(
        MaterialPageRoute(
          builder: (context) => ActivityDetailsPage(
            activity: activity,
            notifier: _notifier,
          ),
        ),
      );
      
      if (result != null) {
        print('✅ Activity logged successfully: ${result.activityName}');
      }
    } catch (e) {
      print('❌ Error navigating to activity details: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke åbne aktivitetsdetaljer'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onManualActivityTap() async {
    print('📝 Manual activity registration tapped');
    
    try {
      final result = await Navigator.of(context).push<UserActivityLogModel>(
        MaterialPageRoute(
          builder: (context) => ManualActivityPage(
            notifier: _notifier,
          ),
        ),
      );
      
      if (result != null) {
        print('✅ Manual activity logged successfully: ${result.activityName}');
      }
    } catch (e) {
      print('❌ Error navigating to manual activity page: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke åbne manuel aktivitetsregistrering'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onManualCaloriesTap() async {
    print('🔥 Manual calories entry tapped');
    
    try {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KSizes.radiusXL),
          ),
          content: ManualCalorieEntryWidget(
            notifier: _notifier,
            onCaloriesLogged: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      );
    } catch (e) {
      print('❌ Error with manual calories entry: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke registrere kalorier'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onDeleteActivity(UserActivityLogModel activity) async {
    print('🗑️ Deleting activity: ${activity.activityName}');
    
    try {
      final success = await _notifier.deleteActivity(activity.logEntryId);
      
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success 
                  ? 'Aktivitet slettet' 
                  : 'Kunne ikke slette aktivitet'),
                backgroundColor: success ? AppColors.success : AppColors.error,
              ),
            );
          }
        });
      }
    } catch (e) {
      print('❌ Error deleting activity: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved sletning af aktivitet'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
} 