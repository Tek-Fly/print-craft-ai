import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../models/generation_model.dart';
import '../../config/api_endpoints.dart';

class GenerationService {
  late final Dio _dio;
  
  GenerationService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    // Add interceptors for logging and error handling
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Add auth token if available
        final token = _getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        // Handle errors globally
        _handleApiError(error);
        handler.next(error);
      },
    ));
  }
  
  String? _getAuthToken() {
    // Get token from storage or auth provider
    // This would be implemented based on your auth strategy
    return null;
  }
  
  void _handleApiError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.connectionError:
        throw 'Connection error. Please check your internet connection.';
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data['message'] ?? 'An error occurred';
        throw 'Error $statusCode: $message';
      default:
        throw 'An unexpected error occurred';
    }
  }
  
  // Main generation method
  Future<GenerationModel> generateImage({
    required String userId,
    required String prompt,
    String? negativePrompt,
    required String style,
    required GenerationQuality quality,
    Map<String, dynamic>? advancedSettings,
  }) async {
    try {
      // Prepare request data
      final requestData = {
        'user_id': userId,
        'prompt': prompt,
        'negative_prompt': negativePrompt ?? '',
        'style': style,
        'quality': quality.name,
        'width': _getWidthForQuality(quality),
        'height': _getHeightForQuality(quality),
        'transparent_background': true,
        'settings': {
          'guidance_scale': advancedSettings?['guidance'] ?? 7.5,
          'num_inference_steps': advancedSettings?['steps'] ?? 50,
          'seed': advancedSettings?['seed'],
          ...?advancedSettings,
        },
      };
      
      // Make API call to start generation
      final response = await _dio.post(
        ApiEndpoints.generateImage,
        data: requestData,
      );
      
      // Parse response
      final generationId = response.data['generation_id'];
      final status = response.data['status'];
      
      // Create generation model
      final generation = GenerationModel(
        id: generationId,
        userId: userId,
        prompt: prompt,
        negativePrompt: negativePrompt,
        status: _parseStatus(status),
        quality: quality,
        style: style,
        createdAt: DateTime.now(),
        width: _getWidthForQuality(quality),
        height: _getHeightForQuality(quality),
        settings: advancedSettings,
      );
      
      // If generation is async, poll for status
      if (generation.status == GenerationStatus.processing) {
        return _pollGenerationStatus(generation);
      }
      
      return generation;
    } catch (e) {
      print('Error generating image: $e');
      rethrow;
    }
  }
  
  // Poll for generation status (for async generation)
  Future<GenerationModel> _pollGenerationStatus(GenerationModel generation) async {
    const maxAttempts = 60; // 5 minutes with 5 second intervals
    const pollInterval = Duration(seconds: 5);
    
    for (int i = 0; i < maxAttempts; i++) {
      await Future.delayed(pollInterval);
      
      try {
        final status = await getGenerationStatus(generation.id);
        
        if (status.isComplete || status.hasFailed) {
          return status;
        }
        
        // Update progress if available
        if (status.progress != null) {
          // You could emit progress updates here via a stream
        }
      } catch (e) {
        print('Error polling generation status: $e');
        // Continue polling unless it's a critical error
      }
    }
    
    // Timeout - mark as failed
    return generation.copyWith(
      status: GenerationStatus.failed,
      errorMessage: 'Generation timed out',
    );
  }
  
  // Get generation status
  Future<GenerationModel> getGenerationStatus(String generationId) async {
    try {
      final response = await _dio.get(
        '${ApiEndpoints.generationStatus}/$generationId',
      );
      
      return GenerationModel.fromMap(response.data);
    } catch (e) {
      print('Error getting generation status: $e');
      rethrow;
    }
  }
  
  // Download generated image
  Future<Uint8List> downloadImage(String imageUrl) async {
    try {
      final response = await _dio.get<List<int>>(
        imageUrl,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );
      
      return Uint8List.fromList(response.data!);
    } catch (e) {
      print('Error downloading image: $e');
      rethrow;
    }
  }
  
  // Get user's generation history
  Future<List<GenerationModel>> getUserGenerations({
    required String userId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.userGenerations,
        queryParameters: {
          'user_id': userId,
          'page': page,
          'limit': limit,
        },
      );
      
      final List<dynamic> data = response.data['generations'];
      return data.map((json) => GenerationModel.fromMap(json)).toList();
    } catch (e) {
      print('Error getting user generations: $e');
      return [];
    }
  }
  
  // Delete generation
  Future<bool> deleteGeneration(String generationId) async {
    try {
      await _dio.delete(
        '${ApiEndpoints.deleteGeneration}/$generationId',
      );
      return true;
    } catch (e) {
      print('Error deleting generation: $e');
      return false;
    }
  }
  
  // Get available styles
  Future<List<StyleOption>> getAvailableStyles() async {
    try {
      final response = await _dio.get(ApiEndpoints.styles);
      
      final List<dynamic> data = response.data['styles'];
      return data.map((json) => StyleOption.fromMap(json)).toList();
    } catch (e) {
      print('Error getting styles: $e');
      // Return default styles
      return _getDefaultStyles();
    }
  }
  
  // Helper methods
  int _getWidthForQuality(GenerationQuality quality) {
    switch (quality) {
      case GenerationQuality.standard:
        return 2250;
      case GenerationQuality.hd:
        return 3000;
      case GenerationQuality.ultra:
        return 4500;
    }
  }
  
  int _getHeightForQuality(GenerationQuality quality) {
    switch (quality) {
      case GenerationQuality.standard:
        return 2700;
      case GenerationQuality.hd:
        return 3600;
      case GenerationQuality.ultra:
        return 5400;
    }
  }
  
  GenerationStatus _parseStatus(String status) {
    try {
      return GenerationStatus.values.byName(status.toLowerCase());
    } catch (e) {
      return GenerationStatus.pending;
    }
  }
  
  List<StyleOption> _getDefaultStyles() {
    return [
      StyleOption(id: 'realistic', name: 'Realistic', icon: '🎨'),
      StyleOption(id: 'artistic', name: 'Artistic', icon: '🖼'),
      StyleOption(id: 'cartoon', name: 'Cartoon', icon: '🎭'),
      StyleOption(id: 'anime', name: 'Anime', icon: '🌸'),
      StyleOption(id: 'vintage', name: 'Vintage', icon: '📷'),
      StyleOption(id: 'minimalist', name: 'Minimalist', icon: '⚪'),
      StyleOption(id: 'abstract', name: 'Abstract', icon: '🌀'),
      StyleOption(id: 'watercolor', name: 'Watercolor', icon: '💧'),
    ];
  }
}

// Style option model
class StyleOption {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? thumbnailUrl;
  final bool isPremium;
  
  StyleOption({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.thumbnailUrl,
    this.isPremium = false,
  });
  
  factory StyleOption.fromMap(Map<String, dynamic> map) {
    return StyleOption(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      icon: map['icon'],
      thumbnailUrl: map['thumbnail_url'],
      isPremium: map['is_premium'] ?? false,
    );
  }
}
