---
name: pod-image-generation
description: PrintMaster Pro system for optimizing AI prompts for print-on-demand products with market intelligence, design trends, and technical POD requirements
---

# POD Image Generation Skill

This skill implements the PrintMaster Pro system for generating high-quality, market-optimized print-on-demand designs with AI.

## Core Competencies

### 1. PrintMaster Pro Prompt Engineering

#### Prompt Analysis & Enhancement
```dart
class PrintMasterPro {
  static const String systemRole = '''
You are PrintMaster Pro, an expert AI assistant specialized in creating 
print-on-demand t-shirt designs. Your expertise includes:

1. Market Intelligence: Current design trends, seasonal themes, demographics
2. Design Principles: Typography, composition, color theory for apparel
3. Technical Requirements: Print specifications, color limitations, file formats
4. Prompt Engineering: Converting ideas into detailed AI generation prompts
''';

  static String enhancePrompt({
    required String userInput,
    required String style,
    required Map<String, dynamic> context,
  }) {
    final analysis = _analyzeInput(userInput);
    final enhancement = _buildEnhancement(analysis, style, context);
    
    return enhancement.fullPrompt;
  }
  
  static _InputAnalysis _analyzeInput(String input) {
    return _InputAnalysis(
      hasQuote: _detectQuote(input),
      theme: _detectTheme(input),
      audience: _detectAudience(input),
      complexity: _assessComplexity(input),
      keywords: _extractKeywords(input),
    );
  }
  
  static bool _detectQuote(String input) {
    return input.contains('"') || 
           input.contains("'") || 
           RegExp(r'(quote|saying|text|words):?\s*(.+)', caseSensitive: false)
               .hasMatch(input);
  }
  
  static DesignTheme _detectTheme(String input) {
    final themes = {
      DesignTheme.motivational: ['motivational', 'inspire', 'success', 'dream'],
      DesignTheme.funny: ['funny', 'humor', 'joke', 'sarcastic', 'witty'],
      DesignTheme.nature: ['nature', 'outdoor', 'mountain', 'forest', 'ocean'],
      DesignTheme.tech: ['tech', 'coding', 'developer', 'geek', 'nerd'],
      DesignTheme.fitness: ['fitness', 'gym', 'workout', 'strong', 'health'],
      DesignTheme.vintage: ['vintage', 'retro', 'classic', '80s', '90s'],
    };
    
    for (final entry in themes.entries) {
      if (entry.value.any((keyword) => 
          input.toLowerCase().contains(keyword))) {
        return entry.key;
      }
    }
    
    return DesignTheme.general;
  }
}
```

### 2. Design Specifications

#### POD Technical Requirements
```dart
class PODSpecifications {
  // Print area constraints
  static const Map<PrintSize, Dimensions> printAreas = {
    PrintSize.small: Dimensions(width: 2250, height: 2700),
    PrintSize.standard: Dimensions(width: 3000, height: 3600),
    PrintSize.large: Dimensions(width: 4500, height: 5400), // Ultra POD
  };
  
  // Color specifications
  static const PODColorProfile colorProfile = PODColorProfile(
    colorSpace: ColorSpace.sRGB,
    maxColors: 4,  // For cost efficiency
    recommendedColors: 2,  // Optimal for most designs
    backgroundTransparency: true,
    contrastRequirement: ContrastLevel.high,
  );
  
  // Typography rules
  static const TypographyRules typography = TypographyRules(
    minFontSize: 24,  // Points at print size
    recommendedFontSize: 36,
    maxTextLength: 20,  // Words for readability
    fontWeightMin: FontWeight.medium,
    letterSpacingMin: 1.2,
  );
  
  // File requirements
  static const FileRequirements fileReqs = FileRequirements(
    format: 'PNG',
    colorMode: 'sRGB',
    bitDepth: 24,
    transparency: true,
    dpi: 300,
    compressionLevel: 0,  // No compression for quality
  );
}
```

### 3. Prompt Enhancement System

