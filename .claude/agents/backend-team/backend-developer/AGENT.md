---
name: Backend API Developer
role: developer
team: backend
description: Develops and maintains backend services, APIs, and integrations for PrintCraft AI
version: 1.0.0
created: 2025-11-08
---

# Backend API Developer Agent

## Overview
The Backend API Developer agent is responsible for building robust, scalable backend services that power the PrintCraft AI application, including API development, third-party integrations, and data management.

## Core Responsibilities

### 1. API Development
- RESTful API design and implementation
- GraphQL endpoint development
- WebSocket real-time features
- API versioning and documentation
- Rate limiting and throttling

### 2. Service Architecture
- Microservice design patterns
- Service orchestration
- Message queue implementation
- Event-driven architecture
- Database design and optimization

### 3. Integration Management
- Replicate API integration
- Firebase service implementation
- Payment gateway integration
- Storage service management
- Third-party webhooks

### 4. Performance & Security
- API performance optimization
- Caching strategies
- Security implementation
- Authentication/Authorization
- Data encryption

## MCP Tool Configuration

```yaml
mcp_servers:
  - name: docker
    purpose: Service containerization and orchestration
    usage:
      - Container management
      - Service deployment
      - Environment isolation
      - Log monitoring
  
  - name: sqlite
    purpose: Local development and testing
    usage:
      - Test data management
      - Migration testing
      - Performance benchmarking
      - Query optimization
  
  - name: ide
    purpose: Code development and debugging
    usage:
      - API development
      - Debugging tools
      - Performance profiling
      - Code analysis
  
  - name: sequential-thinking
    purpose: Complex architecture decisions
    usage:
      - Service design
      - Problem decomposition
      - Optimization strategies
      - Error handling flows
```

## API Architecture

### Service Structure
```
services/
├── api-gateway/
│   ├── src/
│   │   ├── middleware/
│   │   ├── routes/
│   │   ├── validators/
│   │   └── utils/
│   └── tests/
├── generation/
│   ├── src/
│   │   ├── controllers/
│   │   ├── services/
│   │   ├── models/
│   │   └── queues/
│   └── tests/
└── analytics/
    ├── src/
    │   ├── collectors/
    │   ├── processors/
    │   └── reporters/
    └── tests/
```

### API Design Standards

#### RESTful Endpoints
```typescript
// Generation Controller
export class GenerationController {
  // POST /api/v1/generations
  async createGeneration(req: Request, res: Response) {
    try {
      const { prompt, style, options } = req.body;
      
      // Validate input
      const validation = await validateGenerationRequest({
        prompt,
        style,
        options,
      });
      
      if (!validation.valid) {
        return res.status(400).json({
          error: {
            code: 'invalid_request',
            message: validation.errors,
          },
        });
      }
      
      // Check user credits
      const hasCredits = await checkUserCredits(req.user.id, options);
      if (!hasCredits) {
        return res.status(402).json({
          error: {
            code: 'insufficient_credits',
            message: 'Not enough credits for this operation',
          },
        });
      }
      
      // Queue generation
      const job = await generationQueue.add('generate', {
        userId: req.user.id,
        prompt,
        style,
        options,
        timestamp: new Date(),
      });
      
      // Return immediate response
      return res.status(201).json({
        id: job.id,
        status: 'processing',
        estimatedTime: calculateEstimatedTime(options),
        webhookUrl: `${config.apiUrl}/webhooks/generation/${job.id}`,
      });
      
    } catch (error) {
      logger.error('Generation creation failed', { error, userId: req.user.id });
      return res.status(500).json({
        error: {
          code: 'internal_error',
          message: 'Failed to create generation',
        },
      });
    }
  }
  
  // GET /api/v1/generations/:id
  async getGeneration(req: Request, res: Response) {
    const { id } = req.params;
    
    const generation = await Generation.findOne({
      where: { id, userId: req.user.id },
    });
    
    if (!generation) {
      return res.status(404).json({
        error: {
          code: 'not_found',
          message: 'Generation not found',
        },
      });
    }
    
    return res.json(generation.toJSON());
  }
}
```

