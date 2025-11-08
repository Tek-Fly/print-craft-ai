import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';

class UserPreferencesProvider extends ChangeNotifier {
  // Display preferences
  bool _showGenerationHints = true;
  bool _autoSaveGenerations = true;
  bool _highQualityPreview = false;
  
  // Generation preferences
  String _defaultStyle = 'realistic';
  String _defaultQuality = 'ultra';
  int _defaultSteps = 50;
  double _defaultGuidance = 7.5;
  
  // Notification preferences
  bool _pushNotifications = true;
  bool _generationCompleteNotification = true;
  bool _promotionalNotifications = false;
  
  // Privacy preferences
  bool _analyticsEnabled = true;
  bool _crashReportingEnabled = true;
  
  // UI preferences
  bool _compactMode = false;
  bool _showGenerationTime = true;
  bool _vibrateOnActions = true;
  
  // Getters
  bool get showGenerationHints => _showGenerationHints;
  bool get autoSaveGenerations => _autoSaveGenerations;
  bool get highQualityPreview => _highQualityPreview;
  String get defaultStyle => _defaultStyle;
  String get defaultQuality => _defaultQuality;
  int get defaultSteps => _defaultSteps;
  double get defaultGuidance => _defaultGuidance;
  bool get pushNotifications => _pushNotifications;
  bool get generationCompleteNotification => _generationCompleteNotification;
  bool get promotionalNotifications => _promotionalNotifications;
  bool get analyticsEnabled => _analyticsEnabled;
  bool get crashReportingEnabled => _crashReportingEnabled;
  bool get compactMode => _compactMode;
  bool get showGenerationTime => _showGenerationTime;
  bool get vibrateOnActions => _vibrateOnActions;
  
  UserPreferencesProvider() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    _showGenerationHints = await StorageService.getBool('show_generation_hints') ?? true;
    _autoSaveGenerations = await StorageService.getBool('auto_save_generations') ?? true;
    _highQualityPreview = await StorageService.getBool('high_quality_preview') ?? false;
    
    _defaultStyle = await StorageService.getString('default_style') ?? 'realistic';
    _defaultQuality = await StorageService.getString('default_quality') ?? 'ultra';
    _defaultSteps = await StorageService.getInt('default_steps') ?? 50;
    _defaultGuidance = await StorageService.getDouble('default_guidance') ?? 7.5;
    
    _pushNotifications = await StorageService.getBool('push_notifications') ?? true;
    _generationCompleteNotification = await StorageService.getBool('generation_complete_notification') ?? true;
    _promotionalNotifications = await StorageService.getBool('promotional_notifications') ?? false;
    
    _analyticsEnabled = await StorageService.getBool('analytics_enabled') ?? true;
    _crashReportingEnabled = await StorageService.getBool('crash_reporting_enabled') ?? true;
    
    _compactMode = await StorageService.getBool('compact_mode') ?? false;
    _showGenerationTime = await StorageService.getBool('show_generation_time') ?? true;
    _vibrateOnActions = await StorageService.getBool('vibrate_on_actions') ?? true;
    
