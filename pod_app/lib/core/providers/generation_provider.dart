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
  
  Future<void> generateImage(String prompt) async {
    if (_isGenerating) return;
    
    _isGenerating = true;
    notifyListeners();
    
    try {
      // Simulate API call for generation
      await Future.delayed(const Duration(seconds: 5));
      
      final generation = GenerationModel(
        id: _uuid.v4(),
        prompt: prompt,
        imageUrl: 'https://picsum.photos/450/540?random=${DateTime.now().millisecondsSinceEpoch}',
        style: _selectedStyle,
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
      // Handle error
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
