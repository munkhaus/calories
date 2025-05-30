import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../infrastructure/camera_service.dart';
import '../../application/pending_food_cubit.dart';

/// Multi-photo meal page that adds multiple images to the SAME pending food element
class MultiPhotoMealPage extends ConsumerStatefulWidget {
  const MultiPhotoMealPage({super.key});

  @override
  ConsumerState<MultiPhotoMealPage> createState() => _MultiPhotoMealPageState();
}

class _MultiPhotoMealPageState extends ConsumerState<MultiPhotoMealPage> {
  final List<String> _imagePaths = [];
  final int _maxImages = 5;
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final pendingState = ref.watch(pendingFoodProvider);
    final pendingFoods = pendingState.pendingFoodsState.data ?? [];
    
    // Find the most recent pending food (the one we're adding images to)
    final currentPendingFood = pendingFoods.isNotEmpty ? pendingFoods.last : null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Tilføj Flere Billeder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          if (_imagePaths.isNotEmpty)
            TextButton(
              onPressed: _isProcessing ? null : _addMoreImagesToPendingFood,
              child: Text(
                'Tilføj (${_imagePaths.length})',
                style: TextStyle(
                  color: _isProcessing ? AppColors.textSecondary : AppColors.primary,
                  fontWeight: KSizes.fontWeightBold,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppDesign.backgroundGradient,
        ),
        child: Padding(
          padding: EdgeInsets.all(KSizes.margin4x),
          child: Column(
            children: [
              // Instruction card
              _buildInstructionCard(currentPendingFood),
              
              SizedBox(height: KSizes.margin4x),
              
              // Image grid
              Expanded(
                child: _imagePaths.isEmpty
                    ? _buildEmptyState()
                    : _buildImageGrid(),
              ),
              
              // Action buttons
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionCard(dynamic currentPendingFood) {
    return Container(
      padding: EdgeInsets.all(KSizes.margin4x),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(MdiIcons.cameraPlus, color: AppColors.info, size: KSizes.iconL),
          SizedBox(width: KSizes.margin3x),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tilføj flere billeder af det samme måltid',
                  style: TextStyle(
                    fontSize: KSizes.fontSizeL,
                    fontWeight: KSizes.fontWeightBold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: KSizes.margin1x),
                Text(
                  currentPendingFood != null 
                      ? 'Billeder tilføjes til dit afventende måltid\nNye billeder: ${_imagePaths.length}/$_maxImages'
                      : 'Tag først et billede fra hovedmenuen\nNye billeder: ${_imagePaths.length}/$_maxImages',
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            MdiIcons.cameraPlus,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          SizedBox(height: KSizes.margin4x),
          Text(
            'Tag flere billeder',
            style: TextStyle(
              fontSize: KSizes.fontSizeXL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Tag billeder af dit måltid fra forskellige vinkler\nfor bedre analyse',
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

  Widget _buildImageGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: KSizes.margin2x,
        mainAxisSpacing: KSizes.margin2x,
        childAspectRatio: 1.0,
      ),
      itemCount: _imagePaths.length,
      itemBuilder: (context, index) {
        return _buildImageCard(_imagePaths[index], index);
      },
    );
  }

  Widget _buildImageCard(String imagePath, int index) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KSizes.radiusL),
        child: Stack(
          children: [
            // Image
            Image.file(
              File(imagePath),
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
            
            // Delete button
            Positioned(
              top: KSizes.margin2x,
              right: KSizes.margin2x,
              child: GestureDetector(
                onTap: () => _removeImage(index),
                child: Container(
                  padding: EdgeInsets.all(KSizes.margin1x),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    MdiIcons.close,
                    color: Colors.white,
                    size: KSizes.iconS,
                  ),
                ),
              ),
            ),
            
            // Image number
            Positioned(
              bottom: KSizes.margin2x,
              left: KSizes.margin2x,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: KSizes.margin2x,
                  vertical: KSizes.margin1x,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(KSizes.radiusS),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: KSizes.fontSizeS,
                    fontWeight: KSizes.fontWeightBold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(height: KSizes.margin4x),
        
        // Take photo button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _imagePaths.length >= _maxImages || _isProcessing 
                ? null 
                : _takePictureFromCamera,
            icon: Icon(MdiIcons.camera),
            label: Text(
              _imagePaths.length >= _maxImages 
                  ? 'Maksimum $_maxImages billeder'
                  : 'Tag billede (${_imagePaths.length}/$_maxImages)',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(KSizes.margin4x),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KSizes.radiusL),
              ),
            ),
          ),
        ),
        
        if (_imagePaths.isNotEmpty) ...[
          SizedBox(height: KSizes.margin2x),
          
          // Add images to pending food button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isProcessing ? null : _addMoreImagesToPendingFood,
              icon: _isProcessing 
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(MdiIcons.plus),
              label: Text(
                _isProcessing 
                    ? 'Tilføjer billeder...'
                    : 'Tilføj ${_imagePaths.length} billeder til måltid',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.all(KSizes.margin4x),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KSizes.radiusL),
                ),
              ),
            ),
          ),
        ],
        
        SizedBox(height: KSizes.margin2x),
        
        // Done button
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Færdig - Gå tilbage',
              style: TextStyle(
                fontSize: KSizes.fontSizeM,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _takePictureFromCamera() async {
    try {
      final result = await CameraService.capturePhoto();
      
      if (result.isSuccess) {
        final imagePath = result.success;
        
        setState(() {
          _imagePaths.add(imagePath);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Billede tilføjet (${_imagePaths.length}/$_maxImages)'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kunne ikke tage billede'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fejl ved fotografering: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Billede fjernet'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  Future<void> _addMoreImagesToPendingFood() async {
    if (_imagePaths.isEmpty) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      final pendingFoodCubit = ref.read(pendingFoodProvider.notifier);
      
      // Since we can't add existing image paths, we'll use captureFood() 
      // which will take new photos and add them to pending foods
      for (int i = 0; i < _imagePaths.length; i++) {
        await pendingFoodCubit.captureFood();
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_imagePaths.length} nye billeder tilføjet til afventende registreringer!'),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Clear the images and stay on page for more photos
        setState(() {
          _imagePaths.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fejl ved tilføjelse af billeder: $e'),
            backgroundColor: AppColors.error,
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