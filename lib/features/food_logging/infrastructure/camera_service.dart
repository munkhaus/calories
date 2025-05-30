import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:result_type/result_type.dart';

/// Errors that can occur during camera operations
enum CameraError {
  permissionDenied,
  cameraNotAvailable,
  imageSaveFailed,
  userCancelled,
  unknown,
}

/// Service for handling camera operations
class CameraService {
  static final ImagePicker _picker = ImagePicker();

  /// Capture photo from camera
  static Future<Result<String, CameraError>> capturePhoto() async {
    try {
      // Pick image from camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80, // Reduce quality to save storage
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        // User cancelled
        return Failure(CameraError.userCancelled);
      }

      // Save image to app directory
      final savedPath = await _saveImageToAppDirectory(image);
      if (savedPath == null) {
        return Failure(CameraError.imageSaveFailed);
      }

      return Success(savedPath);
    } catch (e) {
      if (e.toString().contains('permission')) {
        return Failure(CameraError.permissionDenied);
      } else if (e.toString().contains('camera')) {
        return Failure(CameraError.cameraNotAvailable);
      }
      return Failure(CameraError.unknown);
    }
  }

  /// Pick image from gallery as alternative
  static Future<Result<String, CameraError>> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image == null) {
        return Failure(CameraError.userCancelled);
      }

      // Save image to app directory
      final savedPath = await _saveImageToAppDirectory(image);
      if (savedPath == null) {
        return Failure(CameraError.imageSaveFailed);
      }

      return Success(savedPath);
    } catch (e) {
      return Failure(CameraError.unknown);
    }
  }

  /// Save image to app's documents directory
  static Future<String?> _saveImageToAppDirectory(XFile image) async {
    try {
      // Get app documents directory
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String appDocPath = appDocDir.path;
      
      // Create food_images directory if it doesn't exist
      final Directory foodImagesDir = Directory('$appDocPath/food_images');
      if (!await foodImagesDir.exists()) {
        await foodImagesDir.create(recursive: true);
      }

      // Generate unique filename with timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'food_$timestamp.jpg';
      final String filePath = '${foodImagesDir.path}/$fileName';

      // Copy image to new location
      final File savedImage = await File(image.path).copy(filePath);
      
      return savedImage.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  /// Delete image file
  static Future<bool> deleteImage(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        await imageFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Check if image file exists
  static Future<bool> imageExists(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      return await imageFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get image file size in bytes
  static Future<int?> getImageSize(String imagePath) async {
    try {
      final File imageFile = File(imagePath);
      if (await imageFile.exists()) {
        return await imageFile.length();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
} 