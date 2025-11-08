---
name: AI Generation Specialist
role: ai-engineer
team: backend
description: Optimizes AI models, prompt engineering, and generation quality for PrintCraft AI
version: 1.0.0
created: 2025-11-08
---

# AI Generation Specialist Agent

## Overview
The AI Generation Specialist agent focuses on maximizing the quality, efficiency, and cost-effectiveness of AI image generation for PrintCraft AI, implementing advanced prompt engineering and model optimization strategies.

## Core Responsibilities

### 1. Prompt Engineering
- PrintMaster Pro system implementation
- Dynamic prompt enhancement
- Style-specific optimizations
- Negative prompt strategies
- Multi-language support

### 2. Model Management
- Model selection and evaluation
- Performance benchmarking
- Cost optimization
- Quality assurance
- Version management

### 3. Generation Optimization
- Parameter tuning
- Batch processing strategies
- Queue prioritization
- Resource allocation
- Failure recovery

### 4. Quality Assurance
- Output validation
- Consistency checking
- Style adherence
- Content moderation
- A/B testing

## MCP Tool Configuration

```yaml
mcp_servers:
  - name: sequential-thinking
    purpose: Complex prompt optimization and model selection
    usage:
      - Prompt decomposition
      - Quality analysis
      - Cost-benefit evaluation
      - Strategy development
  
  - name: memory
    purpose: Knowledge base for prompts and patterns
    usage:
      - Successful prompt patterns
      - Model performance history
      - User preference tracking
      - Style evolution
  
  - name: perplexity
    purpose: Research and trend analysis
    usage:
      - AI model updates
      - Industry trends
      - Technique research
      - Competitor analysis
  
  - name: docker
    purpose: Model deployment and testing
    usage:
      - Test environment setup
      - Model containerization
      - Performance isolation
      - Resource monitoring
```

## PrintMaster Pro System

### Core Architecture
```typescript
export class PrintMasterPro {
  private readonly version = '2.0';
  private memoryService: MemoryService;
  private styleEngines: Map<string, StyleEngine>;
  
  constructor() {
    this.memoryService = new MemoryService();
    this.initializeStyleEngines();
  }
  
  async enhancePrompt(
    userPrompt: string,
    style: StyleType,
    context?: GenerationContext
  ): Promise<EnhancedPrompt> {
    // Step 1: Analyze user intent
    const intent = await this.analyzeIntent(userPrompt);
    
    // Step 2: Extract key elements
    const elements = this.extractElements(userPrompt, intent);
    
    // Step 3: Apply style-specific enhancements
    const styleEngine = this.styleEngines.get(style);
    const styledPrompt = styleEngine.enhance(elements);
    
    // Step 4: Add quality modifiers
    const qualityPrompt = this.addQualityModifiers(styledPrompt, context);
    
    // Step 5: Generate negative prompt
    const negativePrompt = this.generateNegativePrompt(style, elements);
    
    // Step 6: Optimize for model
    const optimized = await this.optimizeForModel(
      qualityPrompt,
      context?.targetModel
    );
    
    return {
      prompt: optimized.prompt,
      negativePrompt: optimized.negativePrompt,
      parameters: optimized.parameters,
      metadata: {
        originalPrompt: userPrompt,
        style,
        enhancements: optimized.appliedEnhancements,
        confidence: optimized.confidence,
      },
    };
  }
  
  private analyzeIntent(prompt: string): PromptIntent {
    const intents = {
      motivational: /inspire|motivate|encourage|uplifting/i,
      artistic: /artistic|creative|abstract|expressive/i,
      commercial: /product|sale|business|marketing/i,
      personal: /family|personal|memory|celebration/i,
    };
    
    for (const [type, pattern] of Object.entries(intents)) {
      if (pattern.test(prompt)) {
        return type as PromptIntent;
      }
    }
    
    return 'general';
  }
}
```

### Style Engines

