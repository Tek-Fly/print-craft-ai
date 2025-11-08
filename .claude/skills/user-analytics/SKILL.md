---
name: user-analytics
version: 1.0.0
description: Expertise in user behavior analytics, A/B testing, and data-driven insights
author: PrintCraft AI Team
tags:
  - analytics
  - metrics
  - user-behavior
  - data-analysis
---

# User Analytics Skill

## Overview
This skill provides comprehensive user analytics capabilities including event tracking, user journey analysis, A/B testing frameworks, and actionable insights generation for PrintCraft AI.

## Core Competencies

### 1. Event Tracking Implementation

#### Flutter Analytics Integration
```dart
// Analytics service for Flutter
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  
  final FirebaseAnalytics _firebase = FirebaseAnalytics.instance;
  final List<AnalyticsProvider> _providers = [];
  
  // Initialize analytics providers
  Future<void> initialize() async {
    // Firebase Analytics
    await _firebase.setAnalyticsCollectionEnabled(true);
    
    // Add custom providers
    _providers.addAll([
      MixpanelProvider(token: Environment.mixpanelToken),
      AmplitudeProvider(apiKey: Environment.amplitudeKey),
      CustomAnalyticsProvider(endpoint: Environment.analyticsEndpoint),
    ]);
    
    // Set user properties
    await _setDefaultUserProperties();
  }
  
  // Track events with automatic enrichment
  Future<void> track(String eventName, [Map<String, dynamic>? parameters]) async {
    final enrichedParams = await _enrichParameters(parameters ?? {});
    
    // Log to all providers
    await Future.wait([
      _firebase.logEvent(name: eventName, parameters: enrichedParams),
      ..._providers.map((p) => p.track(eventName, enrichedParams)),
    ]);
    
    // Store locally for offline support
    await _storeLocalEvent(eventName, enrichedParams);
  }
  
  // Screen view tracking with timing
  Future<void> trackScreenView({
    required String screenName,
    String? screenClass,
    Map<String, dynamic>? parameters,
  }) async {
    final startTime = DateTime.now();
    
    await _firebase.setCurrentScreen(
      screenName: screenName,
      screenClassOverride: screenClass,
    );
    
    await track('screen_view', {
      'screen_name': screenName,
      'screen_class': screenClass,
      'previous_screen': _previousScreen,
      'transition_time': _transitionTime,
      ...?parameters,
    });
    
    _previousScreen = screenName;
    _screenStartTime = startTime;
  }
  
  // User action tracking
  Future<void> trackAction({
    required String action,
    required String category,
    String? label,
    num? value,
    Map<String, dynamic>? metadata,
  }) async {
    await track('user_action', {
      'action': action,
      'category': category,
      'label': label,
      'value': value,
      'interaction_time': DateTime.now().millisecondsSinceEpoch,
      ...?metadata,
    });
  }
  
  // Generation tracking with detailed metrics
  Future<void> trackGeneration({
    required String generationId,
    required String status,
    required GenerationMetrics metrics,
  }) async {
    await track('generation_${status}', {
      'generation_id': generationId,
      'prompt_length': metrics.promptLength,
      'style': metrics.style,
      'quality': metrics.quality,
      'processing_time': metrics.processingTime,
      'model_used': metrics.modelUsed,
      'cost': metrics.cost,
      'error_code': metrics.errorCode,
      'retry_count': metrics.retryCount,
    });
  }
  
  // Conversion tracking
  Future<void> trackConversion({
    required String conversionType,
    required double value,
    String? currency,
    Map<String, dynamic>? items,
  }) async {
    await track('conversion', {
      'conversion_type': conversionType,
      'value': value,
      'currency': currency ?? 'USD',
      'items': items,
      'conversion_path': await _getConversionPath(),
    });
    
    // Special handling for revenue events
    if (conversionType == 'purchase') {
      await _firebase.logPurchase(
        currency: currency ?? 'USD',
        value: value,
        items: _convertToFirebaseItems(items),
      );
    }
  }
  
  // Automatic parameter enrichment
  Future<Map<String, dynamic>> _enrichParameters(
    Map<String, dynamic> params,
  ) async {
    final deviceInfo = await DeviceInfoPlugin().deviceInfo;
    final packageInfo = await PackageInfo.fromPlatform();
    
    return {
      ...params,
      'timestamp': DateTime.now().toIso8601String(),
      'session_id': _sessionId,
      'user_id': _userId,
      'device_id': _deviceId,
      'platform': Platform.operatingSystem,
      'app_version': packageInfo.version,
      'build_number': packageInfo.buildNumber,
      'device_model': deviceInfo.model,
      'os_version': deviceInfo.systemVersion,
      'screen_resolution': '${window.physicalSize.width}x${window.physicalSize.height}',
      'locale': Platform.localeName,
      'timezone': DateTime.now().timeZoneName,
      'connection_type': await _getConnectionType(),
    };
  }
}
```

