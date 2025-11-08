import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/generation_provider.dart';
import '../../../../core/models/generation_model.dart';

class AdvancedSettingsSheet extends StatefulWidget {
  const AdvancedSettingsSheet({super.key});

  @override
  State<AdvancedSettingsSheet> createState() => _AdvancedSettingsSheetState();
}

class _AdvancedSettingsSheetState extends State<AdvancedSettingsSheet> {
  late Map<String, dynamic> _settings;
  late TextEditingController _negativePromptController;
  late TextEditingController _seedController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<GenerationProvider>();
    _settings = Map<String, dynamic>.from(provider.advancedSettings);
    _negativePromptController = TextEditingController(
      text: _settings['negativePrompt'] ?? '',
    );
    _seedController = TextEditingController(
      text: _settings['seed']?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _negativePromptController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    _settings['negativePrompt'] = _negativePromptController.text;
    _settings['seed'] = _seedController.text.isNotEmpty
        ? int.tryParse(_seedController.text)
        : null;
    
    context.read<GenerationProvider>().updateAdvancedSettings(_settings);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    return Container(
      height: size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Settings',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          
          // Settings Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quality Setting
                  _buildSectionTitle('Quality'),
                  _buildQualitySelector(),
                  const SizedBox(height: 24),
                  
                  // Aspect Ratio
                  _buildSectionTitle('Aspect Ratio'),
                  _buildAspectRatioSelector(),
                  const SizedBox(height: 24),
                  
                  // Negative Prompt
                  _buildSectionTitle('Negative Prompt'),
                  _buildNegativePromptInput(),
                  const SizedBox(height: 24),
                  
                  // Guidance Scale
                  _buildSectionTitle('Guidance Scale'),
                  _buildGuidanceSlider(),
                  const SizedBox(height: 24),
                  
                  // Steps
                  _buildSectionTitle('Inference Steps'),
                  _buildStepsSlider(),
                  const SizedBox(height: 24),
                  
                  // Seed
                  _buildSectionTitle('Seed (Optional)'),
                  _buildSeedInput(),
                  const SizedBox(height: 24),
                  
                  // Advanced Options
                  _buildSectionTitle('Advanced Options'),
                  _buildToggleOption(
                    'Transparent Background',
                    'transparent',
                    true,
                  ),
                  _buildToggleOption(
                    'Upscale Result',
                    'upscale',
                    false,
                  ),
                  _buildToggleOption(
                    'Enhanced Details',
                    'enhanceDetails',
                    false,
                  ),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Save Button
          Container(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _saveSettings,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: const Text('Save Settings'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge,
      ),
    );
  }

  Widget _buildQualitySelector() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Row(
      children: [
        _buildQualityOption('Standard', GenerationQuality.standard),
        const SizedBox(width: 8),
        _buildQualityOption('HD', GenerationQuality.hd),
        const SizedBox(width: 8),
        _buildQualityOption('Ultra POD', GenerationQuality.ultra),
      ],
    );
  }

  Widget _buildQualityOption(String label, GenerationQuality quality) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _settings['quality'] == quality.name;
    
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _settings['quality'] = quality.name;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? (isDark
                    ? AppColors.primaryGradientDark
                    : AppColors.primaryGradient)
                : null,
            color: !isSelected
                ? (isDark
                    ? AppColors.chipBackgroundDark
                    : AppColors.chipBackgroundLight)
                : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : (isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getQualitySize(quality),
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected
                      ? Colors.white.withOpacity(0.8)
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getQualitySize(GenerationQuality quality) {
    switch (quality) {
      case GenerationQuality.standard:
        return '2250x2700';
      case GenerationQuality.hd:
        return '3000x3600';
      case GenerationQuality.ultra:
        return '4500x5400';
    }
  }

  Widget _buildAspectRatioSelector() {
    final ratios = ['4:5', '3:4', '1:1', '4:3', '16:9'];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: ratios.map((ratio) {
        final isSelected = _settings['aspectRatio'] == ratio;
        
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _settings['aspectRatio'] = ratio;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark ? AppColors.primaryDark : AppColors.primaryLight)
                  : (isDark
                      ? AppColors.chipBackgroundDark
                      : AppColors.chipBackgroundLight),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : (isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
            ),
            child: Text(
              ratio,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? Colors.black : Colors.white)
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNegativePromptInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextField(
      controller: _negativePromptController,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: 'Things to avoid in the image...',
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
      ),
    );
  }

  Widget _buildGuidanceSlider() {
    final value = (_settings['guidance'] as double? ?? 7.5);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Less Creative',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value.toStringAsFixed(1),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'More Creative',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1.0,
          max: 20.0,
          divisions: 38,
          activeColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          onChanged: (newValue) {
            setState(() {
              _settings['guidance'] = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStepsSlider() {
    final value = (_settings['steps'] as int? ?? 50);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Faster',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              value.toString(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              'Better Quality',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 20,
          max: 150,
          divisions: 13,
          activeColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          onChanged: (newValue) {
            setState(() {
              _settings['steps'] = newValue.toInt();
            });
          },
        ),
      ],
    );
  }

  Widget _buildSeedInput() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextField(
      controller: _seedController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        hintText: 'Leave empty for random seed',
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        filled: true,
        fillColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLight,
      ),
    );
  }

  Widget _buildToggleOption(String label, String key, bool defaultValue) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final value = _settings[key] as bool? ?? defaultValue;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Switch(
            value: value,
            onChanged: (newValue) {
              setState(() {
                _settings[key] = newValue;
              });
            },
            activeColor: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          ),
        ],
      ),
    );
  }
}
