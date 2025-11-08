---
name: replicate-api-integration
description: Secure and efficient Replicate API integration for AI image generation with cost optimization, error handling, and production-ready patterns
---

# Replicate API Integration Skill

This skill provides comprehensive expertise for integrating Replicate API in production applications with focus on security, performance, and cost optimization.

## Core Competencies

### 1. Secure API Configuration

#### Environment Variable Management
```dart
// NEVER hardcode API keys
class ReplicateConfig {
  static const String apiVersion = 'v1';
  static const String baseUrl = 'https://api.replicate.com';
  
  // Load from environment or secure storage
  static String get apiToken {
    final token = Platform.environment['REPLICATE_API_TOKEN'] ?? 
                  const String.fromEnvironment('REPLICATE_API_TOKEN');
    
    if (token.isEmpty) {
      throw ConfigurationException(
        'REPLICATE_API_TOKEN not configured. '
        'Set environment variable or use --dart-define',
      );
    }
    
    return token;
  }
}
```

#### Secure Storage Implementation
```dart
class SecureApiTokenManager {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'replicate_api_token';
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }
  
  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

### 2. API Client Implementation

#### Professional HTTP Client
```dart
class ReplicateApiClient {
  final Dio _dio;
  final String _apiToken;
  
  ReplicateApiClient({required String apiToken})
      : _apiToken = apiToken,
        _dio = Dio(BaseOptions(
          baseUrl: '${ReplicateConfig.baseUrl}/${ReplicateConfig.apiVersion}',
          headers: {
            'Authorization': 'Token $apiToken',
            'Content-Type': 'application/json',
            'User-Agent': 'PrintCraftAI/1.0.0',
          },
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        )) {
    _setupInterceptors();
  }
  
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log requests in debug mode only
          if (kDebugMode) {
            print('API Request: ${options.method} ${options.path}');
          }
          handler.next(options);
        },
        onError: (error, handler) {
          final apiError = _handleApiError(error);
          handler.reject(apiError);
        },
      ),
    );
    
    // Retry interceptor
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 4),
        ],
        retryEvaluator: (error, attempt) {
          // Retry on network errors and 5xx status codes
          return error.type == DioExceptionType.connectionTimeout ||
                 error.type == DioExceptionType.receiveTimeout ||
                 (error.response?.statusCode ?? 0) >= 500;
        },
      ),
    );
  }
  
  DioException _handleApiError(DioException error) {
    String message = 'An error occurred';
    String? code;
    
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic>) {
        message = data['detail'] ?? data['message'] ?? message;
        code = data['error_code'];
      }
      
      switch (error.response!.statusCode) {
        case 401:
          message = 'Invalid API token';
          break;
        case 402:
          message = 'Payment required - Please add credits';
          break;
        case 429:
          message = 'Rate limit exceeded - Please try again later';
          break;
      }
    }
    
    return DioException(
      requestOptions: error.requestOptions,
      response: error.response,
      type: error.type,
      error: ReplicateApiException(
        message: message,
        code: code,
        statusCode: error.response?.statusCode,
      ),
    );
  }
}
```

### 3. Model Configuration

#### AI Model Registry
```dart
enum AIModelType {
  imagen4Ultra,
  fluxProUltra,
  fluxSchnell,
  seeDream4,
}

class AIModel {
  final String id;
  final String name;
  final AIModelType type;
  final double costPerImage;
  final Duration averageTime;
  final Map<String, dynamic> defaultParams;
  final bool supportsTransparentBg;
  
  const AIModel({
    required this.id,
    required this.name,
    required this.type,
    required this.costPerImage,
    required this.averageTime,
    required this.defaultParams,
    this.supportsTransparentBg = true,
  });
  
