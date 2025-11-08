---
name: performance-optimization
version: 1.0.0
description: Expertise in optimizing application performance across mobile, backend, and AI services
author: PrintCraft AI Team
tags:
  - performance
  - optimization
  - profiling
  - monitoring
---

# Performance Optimization Skill

## Overview
This skill provides comprehensive performance optimization capabilities across all layers of the PrintCraft AI application, from Flutter UI rendering to backend API response times and AI model inference optimization.

## Core Competencies

### 1. Flutter Performance Optimization

#### Widget Performance
```dart
// Optimized widget building
class OptimizedImageGrid extends StatelessWidget {
  final List<GeneratedImage> images;
  
  const OptimizedImageGrid({super.key, required this.images});
  
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      // Improve scrolling performance
      physics: const BouncingScrollPhysics(),
      cacheExtent: 200, // Cache 200 pixels outside viewport
      slivers: [
        SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => OptimizedImageTile(
              key: ValueKey(images[index].id), // Stable keys
              image: images[index],
            ),
            childCount: images.length,
            // Reuse widgets when possible
            addAutomaticKeepAlives: false,
            addRepaintBoundaries: true,
          ),
        ),
      ],
    );
  }
}

class OptimizedImageTile extends StatelessWidget {
  final GeneratedImage image;
  
  const OptimizedImageTile({
    super.key,
    required this.image,
  });
  
  @override
  Widget build(BuildContext context) {
    return RepaintBoundary( // Isolate repaint
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Progressive image loading
              FadeInImage(
                placeholder: MemoryImage(kTransparentImage),
                image: CachedNetworkImageProvider(
                  image.thumbnailUrl,
                  cacheKey: image.id,
                ),
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
              ),
              // Lazy load full image on tap
              if (image.status == GenerationStatus.completed)
                Positioned.fill(
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _loadFullImage(context),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### State Management Optimization
```dart
// Optimized Provider usage
class OptimizedGenerationProvider extends ChangeNotifier {
  final Map<String, GenerationModel> _generationsCache = {};
  final LRUCache<String, Uint8List> _imageCache = LRUCache(maxSize: 50);
  
  // Selective rebuilds
  GenerationModel? getGeneration(String id) {
    return _generationsCache[id];
  }
  
  // Batch updates to minimize rebuilds
  void updateGenerations(List<GenerationModel> updates) {
    var hasChanges = false;
    
    for (final update in updates) {
      final existing = _generationsCache[update.id];
      if (existing == null || existing != update) {
        _generationsCache[update.id] = update;
        hasChanges = true;
      }
    }
    
    if (hasChanges) {
      notifyListeners();
    }
  }
  
  // Debounced updates
  Timer? _debounceTimer;
  void debouncedUpdate(VoidCallback update) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      update();
      notifyListeners();
    });
  }
  
  // Memory management
  void clearOldCache() {
    final cutoff = DateTime.now().subtract(const Duration(hours: 1));
    _generationsCache.removeWhere(
      (_, gen) => gen.createdAt.isBefore(cutoff)
    );
  }
}
```

### 2. Backend Performance Optimization

#### Database Query Optimization
```typescript
export class QueryOptimizer {
  // Use query builder with optimizations
  async getOptimizedGenerations(
    userId: string,
    options: QueryOptions
  ): Promise<Generation[]> {
    const query = this.db
      .select([
        'g.id',
        'g.prompt',
        'g.status',
        'g.imageUrl',
        'g.createdAt',
        // Only select needed fields
      ])
      .from('generations as g')
      .where('g.userId', userId)
      .orderBy('g.createdAt', 'desc')
      .limit(options.limit || 20);
    
    // Add indexes hint
    query.hint('USE INDEX (idx_user_created)');
    
    // Use read replica for read queries
    const results = await query.execute({ 
      connection: this.readReplica 
    });
    
    // Batch load related data
    if (options.includeMetadata) {
      await this.batchLoadMetadata(results);
    }
    
    return results;
  }
  
