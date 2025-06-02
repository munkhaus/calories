import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/k_sizes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../infrastructure/barcode_food_service.dart';
import '../../domain/favorite_food_model.dart';

/// Widget for scanning barcodes and fetching food data
class BarcodeScannerWidget extends StatefulWidget {
  final Function(FavoriteFoodModel) onFoodFound;
  final VoidCallback? onClose;

  const BarcodeScannerWidget({
    super.key,
    required this.onFoodFound,
    this.onClose,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  bool _hasFoundBarcode = false;
  String? _errorMessage;
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    // Ensure scanner is stopped before disposal
    _controller?.stop();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Scan stregkode',
          style: TextStyle(
            fontSize: KSizes.fontSizeL,
            fontWeight: KSizes.fontWeightBold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: widget.onClose,
          icon: Icon(
            MdiIcons.close,
            color: Colors.white,
            size: KSizes.iconL,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              _flashOn ? MdiIcons.flashlight : MdiIcons.flashlightOff,
              color: Colors.white,
              size: KSizes.iconL,
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Scanner area
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      if (!_isProcessing && !_hasFoundBarcode && barcode.rawValue != null) {
                        _processBarcode(barcode.rawValue!);
                        break;
                      }
                    }
                  },
                ),
                
                // Scanner overlay with cutout
                ClipPath(
                  clipper: ScannerOverlayClipper(
                    cutOutSize: MediaQuery.of(context).size.width * 0.8,
                  ),
                  child: Container(
                    color: Colors.black.withOpacity(0.6),
                  ),
                ),
                
                // Scanner border
                Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.primary,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(KSizes.radiusL),
                    ),
                  ),
                ),
                
                // Processing overlay
                if (_isProcessing)
                  Container(
                    color: Colors.black.withOpacity(0.7),
                    child: Center(
                      child: Container(
                        padding: EdgeInsets.all(KSizes.margin6x),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(KSizes.radiusL),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                            SizedBox(height: KSizes.margin4x),
                            Text(
                              'Henter produktdata...',
                              style: TextStyle(
                                fontSize: KSizes.fontSizeL,
                                fontWeight: KSizes.fontWeightMedium,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Instructions and error message
          Container(
            padding: EdgeInsets.all(KSizes.margin4x),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(KSizes.radiusXL),
                topRight: Radius.circular(KSizes.radiusXL),
              ),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.only(bottom: KSizes.margin4x),
                  decoration: BoxDecoration(
                    color: AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                if (_errorMessage != null) ...[
                  Container(
                    padding: EdgeInsets.all(KSizes.margin4x),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(KSizes.radiusM),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          MdiIcons.alertCircle,
                          color: AppColors.error,
                          size: KSizes.iconM,
                        ),
                        SizedBox(width: KSizes.margin3x),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: KSizes.fontSizeM,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: KSizes.margin4x),
                ],
                
                // Instructions
                Container(
                  padding: EdgeInsets.all(KSizes.margin4x),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(KSizes.radiusM),
                    border: Border.all(
                      color: AppColors.info.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            MdiIcons.barcodeScan,
                            color: AppColors.info,
                            size: KSizes.iconM,
                          ),
                          SizedBox(width: KSizes.margin3x),
                          Expanded(
                            child: Text(
                              'Placer stregkoden i rammen',
                              style: TextStyle(
                                fontSize: KSizes.fontSizeL,
                                fontWeight: KSizes.fontWeightMedium,
                                color: AppColors.info,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: KSizes.margin2x),
                      Text(
                        'Vi henter automatisk ernæringsdata fra Open Food Facts database når stregkoden scannes.',
                        style: TextStyle(
                          fontSize: KSizes.fontSizeM,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Manual input option
                OutlinedButton.icon(
                  onPressed: _showManualBarcodeInput,
                  icon: Icon(
                    MdiIcons.keyboard,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    'Indtast stregkode manuelt',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: KSizes.fontSizeM,
                      fontWeight: KSizes.fontWeightMedium,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      horizontal: KSizes.margin6x,
                      vertical: KSizes.margin3x,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KSizes.radiusL),
                    ),
                    side: BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
                
                SizedBox(height: KSizes.margin4x),
                
                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.onClose,
                    icon: Icon(MdiIcons.close, size: KSizes.iconM),
                    label: Text(
                      'Annuller',
                      style: TextStyle(
                        fontSize: KSizes.fontSizeL,
                        fontWeight: KSizes.fontWeightMedium,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.textSecondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.all(KSizes.margin4x),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KSizes.radiusL),
                      ),
                    ),
                  ),
                ),
                
                // Safe area padding at bottom
                SizedBox(height: MediaQuery.of(context).padding.bottom + KSizes.margin2x),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFlash() async {
    if (_controller != null) {
      await _controller!.toggleTorch();
      if (mounted) {
        setState(() {
          _flashOn = !_flashOn;
        });
      }
    }
  }

  Future<void> _processBarcode(String barcode) async {
    if (_isProcessing || _hasFoundBarcode) return;

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _hasFoundBarcode = true; // Set this immediately to prevent multiple calls
        _errorMessage = null;
      });
    }

    try {
      // Stop the scanner immediately
      await _controller?.stop();
      
      final result = await BarcodeFoodService.fetchFoodFromBarcode(barcode);
      
      if (result.isSuccess) {
        // Call the callback after stopping scanner
        widget.onFoodFound(result.success);
      } else {
        // Reset if there was an error so user can try again
        if (mounted) {
          setState(() {
            _hasFoundBarcode = false;
            _errorMessage = result.failure.message;
          });
          // Restart scanner for retry
          await _controller?.start();
        }
      }
    } catch (e) {
      // Reset on error so user can try again
      if (mounted) {
        setState(() {
          _hasFoundBarcode = false;
          _errorMessage = 'Uventet fejl: $e';
        });
        // Restart scanner for retry
        await _controller?.start();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _showManualBarcodeInput() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Indtast stregkode'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'fx. 3017624010701',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuller'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (controller.text.isNotEmpty) {
                _processBarcode(controller.text.trim());
              }
            },
            child: Text('Scan'),
          ),
        ],
      ),
    );
  }
}

/// Custom clipper to create a cutout in the scanner overlay
class ScannerOverlayClipper extends CustomClipper<Path> {
  final double cutOutSize;
  
  ScannerOverlayClipper({required this.cutOutSize});
  
  @override
  Path getClip(Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    
    final cutOutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );
    
    path.addRRect(RRect.fromRectAndRadius(
      cutOutRect, 
      Radius.circular(20),
    ));
    
    return path..fillType = PathFillType.evenOdd;
  }
  
  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
} 