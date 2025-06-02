import 'dart:io';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
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
  QRViewController? _controller;
  final GlobalKey _qrKey = GlobalKey(debugLabel: 'QR');
  bool _isProcessing = false;
  String? _errorMessage;
  bool _flashOn = false;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      _controller?.pauseCamera();
    } else if (Platform.isIOS) {
      _controller?.resumeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppDesign.backgroundGradient,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(KSizes.margin4x),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onClose,
                  icon: Icon(
                    MdiIcons.close,
                    color: AppColors.textPrimary,
                    size: KSizes.iconM,
                  ),
                ),
                Expanded(
                  child: Text(
                    'Scan stregkode',
                    style: TextStyle(
                      fontSize: KSizes.fontSizeXL,
                      fontWeight: KSizes.fontWeightBold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton(
                  onPressed: _toggleFlash,
                  icon: Icon(
                    _flashOn ? MdiIcons.flashlight : MdiIcons.flashlightOff,
                    color: AppColors.textPrimary,
                    size: KSizes.iconM,
                  ),
                ),
              ],
            ),
          ),
          
          // Scanner area
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                QRView(
                  key: _qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: AppColors.primary,
                    borderRadius: KSizes.radiusL,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: MediaQuery.of(context).size.width * 0.8,
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
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(KSizes.margin4x),
              child: Column(
                children: [
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
                  TextButton.icon(
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });

    controller.scannedDataStream.listen((scanData) {
      if (!_isProcessing && scanData.code != null) {
        _processBarcode(scanData.code!);
      }
    });
  }

  void _toggleFlash() async {
    if (_controller != null) {
      await _controller!.toggleFlash();
      setState(() {
        _flashOn = !_flashOn;
      });
    }
  }

  Future<void> _processBarcode(String barcode) async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      final result = await BarcodeFoodService.fetchFoodFromBarcode(barcode);
      
      if (result.isSuccess) {
        widget.onFoodFound(result.success);
      } else {
        setState(() {
          _errorMessage = result.failure.message;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Uventet fejl: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
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