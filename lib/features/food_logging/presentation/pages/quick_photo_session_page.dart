import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../infrastructure/camera_service.dart';
import '../../infrastructure/gemini_service.dart';
import '../../application/pending_food_cubit.dart';
import '../../domain/pending_food_model.dart';
import '../../infrastructure/pending_food_service.dart';
import '../../presentation/pages/categorize_food_page.dart';
import '../../../dashboard/presentation/dashboard_page.dart';

/// Page for quick photo session - starts immediately with camera capture
/// Allows multiple photos of the same meal element
class QuickPhotoSessionPage extends ConsumerStatefulWidget {
  const QuickPhotoSessionPage({super.key});

  @override
  ConsumerState<QuickPhotoSessionPage> createState() => _QuickPhotoSessionPageState();
}

class _QuickPhotoSessionPageState extends ConsumerState<QuickPhotoSessionPage> {
  final List<String> _capturedImages = [];
  bool _isCapturing = false;
  bool _hasStartedCapture = false;

  @override
  void initState() {
    super.initState();
    // Start with immediate camera capture
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureFirstImage();
    });
  }

  Future<void> _captureFirstImage() async {
    if (_hasStartedCapture && _capturedImages.isNotEmpty) {
      // Only skip if we have actually captured images
      return;
    }
    _hasStartedCapture = true;
    
    setState(() {
      _isCapturing = true;
    });

    try {
      final result = await CameraService.capturePhoto();
      
      if (result.isSuccess && mounted) {
        setState(() {
          _capturedImages.add(result.success);
          _isCapturing = false;
        });
      } else if (mounted) {
        // User cancelled or error - go back
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        _showError('Kunne ikke tage billede: $e');
      }
    }
  }

  Future<void> _captureAdditionalImage() async {
    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      final result = await CameraService.capturePhoto();
      
      if (result.isSuccess && mounted) {
        setState(() {
          _capturedImages.add(result.success);
          _isCapturing = false;
        });
      } else if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
        _showError('Kunne ikke tage billede: $e');
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hurtig Billeder (${_capturedImages.length})'),
        backgroundColor: AppColors.warning,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _isCapturing && _capturedImages.isEmpty
                ? _buildLoadingView()
                : _buildPhotoGridView(),
          ),
          
          // Bottom action area with 2 prominent buttons - MODERN DESIGN
          if (_capturedImages.isNotEmpty)
            Container(
              padding: EdgeInsets.all(KSizes.margin6x),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(KSizes.radiusXL),
                  topRight: Radius.circular(KSizes.radiusXL),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Modern instructions - SIMPLIFIED
                  Container(
                    padding: EdgeInsets.all(KSizes.margin3x),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusL),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          MdiIcons.informationOutline,
                          color: AppColors.primary,
                          size: KSizes.iconS,
                        ),
                        SizedBox(width: KSizes.margin2x),
                        Expanded(
                          child: Text(
                            '${_capturedImages.length} billede${_capturedImages.length == 1 ? '' : 'r'} af samme måltid',
                            style: TextStyle(
                              fontSize: KSizes.fontSizeM,
                              fontWeight: KSizes.fontWeightSemiBold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: KSizes.margin6x),
                  
                  // Single "Færdig" button - Always go to categorization
                  Container(
                    width: double.infinity,
                    height: 80,
                    child: ElevatedButton.icon(
                      onPressed: _goDirectToCategorizeFoods,
                      icon: Icon(
                        MdiIcons.check,
                        size: KSizes.iconL,
                      ),
                      label: Text(
                        'Færdig',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeXL,
                          fontWeight: KSizes.fontWeightBold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusL),
                        ),
                        padding: EdgeInsets.all(KSizes.margin4x),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: KSizes.margin4x),
                  
                  // Add more photos button - LARGER AND MORE PROMINENT
                  Container(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _isCapturing ? null : _captureAdditionalImage,
                      icon: Icon(
                        _isCapturing ? MdiIcons.loading : MdiIcons.cameraPlus,
                        size: KSizes.iconM,
                      ),
                      label: Text(
                        _isCapturing ? 'Tager billede...' : 'Tag endnu et billede',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeL,
                          fontWeight: KSizes.fontWeightBold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.info.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(KSizes.radiusL),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: KSizes.margin6x,
                          vertical: KSizes.margin4x,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ),
          SizedBox(height: KSizes.margin4x),
          Text(
            'Tager første billede...',
            style: TextStyle(
              fontSize: KSizes.fontSizeL,
              fontWeight: KSizes.fontWeightBold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: KSizes.margin2x),
          Text(
            'Kameraet åbnes automatisk',
            style: TextStyle(
              fontSize: KSizes.fontSizeM,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGridView() {
    if (_capturedImages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              MdiIcons.cameraOff,
              size: 80,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            SizedBox(height: KSizes.margin4x),
            Text(
              'Ingen billeder taget endnu',
              style: TextStyle(
                fontSize: KSizes.fontSizeL,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: KSizes.margin4x),
            ElevatedButton.icon(
              onPressed: _isCapturing ? null : _captureFirstImage,
              icon: Icon(_isCapturing ? MdiIcons.loading : MdiIcons.camera),
              label: Text(_isCapturing ? 'Tager billede...' : 'Tag første billede'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.warning,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(KSizes.margin4x),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [          
          // Photo grid - REMOVED DUPLICATE HEADER INFO
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: KSizes.margin2x,
                mainAxisSpacing: KSizes.margin2x,
                childAspectRatio: 1.0,
              ),
              itemCount: _capturedImages.length + (_isCapturing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index < _capturedImages.length) {
                  return _buildPhotoCard(_capturedImages[index], index + 1);
                } else {
                  return _buildCapturingCard();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(String imagePath, int number) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
      ),
      child: Stack(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(KSizes.radiusM),
            child: File(imagePath).existsSync()
                ? Image.file(
                    File(imagePath),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: AppColors.surface,
                    child: Icon(
                      MdiIcons.imageOff,
                      color: AppColors.textSecondary,
                      size: KSizes.iconL,
                    ),
                  ),
          ),
          
          // Number badge
          Positioned(
            top: KSizes.margin2x,
            left: KSizes.margin2x,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: KSizes.fontSizeM,
                    fontWeight: KSizes.fontWeightBold,
                  ),
                ),
              ),
            ),
          ),
          
          // Remove button
          Positioned(
            top: KSizes.margin2x,
            right: KSizes.margin2x,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _capturedImages.removeAt(number - 1);
                  // Reset hasStartedCapture if no images left so first capture can work again
                  if (_capturedImages.isEmpty) {
                    _hasStartedCapture = false;
                  }
                });
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  MdiIcons.close,
                  color: Colors.white,
                  size: KSizes.iconS,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapturingCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KSizes.radiusM),
        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
        color: AppColors.warning.withOpacity(0.1),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
              ),
            ),
            SizedBox(height: KSizes.margin2x),
            Text(
              'Tager billede...',
              style: TextStyle(
                fontSize: KSizes.fontSizeS,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _goDirectToCategorizeFoods() async {
    if (_capturedImages.isEmpty) {
      _showError('Ingen billeder at kategorisere');
      return;
    }

    try {
      // Create new pending food element with multiple images
      final newPendingFood = PendingFoodModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        imagePaths: List.from(_capturedImages), // Copy the list
        capturedAt: DateTime.now(),
        notes: 'Hurtig kategorisering (${_capturedImages.length} billeder)',
        isProcessed: false,
      );

      // Start AI analysis before navigation
      final geminiService = GeminiService();
      FoodAnalysisResult? analysisResult;
      
      if (mounted) {
        // Show loading indicator during AI analysis
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: KSizes.margin3x),
                Text('Analyserer billeder med AI...'),
              ],
            ),
            backgroundColor: AppColors.info,
            duration: Duration(seconds: 3),
          ),
        );
      }

      try {
        print('🤖 QuickPhotoSession: Starting AI analysis for categorization with ${_capturedImages.length} images');
        if (_capturedImages.length > 1) {
          final result = await geminiService.analyzeMultipleFoodImages(_capturedImages);
          if (result.isSuccess) {
            analysisResult = result.success;
            print('🤖 QuickPhotoSession: Multi-image analysis completed for categorization: ${analysisResult.foodName}');
          }
        } else {
          final result = await geminiService.analyzeFoodImage(_capturedImages.first);
          if (result.isSuccess) {
            analysisResult = result.success;
            print('🤖 QuickPhotoSession: Single image analysis completed for categorization: ${analysisResult.foodName}');
          }
        }
      } catch (e) {
        print('🤖 QuickPhotoSession: AI analysis failed for categorization: $e');
        // Continue without AI analysis
      }

      if (mounted) {
        // Hide loading indicator
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        // Create pending food with AI results if available
        final pendingFoodWithAI = analysisResult != null 
            ? newPendingFood.copyWith(aiResult: analysisResult)
            : newPendingFood;

        // Navigate directly to categorization
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CategorizeFoodPage(
              pendingFood: pendingFoodWithAI,
              fromQuickPhoto: true,
            ),
          ),
        );
        
        // Handle different results from categorization
        if (result == true && mounted) {
          // User successfully categorized - go back to dashboard
          Navigator.of(context).pop();
        } else if (result == 'saved_for_later' && mounted) {
          // User saved for later - also go back to dashboard
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showError('Fejl ved kategorisering: $e');
      }
    }
  }
} 