#### Backend Analytics Collection
```typescript
export class AnalyticsCollector {
  private readonly queue: AnalyticsQueue;
  private readonly storage: AnalyticsStorage;
  
  constructor() {
    this.queue = new AnalyticsQueue({
      batchSize: 100,
      flushInterval: 5000, // 5 seconds
    });
    
    this.storage = new AnalyticsStorage({
      retention: 90, // days
      compression: true,
    });
  }
  
  // Middleware for automatic API tracking
  trackAPIUsage() {
    return async (req: Request, res: Response, next: NextFunction) => {
      const startTime = process.hrtime.bigint();
      const requestId = req.headers['x-request-id'] || uuidv4();
      
      // Capture request details
      const event: APIEvent = {
        eventType: 'api_request',
        timestamp: new Date(),
        requestId,
        userId: req.user?.id,
        method: req.method,
        endpoint: req.route?.path || req.path,
        query: req.query,
        headers: this.sanitizeHeaders(req.headers),
        ip: req.ip,
        userAgent: req.headers['user-agent'],
      };
      
      // Intercept response
      const originalSend = res.send;
      res.send = function(data: any) {
        const endTime = process.hrtime.bigint();
        const duration = Number(endTime - startTime) / 1e6; // milliseconds
        
        // Complete event
        event.responseStatus = res.statusCode;
        event.responseTime = duration;
        event.responseSize = Buffer.byteLength(data);
        
        // Queue for processing
        this.queue.push(event);
        
        return originalSend.call(this, data);
      }.bind(this);
      
      next();
    };
  }
  
  // Track custom events
  async track(event: AnalyticsEvent): Promise<void> {
    // Validate event
    const validationResult = this.validateEvent(event);
    if (!validationResult.valid) {
      throw new Error(`Invalid event: ${validationResult.errors.join(', ')}`);
    }
    
    // Enrich event
    const enrichedEvent = this.enrichEvent(event);
    
    // Add to queue
    await this.queue.push(enrichedEvent);
    
    // Real-time processing for critical events
    if (event.priority === 'high') {
      await this.processImmediately(enrichedEvent);
    }
  }
  
  // Batch processing
  async processBatch(events: AnalyticsEvent[]): Promise<void> {
    // Group by event type
    const grouped = this.groupBy(events, 'eventType');
    
    // Process each group
    await Promise.all(
      Object.entries(grouped).map(async ([type, typeEvents]) => {
        await this.processEventType(type, typeEvents);
      })
    );
    
    // Store raw events
    await this.storage.store(events);
    
    // Update aggregates
    await this.updateAggregates(events);
    
    // Trigger alerts if needed
    await this.checkAlertConditions(events);
  }
}
```

### 2. User Journey Analysis