  // Implement query result caching
  private queryCache = new NodeCache({ 
    stdTTL: 300, // 5 minutes
    checkperiod: 60 
  });
  
  async getCachedQuery<T>(
    key: string,
    queryFn: () => Promise<T>
  ): Promise<T> {
    const cached = this.queryCache.get<T>(key);
    if (cached) {
      // Update cache in background
      this.refreshCacheInBackground(key, queryFn);
      return cached;
    }
    
    const result = await queryFn();
    this.queryCache.set(key, result);
    return result;
  }
}

// Connection pooling optimization
export const optimizedDbConfig = {
  client: 'postgresql',
  connection: {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
  },
  pool: {
    min: 2,
    max: 10,
    acquireTimeoutMillis: 30000,
    createTimeoutMillis: 30000,
    destroyTimeoutMillis: 5000,
    idleTimeoutMillis: 30000,
    reapIntervalMillis: 1000,
    createRetryIntervalMillis: 100,
  },
  // Enable query performance logging
  debug: process.env.NODE_ENV === 'development',
};
```

#### API Response Optimization
```typescript
export class ResponseOptimizer {
  // Response compression
  compressionMiddleware() {
    return compression({
      filter: (req, res) => {
        if (req.headers['x-no-compression']) {
          return false;
        }
        return compression.filter(req, res);
      },
      threshold: 1024, // Only compress responses > 1KB
    });
  }
  
  // Pagination with cursor
  async paginateWithCursor<T>(
    query: Query<T>,
    cursor?: string,
    limit: number = 20
  ): Promise<PaginatedResponse<T>> {
    let modifiedQuery = query.limit(limit + 1);
    
    if (cursor) {
      const decodedCursor = this.decodeCursor(cursor);
      modifiedQuery = modifiedQuery.where(
        'createdAt',
        '<',
        decodedCursor.timestamp
      );
    }
    
    const results = await modifiedQuery.execute();
    const hasMore = results.length > limit;
    const items = hasMore ? results.slice(0, -1) : results;
    
    return {
      items,
      hasMore,
      nextCursor: hasMore 
        ? this.encodeCursor(items[items.length - 1])
        : undefined,
    };
  }
  
  // Field filtering
  filterResponseFields<T>(
    data: T,
    fields?: string[]
  ): Partial<T> {
    if (!fields || fields.length === 0) return data;
    
    const result: any = {};
    for (const field of fields) {
      if (field.includes('.')) {
        // Handle nested fields
        this.setNestedField(result, field, this.getNestedField(data, field));
      } else {
        result[field] = data[field];
      }
    }
    
    return result;
  }
}
```

### 3. AI Model Performance Optimization

#### Inference Optimization
```python
import torch
from torch import nn
from typing import List, Tuple
import numpy as np

class OptimizedInference:
    def __init__(self, model_path: str):
        self.device = torch.device(
            "cuda" if torch.cuda.is_available() else "cpu"
        )
        
        # Load model with optimizations
        self.model = self.load_optimized_model(model_path)
        
        # Enable mixed precision
        self.scaler = torch.cuda.amp.GradScaler()
        
        # Compile model for faster inference (PyTorch 2.0+)
        if hasattr(torch, 'compile'):
            self.model = torch.compile(self.model)
    
    def load_optimized_model(self, path: str):
        model = torch.load(path, map_location=self.device)
        model.eval()
        
        # Quantization for faster inference
        if self.device.type == 'cpu':
            model = torch.quantization.quantize_dynamic(
                model,
                {nn.Linear, nn.Conv2d},
                dtype=torch.qint8
            )
        
        return model
    
    @torch.no_grad()
    def batch_inference(
        self,
        inputs: List[torch.Tensor],
        batch_size: int = 8
    ) -> List[torch.Tensor]:
        results = []
        
        # Process in batches
        for i in range(0, len(inputs), batch_size):
            batch = torch.stack(inputs[i:i + batch_size])
            batch = batch.to(self.device)
            
            # Mixed precision inference
            with torch.cuda.amp.autocast():
                outputs = self.model(batch)
            
            results.extend(outputs.cpu())
        
        return results
    
    def optimize_prompt(self, prompt: str) -> str:
        # Token optimization
        tokens = self.tokenizer.encode(prompt)
        
        # Remove redundant tokens
        optimized_tokens = self.remove_redundancy(tokens)
        
        # Ensure within model limits
        if len(optimized_tokens) > self.max_tokens:
            optimized_tokens = self.truncate_smart(optimized_tokens)
        
        return self.tokenizer.decode(optimized_tokens)