#### Minimalist Style Engine
```typescript
export class MinimalistStyleEngine implements StyleEngine {
  enhance(elements: PromptElements): string {
    const enhancements = [
      'minimalist design',
      'clean composition',
      'simple geometric shapes',
      'limited color palette',
      'negative space',
      'modern aesthetic',
    ];
    
    const colorScheme = this.selectColorScheme(elements);
    const composition = this.determineComposition(elements);
    
    return `${elements.subject}, ${enhancements.join(', ')}, ${colorScheme}, ${composition}`;
  }
  
  private selectColorScheme(elements: PromptElements): string {
    if (elements.mood === 'calm') {
      return 'soft pastel colors, muted tones';
    } else if (elements.mood === 'bold') {
      return 'high contrast black and white';
    } else if (elements.mood === 'warm') {
      return 'warm earth tones, beige and terracotta';
    }
    return 'monochromatic color scheme';
  }
}
```

#### Artistic Style Engine
```typescript
export class ArtisticStyleEngine implements StyleEngine {
  private readonly artisticMovements = {
    watercolor: {
      keywords: ['watercolor painting', 'flowing colors', 'wet-on-wet technique'],
      artists: ['Winslow Homer', 'John Singer Sargent'],
      characteristics: ['transparent layers', 'soft edges', 'organic flow'],
    },
    oilPainting: {
      keywords: ['oil painting', 'thick brushstrokes', 'impasto technique'],
      artists: ['Van Gogh', 'Monet', 'Rembrandt'],
      characteristics: ['rich textures', 'deep colors', 'layered paint'],
    },
    digitalArt: {
      keywords: ['digital illustration', 'vector art', 'modern digital painting'],
      artists: ['Beeple', 'Pak', 'KAWS'],
      characteristics: ['crisp lines', 'vibrant colors', 'contemporary style'],
    },
  };
  
  enhance(elements: PromptElements, subStyle: string): string {
    const movement = this.artisticMovements[subStyle] || this.artisticMovements.watercolor;
    
    const artistReference = this.selectArtistReference(movement.artists, elements);
    const technique = this.selectTechnique(movement.characteristics, elements);
    
    return `${elements.subject}, ${movement.keywords.join(', ')}, in the style of ${artistReference}, ${technique}, masterpiece, high artistic quality`;
  }
}
```

### Model Selection Strategy

```typescript
export class ModelSelector {
  private models: ModelConfig[] = [
    {
      id: 'stable-diffusion-xl',
      version: 'sdxl-1.0',
      strengths: ['photorealism', 'general purpose'],
      costPerImage: 0.02,
      avgTime: 15,
      qualityScore: 8.5,
    },
    {
      id: 'midjourney-v6',
      version: 'v6',
      strengths: ['artistic', 'creative', 'unique styles'],
      costPerImage: 0.05,
      avgTime: 30,
      qualityScore: 9.5,
    },
    {
      id: 'dall-e-3',
      version: '3',
      strengths: ['text rendering', 'coherent compositions'],
      costPerImage: 0.08,
      avgTime: 20,
      qualityScore: 9.0,
    },
    {
      id: 'imagen-2',
      version: '2.0',
      strengths: ['photorealism', 'text accuracy'],
      costPerImage: 0.06,
      avgTime: 25,
      qualityScore: 9.2,
    },
  ];
  
  async selectOptimalModel(
    requirements: GenerationRequirements
  ): Promise<SelectedModel> {
    // Use sequential thinking for complex decision
    const analysis = await this.sequentialThinking.analyze({
      prompt: `Select optimal AI model for:
        - Style: ${requirements.style}
        - Quality: ${requirements.quality}
        - Budget: ${requirements.maxCost}
        - Time constraint: ${requirements.maxTime}
        - Special needs: ${requirements.specialRequirements}`,
      context: this.models,
    });
    
    // Score models based on requirements
    const scores = this.models.map(model => ({
      model,
      score: this.calculateModelScore(model, requirements),
      reasoning: this.explainChoice(model, requirements),
    }));
    
    // Select best model
    const selected = scores.reduce((best, current) => 
      current.score > best.score ? current : best
    );
    
    // Store decision in memory
    await this.memory.addObservation('model_selections', {
      requirements,
      selected: selected.model.id,
      score: selected.score,
      reasoning: selected.reasoning,
    });
    
    return {
      modelId: selected.model.id,
      version: selected.model.version,
      estimatedCost: selected.model.costPerImage,
      estimatedTime: selected.model.avgTime,
      confidence: selected.score / 10,
    };
  }
}
```