#### Journey Mapping
```typescript
export class UserJourneyAnalyzer {
  // Track user journey through the app
  async analyzeJourney(userId: string): Promise<UserJourney> {
    // Get user events
    const events = await this.getUserEvents(userId, {
      limit: 1000,
      timeRange: '30d',
    });
    
    // Build journey map
    const journey = this.buildJourneyMap(events);
    
    // Identify patterns
    const patterns = this.identifyPatterns(journey);
    
    // Calculate metrics
    const metrics = this.calculateJourneyMetrics(journey);
    
    // Find drop-off points
    const dropOffPoints = this.findDropOffPoints(journey);
    
    // Generate insights
    const insights = await this.generateInsights({
      journey,
      patterns,
      metrics,
      dropOffPoints,
    });
    
    return {
      userId,
      journey,
      patterns,
      metrics,
      dropOffPoints,
      insights,
    };
  }
  
  private buildJourneyMap(events: AnalyticsEvent[]): JourneyMap {
    const sessions = this.groupIntoSessions(events);
    const journeyMap: JourneyMap = {
      nodes: new Map(),
      edges: new Map(),
      sessions,
    };
    
    sessions.forEach(session => {
      let previousEvent: AnalyticsEvent | null = null;
      
      session.events.forEach(event => {
        // Add node
        const nodeId = this.getNodeId(event);
        if (!journeyMap.nodes.has(nodeId)) {
          journeyMap.nodes.set(nodeId, {
            id: nodeId,
            type: event.eventType,
            name: event.eventName,
            count: 0,
            totalDuration: 0,
            conversions: 0,
          });
        }
        
        const node = journeyMap.nodes.get(nodeId)!;
        node.count++;
        
        // Add edge
        if (previousEvent) {
          const edgeId = `${this.getNodeId(previousEvent)}->${nodeId}`;
          if (!journeyMap.edges.has(edgeId)) {
            journeyMap.edges.set(edgeId, {
              id: edgeId,
              source: this.getNodeId(previousEvent),
              target: nodeId,
              count: 0,
              averageDuration: 0,
            });
          }
          
          const edge = journeyMap.edges.get(edgeId)!;
          edge.count++;
          edge.averageDuration = this.updateAverage(
            edge.averageDuration,
            event.timestamp - previousEvent.timestamp,
            edge.count
          );
        }
        
        previousEvent = event;
      });
    });
    
    return journeyMap;
  }
  
  private identifyPatterns(journey: JourneyMap): Pattern[] {
    const patterns: Pattern[] = [];
    
    // Common paths
    const commonPaths = this.findCommonPaths(journey, {
      minSupport: 0.1, // 10% of users
      maxLength: 10,
    });
    patterns.push(...commonPaths);
    
    // Loops and returns
    const loops = this.findLoops(journey);
    patterns.push(...loops);
    
    // Fast/slow paths
    const speedPatterns = this.analyzePathSpeed(journey);
    patterns.push(...speedPatterns);
    
    // Success patterns
    const successPatterns = this.findSuccessPatterns(journey);
    patterns.push(...successPatterns);
    
    return patterns;
  }
  
  // Funnel analysis
  async analyzeFunnel(
    funnelDefinition: FunnelDefinition
  ): Promise<FunnelAnalysis> {
    const results: FunnelAnalysis = {
      funnel: funnelDefinition,
      steps: [],
      overallConversion: 0,
      averageTime: 0,
    };
    
    // Get users who entered the funnel
    const enteredUsers = await this.getUsersAtStep(funnelDefinition.steps[0]);
    let currentUsers = new Set(enteredUsers);
    
    // Analyze each step
    for (let i = 0; i < funnelDefinition.steps.length; i++) {
      const step = funnelDefinition.steps[i];
      const stepUsers = await this.getUsersAtStep(step);
      const convertedUsers = new Set(
        [...currentUsers].filter(u => stepUsers.has(u))
      );
      
      const conversionRate = currentUsers.size > 0
        ? convertedUsers.size / currentUsers.size
        : 0;
      
      results.steps.push({
        step,
        users: convertedUsers.size,
        conversionRate,
        dropOff: currentUsers.size - convertedUsers.size,
        averageTime: await this.getAverageTimeBetweenSteps(
          i > 0 ? funnelDefinition.steps[i - 1] : null,
          step
        ),
      });
      
      currentUsers = convertedUsers;
    }
    
    results.overallConversion = currentUsers.size / enteredUsers.size;
    results.averageTime = results.steps.reduce(
      (sum, step) => sum + step.averageTime,
      0
    );
    
    return results;
  }
}
```

### 3. A/B Testing Framework