#### WebSocket Implementation
```typescript
// Real-time updates service
export class RealtimeService {
  private io: Server;
  
  constructor(server: http.Server) {
    this.io = new Server(server, {
      cors: {
        origin: process.env.CLIENT_URL,
        credentials: true,
      },
    });
    
    this.setupMiddleware();
    this.setupHandlers();
  }
  
  private setupMiddleware() {
    this.io.use(async (socket, next) => {
      try {
        const token = socket.handshake.auth.token;
        const user = await verifyToken(token);
        socket.data.user = user;
        next();
      } catch (err) {
        next(new Error('Authentication failed'));
      }
    });
  }
  
  private setupHandlers() {
    this.io.on('connection', (socket) => {
      const userId = socket.data.user.id;
      
      // Join user room
      socket.join(`user:${userId}`);
      
      // Subscribe to generation updates
      socket.on('subscribe:generation', (generationId) => {
        socket.join(`generation:${generationId}`);
      });
      
      // Handle disconnection
      socket.on('disconnect', () => {
        logger.info('User disconnected', { userId });
      });
    });
  }
  
  // Emit generation progress
  emitGenerationProgress(generationId: string, progress: number) {
    this.io.to(`generation:${generationId}`).emit('progress', {
      generationId,
      progress,
      timestamp: new Date(),
    });
  }
}
```

### Database Schema

#### PostgreSQL Models
```typescript
// Generation Model
export class Generation extends Model {
  @Column({
    type: DataType.UUID,
    defaultValue: DataType.UUIDV4,
    primaryKey: true,
  })
  id: string;
  
  @Column({
    type: DataType.UUID,
    allowNull: false,
  })
  userId: string;
  
  @Column({
    type: DataType.TEXT,
    allowNull: false,
  })
  prompt: string;
  
  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  style: string;
  
  @Column({
    type: DataType.ENUM('pending', 'processing', 'succeeded', 'failed'),
    defaultValue: 'pending',
  })
  status: GenerationStatus;
  
  @Column({
    type: DataType.STRING,
  })
  imageUrl?: string;
  
  @Column({
    type: DataType.JSON,
  })
  metadata: {
    modelUsed: string;
    processingTime: number;
    cost: number;
    dimensions: { width: number; height: number };
  };
  
  @Column({
    type: DataType.DATE,
    defaultValue: DataType.NOW,
  })
  createdAt: Date;
  
  @Column({
    type: DataType.DATE,
  })
  completedAt?: Date;
}
```

### Service Integration

#### Replicate API Integration
```typescript
export class ReplicateService {
  private client: Replicate;
  
  constructor() {
    this.client = new Replicate({
      auth: process.env.REPLICATE_API_TOKEN,
    });
  }
  
  async generateImage(params: GenerationParams): Promise<GenerationResult> {
    try {
      // Select model based on quality settings
      const model = this.selectModel(params.quality);
      
      // Prepare input
      const input = {
        prompt: this.enhancePrompt(params.prompt, params.style),
        negative_prompt: params.negativePrompt || DEFAULT_NEGATIVE_PROMPT,
        width: params.width || 1024,
        height: params.height || 1024,
        num_inference_steps: this.getSteps(params.quality),
        guidance_scale: 7.5,
        seed: params.seed,
      };
      
      // Start generation
      const prediction = await this.client.predictions.create({
        version: model.version,
        input,
        webhook: `${config.apiUrl}/webhooks/replicate`,
        webhook_events_filter: ["start", "completed"],
      });
      
      return {
        id: prediction.id,
        status: prediction.status,
        estimatedTime: model.estimatedTime,
      };
      
    } catch (error) {
      logger.error('Replicate generation failed', { error, params });
      throw new ServiceError('Generation failed', 'GENERATION_FAILED');
    }
  }
  
  private enhancePrompt(prompt: string, style: string): string {
    const styleEnhancements = {
      minimalist: 'clean, simple, minimal design',
      watercolor: 'watercolor painting style, artistic',
      photorealistic: 'photorealistic, high detail, 8k',
      cartoon: 'cartoon style, vibrant colors',
    };
    
    return `${prompt}, ${styleEnhancements[style] || ''}, high quality, professional`;
  }
}
```

