import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/favorite_activity_model.dart';
import '../../domain/user_activity_log_model.dart';
import '../../infrastructure/favorite_activity_service.dart';
import '../../../dashboard/application/date_aware_providers.dart';

/// Page for selecting activity favorites
class ActivityFavoritesPage extends ConsumerStatefulWidget {
  const ActivityFavoritesPage({super.key});

  @override
  ConsumerState<ActivityFavoritesPage> createState() => _ActivityFavoritesPageState();
}

class _ActivityFavoritesPageState extends ConsumerState<ActivityFavoritesPage> {
  final FavoriteActivityService _favoriteService = FavoriteActivityService();
  List<FavoriteActivityModel> _favorites = [];
  bool _isLoading = true;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });

    final result = await _favoriteService.getFavorites();
    
    if (!mounted) return;
    
    if (result.isSuccess) {
      setState(() {
        _favorites = result.success;
        _isLoading = false;
      });
    } else {
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke indlæse favoritter'),
            backgroundColor: AppColors.error,
    ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Aktivitets Favoritter'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Vælg fra dine gemte favoritter',
                style: TextStyle(
                  fontSize: KSizes.fontSizeL,
                  fontWeight: KSizes.fontWeightBold,
                  color: AppColors.textPrimary,
                ),
              ),
              
              SizedBox(height: KSizes.margin2x),
              
              Text(
                'Tryk på en favorit for at registrere den',
                style: TextStyle(
                  fontSize: KSizes.fontSizeM,
                  color: AppColors.textSecondary,
                ),
              ),
              
              SizedBox(height: KSizes.margin6x),
              
              // Content
              Expanded(
                child: _isLoading 
                    ? _buildLoadingState()
                    : _favorites.isEmpty 
                    ? _buildEmptyState()
                        : _buildFavoritesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.secondary,
          ),
          SizedBox(height: KSizes.margin4x),
          Text(
            'Indlæser favoritter...',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.separated(
      itemCount: _favorites.length,
      separatorBuilder: (context, index) => SizedBox(height: KSizes.margin3x),
      itemBuilder: (context, index) {
        final favorite = _favorites[index];
        return _buildFavoriteCard(favorite);
      },
    );
  }

  Widget _buildFavoriteCard(FavoriteActivityModel favorite) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      child: InkWell(
        onTap: _isProcessing ? null : () => _selectFavorite(favorite),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  _getIconForActivity(favorite.activityName),
                  color: AppColors.secondary,
                  size: KSizes.iconL,
                ),
              ),
              
              SizedBox(width: KSizes.margin4x),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      favorite.activityName,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      favorite.displayText,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (favorite.notes.isNotEmpty) ...[
                      SizedBox(height: KSizes.margin1x),
                      Text(
                        favorite.notes,
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: AppColors.textSecondary.withOpacity(0.7),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Arrow or loading
              if (_isProcessing)
                SizedBox(
                  width: KSizes.iconM,
                  height: KSizes.iconM,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                )
              else
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

  IconData _getIconForActivity(String activityName) {
    final name = activityName.toLowerCase();
    
    if (name.contains('løb') || name.contains('run')) {
      return MdiIcons.run;
    } else if (name.contains('cykel') || name.contains('bike')) {
      return MdiIcons.bike;
    } else if (name.contains('gå') || name.contains('walk')) {
      return MdiIcons.walk;
    } else if (name.contains('svøm') || name.contains('swim')) {
      return MdiIcons.swim;
    } else if (name.contains('gym') || name.contains('fitness')) {
      return MdiIcons.dumbbell;
    } else if (name.contains('fodbold') || name.contains('football')) {
      return MdiIcons.soccerField;
    } else {
      return MdiIcons.runFast;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(KSizes.margin6x),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              MdiIcons.starOutline,
              size: 64,
              color: AppColors.secondary.withOpacity(0.5),
            ),
          ),
          
          SizedBox(height: KSizes.margin4x),
          
          Text(
            'Ingen favoritter endnu',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          
          SizedBox(height: KSizes.margin2x),
          
          Text(
            'Gem dine ofte brugte aktiviteter som favoritter for hurtig adgang',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _selectFavorite(FavoriteActivityModel favorite) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      // Convert favorite to activity log
      final activityLog = favorite.toUserActivityLog();
      
      // Log the activity using the activity notifier
      await ref.read(activityNotifierProvider.notifier).logActivity(activityLog);
      
      // Update the favorite's usage count
      final updatedFavorite = favorite.withUpdatedUsage();
      await _favoriteService.updateFavorite(updatedFavorite);
      
      // Force refresh of activity calories provider
      try {
        final refreshActivityCaloriesFunction = ref.read(activityRefreshCounterProvider.notifier);
        refreshActivityCaloriesFunction.state = refreshActivityCaloriesFunction.state + 1;
      } catch (e) {
        print('⚠️ ActivityFavoritesPage: Could not refresh activity calories: $e');
      }
      
      if (mounted && context.mounted) {
        // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.check, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: Text('${favorite.activityName} registreret!'),
                ),
              ],
            ),
        backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
      ),
    );
    
        // Navigate back after successful logging
    Navigator.of(context).pop();
  }
    } catch (e) {
      print('❌ ActivityFavoritesPage: Error logging activity: $e');
      
      if (mounted && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(MdiIcons.alertCircle, color: Colors.white),
                SizedBox(width: KSizes.margin2x),
                Expanded(
                  child: Text('Fejl ved registrering af aktivitet'),
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }
} 