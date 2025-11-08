import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import dotenv from 'dotenv';
import { createServer } from 'http';
import { Server as SocketServer } from 'socket.io';
import { PrismaClient } from '@prisma/client';

// Import middleware
import { errorHandler } from './middleware/errorHandler';
import { rateLimiter } from './middleware/rateLimiter';
import { requestLogger } from './middleware/requestLogger';

// Import routes
// import authRoutes from './routes/auth.routes';
import userRoutes from './routes/user.routes';
import generationRoutes from './routes/generation.routes';
import subscriptionRoutes from './routes/subscription.routes';
import paymentRoutes from './routes/payment.routes';
import styleRoutes from './routes/style.routes';
import webhookRoutes from './routes/webhook.routes';
import healthRoutes from './routes/health.routes';

// Import services
import { logger } from './utils/logger';
import { initializeRedis } from './services/redis.service';
import { initializeQueue } from './services/queue.service';
import { initializeWebSocket } from './services/websocket.service';

// Load environment variables
dotenv.config();

// Initialize Prisma
export const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'error', 'warn'] : ['error'],
});

// Create Express app
const app = express();
const server = createServer(app);
const io = new SocketServer(server, {
  cors: {
    origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
    credentials: true,
  },
});

// App configuration
const PORT = process.env.PORT || 8000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' },
}));
app.use(cors({
  origin: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));
app.use(compression());
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));
app.use(morgan(NODE_ENV === 'production' ? 'combined' : 'dev'));

// Custom middleware
app.use(requestLogger);
app.use('/api/v1', rateLimiter);

// API Routes
// app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/user', userRoutes);
app.use('/api/v1/generation', generationRoutes);
app.use('/api/v1/subscription', subscriptionRoutes);
app.use('/api/v1/payment', paymentRoutes);
app.use('/api/v1/styles', styleRoutes);
app.use('/api/v1/webhook', webhookRoutes);
app.use('/api/v1/health', healthRoutes);

// Root route
app.get('/', (_req, res) => {
  res.json({
    message: 'PrintCraft AI API Gateway',
    version: '1.0.0',
    status: 'online',
    docs: '/api/v1/docs',
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.method} ${req.url} not found`,
  });
});

// Error handler (must be last)
app.use(errorHandler);

// Graceful shutdown
const gracefulShutdown = async () => {
  logger.info('Received shutdown signal, closing server gracefully...');
  
  server.close(() => {
    logger.info('HTTP server closed');
  });

  // Close database connections
  await prisma.$disconnect();
  logger.info('Database connection closed');

  // Close Redis connection
  const redis = await initializeRedis();
  await redis.quit();
  logger.info('Redis connection closed');

  process.exit(0);
};

process.on('SIGTERM', gracefulShutdown);
process.on('SIGINT', gracefulShutdown);

// Start server
const startServer = async () => {
  try {
    // Test database connection
    await prisma.$connect();
    logger.info('✅ Database connected successfully');

    // Initialize Redis
    await initializeRedis();
    logger.info('✅ Redis connected successfully');

    // Initialize Queue
    await initializeQueue();
    logger.info('✅ Queue system initialized');

    // Initialize WebSocket
    initializeWebSocket(io);
    logger.info('✅ WebSocket server initialized');

    // Start listening
    server.listen(PORT, () => {
      logger.info(`🚀 Server is running on port ${PORT} in ${NODE_ENV} mode`);
      logger.info(`📝 API documentation available at http://localhost:${PORT}/api/v1/docs`);
    });
  } catch (error) {
    logger.error('Failed to start server:', error);
    process.exit(1);
  }
};

// Start the server
startServer();

// Export for testing
export { app, server, io };