    notifyListeners();
  }
  
  // Setters with persistence
  Future<void> setShowGenerationHints(bool value) async {
    _showGenerationHints = value;
    await StorageService.setBool('show_generation_hints', value);
    notifyListeners();
  }
  
  Future<void> setAutoSaveGenerations(bool value) async {
    _autoSaveGenerations = value;
    await StorageService.setBool('auto_save_generations', value);
    notifyListeners();
  }
  
  Future<void> setHighQualityPreview(bool value) async {
    _highQualityPreview = value;
    await StorageService.setBool('high_quality_preview', value);
    notifyListeners();
  }
  
  Future<void> setDefaultStyle(String value) async {
    _defaultStyle = value;
    await StorageService.setString('default_style', value);
    notifyListeners();
  }
  
  Future<void> setDefaultQuality(String value) async {
    _defaultQuality = value;
    await StorageService.setString('default_quality', value);
    notifyListeners();
  }
  
  Future<void> setDefaultSteps(int value) async {
    _defaultSteps = value;
    await StorageService.setInt('default_steps', value);
    notifyListeners();
  }
  
  Future<void> setDefaultGuidance(double value) async {
    _defaultGuidance = value;
    await StorageService.setDouble('default_guidance', value);
    notifyListeners();
  }
  
  Future<void> setPushNotifications(bool value) async {
    _pushNotifications = value;
    await StorageService.setBool('push_notifications', value);
    
    // Update system notification settings
    if (value) {
      // Request notification permissions
    } else {
      // Disable notifications
    }
    
    notifyListeners();
  }
  
  Future<void> setGenerationCompleteNotification(bool value) async {
    _generationCompleteNotification = value;
    await StorageService.setBool('generation_complete_notification', value);
    notifyListeners();
  }
  
  Future<void> setPromotionalNotifications(bool value) async {
    _promotionalNotifications = value;
    await StorageService.setBool('promotional_notifications', value);
    notifyListeners();
  }
  
  Future<void> setAnalyticsEnabled(bool value) async {
    _analyticsEnabled = value;
    await StorageService.setBool('analytics_enabled', value);
    
    // Update analytics settings
    if (!value) {
      // Disable analytics collection
    }
    
    notifyListeners();
  }
  
  Future<void> setCrashReportingEnabled(bool value) async {
    _crashReportingEnabled = value;
    await StorageService.setBool('crash_reporting_enabled', value);
    
    // Update crash reporting settings
    if (!value) {
      // Disable crash reporting
    }
    
    notifyListeners();
  }
  
  Future<void> setCompactMode(bool value) async {
    _compactMode = value;
    await StorageService.setBool('compact_mode', value);
    notifyListeners();
  }
  
  Future<void> setShowGenerationTime(bool value) async {
    _showGenerationTime = value;
    await StorageService.setBool('show_generation_time', value);
    notifyListeners();
  }
  
  Future<void> setVibrateOnActions(bool value) async {
    _vibrateOnActions = value;
    await StorageService.setBool('vibrate_on_actions', value);
    notifyListeners();
  }
  
  // Reset to defaults
  Future<void> resetToDefaults() async {
    await setShowGenerationHints(true);
    await setAutoSaveGenerations(true);
    await setHighQualityPreview(false);
    await setDefaultStyle('realistic');
    await setDefaultQuality('ultra');
    await setDefaultSteps(50);
    await setDefaultGuidance(7.5);
    await setPushNotifications(true);
    await setGenerationCompleteNotification(true);
    await setPromotionalNotifications(false);
    await setAnalyticsEnabled(true);
    await setCrashReportingEnabled(true);
    await setCompactMode(false);
    await setShowGenerationTime(true);
    await setVibrateOnActions(true);
  }
  
  // Export preferences
  Map<String, dynamic> exportPreferences() {
    return {
      'showGenerationHints': _showGenerationHints,
      'autoSaveGenerations': _autoSaveGenerations,
      'highQualityPreview': _highQualityPreview,
      'defaultStyle': _defaultStyle,
      'defaultQuality': _defaultQuality,
      'defaultSteps': _defaultSteps,
      'defaultGuidance': _defaultGuidance,
      'pushNotifications': _pushNotifications,
      'generationCompleteNotification': _generationCompleteNotification,
      'promotionalNotifications': _promotionalNotifications,
      'analyticsEnabled': _analyticsEnabled,
      'crashReportingEnabled': _crashReportingEnabled,
      'compactMode': _compactMode,
      'showGenerationTime': _showGenerationTime,
      'vibrateOnActions': _vibrateOnActions,
    };
  }
  
  // Import preferences
  Future<void> importPreferences(Map<String, dynamic> preferences) async {
    if (preferences['showGenerationHints'] != null) {
      await setShowGenerationHints(preferences['showGenerationHints']);
    }
    if (preferences['autoSaveGenerations'] != null) {
      await setAutoSaveGenerations(preferences['autoSaveGenerations']);
    }
    if (preferences['highQualityPreview'] != null) {
      await setHighQualityPreview(preferences['highQualityPreview']);
    }
    if (preferences['defaultStyle'] != null) {
      await setDefaultStyle(preferences['defaultStyle']);
    }
    if (preferences['defaultQuality'] != null) {
      await setDefaultQuality(preferences['defaultQuality']);
    }
    if (preferences['defaultSteps'] != null) {
      await setDefaultSteps(preferences['defaultSteps']);
    }
    if (preferences['defaultGuidance'] != null) {
      await setDefaultGuidance(preferences['defaultGuidance']);
    }
    if (preferences['pushNotifications'] != null) {
      await setPushNotifications(preferences['pushNotifications']);
    }
    if (preferences['generationCompleteNotification'] != null) {
      await setGenerationCompleteNotification(preferences['generationCompleteNotification']);
    }
    if (preferences['promotionalNotifications'] != null) {
      await setPromotionalNotifications(preferences['promotionalNotifications']);
    }
    if (preferences['analyticsEnabled'] != null) {
      await setAnalyticsEnabled(preferences['analyticsEnabled']);
    }
    if (preferences['crashReportingEnabled'] != null) {
      await setCrashReportingEnabled(preferences['crashReportingEnabled']);
    }
    if (preferences['compactMode'] != null) {
      await setCompactMode(preferences['compactMode']);
    }
    if (preferences['showGenerationTime'] != null) {
      await setShowGenerationTime(preferences['showGenerationTime']);
    }
    if (preferences['vibrateOnActions'] != null) {
      await setVibrateOnActions(preferences['vibrateOnActions']);
    }
  }
}
