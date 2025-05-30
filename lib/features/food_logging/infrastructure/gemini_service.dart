import 'dart:io';
import 'dart:typed_data';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:result_type/result_type.dart';

/// Error types for Gemini operations
enum GeminiError {
  invalidApiKey,
  networkError,
  imageProcessingError,
  parseError,
  quotaExceeded,
  unknown,
}

/// Model for food analysis result
class FoodAnalysisResult {
  final String foodName;
  final String description;
  final String portionSize;
  final int estimatedCalories;
  final double confidence; // 0-1 scale

  const FoodAnalysisResult({
    required this.foodName,
    required this.description,
    required this.portionSize,
    required this.estimatedCalories,
    required this.confidence,
  });
}

/// Service for analyzing food images using Google Gemini
class GeminiService {
  static const String _apiKey = 'AIzaSyA0A1vDv1t4tZ_5uAFBzqRns9PdrTTp-fQ'; // Real API key
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
    );
  }

  /// Analyze food image and extract information
  Future<Result<FoodAnalysisResult, GeminiError>> analyzeFoodImage(String imagePath) async {
    print('🤖 GeminiService: Starting analyzeFoodImage');
    print('🤖 GeminiService: Image path: $imagePath');
    print('🤖 GeminiService: API key: ${_apiKey.substring(0, 10)}...');
    
    try {
      // Read image file
      print('🤖 GeminiService: Reading image file...');
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        print('🤖 GeminiService: Image file does not exist!');
        return Failure(GeminiError.imageProcessingError);
      }

      final imageBytes = await imageFile.readAsBytes();
      print('🤖 GeminiService: Image file read successfully, size: ${imageBytes.length} bytes');
      
      // Create prompt for food analysis
      final prompt = '''
Analyser dette billede af mad og giv følgende information på dansk:

1. Navn på maden/retten
2. Kort beskrivelse af hvad der er på billedet
3. Estimeret portion størrelse (f.eks. "1 mellem pizza", "200g pasta", "1 kop kaffe")
4. Estimeret kalorier for hele portionen
5. Konfidensniveau (0-100) for hvor sikker du er

Formater svaret som JSON:
{
  "foodName": "navn på maden",
  "description": "beskrivelse af hvad der ses",
  "portionSize": "estimeret størrelse",
  "estimatedCalories": antal_kalorier_som_nummer,
  "confidence": konfidens_som_nummer_mellem_0_og_100
}

Hvis billedet ikke viser mad, sæt confidence til 0.
''';

      print('🤖 GeminiService: Prompt created, length: ${prompt.length} characters');

      // Create content with image and text
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      print('🤖 GeminiService: Content created, calling Gemini API...');

      // Generate response
      final response = await _model.generateContent(content);
      
      print('🤖 GeminiService: API call completed');
      print('🤖 GeminiService: Response text length: ${response.text?.length ?? 0}');
      print('🤖 GeminiService: Raw response: ${response.text}');
      
      if (response.text == null || response.text!.isEmpty) {
        print('🤖 GeminiService: Empty response from API');
        return Failure(GeminiError.parseError);
      }

      // Parse JSON response
      print('🤖 GeminiService: Parsing response...');
      final result = _parseGeminiResponse(response.text!);
      
      if (result.isSuccess) {
        print('🤖 GeminiService: Parsing successful');
        final analysis = result.success;
        print('🤖 GeminiService: Food: ${analysis.foodName}');
        print('🤖 GeminiService: Calories: ${analysis.estimatedCalories}');
        print('🤖 GeminiService: Confidence: ${analysis.confidence}');
      } else {
        print('🤖 GeminiService: Parsing failed: ${result.failure}');
      }
      
      return result;

    } catch (e) {
      print('🤖 GeminiService: Exception caught: $e');
      print('🤖 GeminiService: Exception type: ${e.runtimeType}');
      print('🤖 GeminiService: Stack trace: ${StackTrace.current}');
      
      if (e.toString().contains('API_KEY')) {
        print('🤖 GeminiService: API key error detected');
        return Failure(GeminiError.invalidApiKey);
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        print('🤖 GeminiService: Network error detected');
        return Failure(GeminiError.networkError);
      } else if (e.toString().contains('quota')) {
        print('🤖 GeminiService: Quota error detected');
        return Failure(GeminiError.quotaExceeded);
      }
      print('🤖 GeminiService: Unknown error detected');
      return Failure(GeminiError.unknown);
    }
  }

  /// Parse Gemini JSON response into FoodAnalysisResult
  Result<FoodAnalysisResult, GeminiError> _parseGeminiResponse(String response) {
    print('🤖 GeminiService: _parseGeminiResponse called');
    print('🤖 GeminiService: Raw response length: ${response.length}');
    print('🤖 GeminiService: First 200 chars: ${response.length > 200 ? response.substring(0, 200) : response}');
    
    try {
      // Clean response (remove markdown code blocks if present)
      String cleanResponse = response.trim();
      print('🤖 GeminiService: After trim: ${cleanResponse.substring(0, cleanResponse.length > 100 ? 100 : cleanResponse.length)}...');
      
      if (cleanResponse.startsWith('```json')) {
        cleanResponse = cleanResponse.substring(7);
        print('🤖 GeminiService: Removed ```json prefix');
      }
      if (cleanResponse.endsWith('```')) {
        cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
        print('🤖 GeminiService: Removed ``` suffix');
      }
      cleanResponse = cleanResponse.trim();
      print('🤖 GeminiService: Final clean response: $cleanResponse');

      // Parse JSON manually for now (could use json_annotation later)
      final lines = cleanResponse.split('\n');
      print('🤖 GeminiService: Split into ${lines.length} lines');
      
      String foodName = '';
      String description = '';
      String portionSize = '';
      int estimatedCalories = 0;
      double confidence = 0.0;

      for (int i = 0; i < lines.length; i++) {
        String line = lines[i].trim();
        print('🤖 GeminiService: Processing line $i: $line');
        
        if (line.contains('"foodName":')) {
          foodName = _extractStringValue(line);
          print('🤖 GeminiService: Extracted foodName: $foodName');
        } else if (line.contains('"description":')) {
          description = _extractStringValue(line);
          print('🤖 GeminiService: Extracted description: $description');
        } else if (line.contains('"portionSize":')) {
          portionSize = _extractStringValue(line);
          print('🤖 GeminiService: Extracted portionSize: $portionSize');
        } else if (line.contains('"estimatedCalories":')) {
          estimatedCalories = _extractNumberValue(line);
          print('🤖 GeminiService: Extracted estimatedCalories: $estimatedCalories');
        } else if (line.contains('"confidence":')) {
          confidence = _extractNumberValue(line).toDouble() / 100.0; // Convert to 0-1 scale
          print('🤖 GeminiService: Extracted confidence: $confidence');
        }
      }

      print('🤖 GeminiService: Final extracted values:');
      print('🤖 GeminiService: - foodName: "$foodName"');
      print('🤖 GeminiService: - description: "$description"');
      print('🤖 GeminiService: - portionSize: "$portionSize"');
      print('🤖 GeminiService: - estimatedCalories: $estimatedCalories');
      print('🤖 GeminiService: - confidence: $confidence');

      // Validate required fields
      if (foodName.isEmpty || description.isEmpty) {
        print('🤖 GeminiService: Validation failed - missing required fields');
        return Failure(GeminiError.parseError);
      }

      print('🤖 GeminiService: Validation passed, creating result');
      return Success(FoodAnalysisResult(
        foodName: foodName,
        description: description,
        portionSize: portionSize.isNotEmpty ? portionSize : 'Ukendt størrelse',
        estimatedCalories: estimatedCalories,
        confidence: confidence.clamp(0.0, 1.0),
      ));

    } catch (e) {
      print('🤖 GeminiService: Parse exception: $e');
      print('🤖 GeminiService: Parse exception type: ${e.runtimeType}');
      return Failure(GeminiError.parseError);
    }
  }

  /// Extract string value from JSON line
  String _extractStringValue(String line) {
    print('🤖 GeminiService: _extractStringValue input: $line');
    
    final colonIndex = line.indexOf(':');
    if (colonIndex == -1) {
      print('🤖 GeminiService: No colon found in line');
      return '';
    }
    
    String value = line.substring(colonIndex + 1).trim();
    print('🤖 GeminiService: After colon extraction: $value');
    
    // Remove quotes and comma
    value = value.replaceAll('"', '').replaceAll(',', '').trim();
    print('🤖 GeminiService: Final string value: $value');
    
    return value;
  }

  /// Extract number value from JSON line
  int _extractNumberValue(String line) {
    print('🤖 GeminiService: _extractNumberValue input: $line');
    
    final colonIndex = line.indexOf(':');
    if (colonIndex == -1) {
      print('🤖 GeminiService: No colon found in line');
      return 0;
    }
    
    String value = line.substring(colonIndex + 1).trim();
    print('🤖 GeminiService: After colon extraction: $value');
    
    // Remove comma and parse
    value = value.replaceAll(',', '').trim();
    print('🤖 GeminiService: Cleaned number string: $value');
    
    final parsed = int.tryParse(value) ?? 0;
    print('🤖 GeminiService: Parsed number: $parsed');
    
    return parsed;
  }

  /// Mock analysis for testing when API key is not available
  Future<Result<FoodAnalysisResult, GeminiError>> mockAnalyzeFoodImage(String imagePath) async {
    print('🤖 GeminiService: mockAnalyzeFoodImage called');
    print('🤖 GeminiService: Mock image path: $imagePath');
    
    // Simulate network delay
    print('🤖 GeminiService: Simulating 2 second delay...');
    await Future.delayed(const Duration(seconds: 2));
    
    // Return mock data based on filename or random
    print('🤖 GeminiService: Returning mock data');
    return Success(FoodAnalysisResult(
      foodName: 'Pasta Bolognese',
      description: 'En portion pasta med kødbaseret tomatsauce, pyntet med parmesan',
      portionSize: 'Ca. 300g pasta med sauce',
      estimatedCalories: 650,
      confidence: 0.85,
    ));
  }

  /// Analyze multiple food images of the same meal and extract comprehensive information
  Future<Result<FoodAnalysisResult, GeminiError>> analyzeMultipleFoodImages(List<String> imagePaths) async {
    print('🤖 GeminiService: Starting analyzeMultipleFoodImages');
    print('🤖 GeminiService: Number of images: ${imagePaths.length}');
    print('🤖 GeminiService: API key: ${_apiKey.substring(0, 10)}...');
    
    if (imagePaths.isEmpty) {
      print('🤖 GeminiService: No images provided');
      return Failure(GeminiError.imageProcessingError);
    }
    
    try {
      // Prepare all images
      final List<DataPart> imageParts = [];
      
      for (int i = 0; i < imagePaths.length; i++) {
        final imagePath = imagePaths[i];
        print('🤖 GeminiService: Reading image ${i + 1}: $imagePath');
        
        final imageFile = File(imagePath);
        if (!await imageFile.exists()) {
          print('🤖 GeminiService: Image file ${i + 1} does not exist!');
          continue; // Skip missing images rather than failing completely
        }

        final imageBytes = await imageFile.readAsBytes();
        print('🤖 GeminiService: Image ${i + 1} read successfully, size: ${imageBytes.length} bytes');
        
        imageParts.add(DataPart('image/jpeg', imageBytes));
      }
      
      if (imageParts.isEmpty) {
        print('🤖 GeminiService: No valid images found');
        return Failure(GeminiError.imageProcessingError);
      }
      
      // Create comprehensive prompt for multiple images
      final prompt = '''
Analyser disse ${imageParts.length} billeder af det samme måltid og giv samlet information på dansk:

Billederne viser forskellige vinkler eller dele af samme måltid. Kombiner informationen fra alle billeder til at give:

1. Navn på maden/retten (baseret på alle billeder)
2. Samlet beskrivelse af hele måltidet (hvad ses på alle billeder tilsammen)
3. Estimeret total portion størrelse for hele måltidet (f.eks. "1 mellem pizza", "200g pasta + salat", "1 kop kaffe + kage")
4. Estimeret samlede kalorier for hele måltidet (sum af alt der ses på billederne)
5. Konfidensniveau (0-100) for hvor sikker du er på den samlede analyse

Formater svaret som JSON:
{
  "foodName": "navn på hele måltidet",
  "description": "beskrivelse af hele måltidet fra alle billeder",
  "portionSize": "estimeret samlet størrelse",
  "estimatedCalories": antal_kalorier_som_nummer_for_hele_måltidet,
  "confidence": konfidens_som_nummer_mellem_0_og_100
}

Hvis billederne ikke viser mad, eller hvis de viser helt forskellige måltider (ikke samme måltid), sæt confidence til 0.
Hvis nogle billeder er uskarpe eller ubrugelige, fokuser på de bedste billeder.
''';

      print('🤖 GeminiService: Prompt created for multiple images, length: ${prompt.length} characters');

      // Create content with all images and text
      final contentParts = <Part>[TextPart(prompt)];
      contentParts.addAll(imageParts);
      
      final content = [Content.multi(contentParts)];

      print('🤖 GeminiService: Content created with ${imageParts.length} images, calling Gemini API...');

      // Generate response
      final response = await _model.generateContent(content);
      
      print('🤖 GeminiService: API call completed');
      print('🤖 GeminiService: Response text length: ${response.text?.length ?? 0}');
      print('🤖 GeminiService: Raw response: ${response.text}');
      
      if (response.text == null || response.text!.isEmpty) {
        print('🤖 GeminiService: Empty response from API');
        return Failure(GeminiError.parseError);
      }

      // Parse JSON response
      print('🤖 GeminiService: Parsing response...');
      final result = _parseGeminiResponse(response.text!);
      
      if (result.isSuccess) {
        print('🤖 GeminiService: Multi-image parsing successful');
        final analysis = result.success;
        print('🤖 GeminiService: Combined Food: ${analysis.foodName}');
        print('🤖 GeminiService: Combined Calories: ${analysis.estimatedCalories}');
        print('🤖 GeminiService: Combined Confidence: ${analysis.confidence}');
      } else {
        print('🤖 GeminiService: Multi-image parsing failed: ${result.failure}');
      }
      
      return result;

    } catch (e) {
      print('🤖 GeminiService: Multi-image exception caught: $e');
      print('🤖 GeminiService: Exception type: ${e.runtimeType}');
      print('🤖 GeminiService: Stack trace: ${StackTrace.current}');
      
      if (e.toString().contains('API_KEY')) {
        print('🤖 GeminiService: API key error detected');
        return Failure(GeminiError.invalidApiKey);
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        print('🤖 GeminiService: Network error detected');
        return Failure(GeminiError.networkError);
      } else if (e.toString().contains('quota')) {
        print('🤖 GeminiService: Quota error detected');
        return Failure(GeminiError.quotaExceeded);
      }
      print('🤖 GeminiService: Unknown error detected');
      return Failure(GeminiError.unknown);
    }
  }
} 