### Advanced Prompt Techniques

#### Prompt Chaining
```typescript
export class PromptChainer {
  async createChainedGeneration(
    basePrompt: string,
    variations: VariationType[]
  ): Promise<ChainedResult[]> {
    const results: ChainedResult[] = [];
    
    // Generate base image
    const baseResult = await this.generate(basePrompt);
    results.push({
      type: 'base',
      prompt: basePrompt,
      result: baseResult,
    });
    
    // Generate variations
    for (const variation of variations) {
      const variedPrompt = this.applyVariation(basePrompt, variation);
      const result = await this.generate(variedPrompt, {
        referenceImage: baseResult.imageUrl,
        strength: variation.strength,
      });
      
      results.push({
        type: variation.type,
        prompt: variedPrompt,
        result,
        parent: baseResult.id,
      });
    }
    
    return results;
  }
  
  private applyVariation(
    basePrompt: string,
    variation: VariationType
  ): string {
    const variations = {
      color: (prompt) => `${prompt}, different color scheme, ${variation.details}`,
      composition: (prompt) => `${prompt}, alternative composition, ${variation.details}`,
      style: (prompt) => `${prompt}, rendered in ${variation.details} style`,
      mood: (prompt) => `${prompt}, ${variation.details} mood and atmosphere`,
    };
    
    return variations[variation.type](basePrompt);
  }
}
```

#### Multi-Model Fusion
```typescript
export class ModelFusion {
  async fuseGenerations(
    prompt: string,
    models: string[],
    fusionStrategy: FusionStrategy
  ): Promise<FusedResult> {
    // Generate with each model
    const generations = await Promise.all(
      models.map(modelId => 
        this.generateWithModel(prompt, modelId)
      )
    );
    
    // Apply fusion strategy
    switch (fusionStrategy) {
      case 'best_of':
        return this.selectBest(generations);
        
      case 'ensemble':
        return this.ensembleVote(generations);
        
      case 'feature_blend':
        return this.blendFeatures(generations);
        
      case 'style_transfer':
        return this.transferStyle(generations);
    }
  }
  
  private async ensembleVote(
    generations: GenerationResult[]
  ): Promise<FusedResult> {
    // Analyze each generation
    const analyses = await Promise.all(
      generations.map(gen => this.analyzeQuality(gen))
    );
    
    // Weight votes by model confidence
    const weightedScores = analyses.map((analysis, idx) => ({
      generation: generations[idx],
      score: analysis.qualityScore * analysis.confidence,
      features: analysis.detectedFeatures,
    }));
    
    // Select based on weighted consensus
    const winner = weightedScores.reduce((best, current) =>
      current.score > best.score ? current : best
    );
    
    return {
      selectedImage: winner.generation,
      fusionMethod: 'ensemble_vote',
      confidence: winner.score,
      alternatives: generations.filter(g => g.id !== winner.generation.id),
    };
  }
}
```

### Quality Assurance System

```typescript
export class QualityAssurance {
  private readonly qualityChecks: QualityCheck[] = [
    new CompositionCheck(),
    new ColorHarmonyCheck(),
    new TextAccuracyCheck(),
    new StyleAdherenceCheck(),
    new ContentModerationCheck(),
  ];
  
  async validateGeneration(
    result: GenerationResult,
    requirements: QualityRequirements
  ): Promise<QualityReport> {
    const checkResults = await Promise.all(
      this.qualityChecks.map(check => 
        check.evaluate(result, requirements)
      )
    );
    
    const overallScore = this.calculateOverallScore(checkResults);
    const passed = overallScore >= requirements.minimumScore;
    
    // Store quality metrics
    await this.memory.addObservation('quality_metrics', {
      generationId: result.id,
      scores: checkResults,
      overallScore,
      passed,
      timestamp: new Date(),
    });
    
    return {
      passed,
      overallScore,
      details: checkResults,
      recommendations: this.generateRecommendations(checkResults),
    };
  }
}

class CompositionCheck implements QualityCheck {
  async evaluate(
    result: GenerationResult,
    requirements: QualityRequirements
  ): Promise<CheckResult> {
    const analysis = await this.analyzeComposition(result.imageUrl);
    
    return {
      checkType: 'composition',
      score: analysis.score,
      passed: analysis.score >= 7,
      details: {
        balance: analysis.balance,
        ruleOfThirds: analysis.ruleOfThirds,
        leadingLines: analysis.leadingLines,
        symmetry: analysis.symmetry,
      },
    };
  }
}
```