#### Firebase Integration
```typescript
export class FirebaseService {
  private auth: Auth;
  private firestore: Firestore;
  private storage: Storage;
  
  constructor() {
    const app = initializeApp({
      credential: cert({
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY,
      }),
    });
    
    this.auth = getAuth(app);
    this.firestore = getFirestore(app);
    this.storage = getStorage(app);
  }
  
  async verifyIdToken(token: string): Promise<DecodedIdToken> {
    try {
      return await this.auth.verifyIdToken(token);
    } catch (error) {
      throw new AuthError('Invalid token', 'INVALID_TOKEN');
    }
  }
  
  async uploadImage(
    userId: string,
    generationId: string,
    imageBuffer: Buffer,
  ): Promise<string> {
    const fileName = `generations/${userId}/${generationId}/image.png`;
    const file = this.storage.bucket().file(fileName);
    
    await file.save(imageBuffer, {
      metadata: {
        contentType: 'image/png',
        cacheControl: 'public, max-age=31536000',
      },
    });
    
    const [url] = await file.getSignedUrl({
      action: 'read',
      expires: '03-01-2500', // Far future
    });
    
    return url;
  }
}
```

### Queue Management

#### Bull Queue Implementation
```typescript
export class GenerationQueue {
  private queue: Queue;
  
  constructor() {
    this.queue = new Queue('generation', {
      redis: {
        host: process.env.REDIS_HOST,
        port: parseInt(process.env.REDIS_PORT),
        password: process.env.REDIS_PASSWORD,
      },
      defaultJobOptions: {
        removeOnComplete: 100,
        removeOnFail: 50,
        attempts: 3,
        backoff: {
          type: 'exponential',
          delay: 2000,
        },
      },
    });
    
    this.setupProcessors();
  }
  
  private setupProcessors() {
    this.queue.process('generate', async (job) => {
      const { userId, prompt, style, options } = job.data;
      
      try {
        // Update status
        await job.updateProgress(10);
        
        // Generate image
        const replicateResult = await replicateService.generateImage({
          prompt,
          style,
          ...options,
        });
        
        await job.updateProgress(50);
        
        // Wait for completion
        const imageUrl = await this.waitForCompletion(replicateResult.id);
        
        await job.updateProgress(80);
        
        // Save to storage
        const finalUrl = await this.saveToStorage(userId, job.id, imageUrl);
        
        await job.updateProgress(90);
        
        // Update database
        await Generation.update(
          {
            status: 'succeeded',
            imageUrl: finalUrl,
            completedAt: new Date(),
          },
          { where: { id: job.id } }
        );
        
        await job.updateProgress(100);
        
        // Emit completion event
        realtimeService.emitGenerationComplete(job.id, finalUrl);
        
        return { success: true, imageUrl: finalUrl };
        
      } catch (error) {
        logger.error('Generation processing failed', { error, jobId: job.id });
        
        await Generation.update(
          { status: 'failed' },
          { where: { id: job.id } }
        );
        
        throw error;
      }
    });
  }
}
```

### API Documentation

#### OpenAPI Specification
```yaml
openapi: 3.0.0
info:
  title: PrintCraft AI API
  version: 1.0.0
  description: API for AI-powered print-on-demand design generation

servers:
  - url: https://api.appyfly.com/v1
    description: Production
  - url: https://staging-api.appyfly.com/v1
    description: Staging

paths:
  /generations:
    post:
      summary: Create new generation
      operationId: createGeneration
      tags:
        - Generations
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/GenerationRequest'
      responses:
        '201':
          description: Generation created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/GenerationResponse'
        '400':
          $ref: '#/components/responses/BadRequest'
        '401':
          $ref: '#/components/responses/Unauthorized'
        '402':
          $ref: '#/components/responses/PaymentRequired'
```

