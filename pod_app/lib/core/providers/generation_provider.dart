import 'dart:async';
import 'package.flutter/foundation.dart';
import '../models/generation_model.dart';
import '../services/api_service.dart';

class GenerationProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<GenerationModel> _generations = [];
  GenerationModel? _currentGeneration;
  bool _isGenerating = false;
  bool _isLoadingHistory = true;
  String? _error;
  Timer? _pollingTimer;

  GenerationProvider(this._apiService) {
    fetchHistory();
  }

  // Getters
  List<GenerationModel> get generations => _generations;
  GenerationModel? get currentGeneration => _currentGeneration;
  bool get isGenerating => _isGenerating;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get error => _error;

  Future<void> fetchHistory() async {
    _isLoadingHistory = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.getGenerationHistory();
      final List<dynamic> generationData = response['data'];
      _generations = generationData.map((data) => GenerationModel.fromMap(data)).toList();
      if (_generations.isNotEmpty) {
        _currentGeneration = _generations.first;
      }
    } catch (e) {
      _error = "Failed to load generation history: ${e.toString()}";
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<void> generateImage(String prompt, String style) async {
    if (_isGenerating) return;

    _isGenerating = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.createGeneration(prompt, style);
      final newGeneration = GenerationModel.fromMap(response['data']);
      
      _generations.insert(0, newGeneration);
      _currentGeneration = newGeneration;

      // Start polling for status updates
      _startStatusPolling(newGeneration.id);

    } catch (e) {
      _error = "Failed to start generation: ${e.toString()}";
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void _startStatusPolling(String generationId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      try {
        final response = await _apiService.getGenerationStatus(generationId);
        final updatedGeneration = GenerationModel.fromMap(response['data']);
        
        final index = _generations.indexWhere((g) => g.id == generationId);
        if (index != -1) {
          _generations[index] = updatedGeneration;
          if (_currentGeneration?.id == generationId) {
            _currentGeneration = updatedGeneration;
          }
          notifyListeners();
        }

        if (updatedGeneration.status == GenerationStatus.succeeded || updatedGeneration.status == GenerationStatus.failed) {
          timer.cancel();
        }
      } catch (e) {
        // Stop polling on error
        _error = "Failed to get generation status: ${e.toString()}";
        notifyListeners();
        timer.cancel();
      }
    });
  }

  Future<void> deleteGeneration(String generationId) async {
    try {
      await _apiService.deleteGeneration(generationId);
      _generations.removeWhere((gen) => gen.id == generationId);
      if (_currentGeneration?.id == generationId) {
        _currentGeneration = _generations.isNotEmpty ? _generations.first : null;
      }
      notifyListeners();
    } catch (e) {
      _error = "Failed to delete generation: ${e.toString()}";
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