#### A/B Test Implementation
```typescript
export class ABTestingFramework {
  private tests: Map<string, ABTest> = new Map();
  
  // Create and configure A/B test
  async createTest(config: ABTestConfig): Promise<ABTest> {
    const test: ABTest = {
      id: uuidv4(),
      name: config.name,
      hypothesis: config.hypothesis,
      variants: config.variants,
      allocation: config.allocation || this.calculateAllocation(config.variants),
      targeting: config.targeting,
      metrics: config.metrics,
      status: 'draft',
      createdAt: new Date(),
      statistics: {
        sampleSize: this.calculateSampleSize(config),
        duration: this.estimateDuration(config),
        confidence: config.confidence || 0.95,
        power: config.power || 0.8,
      },
    };
    
    // Validate test
    await this.validateTest(test);
    
    // Store test
    this.tests.set(test.id, test);
    await this.storage.saveTest(test);
    
    return test;
  }
  
  // Start A/B test
  async startTest(testId: string): Promise<void> {
    const test = this.tests.get(testId);
    if (!test) throw new Error('Test not found');
    
    if (test.status !== 'draft') {
      throw new Error(`Cannot start test in ${test.status} status`);
    }
    
    test.status = 'running';
    test.startedAt = new Date();
    
    // Initialize metrics collection
    await this.initializeMetrics(test);
    
    // Start traffic allocation
    await this.startTrafficAllocation(test);
    
    // Schedule analysis
    this.scheduleAnalysis(test);
    
    await this.storage.updateTest(test);
  }
  
  // Get variant for user
  async getVariant(testId: string, userId: string): Promise<Variant> {
    const test = this.tests.get(testId);
    if (!test || test.status !== 'running') {
      return { id: 'control', name: 'Control' };
    }
    
    // Check targeting
    if (test.targeting && !await this.matchesTargeting(userId, test.targeting)) {
      return { id: 'control', name: 'Control' };
    }
    
    // Check if user already assigned
    const existingAssignment = await this.getAssignment(testId, userId);
    if (existingAssignment) {
      return existingAssignment;
    }
    
    // Assign variant
    const variant = this.assignVariant(test, userId);
    await this.saveAssignment(testId, userId, variant);
    
    // Track assignment
    await this.trackAssignment(test, userId, variant);
    
    return variant;
  }
  
  // Analyze test results
  async analyzeTest(testId: string): Promise<TestAnalysis> {
    const test = this.tests.get(testId);
    if (!test) throw new Error('Test not found');
    
    const analysis: TestAnalysis = {
      test,
      variants: [],
      winner: null,
      confidence: 0,
      recommendation: '',
    };
    
    // Get data for each variant
    for (const variant of test.variants) {
      const data = await this.getVariantData(test, variant);
      const stats = this.calculateStatistics(data, test.metrics);
      
      analysis.variants.push({
        variant,
        users: data.users,
        ...stats,
      });
    }
    
    // Perform statistical tests
    const significance = await this.performSignificanceTest(analysis.variants);
    
    // Determine winner
    if (significance.significant) {
      analysis.winner = significance.winner;
      analysis.confidence = significance.confidence;
    }
    
    // Generate recommendation
    analysis.recommendation = this.generateRecommendation(analysis, significance);
    
    // Check for early stopping
    if (this.shouldStopEarly(analysis)) {
      await this.stopTest(testId, 'early_stopping');
    }
    
    return analysis;
  }
  
  // Statistical significance testing
  private async performSignificanceTest(
    variants: VariantData[]
  ): Promise<SignificanceResult> {
    // Use appropriate test based on metric type
    const control = variants.find(v => v.variant.id === 'control');
    const treatment = variants.find(v => v.variant.id !== 'control');
    
    if (!control || !treatment) {
      throw new Error('Missing control or treatment variant');
    }
    
    // For conversion metrics - Chi-square test
    if (this.isConversionMetric(control.metric)) {
      return this.chiSquareTest(control, treatment);
    }
    
    // For continuous metrics - t-test
    return this.tTest(control, treatment);
  }
  
  private chiSquareTest(
    control: VariantData,
    treatment: VariantData
  ): SignificanceResult {
    const n1 = control.users;
    const n2 = treatment.users;
    const x1 = control.conversions || 0;
    const x2 = treatment.conversions || 0;
    
    const p1 = x1 / n1;
    const p2 = x2 / n2;
    const p = (x1 + x2) / (n1 + n2);
    
    const z = (p2 - p1) / Math.sqrt(p * (1 - p) * (1/n1 + 1/n2));
    const pValue = 2 * (1 - this.normalCDF(Math.abs(z)));
    
    return {
      significant: pValue < 0.05,
      pValue,
      confidence: 1 - pValue,
      winner: p2 > p1 ? treatment.variant : control.variant,
      uplift: ((p2 - p1) / p1) * 100,
    };
  }
}
```

