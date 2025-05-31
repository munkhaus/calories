import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/activity_notifier.dart';
import '../../domain/activity_item_model.dart';
import 'activity_details_page.dart';
import 'manual_activity_page.dart';
import '../../domain/user_activity_log_model.dart';
import '../../../dashboard/application/date_aware_providers.dart';

/// Quick activity registration page accessible from FAB
class QuickActivityRegistrationPage extends ConsumerStatefulWidget {
  const QuickActivityRegistrationPage({super.key});

  @override
  ConsumerState<QuickActivityRegistrationPage> createState() => _QuickActivityRegistrationPageState();
}

class _QuickActivityRegistrationPageState extends ConsumerState<QuickActivityRegistrationPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Registrer aktivitet',
          style: TextStyle(
            fontSize: KSizes.fontSizeXL,
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(KSizes.margin6x),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.secondary.withOpacity(0.1),
                    AppColors.secondary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusXL),
                border: Border.all(
                  color: AppColors.secondary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      MdiIcons.runFast,
                      color: Colors.white,
                      size: KSizes.iconL,
                    ),
                  ),
                  SizedBox(height: KSizes.margin3x),
                  Text(
                    'Hurtig aktivitetsregistrering',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXL,
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    'Vælg en aktivitet eller opret din egen',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            SizedBox(height: KSizes.margin8x),
            
            // Quick activities section
            Text(
              'Populære aktiviteter',
              style: TextStyle(
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: KSizes.margin4x),
            
            // Grid of common activities
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: KSizes.margin3x,
              crossAxisSpacing: KSizes.margin3x,
              childAspectRatio: 1.1,
              children: _getCommonActivities().map((activity) => 
                _buildActivityCard(activity)
              ).toList(),
            ),
            
            SizedBox(height: KSizes.margin8x),
            
            // Manual options section
            Text(
              'Manuel registrering',
              style: TextStyle(
                fontSize: KSizes.fontSizeXL,
                fontWeight: KSizes.fontWeightBold,
                color: AppColors.textPrimary,
              ),
            ),
            
            SizedBox(height: KSizes.margin4x),
            
            // Manual activity button
            _buildManualOption(
              title: 'Opret aktivitet',
              subtitle: 'Registrer en brugerdefineret aktivitet',
              icon: MdiIcons.pencilPlus,
              color: AppColors.primary,
              onTap: _onManualActivityTap,
            ),
            
            SizedBox(height: KSizes.margin3x),
            
            // Direct calories button
            _buildManualOption(
              title: 'Direkte kalorier',
              subtitle: 'Indtast kun forbrændte kalorier',
              icon: MdiIcons.fire,
              color: AppColors.warning,
              onTap: _onDirectCaloriesTap,
            ),
            
            SizedBox(height: KSizes.margin8x),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityItemModel activity) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onActivitySelected(activity),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: AppColors.border.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.secondary, AppColors.secondary.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  _getActivityIcon(activity.name),
                  color: Colors.white,
                  size: KSizes.iconM,
                ),
              ),
              SizedBox(height: KSizes.margin3x),
              Text(
                activity.name,
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  fontWeight: KSizes.fontWeightSemiBold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: KSizes.margin1x),
              Text(
                activity.category,
                style: TextStyle(
                  fontSize: KSizes.fontSizeS,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(KSizes.margin4x),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(KSizes.radiusL),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: KSizes.iconM,
                ),
              ),
              SizedBox(width: KSizes.margin4x),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                MdiIcons.chevronRight,
                color: AppColors.textSecondary,
                size: KSizes.iconM,
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<ActivityItemModel> _getCommonActivities() {
    return [
      ActivityItemModel(
        activityId: 1,
        name: 'Gang',
        category: 'Kardio',
        description: 'Almindelig gang',
        caloriesPerMinute: 4.0,
        caloriesPerKgPerKm: 0.5,
        supportsDuration: true,
        supportsDistance: true,
        iconName: 'walk',
      ),
      ActivityItemModel(
        activityId: 2,
        name: 'Løb',
        category: 'Kardio',
        description: 'Løb og jogging',
        caloriesPerMinute: 10.0,
        caloriesPerKgPerKm: 1.0,
        supportsDuration: true,
        supportsDistance: true,
        iconName: 'run',
      ),
      ActivityItemModel(
        activityId: 3,
        name: 'Cykling',
        category: 'Kardio',
        description: 'Cykling udendørs eller indendørs',
        caloriesPerMinute: 8.0,
        caloriesPerKgPerKm: 0.3,
        supportsDuration: true,
        supportsDistance: true,
        iconName: 'bike',
      ),
      ActivityItemModel(
        activityId: 4,
        name: 'Styrketræning',
        category: 'Styrke',
        description: 'Vægtløftning og styrketræning',
        caloriesPerMinute: 6.0,
        caloriesPerKgPerKm: 0.0,
        supportsDuration: true,
        supportsDistance: false,
        iconName: 'dumbbell',
      ),
      ActivityItemModel(
        activityId: 5,
        name: 'Svømning',
        category: 'Kardio',
        description: 'Svømning i pool eller åbent vand',
        caloriesPerMinute: 12.0,
        caloriesPerKgPerKm: 0.0,
        supportsDuration: true,
        supportsDistance: true,
        iconName: 'swim',
      ),
      ActivityItemModel(
        activityId: 6,
        name: 'Yoga',
        category: 'Fleksibilitet',
        description: 'Yoga og stretching',
        caloriesPerMinute: 3.0,
        caloriesPerKgPerKm: 0.0,
        supportsDuration: true,
        supportsDistance: false,
        iconName: 'yoga',
      ),
    ];
  }

  IconData _getActivityIcon(String activityName) {
    switch (activityName.toLowerCase()) {
      case 'gang':
        return MdiIcons.walk;
      case 'løb':
        return MdiIcons.run;
      case 'cykling':
        return MdiIcons.bike;
      case 'styrketræning':
        return MdiIcons.dumbbell;
      case 'svømning':
        return MdiIcons.swim;
      case 'yoga':
        return MdiIcons.yoga;
      default:
        return MdiIcons.runFast;
    }
  }

  void _onActivitySelected(ActivityItemModel activity) async {
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ActivityDetailsPage(
            activity: activity,
            notifier: ref.read(activityNotifierProvider),
          ),
        ),
      );
      
      if (result != null && mounted) {
        // Activity was logged successfully, go back to main screen
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${activity.name} er registreret!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke registrere aktivitet'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onManualActivityTap() async {
    try {
      final result = await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ManualActivityPage(
            notifier: ref.read(activityNotifierProvider),
          ),
        ),
      );
      
      if (result != null && mounted) {
        // Activity was logged successfully, go back to main screen
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Aktivitet er registreret!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke registrere aktivitet'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _onDirectCaloriesTap() async {
    // Show dialog for direct calorie entry
    final result = await showDialog<int>(
      context: context,
      builder: (context) => _DirectCaloriesDialog(),
    );
    
    if (result != null && result > 0 && mounted) {
      try {
        // Log direct calories using activity model
        final activity = UserActivityLogModel(
          userId: 1, // TODO: Get real user ID
          activityName: 'Manuel kalorieangivelse',
          inputType: ActivityInputType.varighed,
          durationMinutes: 0,
          distanceKm: 0,
          intensity: ActivityIntensity.moderat,
          caloriesBurned: result,
          isManualEntry: true,
          isCaloriesAdjusted: false,
          notes: 'Manuelt angivet kalorieforbrug',
        );

        await ref.read(activityNotifierProvider).logActivity(activity);
        
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$result kalorier er registreret!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke registrere kalorier'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

/// Dialog for entering calories directly
class _DirectCaloriesDialog extends StatefulWidget {
  @override
  _DirectCaloriesDialogState createState() => _DirectCaloriesDialogState();
}

class _DirectCaloriesDialogState extends State<_DirectCaloriesDialog> {
  final TextEditingController _caloriesController = TextEditingController();
  
  @override
  void dispose() {
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      title: Row(
        children: [
          Icon(
            MdiIcons.fire,
            color: AppColors.warning,
            size: KSizes.iconL,
          ),
          SizedBox(width: KSizes.margin2x),
          Text('Registrer kalorier'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Hvor mange kalorier har du forbrændt?',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: KSizes.margin4x),
          TextField(
            controller: _caloriesController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Antal kalorier',
              suffixText: 'kcal',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
              prefixIcon: Icon(
                MdiIcons.fire,
                color: AppColors.warning,
              ),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Annuller'),
        ),
        ElevatedButton(
          onPressed: () {
            final calories = int.tryParse(_caloriesController.text);
            if (calories != null && calories > 0) {
              Navigator.of(context).pop(calories);
            }
          },
          child: Text('Registrer'),
        ),
      ],
    );
  }
} 