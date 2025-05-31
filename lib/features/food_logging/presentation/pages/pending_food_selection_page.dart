import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/pending_food_model.dart';
import '../../application/pending_food_cubit.dart';
import 'categorize_food_page.dart';

/// Page for selecting which pending food to categorize
class PendingFoodSelectionPage extends ConsumerWidget {
  final List<PendingFoodModel> pendingFoods;

  const PendingFoodSelectionPage({
    super.key,
    required this.pendingFoods,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Vælg måltid at kategorisere',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightBold,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: Column(
          children: [
            // Header info card - following favorites style
            Container(
              margin: EdgeInsets.all(KSizes.margin4x),
              padding: EdgeInsets.all(KSizes.margin6x),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    AppColors.primary.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(KSizes.radiusXL),
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
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
                        colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      MdiIcons.silverwareForkKnife,
                      color: Colors.white,
                      size: KSizes.iconL,
                    ),
                  ),
                  SizedBox(height: KSizes.margin3x),
                  Text(
                    '${pendingFoods.length} ventende måltider',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXL,
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: KSizes.margin1x),
                  Text(
                    'Vælg det måltid du vil kategorisere',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeM,
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            // List of pending foods - following favorites grid/list style
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: KSizes.margin4x),
                itemCount: pendingFoods.length,
                itemBuilder: (context, index) {
                  final food = pendingFoods[index];
                  return _PendingFoodCard(
                    food: food,
                    onTap: () => _navigateToCategorizePage(context, food),
                    onDeleteTap: () => _deletePendingFood(context, ref, food),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToCategorizePage(BuildContext context, PendingFoodModel selectedFood) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategorizeFoodPage(pendingFood: selectedFood),
      ),
    );
  }

  Future<void> _deletePendingFood(BuildContext context, WidgetRef ref, PendingFoodModel food) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Slet ventende måltid?'),
        content: Text('Er du sikker på at du vil slette dette ventende måltid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Slet'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(pendingFoodProvider.notifier).deletePendingFood(food.id);
      if (context.mounted) {
        Navigator.of(context).pop(); // Go back if no more items
      }
    }
  }
}

/// Widget for displaying individual pending food cards - following favorites style
class _PendingFoodCard extends StatefulWidget {
  final PendingFoodModel food;
  final VoidCallback onTap;
  final VoidCallback onDeleteTap;
  
  const _PendingFoodCard({
    required this.food,
    required this.onTap,
    required this.onDeleteTap,
  });
  
  @override
  State<_PendingFoodCard> createState() => _PendingFoodCardState();
}