### 4. Real-time Analytics

#### Stream Processing
```typescript
export class RealTimeAnalytics {
  private streams: Map<string, AnalyticsStream> = new Map();
  
  // Initialize real-time processing
  async initialize(): Promise<void> {
    // User activity stream
    this.createStream('user_activity', {
      windowSize: 60000, // 1 minute
      slideInterval: 5000, // 5 seconds
      aggregations: ['count', 'unique', 'rate'],
    });
    
    // Conversion stream
    this.createStream('conversions', {
      windowSize: 300000, // 5 minutes
      slideInterval: 30000, // 30 seconds
      aggregations: ['sum', 'rate', 'funnel'],
    });
    
    // Error stream
    this.createStream('errors', {
      windowSize: 300000, // 5 minutes
      slideInterval: 10000, // 10 seconds
      aggregations: ['count', 'rate', 'pattern'],
    });
    
    // Performance stream
    this.createStream('performance', {
      windowSize: 60000, // 1 minute
      slideInterval: 10000, // 10 seconds
      aggregations: ['avg', 'p95', 'p99'],
    });
  }
  
  // Process incoming events
  async processEvent(event: AnalyticsEvent): Promise<void> {
    // Route to appropriate streams
    const streams = this.getStreamsForEvent(event);
    
    await Promise.all(
      streams.map(stream => stream.addEvent(event))
    );
    
    // Check for anomalies
    await this.detectAnomalies(event);
    
    // Update dashboards
    await this.updateDashboards(event);
  }
  
  // Real-time dashboard data
  async getDashboardData(): Promise<DashboardData> {
    return {
      activeUsers: await this.getActiveUsers(),
      currentConversions: await this.getCurrentConversions(),
      realtimeMetrics: await this.getRealtimeMetrics(),
      alerts: await this.getActiveAlerts(),
      trends: await this.getRealtimeTrends(),
    };
  }
  
  private async getActiveUsers(): Promise<ActiveUsersData> {
    const stream = this.streams.get('user_activity')!;
    const windows = stream.getWindows();
    
    return {
      current: windows[0].uniqueUsers,
      trend: this.calculateTrend(windows.map(w => w.uniqueUsers)),
      byPlatform: this.groupBy(windows[0].events, 'platform'),
      byCountry: this.groupBy(windows[0].events, 'country'),
      newVsReturning: {
        new: windows[0].newUsers,
        returning: windows[0].returningUsers,
      },
    };
  }
  
  // Anomaly detection
  private async detectAnomalies(event: AnalyticsEvent): Promise<void> {
    const detectors = [
      new ThresholdDetector(),
      new PatternDetector(),
      new MLAnomalyDetector(),
    ];
    
    for (const detector of detectors) {
      const anomaly = await detector.detect(event, this.getContext());
      
      if (anomaly) {
        await this.handleAnomaly(anomaly);
      }
    }
  }
}
```

### 5. Insights Generation