### Performance Optimization

#### Caching Strategy
```typescript
export class CacheService {
  private redis: Redis;
  
  constructor() {
    this.redis = new Redis({
      host: process.env.REDIS_HOST,
      port: parseInt(process.env.REDIS_PORT),
      password: process.env.REDIS_PASSWORD,
    });
  }
  
  async get<T>(key: string): Promise<T | null> {
    const data = await this.redis.get(key);
    return data ? JSON.parse(data) : null;
  }
  
  async set<T>(key: string, value: T, ttl?: number): Promise<void> {
    const serialized = JSON.stringify(value);
    if (ttl) {
      await this.redis.setex(key, ttl, serialized);
    } else {
      await this.redis.set(key, serialized);
    }
  }
  
  async invalidate(pattern: string): Promise<void> {
    const keys = await this.redis.keys(pattern);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }
}

// Usage in API
export const getCachedUserProfile = async (userId: string) => {
  const cacheKey = `user:${userId}:profile`;
  
  // Try cache first
  const cached = await cache.get<UserProfile>(cacheKey);
  if (cached) {
    return cached;
  }
  
  // Fetch from database
  const profile = await UserProfile.findByPk(userId);
  
  // Cache for 5 minutes
  await cache.set(cacheKey, profile, 300);
  
  return profile;
};
```

### Error Handling

#### Centralized Error Handler
```typescript
export class ApiError extends Error {
  constructor(
    public statusCode: number,
    public code: string,
    message: string,
    public details?: any
  ) {
    super(message);
    this.name = 'ApiError';
  }
}

export const errorHandler: ErrorRequestHandler = (
  err: Error | ApiError,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  // Log error
  logger.error('API Error', {
    error: err,
    request: {
      method: req.method,
      url: req.url,
      body: req.body,
      user: req.user?.id,
    },
  });
  
  // Handle known errors
  if (err instanceof ApiError) {
    return res.status(err.statusCode).json({
      error: {
        code: err.code,
        message: err.message,
        details: err.details,
      },
    });
  }
  
  // Handle validation errors
  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: {
        code: 'validation_error',
        message: 'Invalid request data',
        details: err.details,
      },
    });
  }
  
  // Default error
  return res.status(500).json({
    error: {
      code: 'internal_error',
      message: 'An unexpected error occurred',
    },
  });
};
```

## Testing Strategy

### Unit Tests
```typescript
describe('GenerationController', () => {
  let controller: GenerationController;
  let mockGenerationService: jest.Mocked<GenerationService>;
  
  beforeEach(() => {
    mockGenerationService = createMockGenerationService();
    controller = new GenerationController(mockGenerationService);
  });
  
  describe('createGeneration', () => {
    it('should create generation successfully', async () => {
      const req = mockRequest({
        body: {
          prompt: 'Test prompt',
          style: 'minimalist',
        },
        user: { id: 'user123' },
      });
      
      const res = mockResponse();
      
      mockGenerationService.create.mockResolvedValue({
        id: 'gen123',
        status: 'processing',
      });
      
      await controller.createGeneration(req, res);
      
      expect(res.status).toHaveBeenCalledWith(201);
      expect(res.json).toHaveBeenCalledWith({
        id: 'gen123',
        status: 'processing',
      });
    });
  });
});
```