class _PendingFoodCardState extends State<_PendingFoodCard> {
  int _currentImageIndex = 0;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: KSizes.margin3x),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onLongPress: widget.onDeleteTap,
          borderRadius: BorderRadius.circular(KSizes.radiusL),
          child: Container(
            padding: EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(KSizes.radiusL),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Image preview - smaller like favorites
                Container(
                  width: 80,
                  height: 80,
                  child: _buildImagePreview(),
                ),
                
                SizedBox(width: KSizes.margin4x),
                
                // Content section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food name
                      Text(
                        widget.food.aiResult?.foodName.isNotEmpty == true 
                            ? widget.food.aiResult!.foodName
                            : 'Måltid ${widget.food.id.substring(widget.food.id.length - 4)}',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      
                      SizedBox(height: KSizes.margin1x),
                      
                      // AI info
                      if (widget.food.aiResult?.estimatedCalories != null && widget.food.aiResult!.estimatedCalories > 0)
                        Text(
                          '${widget.food.aiResult!.estimatedCalories} kcal • AI analyse',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            color: AppColors.textSecondary,
                          ),
                        )
                      else
                        Text(
                          'Klar til kategorisering',
                          style: TextStyle(
                            fontSize: KSizes.fontSizeM,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      
                      SizedBox(height: KSizes.margin1x),
                      
                      // Time info
                      Text(
                        _formatDateTime(widget.food.capturedAt),
                        style: TextStyle(
                          fontSize: KSizes.fontSizeS,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Action section - following favorites style
                Column(
                  children: [
                    Icon(
                      MdiIcons.arrowRight,
                      color: AppColors.primary,
                      size: KSizes.iconM,
                    ),
                    SizedBox(height: KSizes.margin1x),
                    Text(
                      'Tryk: kategoriser\nHold: slet',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeXS,
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildImagePreview() {
    if (widget.food.imagePaths.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.border.withOpacity(0.1),
          borderRadius: BorderRadius.circular(KSizes.radiusM),
        ),
        child: Center(
          child: Icon(
            MdiIcons.imageOff,
            size: KSizes.iconL,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: widget.food.imageCount > 1 ? _showImageGallery : null,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            child: Image.file(
              File(widget.food.imagePaths[_currentImageIndex]),
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 80,
                height: 80,
                color: AppColors.border.withOpacity(0.1),
                child: Center(
                  child: Icon(
                    MdiIcons.imageOff,
                    size: KSizes.iconL,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          ),
          
          // Image counter
          if (widget.food.imageCount > 1)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Text(
                  '${widget.food.imageCount}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: KSizes.fontSizeXS,
                    fontWeight: KSizes.fontWeightBold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  void _showImageGallery() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.all(KSizes.margin4x),
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // Header with categorize button
              Container(
                padding: EdgeInsets.all(KSizes.margin4x),
                child: Row(
                  children: [
                    Text(
                      'Billeder af måltid',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightBold,
                      ),
                    ),
                    Spacer(),
                    // Direct categorize button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close gallery
                        widget.onTap(); // Navigate to categorization
                      },
                      icon: Icon(MdiIcons.silverwareForkKnife),
                      label: Text('Kategoriser'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    SizedBox(width: KSizes.margin2x),
                    if (widget.food.imageCount > 1)
                      Text(
                        '${_currentImageIndex + 1} af ${widget.food.imageCount}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: KSizes.fontSizeM,
                        ),
                      ),
                    SizedBox(width: KSizes.margin2x),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        MdiIcons.close,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Image gallery
              Expanded(
                child: PageView.builder(
                  controller: PageController(initialPage: _currentImageIndex),
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemCount: widget.food.imageCount,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.all(KSizes.margin4x),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                        child: Image.file(
                          File(widget.food.imagePaths[index]),
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.border.withOpacity(0.2),
                            child: Center(
                              child: Icon(
                                MdiIcons.imageOff,
                                size: KSizes.iconXXL,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom action bar with additional info
              Container(
                padding: EdgeInsets.all(KSizes.margin4x),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(KSizes.radiusL),
                    bottomRight: Radius.circular(KSizes.radiusL),
                  ),
                ),
                child: Row(
                  children: [
                    // AI results info
                    if (widget.food.aiResult != null) ...[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Analyse:',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: KSizes.fontSizeS,
                              ),
                            ),
                            Text(
                              widget.food.aiResult!.foodName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: KSizes.fontSizeM,
                                fontWeight: KSizes.fontWeightBold,
                              ),
                            ),
                            if (widget.food.aiResult!.estimatedCalories > 0)
                              Text(
                                '${widget.food.aiResult!.estimatedCalories} kcal',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: KSizes.fontSizeS,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: Text(
                          'Klar til kategorisering',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: KSizes.fontSizeM,
                          ),
                        ),
                      ),
                    ],
                    
                    // Action button
                    SizedBox(
                      height: KSizes.buttonHeight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close gallery
                          widget.onTap(); // Navigate to categorization
                        },
                        icon: Icon(MdiIcons.arrowRight),
                        label: Text('Kategoriser Nu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(KSizes.radiusM),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Lige nu';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} min siden';
    } else if (difference.inDays < 1) {
      return '${difference.inHours} timer siden';  
    } else {
      return '${difference.inDays} dage siden';
    }
  }
} 