#### Automated Insights
```typescript
export class InsightsGenerator {
  // Generate insights from analytics data
  async generateInsights(
    timeRange: TimeRange
  ): Promise<Insight[]> {
    const insights: Insight[] = [];
    
    // User behavior insights
    insights.push(...await this.generateUserInsights(timeRange));
    
    // Conversion insights
    insights.push(...await this.generateConversionInsights(timeRange));
    
    // Performance insights
    insights.push(...await this.generatePerformanceInsights(timeRange));
    
    // Revenue insights
    insights.push(...await this.generateRevenueInsights(timeRange));
    
    // Predictive insights
    insights.push(...await this.generatePredictiveInsights(timeRange));
    
    // Rank by importance
    return this.rankInsights(insights);
  }
  
  private async generateUserInsights(
    timeRange: TimeRange
  ): Promise<Insight[]> {
    const insights: Insight[] = [];
    
    // User growth analysis
    const growth = await this.analyzeUserGrowth(timeRange);
    if (growth.significant) {
      insights.push({
        type: 'user_growth',
        title: growth.trend > 0 
          ? `User growth increased by ${growth.percentage}%`
          : `User growth decreased by ${Math.abs(growth.percentage)}%`,
        description: this.explainUserGrowth(growth),
        impact: 'high',
        recommendations: this.getUserGrowthRecommendations(growth),
        data: growth,
      });
    }
    
    // Cohort analysis
    const cohorts = await this.analyzeCohorts(timeRange);
    for (const cohort of cohorts.significantFindings) {
      insights.push({
        type: 'cohort_behavior',
        title: `${cohort.name} shows ${cohort.behavior}`,
        description: cohort.description,
        impact: cohort.impact,
        recommendations: cohort.recommendations,
        data: cohort.data,
      });
    }
    
    // User segmentation insights
    const segments = await this.analyzeUserSegments(timeRange);
    insights.push(...this.generateSegmentInsights(segments));
    
    return insights;
  }
  
  // Machine learning for predictive insights
  private async generatePredictiveInsights(
    timeRange: TimeRange
  ): Promise<Insight[]> {
    const insights: Insight[] = [];
    
    // Churn prediction
    const churnPrediction = await this.predictChurn();
    if (churnPrediction.riskUsers.length > 0) {
      insights.push({
        type: 'churn_risk',
        title: `${churnPrediction.riskUsers.length} users at risk of churning`,
        description: 'Based on usage patterns, these users show signs of disengagement',
        impact: 'high',
        recommendations: [
          'Send re-engagement campaigns',
          'Offer personalized incentives',
          'Analyze common characteristics',
        ],
        data: churnPrediction,
      });
    }
    
    // Revenue prediction
    const revenuePrediction = await this.predictRevenue();
    insights.push({
      type: 'revenue_forecast',
      title: `Projected revenue: $${revenuePrediction.forecast.toFixed(2)}`,
      description: `Based on current trends, expected ${revenuePrediction.confidence}% confidence`,
      impact: 'medium',
      recommendations: revenuePrediction.recommendations,
      data: revenuePrediction,
    });
    
    // Feature adoption prediction
    const adoptionPrediction = await this.predictFeatureAdoption();
    insights.push(...this.generateAdoptionInsights(adoptionPrediction));
    
    return insights;
  }
}
```

### 6. Privacy & Compliance

#### Data Privacy Implementation
```typescript
export class PrivacyCompliantAnalytics {
  // GDPR compliant data collection
  async collectData(
    event: AnalyticsEvent,
    consent: UserConsent
  ): Promise<void> {
    // Check consent
    if (!consent.analytics) {
      return; // Don't collect
    }
    
    // Anonymize PII
    const anonymized = this.anonymizeEvent(event);
    
    // Apply data minimization
    const minimized = this.minimizeData(anonymized, consent.level);
    
    // Add privacy metadata
    minimized.privacy = {
      consentId: consent.id,
      consentTimestamp: consent.timestamp,
      dataRetention: this.getRetentionPeriod(consent),
      purposes: consent.purposes,
    };
    
    // Store with encryption
    await this.secureStore(minimized);
  }
  
  // Data anonymization
  private anonymizeEvent(event: AnalyticsEvent): AnalyticsEvent {
    const anonymized = { ...event };
    
    // Hash user ID
    if (anonymized.userId) {
      anonymized.userId = this.hashUserId(anonymized.userId);
    }
    
    // Remove/mask IP address
    if (anonymized.ip) {
      anonymized.ip = this.maskIP(anonymized.ip);
    }
    
    // Remove exact location
    if (anonymized.location) {
      anonymized.location = {
        country: anonymized.location.country,
        region: anonymized.location.region,
        // Remove city and exact coordinates
      };
    }
    
    // Remove device identifiers
    delete anonymized.deviceId;
    delete anonymized.advertisingId;
    
    return anonymized;
  }
  
  // Handle data deletion requests
  async deleteUserData(userId: string): Promise<void> {
    const hashedUserId = this.hashUserId(userId);
    
    // Delete from all stores
    await Promise.all([
      this.storage.deleteUserEvents(hashedUserId),
      this.storage.deleteUserProfile(hashedUserId),
      this.storage.deleteUserSegments(hashedUserId),
      this.cache.purgeUser(hashedUserId),
    ]);
    
    // Log deletion for compliance
    await this.auditLog.log({
      action: 'user_data_deletion',
      userId: hashedUserId,
      timestamp: new Date(),
      reason: 'user_request',
    });
  }
}
```