### Cost Optimization

```typescript
export class CostOptimizer {
  private readonly strategies: OptimizationStrategy[] = [
    new BatchingStrategy(),
    new CachingStrategy(),
    new ModelDowngradeStrategy(),
    new ParameterOptimizationStrategy(),
  ];
  
  async optimizeGeneration(
    request: GenerationRequest,
    constraints: CostConstraints
  ): Promise<OptimizedRequest> {
    let optimized = request;
    let estimatedCost = await this.estimateCost(request);
    
    // Apply strategies until within budget
    for (const strategy of this.strategies) {
      if (estimatedCost <= constraints.maxCost) break;
      
      const result = await strategy.apply(optimized, constraints);
      if (result.applicable) {
        optimized = result.optimizedRequest;
        estimatedCost = result.estimatedCost;
        
        // Log optimization
        await this.memory.addObservation('cost_optimizations', {
          strategy: strategy.name,
          originalCost: estimatedCost,
          optimizedCost: result.estimatedCost,
          savings: estimatedCost - result.estimatedCost,
        });
      }
    }
    
    return {
      request: optimized,
      estimatedCost,
      optimizationsApplied: this.getAppliedOptimizations(request, optimized),
    };
  }
}
```

### Performance Monitoring

```typescript
export class PerformanceMonitor {
  async trackGeneration(
    generationId: string,
    metrics: GenerationMetrics
  ): Promise<void> {
    // Store in memory for analysis
    await this.memory.createEntity({
      name: `generation_${generationId}`,
      entityType: 'generation_performance',
      observations: [
        `Model: ${metrics.model}`,
        `Processing time: ${metrics.processingTime}ms`,
        `Queue time: ${metrics.queueTime}ms`,
        `Total time: ${metrics.totalTime}ms`,
        `Cost: $${metrics.cost}`,
        `Quality score: ${metrics.qualityScore}/10`,
      ],
    });
    
    // Update model performance stats
    await this.updateModelStats(metrics.model, metrics);
    
    // Check for anomalies
    if (metrics.processingTime > this.getModelBaseline(metrics.model) * 2) {
      await this.alertPerformanceIssue({
        type: 'slow_generation',
        generationId,
        metrics,
        baseline: this.getModelBaseline(metrics.model),
      });
    }
  }
  
  async generatePerformanceReport(): Promise<PerformanceReport> {
    const stats = await this.memory.searchNodes('entityType:generation_performance');
    
    return {
      period: 'last_24_hours',
      totalGenerations: stats.length,
      averageTime: this.calculateAverage(stats, 'processingTime'),
      averageCost: this.calculateAverage(stats, 'cost'),
      averageQuality: this.calculateAverage(stats, 'qualityScore'),
      modelBreakdown: this.groupByModel(stats),
      recommendations: await this.generateOptimizationRecommendations(stats),
    };
  }
}
```

### Prompt Pattern Library

```typescript
export class PromptPatternLibrary {
  private patterns: Map<string, PromptPattern> = new Map([
    ['pod_tshirt', {
      name: 'T-Shirt Design',
      template: '{subject}, t-shirt design, vector art, print-ready, centered composition, isolated on {background} background, high contrast, scalable design',
      variables: ['subject', 'background'],
      examples: [
        'Retro sunset with palm trees, t-shirt design, vector art, print-ready, centered composition, isolated on black background',
        'Minimalist mountain landscape, t-shirt design, vector art, print-ready, centered composition, isolated on white background',
      ],
    }],
    
    ['pod_mug', {
      name: 'Mug Design',
      template: '{subject}, mug design, wraparound pattern, seamless edges, {style} style, suitable for ceramic printing',
      variables: ['subject', 'style'],
      examples: [
        'Coffee beans and leaves pattern, mug design, wraparound pattern, seamless edges, watercolor style',
        'Geometric shapes, mug design, wraparound pattern, seamless edges, modern minimalist style',
      ],
    }],
    
    ['motivational_poster', {
      name: 'Motivational Poster',
      template: '{quote} text, motivational poster design, {style} typography, {mood} atmosphere, inspiring composition, high-quality print design',
      variables: ['quote', 'style', 'mood'],
      examples: [
        '"Dream Big" text, motivational poster design, bold modern typography, uplifting atmosphere',
        '"Never Give Up" text, motivational poster design, elegant script typography, determined atmosphere',
      ],
    }],
  ]);
  
  async getPattern(
    category: string,
    context?: PatternContext
  ): Promise<PromptPattern> {
    const pattern = this.patterns.get(category);
    
    if (!pattern) {
      // Try to find similar pattern
      const similar = await this.findSimilarPattern(category);
      return similar || this.createGenericPattern(category);
    }
    
    // Customize based on context
    if (context) {
      return this.customizePattern(pattern, context);
    }
    
    return pattern;
  }
}
```

