import express from 'express';
import { createServer } from 'http';
import cors from 'cors';
import compression from 'compression';
import helmet from 'helmet';
import morgan from 'morgan';
import { Server as SocketServer } from 'socket.io';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

// Import only working routes
import generationRoutes from './routes/generation.routes';
import healthRoutes from './routes/health.routes';

// Import services
import { logger } from './utils/logger';
import { errorHandler } from './middleware/errorHandler';
import { rateLimiter } from './middleware/rateLimiter';
import { prisma } from './utils/prisma';

// Constants
const { PORT = 8000, NODE_ENV = 'development', CORS_ORIGIN } = process.env;

// Initialize Express app
const app = express();
const server = createServer(app);
const io = new SocketServer(server, {
  cors: {
    origin: CORS_ORIGIN?.split(',') || ['http://localhost:3000'],
    credentials: true,
  },
});

// Global middleware
app.use(helmet({
  crossOriginResourcePolicy: { policy: "cross-origin" }
}));
app.use(cors({
  origin: CORS_ORIGIN?.split(',') || true,
  credentials: true,
}));
app.use(compression());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan(NODE_ENV === 'production' ? 'combined' : 'dev'));

// Rate limiting
app.use('/api/v1', rateLimiter);

// API Routes
app.use('/api/v1/generation', generationRoutes);
app.use('/api/v1/health', healthRoutes);

// Root route
app.get('/', (_req, res) => {
  res.json({
    message: 'PrintCraft AI API Gateway',
    version: '1.0.0',
    status: 'online',
    endpoints: {
      health: '/api/v1/health',
      generation: '/api/v1/generation',
    },
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    message: `Route ${req.path} not found`,
  });
});

// Error handler
app.use(errorHandler);

// WebSocket handling
io.on('connection', (socket) => {
  logger.info('Client connected', { socketId: socket.id });

  socket.on('disconnect', () => {
    logger.info('Client disconnected', { socketId: socket.id });
  });

  socket.on('ping', () => {
    socket.emit('pong', { timestamp: new Date().toISOString() });
  });
});

// Start server
const startServer = async () => {
  try {
    // Test database connection
    await prisma.$connect();
    logger.info('✅ Database connected successfully');

    // Start listening
    server.listen(PORT, () => {
      logger.info(`
🚀 Server started successfully!
📡 API Gateway running on http://localhost:${PORT}
🌍 Environment: ${NODE_ENV}
💻 API Docs: http://localhost:${PORT}/api/v1/health

Available endpoints:
- GET  /                        - API info
- GET  /api/v1/health          - Health check
- POST /api/v1/generation/create - Create AI generation
- GET  /api/v1/generation/styles - List available styles
      `);
    });
  } catch (error) {
    logger.error('Failed to start server', error);
    process.exit(1);
  }
};

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  logger.info('SIGTERM received. Shutting down gracefully...');
  
  server.close(() => {
    logger.info('HTTP server closed');
  });
  
  await prisma.$disconnect();
  logger.info('Database disconnected');
  
  process.exit(0);
});

// Start the server
startServer();