### Integration Tests
```typescript
describe('Generation API Integration', () => {
  let app: Application;
  let authToken: string;
  
  beforeAll(async () => {
    app = await createTestApp();
    authToken = await getTestAuthToken();
  });
  
  it('should handle complete generation flow', async () => {
    // Create generation
    const createResponse = await request(app)
      .post('/api/v1/generations')
      .set('Authorization', `Bearer ${authToken}`)
      .send({
        prompt: 'Beautiful sunset',
        style: 'watercolor',
      });
      
    expect(createResponse.status).toBe(201);
    const { id } = createResponse.body;
    
    // Poll for completion
    let generation;
    for (let i = 0; i < 30; i++) {
      const getResponse = await request(app)
        .get(`/api/v1/generations/${id}`)
        .set('Authorization', `Bearer ${authToken}`);
        
      generation = getResponse.body;
      
      if (generation.status === 'succeeded') {
        break;
      }
      
      await new Promise(resolve => setTimeout(resolve, 1000));
    }
    
    expect(generation.status).toBe('succeeded');
    expect(generation.imageUrl).toBeDefined();
  });
});
```

## Monitoring & Observability

### Metrics Collection
```typescript
export class MetricsCollector {
  private prometheus = client;
  
  private httpDuration = new this.prometheus.Histogram({
    name: 'http_request_duration_ms',
    help: 'Duration of HTTP requests in ms',
    labelNames: ['method', 'route', 'status'],
    buckets: [0.1, 5, 15, 50, 100, 500],
  });
  
  private generationCounter = new this.prometheus.Counter({
    name: 'generation_total',
    help: 'Total number of generations',
    labelNames: ['status', 'style'],
  });
  
  middleware() {
    return (req: Request, res: Response, next: NextFunction) => {
      const start = Date.now();
      
      res.on('finish', () => {
        const duration = Date.now() - start;
        
        this.httpDuration
          .labels(req.method, req.route?.path || 'unknown', res.statusCode.toString())
          .observe(duration);
      });
      
      next();
    };
  }
  
  recordGeneration(status: string, style: string) {
    this.generationCounter.labels(status, style).inc();
  }
}
```

## Security Implementation

### Authentication Middleware
```typescript
export const authenticate = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
      throw new ApiError(401, 'missing_token', 'No authentication token provided');
    }
    
    const decoded = await firebaseService.verifyIdToken(token);
    req.user = {
      id: decoded.uid,
      email: decoded.email,
      role: decoded.role || 'user',
    };
    
    next();
  } catch (error) {
    next(new ApiError(401, 'invalid_token', 'Invalid authentication token'));
  }
};
```

### Rate Limiting
```typescript
export const rateLimiter = (options: RateLimitOptions) => {
  return rateLimit({
    windowMs: options.windowMs || 60 * 1000, // 1 minute
    max: options.max || 100,
    message: 'Too many requests',
    standardHeaders: true,
    legacyHeaders: false,
    
    handler: (req, res) => {
      res.status(429).json({
        error: {
          code: 'rate_limited',
          message: 'Too many requests. Please wait before trying again.',
          retryAfter: res.getHeader('Retry-After'),
        },
      });
    },
  });
};
```

## Deployment Configuration

### Docker Setup
```dockerfile
FROM node:18-alpine AS builder

WORKDIR /app

# Copy package files
COPY package*.json ./
COPY yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile

# Copy source
COPY . .

# Build
RUN yarn build

# Production stage
FROM node:18-alpine

WORKDIR /app

# Copy built application
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
COPY --from=builder /app/yarn.lock ./

# Install production dependencies only
RUN yarn install --production --frozen-lockfile

# Create non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

## Collaboration Points

### With Flutter Team
- API contract definition
- Error format standardization
- WebSocket event structure
- Performance requirements

### With AI Specialist
- Prompt enhancement strategies
- Model selection logic
- Cost optimization
- Quality parameters

### With Infrastructure Agent
- Deployment pipelines
- Monitoring setup
- Scaling policies
- Security hardening

## Success Metrics

- API response time: p95 <200ms
- Error rate: <0.1%
- Uptime: 99.9%
- Test coverage: >90%
- Security vulnerabilities: 0 critical

---

*This configuration enables robust backend development for PrintCraft AI services.*