```

#### Model Caching Strategy
```typescript
export class ModelCacheManager {
  private cache: Map<string, CachedModel> = new Map();
  private memoryLimit: number = 2 * 1024 * 1024 * 1024; // 2GB
  private currentMemoryUsage: number = 0;
  
  async getModel(modelId: string): Promise<Model> {
    // Check cache first
    const cached = this.cache.get(modelId);
    if (cached) {
      cached.lastAccessed = Date.now();
      return cached.model;
    }
    
    // Load model
    const model = await this.loadModel(modelId);
    
    // Evict if necessary
    while (this.currentMemoryUsage + model.size > this.memoryLimit) {
      this.evictLRU();
    }
    
    // Cache model
    this.cache.set(modelId, {
      model,
      size: model.size,
      lastAccessed: Date.now(),
    });
    this.currentMemoryUsage += model.size;
    
    return model;
  }
  
  private evictLRU(): void {
    let lruKey: string | undefined;
    let lruTime = Infinity;
    
    for (const [key, value] of this.cache) {
      if (value.lastAccessed < lruTime) {
        lruTime = value.lastAccessed;
        lruKey = key;
      }
    }
    
    if (lruKey) {
      const evicted = this.cache.get(lruKey)!;
      this.cache.delete(lruKey);
      this.currentMemoryUsage -= evicted.size;
    }
  }
}
```

### 4. Network Optimization

#### Request Batching
```typescript
export class RequestBatcher {
  private pendingRequests: Map<string, PendingRequest[]> = new Map();
  private batchTimeout: number = 50; // ms
  private maxBatchSize: number = 100;
  
  async addRequest<T>(
    endpoint: string,
    params: any
  ): Promise<T> {
    return new Promise((resolve, reject) => {
      const key = this.getBatchKey(endpoint);
      
      if (!this.pendingRequests.has(key)) {
        this.pendingRequests.set(key, []);
        this.scheduleBatch(key);
      }
      
      this.pendingRequests.get(key)!.push({
        params,
        resolve,
        reject,
      });
      
      // Execute immediately if batch is full
      if (this.pendingRequests.get(key)!.length >= this.maxBatchSize) {
        this.executeBatch(key);
      }
    });
  }
  
  private scheduleBatch(key: string): void {
    setTimeout(() => {
      if (this.pendingRequests.has(key)) {
        this.executeBatch(key);
      }
    }, this.batchTimeout);
  }
  
  private async executeBatch(key: string): Promise<void> {
    const requests = this.pendingRequests.get(key) || [];
    this.pendingRequests.delete(key);
    
    if (requests.length === 0) return;
    
    try {
      // Make batched request
      const batchResponse = await this.makeBatchRequest(
        key,
        requests.map(r => r.params)
      );
      
      // Distribute results
      requests.forEach((request, index) => {
        request.resolve(batchResponse.results[index]);
      });
    } catch (error) {
      requests.forEach(request => {
        request.reject(error);
      });
    }
  }
}
```

#### CDN and Caching Strategy
```typescript
export class CacheStrategy {
  // Cache headers configuration
  static getCacheHeaders(resourceType: ResourceType): CacheHeaders {
    const strategies = {
      static: {
        'Cache-Control': 'public, max-age=31536000, immutable',
        'Surrogate-Control': 'max-age=31536000',
      },
      api: {
        'Cache-Control': 'private, max-age=0, must-revalidate',
        'Surrogate-Control': 'max-age=60',
      },
      image: {
        'Cache-Control': 'public, max-age=86400, stale-while-revalidate=604800',
        'Surrogate-Control': 'max-age=2592000',
      },
      generation: {
        'Cache-Control': 'private, max-age=300',
        'Surrogate-Control': 'max-age=300',
      },
    };
    
    return strategies[resourceType] || strategies.api;
  }
  