  static const Map<AIModelType, AIModel> models = {
    AIModelType.imagen4Ultra: AIModel(
      id: 'stability-ai/imagen-4-ultra:v1',
      name: 'Google Imagen 4 Ultra',
      type: AIModelType.imagen4Ultra,
      costPerImage: 0.10,
      averageTime: Duration(seconds: 45),
      defaultParams: {
        'width': 1024,
        'height': 1024,
        'num_inference_steps': 50,
        'guidance_scale': 7.5,
      },
    ),
    AIModelType.fluxSchnell: AIModel(
      id: 'black-forest-labs/flux-schnell:v1',
      name: 'FLUX Schnell',
      type: AIModelType.fluxSchnell,
      costPerImage: 0.003,
      averageTime: Duration(seconds: 2),
      defaultParams: {
        'num_inference_steps': 4,
        'guidance_scale': 0,
      },
    ),
    // ... other models
  };
}
```

### 4. Generation Service

#### Production-Ready Generation
```dart
class ReplicateGenerationService {
  final ReplicateApiClient _client;
  final Map<String, StreamController<GenerationModel>> _progressStreams = {};
  
  Future<GenerationModel> generateImage({
    required String userId,
    required String prompt,
    required AIModelType modelType,
    required GenerationMode mode,
    Map<String, dynamic>? advancedSettings,
    Function(GenerationModel)? onProgress,
  }) async {
    try {
      // Select model based on mode
      final model = _selectModel(mode, modelType);
      
      // Prepare input
      final input = _prepareInput(
        prompt: prompt,
        model: model,
        settings: advancedSettings,
      );
      
      // Create prediction
      final prediction = await _createPrediction(model, input);
      
      // Track generation
      final generation = GenerationModel.pending(
        id: prediction['id'],
        userId: userId,
        prompt: prompt,
        modelId: model.id,
        estimatedCost: model.costPerImage,
      );
      
      // Start polling
      return await _pollForCompletion(
        generation: generation,
        onProgress: onProgress,
      );
      
    } catch (e) {
      _handleGenerationError(e);
      rethrow;
    }
  }
  
  Map<String, dynamic> _prepareInput({
    required String prompt,
    required AIModel model,
    Map<String, dynamic>? settings,
  }) {
    final input = Map<String, dynamic>.from(model.defaultParams);
    
    // Apply POD optimizations
    input['prompt'] = prompt;
    input['negative_prompt'] = _generateNegativePrompt();
    input['aspect_ratio'] = '4:3';  // POD optimized
    input['output_format'] = 'png';
    
    // Merge user settings
    if (settings != null) {
      input.addAll(settings);
    }
    
    return input;
  }
  
  String _generateNegativePrompt() {
    return 'blurry, low quality, pixelated, watermark, text overlay, '
           'copyright, signature, distorted, amateur, poor lighting';
  }
}
```

### 5. Polling & Progress Tracking

#### Efficient Polling System
```dart
class PredictionPoller {
  static const Duration _initialDelay = Duration(seconds: 1);
  static const Duration _maxDelay = Duration(seconds: 5);
  static const int _maxAttempts = 120;  // 10 minutes max
  
  Future<Map<String, dynamic>> pollUntilComplete({
    required String predictionId,
    required ReplicateApiClient client,
    Function(double progress)? onProgress,
  }) async {
    int attempt = 0;
    Duration delay = _initialDelay;
    
    while (attempt < _maxAttempts) {
      final response = await client.get('/predictions/$predictionId');
      final prediction = response.data as Map<String, dynamic>;
      
      // Update progress
      if (onProgress != null && prediction['logs'] != null) {
        final progress = _parseProgress(prediction['logs']);
        onProgress(progress);
      }
      
      switch (prediction['status']) {
        case 'succeeded':
          return prediction;
        case 'failed':
          throw PredictionFailedException(
            message: prediction['error'] ?? 'Generation failed',
            predictionId: predictionId,
          );
        case 'canceled':
          throw PredictionCancelledException(predictionId);
        default:
          // Still processing
          await Future.delayed(delay);
          
          // Exponential backoff
          delay = Duration(
            milliseconds: min(
              delay.inMilliseconds * 1.5,
              _maxDelay.inMilliseconds,
            ).toInt(),
          );
          attempt++;
      }
    }
    
    throw PredictionTimeoutException(
      'Generation timed out after ${_maxAttempts * delay.inSeconds} seconds',
    );
  }
  