#### Advanced Prompt Builder
```dart
class PromptEnhancer {
  static PromptResult enhance({
    required String userInput,
    required String style,
    required GenerationMode mode,
  }) {
    final promptBuilder = StringBuffer();
    final negativeBuilder = StringBuffer();
    
    // 1. Base design specification
    promptBuilder.write(_buildBasePrompt(userInput, style));
    
    // 2. Style-specific enhancements
    promptBuilder.write(_applyStyleEnhancements(style));
    
    // 3. Technical specifications
    promptBuilder.write(_addTechnicalSpecs(mode));
    
    // 4. Quality modifiers
    promptBuilder.write(_addQualityModifiers(mode));
    
    // 5. Negative prompt
    negativeBuilder.write(_buildNegativePrompt(style));
    
    return PromptResult(
      enhancedPrompt: promptBuilder.toString(),
      negativePrompt: negativeBuilder.toString(),
      estimatedComplexity: _calculateComplexity(promptBuilder.toString()),
    );
  }
  
  static String _buildBasePrompt(String input, String style) {
    if (_isQuoteDesign(input)) {
      return _buildQuotePrompt(input, style);
    } else if (_isGraphicDesign(input)) {
      return _buildGraphicPrompt(input, style);
    } else {
      return _buildConceptPrompt(input, style);
    }
  }
  
  static String _buildQuotePrompt(String input, String style) {
    final quote = _extractQuote(input);
    final template = '''
Professional t-shirt design featuring bold typography: "$quote"
Style: $style design aesthetic
Layout: Centered composition with dynamic text hierarchy
Typography: Modern, highly legible font with strong visual impact
Background: Transparent PNG for print-on-demand
Technical: 300 DPI, sRGB color space, high contrast for readability
''';
    return template;
  }
}
```

### 4. Style-Specific Templates

#### Design Style Implementations
```dart
class StyleTemplates {
  static const Map<String, StyleTemplate> templates = {
    'minimalist': StyleTemplate(
      name: 'Minimalist',
      colorCount: 1,
      elements: ['simple shapes', 'clean lines', 'negative space'],
      typography: 'sans-serif, geometric',
      mood: 'sophisticated, modern, clean',
      prompt: 'Minimalist design with maximum 2 colors, clean geometry, '
              'substantial negative space, sophisticated simplicity',
    ),
    
    'vintage': StyleTemplate(
      name: 'Vintage',
      colorCount: 3,
      elements: ['distressed textures', 'retro badges', 'worn effects'],
      typography: 'vintage serif, hand-lettered style',
      mood: 'nostalgic, authentic, weathered',
      prompt: 'Vintage retro design with distressed textures, aged appearance, '
              'classic color palette, authentic worn effects',
    ),
    
    'artistic': StyleTemplate(
      name: 'Artistic',
      colorCount: 4,
      elements: ['brushstrokes', 'watercolor effects', 'artistic flourishes'],
      typography: 'hand-drawn, artistic lettering',
      mood: 'creative, expressive, unique',
      prompt: 'Artistic design with painterly effects, creative composition, '
              'expressive brushwork, unique artistic style',
    ),
    
    'neon': StyleTemplate(
      name: 'Neon Glow',
      colorCount: 3,
      elements: ['glowing effects', 'electric colors', 'urban vibes'],
      typography: 'bold neon-style, outlined text',
      mood: 'vibrant, energetic, nightlife',
      prompt: 'Neon glow effect design with electric colors, glowing outlines, '
              'dark background contrast, cyberpunk aesthetic',
      isPremium: true,
    ),
  };
  
  static String applyTemplate(String style, String basePrompt) {
    final template = templates[style] ?? templates['artistic']!;
    return '${basePrompt}\n${template.prompt}';
  }
}
```

### 5. Market Intelligence

#### Trend Analysis & Optimization
```dart
class MarketIntelligence {
  static TrendData analyzeTrends({
    required DateTime currentDate,
    required DesignTheme theme,
    required TargetDemographic demographic,
  }) {
    final seasonal = _getSeasonalTrends(currentDate);
    final thematic = _getThematicTrends(theme);
    final demographic = _getDemographicPreferences(demographic);
    
    return TrendData(
      recommendedColors: _mergeColorTrends(seasonal, thematic, demographic),
      suggestedElements: _mergeSuggestedElements(seasonal, thematic),
      avoidElements: _getElementsToAvoid(currentDate, theme),
    );
  }
  
  static SeasonalTrends _getSeasonalTrends(DateTime date) {
    final month = date.month;
    
    if (month >= 3 && month <= 5) {  // Spring
      return SeasonalTrends(
        colors: ['pastel pink', 'mint green', 'sky blue', 'lavender'],
        themes: ['growth', 'renewal', 'fresh start', 'flowers'],
        holidays: ['Easter', 'Mother\'s Day', 'Spring Break'],
      );
    } else if (month >= 6 && month <= 8) {  // Summer
      return SeasonalTrends(
        colors: ['bright coral', 'ocean blue', 'sunny yellow', 'tropical'],
        themes: ['vacation', 'beach', 'adventure', 'freedom'],
        holidays: ['4th of July', 'Summer vacation', 'Back to school'],
      );
    } else if (month >= 9 && month <= 11) {  // Fall
      return SeasonalTrends(
        colors: ['burnt orange', 'deep red', 'golden yellow', 'brown'],
        themes: ['harvest', 'cozy', 'thanksgiving', 'halloween'],
        holidays: ['Halloween', 'Thanksgiving', 'Black Friday'],
      );
    } else {  // Winter
      return SeasonalTrends(
        colors: ['ice blue', 'silver', 'deep green', 'burgundy'],
        themes: ['holidays', 'new year', 'cozy', 'celebration'],
        holidays: ['Christmas', 'New Year', 'Valentine\'s Day'],
      );
    }
  }
}
```