  // Edge caching with Cloudflare Workers
  static edgeCacheMiddleware(): EdgeWorker {
    return {
      async fetch(request: Request, env: Env): Promise<Response> {
        const cacheKey = this.getCacheKey(request);
        const cache = caches.default;
        
        // Check cache
        let response = await cache.match(cacheKey);
        
        if (!response) {
          // Make request
          response = await fetch(request);
          
          // Cache successful responses
          if (response.ok) {
            const headers = new Headers(response.headers);
            headers.set('Cache-Control', 'public, max-age=3600');
            
            response = new Response(response.body, {
              status: response.status,
              statusText: response.statusText,
              headers,
            });
            
            await cache.put(cacheKey, response.clone());
          }
        }
        
        return response;
      },
    };
  }
}
```

### 5. Monitoring and Profiling

#### Performance Metrics Collection
```typescript
export class PerformanceMonitor {
  private metrics: MetricsCollector;
  
  constructor() {
    this.metrics = new MetricsCollector({
      prefix: 'printcraft',
      tags: {
        app: 'api',
        environment: process.env.NODE_ENV,
      },
    });
  }
  
  // API endpoint monitoring
  measureEndpoint() {
    return (req: Request, res: Response, next: NextFunction) => {
      const start = process.hrtime.bigint();
      
      // Monkey patch response
      const originalSend = res.send;
      res.send = (body: any) => {
        const duration = Number(process.hrtime.bigint() - start) / 1e6;
        
        // Record metrics
        this.metrics.histogram('http_request_duration_ms', duration, {
          method: req.method,
          route: req.route?.path || 'unknown',
          status: res.statusCode,
        });
        
        this.metrics.increment('http_requests_total', {
          method: req.method,
          route: req.route?.path || 'unknown',
          status: res.statusCode,
        });
        
        return originalSend.call(res, body);
      };
      
      next();
    };
  }
  
  // Database query monitoring
  measureQuery(queryName: string) {
    return async <T>(queryFn: () => Promise<T>): Promise<T> => {
      const start = process.hrtime.bigint();
      
      try {
        const result = await queryFn();
        const duration = Number(process.hrtime.bigint() - start) / 1e6;
        
        this.metrics.histogram('db_query_duration_ms', duration, {
          query: queryName,
          status: 'success',
        });
        
        return result;
      } catch (error) {
        const duration = Number(process.hrtime.bigint() - start) / 1e6;
        
        this.metrics.histogram('db_query_duration_ms', duration, {
          query: queryName,
          status: 'error',
        });
        
        throw error;
      }
    };
  }
}
```

#### Flutter Performance Profiling
```dart
class PerformanceProfiler {
  static void profileWidget(String widgetName, VoidCallback builder) {
    Timeline.startSync(widgetName);
    
    try {
      builder();
    } finally {
      Timeline.finishSync();
    }
  }
  
  static Future<T> profileAsync<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final flow = Timeline.startSync(operationName);
    