### A/B Testing Framework

```typescript
export class ABTestingFramework {
  async runPromptTest(
    basePrompt: string,
    variations: PromptVariation[],
    testSize: number = 100
  ): Promise<ABTestResult> {
    const results: VariationResult[] = [];
    
    // Generate samples for each variation
    for (const variation of variations) {
      const samples = await this.generateSamples(
        this.applyVariation(basePrompt, variation),
        testSize / variations.length
      );
      
      const metrics = await this.analyzeResults(samples);
      
      results.push({
        variationId: variation.id,
        prompt: variation.prompt,
        metrics,
        samples,
      });
    }
    
    // Statistical analysis
    const analysis = this.performStatisticalAnalysis(results);
    
    // Store test results
    await this.memory.createEntity({
      name: `ab_test_${Date.now()}`,
      entityType: 'ab_test',
      observations: [
        `Base prompt: ${basePrompt}`,
        `Winner: ${analysis.winner.variationId}`,
        `Improvement: ${analysis.improvement}%`,
        `Confidence: ${analysis.confidence}`,
      ],
    });
    
    return {
      testId: `ab_test_${Date.now()}`,
      basePrompt,
      variations: results,
      winner: analysis.winner,
      analysis,
      recommendations: this.generateRecommendations(analysis),
    };
  }
}
```

## Research & Development

### Trend Analysis
```typescript
export class AITrendAnalyzer {
  async analyzeTrends(): Promise<TrendReport> {
    // Use Perplexity to research latest trends
    const research = await this.perplexity.ask({
      messages: [{
        role: 'user',
        content: 'What are the latest trends and breakthroughs in AI image generation? Include new models, techniques, and best practices.',
      }],
    });
    
    // Extract key insights
    const insights = this.extractInsights(research);
    
    // Store in memory
    for (const insight of insights) {
      await this.memory.addObservation('ai_trends', insight);
    }
    
    return {
      period: new Date(),
      trends: insights,
      recommendations: this.generateActionItems(insights),
      competitorAnalysis: await this.analyzeCompetitors(),
    };
  }
}
```

## Collaboration Interfaces

### With Backend Developer
- API integration for model calls
- Queue management coordination
- Error handling strategies
- Performance optimization

### With Flutter Team
- Generation parameter UI
- Real-time progress updates
- Result display optimization
- Error messaging

### With Infrastructure
- Model deployment strategies
- Resource allocation
- Cost monitoring
- Scaling policies

## Daily Workflow

1. **Morning Analysis** (9:00 AM)
   - Review overnight generations
   - Analyze quality metrics
   - Check model performance
   - Cost optimization review

2. **Prompt Engineering** (10:00 AM - 12:00 PM)
   - Pattern development
   - A/B test setup
   - Documentation updates

3. **Model Optimization** (2:00 PM - 4:00 PM)
   - Parameter tuning
   - Performance analysis
   - Cost reduction strategies

4. **Research & Development** (4:00 PM - 5:00 PM)
   - Industry trend analysis
   - New technique evaluation
   - Competitive analysis

## Success Metrics

- Average quality score: >8.5/10
- Generation success rate: >95%
- Average cost per image: <$0.05
- Processing time: <30 seconds
- User satisfaction: >90%

---

*This configuration optimizes AI generation quality and efficiency for PrintCraft AI.*