  double _parseProgress(String logs) {
    // Parse progress from logs
    final progressMatch = RegExp(r'(\d+)%').firstMatch(logs);
    if (progressMatch != null) {
      return double.parse(progressMatch.group(1)!) / 100;
    }
    return 0.0;
  }
}
```

### 6. Cost Management

#### Cost Tracking & Optimization
```dart
class CostManager {
  static const Map<AIModelType, double> modelCosts = {
    AIModelType.imagen4Ultra: 0.10,
    AIModelType.fluxProUltra: 0.06,
    AIModelType.fluxSchnell: 0.003,
    AIModelType.seeDream4: 0.025,
  };
  
  static double estimateCost({
    required AIModelType model,
    int quantity = 1,
  }) {
    return modelCosts[model]! * quantity;
  }
  
  static AIModelType recommendModel({
    required double budget,
    required int estimatedIterations,
    required bool needsHighQuality,
  }) {
    final costPerIteration = budget / estimatedIterations;
    
    if (needsHighQuality && costPerIteration >= 0.06) {
      return AIModelType.fluxProUltra;
    } else if (costPerIteration >= 0.025) {
      return AIModelType.seeDream4;
    } else {
      return AIModelType.fluxSchnell;
    }
  }
  
  static Future<void> trackUsage({
    required String userId,
    required AIModelType model,
    required bool successful,
  }) async {
    final cost = modelCosts[model]!;
    
    // Log to analytics
    await Analytics.logEvent('generation_completed', {
      'user_id': userId,
      'model': model.name,
      'cost': cost,
      'successful': successful,
    });
    
    // Update user quota if applicable
    if (successful) {
      await UserQuotaService.incrementUsage(userId, cost);
    }
  }
}
```

### 7. Error Handling

#### Comprehensive Error Management
```dart
abstract class ReplicateException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;
  
  ReplicateException(this.message, {this.code, this.statusCode});
}

class ReplicateErrorHandler {
  static GenerationException handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is ReplicateException) {
      return _handleReplicateError(error);
    } else {
      return GenerationException(
        message: 'An unexpected error occurred',
        type: GenerationErrorType.unknown,
        originalError: error,
      );
    }
  }
  
  static GenerationException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return GenerationException(
          message: 'Connection timeout. Please check your internet.',
          type: GenerationErrorType.networkError,
          canRetry: true,
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        if (statusCode == 402) {
          return GenerationException(
            message: 'Insufficient credits. Please add funds.',
            type: GenerationErrorType.insufficientCredits,
            canRetry: false,
          );
        } else if (statusCode == 429) {
          return GenerationException(
            message: 'Too many requests. Please wait.',
            type: GenerationErrorType.rateLimited,
            canRetry: true,
            retryAfter: _parseRetryAfter(error.response?.headers),
          );
        }
        break;
      default:
        break;
    }
    
    return GenerationException(
      message: 'Network error occurred',
      type: GenerationErrorType.networkError,
      canRetry: true,
    );
  }
}
```

### 8. Rate Limiting

#### Intelligent Rate Limiter
```dart
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Queue<DateTime> _requests = Queue();
  
  RateLimiter({
    this.maxRequests = 60,
    this.window = const Duration(minutes: 1),
  });
  
  Future<void> acquire() async {
    _cleanup();
    
    if (_requests.length >= maxRequests) {
      final oldestRequest = _requests.first;
      final waitTime = oldestRequest.add(window).difference(DateTime.now());
      
      if (waitTime.isNegative) {
        _requests.removeFirst();
      } else {
        await Future.delayed(waitTime);
        _requests.removeFirst();
      }
    }
    
    _requests.add(DateTime.now());
  }
  
  void _cleanup() {
    final cutoff = DateTime.now().subtract(window);
    while (_requests.isNotEmpty && _requests.first.isBefore(cutoff)) {
      _requests.removeFirst();
    }
  }
}
```

### 9. Webhook Integration

#### Async Generation with Webhooks
```dart
class WebhookHandler {
  static Future<String> createPredictionWithWebhook({
    required AIModel model,
    required Map<String, dynamic> input,
    required String webhookUrl,
  }) async {
    final response = await _client.post('/predictions', data: {
      'version': model.id,
      'input': input,
      'webhook': webhookUrl,
      'webhook_events_filter': ['completed'],
    });
    
    return response.data['id'];
  }
  
