import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/generation_model.dart';
import '../services/generation_service.dart';
import '../services/storage_service.dart';

class GenerationProvider extends ChangeNotifier {
  final GenerationService _generationService = GenerationService();
  final _uuid = const Uuid();
  
  List<GenerationModel> _recentGenerations = [];
  GenerationModel? _currentGeneration;
  bool _isGenerating = false;
  String _selectedStyle = 'realistic';
  Map<String, dynamic> _advancedSettings = {
    'quality': 'ultra',
    'aspectRatio': '4:5',
    'negativePrompt': '',
    'seed': null,
    'guidance': 7.5,
    'steps': 50,
  };
  
  // Getters
  List<GenerationModel> get recentGenerations => _recentGenerations;
  GenerationModel? get currentGeneration => _currentGeneration;
  bool get isGenerating => _isGenerating;
  String get selectedStyle => _selectedStyle;
  Map<String, dynamic> get advancedSettings => _advancedSettings;
  
  GenerationProvider() {
    _loadRecentGenerations();
  }
  
  Future<void> _loadRecentGenerations() async {
    final stored = await StorageService.getStringList('recent_generations');
    if (stored != null) {
      _recentGenerations = stored.map((json) {
        return GenerationModel.fromJson(json);
      }).toList();
      
      if (_recentGenerations.isNotEmpty) {
        _currentGeneration = _recentGenerations.first;
      }
      
      notifyListeners();
    }
  }
  
  Future<void> _saveRecentGenerations() async {
    final jsonList = _recentGenerations.map((gen) => gen.toJson()).toList();
    await StorageService.setStringList('recent_generations', jsonList);
  }
  
  /// Generates an AI image based on the provided prompt
  /// 
  /// TODO: Replace mock implementation with real API call
  /// 
  /// Steps to implement:
  /// 1. Create ApiService instance
  /// 2. Replace Future.delayed with actual API call
  /// 3. Handle response and map to GenerationModel
  /// 4. Implement proper error handling
  /// 5. Add retry logic for failed requests
  /// 
  /// Example implementation:
  /// ```dart
  /// final response = await _apiService.createGeneration(
  ///   prompt: prompt,
  ///   style: _selectedStyle,
  ///   settings: _advancedSettings,
  /// );
  /// ```
  Future<void> generateImage(String prompt) async {
    if (_isGenerating) return;
    
    _isGenerating = true;
    notifyListeners();
    
    try {
      // MOCK: Simulate API call for generation
      // TODO: Replace with real API call to backend
      await Future.delayed(const Duration(seconds: 5));
      
      final generation = GenerationModel(
        id: _uuid.v4(),
        userId: 'guest-user', // TODO: Get from auth provider using context.read<AuthProvider>().userId
        prompt: prompt,
        imageUrl: 'https://picsum.photos/450/540?random=${DateTime.now().millisecondsSinceEpoch}', // MOCK: Replace with real image URL from API
        style: _selectedStyle,
        status: GenerationStatus.succeeded,
        quality: GenerationQuality.ultra,
        createdAt: DateTime.now(),
        settings: Map<String, dynamic>.from(_advancedSettings),
      );
      
      _currentGeneration = generation;
      _recentGenerations.insert(0, generation);
      
      // Keep only last 100 generations
      if (_recentGenerations.length > 100) {
        _recentGenerations = _recentGenerations.take(100).toList();
      }
      
      await _saveRecentGenerations();
      
    } catch (error) {
      // TODO: Implement proper error handling
      // - Show user-friendly error message
      // - Log error to analytics
      // - Retry logic for network errors
      print('Generation error: $error');
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }
  
  void setSelectedStyle(String style) {
    _selectedStyle = style;
    notifyListeners();
  }
  
  void updateAdvancedSettings(Map<String, dynamic> settings) {
    _advancedSettings = settings;
    notifyListeners();
  }
  
  void toggleFavorite(String generationId) {
    final index = _recentGenerations.indexWhere((gen) => gen.id == generationId);
    if (index != -1) {
      _recentGenerations[index] = _recentGenerations[index].copyWith(
        isFavorite: !_recentGenerations[index].isFavorite,
      );
      _saveRecentGenerations();
      notifyListeners();
    }
  }
  
  void deleteGeneration(String generationId) {
    _recentGenerations.removeWhere((gen) => gen.id == generationId);
    
    if (_currentGeneration?.id == generationId) {
      _currentGeneration = _recentGenerations.isNotEmpty 
          ? _recentGenerations.first 
          : null;
    }
    
    _saveRecentGenerations();
    notifyListeners();
  }
  
  void clearAllGenerations() {
    _recentGenerations.clear();
    _currentGeneration = null;
    _saveRecentGenerations();
    notifyListeners();
  }
  
  Future<void> regenerateWithEdits(String generationId, String newPrompt) async {
    final original = _recentGenerations.firstWhere(
      (gen) => gen.id == generationId,
      orElse: () => throw Exception('Generation not found'),
    );
    
    // Use original settings but with new prompt
    _selectedStyle = original.style;
    _advancedSettings = original.settings ?? _advancedSettings;
    
    await generateImage(newPrompt);
  }
}
