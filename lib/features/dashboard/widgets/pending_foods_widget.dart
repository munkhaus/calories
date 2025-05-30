import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/constants/k_sizes.dart';
import '../../../core/theme/app_theme.dart';
import '../../food_logging/application/pending_food_cubit.dart';
import '../../food_logging/domain/pending_food_model.dart';
import '../../food_logging/presentation/pages/categorize_food_page.dart';
import 'dart:io';

/// Widget showing pending food items that need categorization
class PendingFoodsWidget extends ConsumerWidget {
  const PendingFoodsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingState = ref.watch(pendingFoodProvider);
    final pendingCubit = ref.read(pendingFoodProvider.notifier);

    // Always show the widget - even if no pending foods (so user can capture)
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: KSizes.margin4x),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.warning.withOpacity(0.1),
            AppColors.warning.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(KSizes.radiusXL),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withOpacity(0.1),
            blurRadius: KSizes.blurRadiusL,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon and title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(KSizes.margin2x),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                  ),
                  child: Icon(
                    MdiIcons.camera,
                    color: Colors.white,
                    size: KSizes.iconM,
                  ),
                ),
                
                const SizedBox(width: KSizes.margin3x),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pendingState.hasPendingFoods 
                            ? 'Afventende mad-billeder'
                            : 'Hurtig mad-registrering',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: KSizes.fontWeightBold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        pendingState.hasPendingFoods
                            ? '${pendingState.pendingFoodsCount} ${pendingState.pendingFoodsCount == 1 ? 'billede' : 'billeder'} skal kategoriseres'
                            : 'Tag et billede af din mad og kategoriser det senere',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          color: AppColors.warning,
                          fontWeight: KSizes.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Quick capture button
                GestureDetector(
                  onTap: () => _captureFood(context, ref),
                  child: Container(
                    padding: const EdgeInsets.all(KSizes.margin2x),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      MdiIcons.cameraPlus,
                      color: AppColors.warning,
                      size: KSizes.iconS,
                    ),
                  ),
                ),
              ],
            ),
            
            if (pendingState.isLoadingPendingFoods) ...[
              const SizedBox(height: KSizes.margin4x),
              _buildLoadingState(),
            ] else if (pendingState.hasPendingFoodsError) ...[
              const SizedBox(height: KSizes.margin4x),
              _buildErrorState(context, pendingCubit),
            ] else if (pendingState.hasPendingFoods) ...[
              const SizedBox(height: KSizes.margin4x),
              _buildPendingFoodsList(context, ref, pendingState.pendingFoods),
            ] else ...[
              // Show a helpful message when no pending foods
              const SizedBox(height: KSizes.margin3x),
              _buildEmptyState(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KSizes.margin4x),
        child: CircularProgressIndicator(
          color: AppColors.warning,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, PendingFoodCubit cubit) {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            MdiIcons.alertCircle,
            color: AppColors.error,
            size: KSizes.iconS,
          ),
          const SizedBox(width: KSizes.margin2x),
          Expanded(
            child: Text(
              'Kunne ikke indlæse afventende billeder',
              style: TextStyle(
                color: AppColors.error,
                fontSize: KSizes.fontSizeS,
              ),
            ),
          ),
          TextButton(
            onPressed: cubit.retryLoadPendingFoods,
            child: Text(
              'Prøv igen',
              style: TextStyle(
                color: AppColors.error,
                fontSize: KSizes.fontSizeS,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingFoodsList(BuildContext context, WidgetRef ref, List<PendingFoodModel> pendingFoods) {
    return Column(
      children: pendingFoods.take(3).map((food) => 
        _buildPendingFoodCard(context, ref, food)
      ).toList(),
    );
  }

  Widget _buildPendingFoodCard(BuildContext context, WidgetRef ref, PendingFoodModel food) {
    return Container(
      margin: const EdgeInsets.only(bottom: KSizes.margin2x),
      padding: const EdgeInsets.all(KSizes.margin3x),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Image placeholder with image count indicator
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                  border: Border.all(
                    color: AppColors.border.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: food.hasValidImage && !food.primaryImagePath.startsWith('mock_')
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(KSizes.radiusS),
                        child: Image.file(
                          File(food.primaryImagePath),
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              MdiIcons.imageOff,
                              color: AppColors.textSecondary,
                              size: KSizes.iconM,
                            );
                          },
                        ),
                      )
                    : Icon(
                        MdiIcons.image,
                        color: AppColors.textSecondary,
                        size: KSizes.iconM,
                      ),
              ),
              
              // Image count indicator
              if (food.imageCount > 1)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.warning,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '${food.imageCount}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: KSizes.margin3x),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  food.imageCount > 1 ? 'Måltid (${food.imageCount} billeder)' : 'Mad-billede',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightMedium,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  food.displayTime,
                  style: TextStyle(
                    fontSize: KSizes.fontSizeS,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          // Categorize button
          ElevatedButton(
            onPressed: () => _categorizeFood(context, ref, food),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: KSizes.margin3x,
                vertical: KSizes.margin2x,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusM),
              ),
            ),
            child: Text(
              'Kategoriser',
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                fontWeight: KSizes.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _captureFood(BuildContext context, WidgetRef ref) async {
    final cubit = ref.read(pendingFoodProvider.notifier);
    
    try {
      await cubit.captureFood();
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Billede taget! Kategoriser det når du er klar.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke tage billede'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _categorizeFood(BuildContext context, WidgetRef ref, PendingFoodModel food) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategorizeFoodPage(pendingFood: food),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(KSizes.margin4x),
      child: Column(
        children: [
          Icon(
            MdiIcons.cameraOutline,
            size: KSizes.iconXL,
            color: AppColors.warning,
          ),
          const SizedBox(height: KSizes.margin2x),
          Text(
            'Ingen afventende billeder',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KSizes.margin1x),
          Text(
            'Tag et billede af din mad og kategoriser det senere når du har tid',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 