  static GenerationModel processWebhookPayload(Map<String, dynamic> payload) {
    final status = payload['status'];
    final output = payload['output'];
    
    if (status == 'succeeded' && output != null) {
      return GenerationModel(
        id: payload['id'],
        status: GenerationStatus.succeeded,
        imageUrl: output is List ? output.first : output,
        completedAt: DateTime.parse(payload['completed_at']),
        metrics: payload['metrics'],
      );
    } else if (status == 'failed') {
      throw GenerationFailedException(
        payload['error'] ?? 'Generation failed',
      );
    }
    
    throw UnexpectedWebhookPayloadException();
  }
}
```

### 10. Testing & Mocking

#### Mock Service for Testing
```dart
class MockReplicateService implements ReplicateGenerationService {
  final bool shouldSucceed;
  final Duration mockDelay;
  
  MockReplicateService({
    this.shouldSucceed = true,
    this.mockDelay = const Duration(seconds: 2),
  });
  
  @override
  Future<GenerationModel> generateImage({
    required String userId,
    required String prompt,
    // ... other parameters
  }) async {
    // Simulate processing
    await Future.delayed(mockDelay);
    
    if (!shouldSucceed) {
      throw GenerationException(
        message: 'Mock generation failed',
        type: GenerationErrorType.serverError,
      );
    }
    
    return GenerationModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      prompt: prompt,
      status: GenerationStatus.succeeded,
      imageUrl: 'https://example.com/mock-image.png',
      completedAt: DateTime.now(),
    );
  }
}
```

## Security Checklist

- [ ] API token stored securely (never in code)
- [ ] HTTPS enforced for all requests
- [ ] Request/response logging sanitized
- [ ] Rate limiting implemented
- [ ] Error messages don't leak sensitive info
- [ ] Webhook endpoints verified
- [ ] Input validation on all parameters
- [ ] Cost limits enforced per user

## Performance Optimization

1. **Connection Pooling**
   - Reuse HTTP connections
   - Configure appropriate timeouts
   
2. **Parallel Requests**
   - Batch multiple generations when possible
   - Use isolates for heavy processing
   
3. **Caching Strategy**
   - Cache model configurations
   - Cache successful generations locally
   
4. **Progress Updates**
   - Stream progress in real-time
   - Debounce UI updates

## Cost Optimization Strategies

1. **Tiered Generation**
   ```dart
   // Start with cheap preview
   final preview = await generateImage(
     model: AIModelType.fluxSchnell,
     // ...
   );
   
   // If approved, generate high quality
   if (userApproved) {
     final final = await generateImage(
       model: AIModelType.fluxProUltra,
       // ...
     );
   }
   ```

2. **Batch Processing**
   - Group similar requests
   - Use bulk endpoints when available

3. **Smart Model Selection**
   - Auto-select based on prompt complexity
   - User preference learning

## Monitoring & Analytics

```dart
class ReplicateMonitoring {
  static void trackGeneration({
    required String model,
    required double cost,
    required Duration processingTime,
    required bool successful,
  }) {
    Analytics.track('replicate_generation', {
      'model': model,
      'cost_usd': cost,
      'processing_time_ms': processingTime.inMilliseconds,
      'successful': successful,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```