### 6. Color Optimization

#### POD Color Management
```dart
class PODColorOptimizer {
  static ColorScheme optimizeColors({
    required List<Color> suggestedColors,
    required PrintBackground background,
    required int maxColors,
  }) {
    // Reduce colors for cost efficiency
    final optimized = _reduceColorPalette(suggestedColors, maxColors);
    
    // Ensure contrast
    final contrasted = _ensureContrast(optimized, background);
    
    // Convert to POD-safe colors
    final podSafe = _convertToPODSafe(contrasted);
    
    return ColorScheme(
      primary: podSafe[0],
      secondary: podSafe.length > 1 ? podSafe[1] : null,
      accent: podSafe.length > 2 ? podSafe[2] : null,
      background: background == PrintBackground.transparent 
          ? Colors.transparent 
          : _selectBackgroundColor(podSafe),
    );
  }
  
  static List<Color> _reduceColorPalette(
    List<Color> colors, 
    int maxColors,
  ) {
    if (colors.length <= maxColors) return colors;
    
    // Use k-means clustering to find dominant colors
    final clusters = KMeansColorClustering.cluster(
      colors: colors,
      k: maxColors,
    );
    
    return clusters.map((c) => c.centroid).toList();
  }
  
  static List<Color> _ensureContrast(
    List<Color> colors,
    PrintBackground background,
  ) {
    final bgLuminance = background == PrintBackground.light ? 1.0 : 0.0;
    
    return colors.map((color) {
      final contrast = _calculateContrast(color, bgLuminance);
      
      if (contrast < 4.5) {  // WCAG AA standard
        // Adjust color for better contrast
        return _adjustForContrast(color, bgLuminance);
      }
      
      return color;
    }).toList();
  }
}
```

### 7. Typography Enhancement

#### Text Design Optimization
```dart
class TypographyEnhancer {
  static String enhanceTextDesign({
    required String text,
    required TextStyle style,
    required DesignTheme theme,
  }) {
    final enhanced = StringBuffer();
    
    // Analyze text characteristics
    final analysis = _analyzeText(text);
    
    // Build typography prompt
    enhanced.write('Typography design featuring: "$text"\n');
    
    // Font selection
    enhanced.write('Font style: ${_selectFont(style, theme, analysis)}\n');
    
    // Layout specification
    enhanced.write('Layout: ${_determineLayout(analysis)}\n');
    
    // Effects and styling
    enhanced.write('Effects: ${_selectEffects(style, theme)}\n');
    
    // Technical specs
    enhanced.write('Technical: Bold weight, high legibility, '
                  'kerning optimized, scalable vector quality\n');
    
    return enhanced.toString();
  }
  
  static String _selectFont(
    TextStyle style,
    DesignTheme theme,
    TextAnalysis analysis,
  ) {
    if (analysis.isShort && theme == DesignTheme.motivational) {
      return 'Bold sans-serif, modern geometric typeface';
    } else if (theme == DesignTheme.vintage) {
      return 'Vintage serif with decorative elements, weathered texture';
    } else if (theme == DesignTheme.tech) {
      return 'Monospace or futuristic sans-serif, tech-inspired';
    } else {
      return 'Clean, highly readable sans-serif with character';
    }
  }
  
  static String _determineLayout(TextAnalysis analysis) {
    if (analysis.wordCount <= 3) {
      return 'Large, centered, single line with maximum impact';
    } else if (analysis.wordCount <= 8) {
      return 'Hierarchical layout with emphasis on key words, 2-3 lines';
    } else {
      return 'Balanced multi-line composition with clear hierarchy';
    }
  }
}
```

### 8. Quality Assurance

#### Pre-Generation Validation
```dart
class QualityValidator {
  static ValidationResult validatePrompt({
    required String prompt,
    required GenerationMode mode,
    required Map<String, dynamic> settings,
  }) {
    final errors = <ValidationError>[];
    final warnings = <ValidationWarning>[];
    
    // Check prompt quality
    if (prompt.length < 20) {
      errors.add(ValidationError(
        'Prompt too short. Add more details for better results.',
        ValidationErrorType.promptLength,
      ));
    }
    
    // Check technical requirements
    if (mode == GenerationMode.highQuality) {
      if (settings['width'] != null && settings['width'] < 4500) {
        warnings.add(ValidationWarning(
          'Consider using 4500x5400 for best POD quality',
          ValidationWarningType.resolution,
        ));
      }
    }
    
    // Check color specifications
    if (_hasExcessiveColors(prompt)) {
      warnings.add(ValidationWarning(
        'Design may have too many colors. Consider limiting to 2-3 for cost efficiency.',
        ValidationWarningType.colorCount,
      ));
    }
    
    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      warnings: warnings,
      qualityScore: _calculateQualityScore(prompt, settings),
    );
  }
  
  static double _calculateQualityScore(
    String prompt, 
    Map<String, dynamic> settings,
  ) {
    double score = 0.5;  // Base score
    
    // Prompt completeness
    if (prompt.length > 50) score += 0.1;
    if (prompt.contains('style:')) score += 0.1;
    if (prompt.contains('transparent')) score += 0.1;
    
    // Technical specifications
    if (settings['dpi'] == 300) score += 0.1;
    if (settings['output_format'] == 'png') score += 0.1;
    
    return math.min(score, 1.0);
  }
}
```

