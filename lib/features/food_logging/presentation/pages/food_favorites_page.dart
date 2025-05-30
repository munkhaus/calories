import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';

/// Page for selecting food favorites
class FoodFavoritesPage extends StatefulWidget {
  const FoodFavoritesPage({super.key});

  @override
  State<FoodFavoritesPage> createState() => _FoodFavoritesPageState();
}

class _FoodFavoritesPageState extends State<FoodFavoritesPage> {
  final List<FoodFavorite> _favorites = [
    FoodFavorite(
      id: '1',
      name: 'Havregrød med bær',
      description: 'Morgenmad - 300 kcal',
      icon: MdiIcons.bowlMix,
    ),
    FoodFavorite(
      id: '2', 
      name: 'Kylling og ris',
      description: 'Frokost - 450 kcal',
      icon: MdiIcons.foodDrumstick,
    ),
    FoodFavorite(
      id: '3',
      name: 'Grøn salat',
      description: 'Let måltid - 200 kcal',
      icon: MdiIcons.foodApple,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mad Favoritter'),
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
              
              // Favorites list
              Expanded(
                child: _favorites.isEmpty 
                    ? _buildEmptyState()
                    : ListView.separated(
                        itemCount: _favorites.length,
                        separatorBuilder: (context, index) => SizedBox(height: KSizes.margin3x),
                        itemBuilder: (context, index) {
                          final favorite = _favorites[index];
                          return _buildFavoriteCard(favorite);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(FoodFavorite favorite) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
      ),
      child: InkWell(
        onTap: () => _selectFavorite(favorite),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Row(
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(KSizes.margin3x),
                decoration: BoxDecoration(
                  color: AppColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(KSizes.radiusM),
                ),
                child: Icon(
                  favorite.icon,
                  color: AppColors.warning,
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
                      favorite.name,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      favorite.description,
                      style: TextStyle(
                        fontSize: KSizes.fontSizeM,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(KSizes.margin6x),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              MdiIcons.starOutline,
              size: 64,
              color: AppColors.warning.withOpacity(0.5),
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
            'Gem dine ofte brugte måltider som favoritter for hurtig adgang',
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

  void _selectFavorite(FoodFavorite favorite) {
    // TODO: Implement favorite selection - add to food log
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${favorite.name} registreret!'),
        backgroundColor: AppColors.success,
      ),
    );
    
    Navigator.of(context).pop();
  }
}

/// Model for food favorite
class FoodFavorite {
  final String id;
  final String name;
  final String description;
  final IconData icon;

  FoodFavorite({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
  });
} 