    try {
      final result = await operation();
      return result;
    } finally {
      Timeline.finishSync();
    }
  }
  
  // Custom performance overlay
  static Widget wrapWithPerformanceOverlay({
    required Widget child,
    required bool showPerformanceOverlay,
  }) {
    if (!showPerformanceOverlay) return child;
    
    return Stack(
      children: [
        child,
        Positioned(
          top: 50,
          right: 10,
          child: Container(
            color: Colors.black54,
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StreamBuilder<FrameTiming>(
                  stream: WidgetsBinding.instance.frameTimings,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    
                    final timing = snapshot.data!;
                    final fps = 1000 / timing.totalSpan.inMilliseconds;
                    
                    return Text(
                      'FPS: ${fps.toStringAsFixed(1)}',
                      style: TextStyle(
                        color: fps > 55 ? Colors.green : Colors.red,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
```

## Optimization Strategies

### 1. Memory Management
```typescript
export class MemoryManager {
  // Object pooling for frequently created objects
  private pools: Map<string, ObjectPool> = new Map();
  
  getFromPool<T>(type: string, factory: () => T): T {
    if (!this.pools.has(type)) {
      this.pools.set(type, new ObjectPool(factory));
    }
    
    return this.pools.get(type)!.acquire() as T;
  }
  
  returnToPool<T>(type: string, object: T): void {
    this.pools.get(type)?.release(object);
  }
  
  // Garbage collection hints
  async cleanupMemory(): Promise<void> {
    // Clear caches
    this.clearExpiredCaches();
    
    // Trigger garbage collection if available
    if (global.gc) {
      global.gc();
    }
    
    // Log memory usage
    const usage = process.memoryUsage();
    console.log('Memory Usage:', {
      rss: `${(usage.rss / 1024 / 1024).toFixed(2)} MB`,
      heapTotal: `${(usage.heapTotal / 1024 / 1024).toFixed(2)} MB`,
      heapUsed: `${(usage.heapUsed / 1024 / 1024).toFixed(2)} MB`,
      external: `${(usage.external / 1024 / 1024).toFixed(2)} MB`,
    });
  }
}
```

### 2. Lazy Loading
```dart
class LazyLoader {
  static Widget lazyLoad({
    required Widget placeholder,
    required Future<Widget> Function() loader,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return FutureBuilder<Widget>(
      future: Future.delayed(delay, loader),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: snapshot.data!,
          );
        }
        return placeholder;
      },
    );
  }
  
  // Lazy loading with visibility detection
  static Widget lazyLoadOnVisible({
    required Widget placeholder,
    required Widget child,
    double visibleFraction = 0.1,
  }) {
    return VisibilityDetector(
      key: UniqueKey(),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > visibleFraction) {
          // Load the actual widget
        }
      },
      child: placeholder,
    );
  }
}
```

### 3. Code Splitting
```typescript
// Dynamic imports for code splitting
export class CodeSplitter {
  static async loadFeature(feature: string): Promise<any> {
    switch (feature) {
      case 'analytics':
        return import(
          /* webpackChunkName: "analytics" */
          './features/analytics'
        );
      
      case 'advanced-editor':
        return import(
          /* webpackChunkName: "advanced-editor" */
          './features/advanced-editor'
        );
      
      case 'admin-panel':
        return import(
          /* webpackChunkName: "admin-panel" */
          './features/admin-panel'
        );
      
      default:
        throw new Error(`Unknown feature: ${feature}`);
    }
  }
}
```

## Performance Benchmarks

### Target Metrics
```yaml
performance_targets:
  flutter:
    app_startup: <3s
    screen_transition: <300ms
    list_scroll_fps: >55fps
    memory_usage: <150MB
    
  backend:
    api_response_p50: <50ms
    api_response_p95: <200ms
    api_response_p99: <500ms
    database_query_p95: <100ms
    
  ai_generation:
    model_load_time: <5s
    inference_time: <2s
    queue_processing: <10s
    
  network:
    time_to_first_byte: <200ms
    total_page_load: <2s
    api_latency: <100ms
```

---

*This skill ensures optimal performance across all aspects of PrintCraft AI.*