## Analytics Dashboards

### 1. Executive Dashboard
```typescript
export const executiveDashboard = {
  metrics: [
    {
      id: 'daily_active_users',
      name: 'Daily Active Users',
      query: 'SELECT COUNT(DISTINCT user_id) FROM events WHERE date = TODAY',
      visualization: 'number',
      comparison: 'previous_period',
    },
    {
      id: 'revenue',
      name: 'Revenue',
      query: 'SELECT SUM(value) FROM conversions WHERE type = "purchase"',
      visualization: 'currency',
      comparison: 'target',
    },
    {
      id: 'conversion_rate',
      name: 'Conversion Rate',
      query: 'SELECT COUNT(DISTINCT user_id) FILTER (WHERE converted) / COUNT(DISTINCT user_id)',
      visualization: 'percentage',
      comparison: 'previous_period',
    },
  ],
  charts: [
    {
      id: 'user_growth',
      name: 'User Growth',
      type: 'line',
      metrics: ['new_users', 'active_users', 'retained_users'],
      timeRange: '30d',
    },
    {
      id: 'revenue_breakdown',
      name: 'Revenue by Product',
      type: 'pie',
      metric: 'revenue',
      dimension: 'product_category',
    },
  ],
};
```

### 2. Product Analytics Dashboard
```dart
class ProductAnalyticsDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      title: 'Product Analytics',
      widgets: [
        // Feature adoption
        AnalyticsCard(
          title: 'Feature Adoption',
          child: FeatureAdoptionChart(
            features: [
              'AI Generation',
              'Style Selection',
              'Advanced Settings',
              'Sharing',
            ],
          ),
        ),
        
        // User flow
        AnalyticsCard(
          title: 'User Flow',
          child: SankeyDiagram(
            data: UserFlowData.fetch(),
          ),
        ),
        
        // Engagement metrics
        AnalyticsCard(
          title: 'Engagement',
          child: EngagementMetrics(
            metrics: [
              'Session Duration',
              'Screens per Session',
              'Return Rate',
            ],
          ),
        ),
        
        // A/B test results
        AnalyticsCard(
          title: 'Active Experiments',
          child: ABTestResults(),
        ),
      ],
    );
  }
}
```

## Best Practices

### 1. Event Naming Convention
```typescript
export const eventNamingConvention = {
  format: '{category}_{action}_{target}_{status}',
  examples: [
    'generation_start_image_initiated',
    'user_signup_email_completed',
    'payment_process_subscription_failed',
    'feature_use_advancedsettings_enabled',
  ],
  categories: [
    'user',
    'generation',
    'payment',
    'feature',
    'system',
  ],
  required_properties: [
    'timestamp',
    'user_id',
    'session_id',
    'platform',
  ],
};
```

### 2. Analytics Implementation Checklist
```yaml
analytics_checklist:
  implementation:
    - Define KPIs and success metrics
    - Create event taxonomy
    - Implement tracking code
    - Set up data pipeline
    - Configure dashboards
    
  validation:
    - Verify event firing
    - Check data accuracy
    - Test edge cases
    - Validate privacy compliance
    - Performance impact assessment
    
  optimization:
    - Remove redundant events
    - Batch event sending
    - Implement sampling for high-volume events
    - Cache frequent queries
    - Archive old data
```

## Integration Examples

### With Product Team
- Feature usage analytics
- A/B test coordination
- User feedback integration
- Product metrics dashboards

### With Marketing Team
- Campaign attribution
- User acquisition analytics
- Conversion funnel optimization
- Customer segmentation

### With Engineering Team
- Performance metrics
- Error tracking integration
- API usage analytics
- Infrastructure monitoring

---

*This skill provides comprehensive analytics capabilities to drive data-informed decisions for PrintCraft AI.*