### 9. Batch Processing

#### Efficient Bulk Generation
```dart
class BatchProcessor {
  static Future<List<GenerationModel>> processBatch({
    required List<BatchItem> items,
    required GenerationMode mode,
    Function(int completed, int total)? onProgress,
  }) async {
    final results = <GenerationModel>[];
    final rateLimiter = RateLimiter(maxConcurrent: 3);
    
    // Group by similar styles for efficiency
    final grouped = _groupByStyle(items);
    
    for (final group in grouped.entries) {
      final style = group.key;
      final groupItems = group.value;
      
      // Process group concurrently with rate limiting
      final futures = groupItems.map((item) async {
        await rateLimiter.acquire();
        
        try {
          final result = await _processItem(item, style, mode);
          
          if (onProgress != null) {
            onProgress(results.length + 1, items.length);
          }
          
          return result;
        } finally {
          rateLimiter.release();
        }
      });
      
      results.addAll(await Future.wait(futures));
    }
    
    return results;
  }
  
  static Map<String, List<BatchItem>> _groupByStyle(List<BatchItem> items) {
    final grouped = <String, List<BatchItem>>{};
    
    for (final item in items) {
      grouped.putIfAbsent(item.style, () => []).add(item);
    }
    
    return grouped;
  }
}
```

### 10. Post-Processing

#### Image Optimization
```dart
class PODPostProcessor {
  static Future<ProcessedImage> optimizeForPOD({
    required Uint8List imageData,
    required PODSpecifications specs,
  }) async {
    // Ensure transparent background
    var processed = await _ensureTransparency(imageData);
    
    // Optimize colors
    processed = await _optimizeColors(processed, specs.colorProfile);
    
    // Validate dimensions
    processed = await _validateDimensions(processed, specs.printAreas);
    
    // Add metadata
    processed = await _addPODMetadata(processed, specs);
    
    return ProcessedImage(
      data: processed,
      metadata: _extractMetadata(processed),
      validationReport: _validateFinal(processed, specs),
    );
  }
  
  static Future<Uint8List> _ensureTransparency(Uint8List data) async {
    final image = img.decodeImage(data)!;
    
    // Remove white/light backgrounds
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final pixel = image.getPixel(x, y);
        
        if (_isBackgroundColor(pixel)) {
          image.setPixelRgba(x, y, 0, 0, 0, 0);  // Transparent
        }
      }
    }
    
    return Uint8List.fromList(img.encodePng(image));
  }
}
```

## Best Practices

### Prompt Engineering
1. **Always include technical specs** in prompts
2. **Specify transparent background** explicitly
3. **Limit color palette** for cost efficiency
4. **Include style keywords** for consistency
5. **Add negative prompts** to avoid common issues

### Quality Control
1. **Validate before generation** to save costs
2. **Use preview mode** for iteration
3. **Check contrast ratios** for readability
4. **Verify dimensions** match POD requirements
5. **Test on different backgrounds**

### Cost Optimization
1. **Start with fast/cheap models** for concepts
2. **Use high-quality models** only for finals
3. **Batch similar designs** together
4. **Cache successful prompts** for reuse
5. **Track cost per design** for budgeting

## Common Issues & Solutions

### Issue: Low Text Contrast
```dart
// Solution: Enforce contrast in prompt
prompt += ', high contrast text, bold readable typography, '
         'text clearly visible on both light and dark backgrounds';
```

### Issue: Too Many Colors
```dart
// Solution: Limit palette in prompt
prompt += ', limited color palette with maximum 3 colors, '
         'cohesive color scheme, cost-efficient design';
```

### Issue: Background Not Transparent
```dart
// Solution: Emphasize transparency
prompt += ', transparent PNG background, no background color, '
         'isolated design on transparent canvas, cutout style';
```

## Performance Benchmarks

- Prompt enhancement: < 50ms
- Validation: < 100ms
- Batch processing: 3 concurrent max
- Post-processing: < 2s per image
- Total generation: 2-50s depending on model