import { Server as SocketServer } from 'socket.io';
import { verifyAccessToken } from './auth.service';
import { logger } from '../utils/logger';

let io: SocketServer;

export const initializeWebSocket = (socketServer: SocketServer) => {
  io = socketServer;

  // Authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token;
      
      if (!token) {
        return next(new Error('Authentication required'));
      }

      const decoded = await verifyAccessToken(token);
      socket.data.userId = decoded.userId;
      socket.data.email = decoded.email;

      next();
    } catch (error) {
      logger.error('WebSocket authentication error:', error);
      next(new Error('Authentication failed'));
    }
  });

  // Connection handler
  io.on('connection', (socket) => {
    const userId = socket.data.userId;
    logger.info(`User ${userId} connected via WebSocket`);

    // Join user-specific room
    socket.join(`user:${userId}`);

    // Handle events
    socket.on('subscribe:generation', (generationId: string) => {
      socket.join(`generation:${generationId}`);
      logger.info(`User ${userId} subscribed to generation ${generationId}`);
    });

    socket.on('unsubscribe:generation', (generationId: string) => {
      socket.leave(`generation:${generationId}`);
      logger.info(`User ${userId} unsubscribed from generation ${generationId}`);
    });

    socket.on('ping', () => {
      socket.emit('pong');
    });

    socket.on('disconnect', () => {
      logger.info(`User ${userId} disconnected from WebSocket`);
    });

    socket.on('error', (error) => {
      logger.error(`WebSocket error for user ${userId}:`, error);
    });
  });
};

// Emit generation status update
export const emitGenerationUpdate = (generationId: string, data: {
  status: string;
  progress?: number;
  imageUrl?: string;
  thumbnailUrl?: string;
  error?: string;
}) => {
  if (!io) {
    logger.warn('WebSocket not initialized');
    return;
  }

  io.to(`generation:${generationId}`).emit('generation:update', {
    generationId,
    ...data,
    timestamp: new Date().toISOString(),
  });
};

// Emit to specific user
export const emitToUser = (userId: string, event: string, data: any) => {
  if (!io) {
    logger.warn('WebSocket not initialized');
    return;
  }

  io.to(`user:${userId}`).emit(event, data);
};

// Emit generation completed
export const emitGenerationComplete = (userId: string, generation: {
  id: string;
  imageUrl: string;
  thumbnailUrl: string;
  prompt: string;
  style: string;
  quality: string;
}) => {
  emitToUser(userId, 'generation:complete', generation);
  emitGenerationUpdate(generation.id, {
    status: 'completed',
    imageUrl: generation.imageUrl,
    thumbnailUrl: generation.thumbnailUrl,
  });
};

// Emit generation failed
export const emitGenerationFailed = (generationId: string, userId: string, error: string) => {
  emitToUser(userId, 'generation:failed', {
    generationId,
    error,
  });
  emitGenerationUpdate(generationId, {
    status: 'failed',
    error,
  });
};

// Emit queue position update
export const emitQueueUpdate = (userId: string, data: {
  position: number;
  estimatedTime: number;
}) => {
  emitToUser(userId, 'queue:update', data);
};

// Emit subscription update
export const emitSubscriptionUpdate = (userId: string, data: {
  plan: string;
  generationsRemaining: number;
  resetAt: Date;
}) => {
  emitToUser(userId, 'subscription:update', data);
};

// Broadcast system message
export const broadcastSystemMessage = (message: {
  type: 'info' | 'warning' | 'error';
  title: string;
  content: string;
}) => {
  if (!io) {
    logger.warn('WebSocket not initialized');
    return;
  }

  io.emit('system:message', {
    ...message,
    timestamp: new Date().toISOString(),
  });
};

// Get connected users count
export const getConnectedUsersCount = (): number => {
  if (!io) return 0;
  return io.sockets.sockets.size;
};

// Get user's active connections
export const getUserConnections = async (userId: string): Promise<string[]> => {
  if (!io) return [];
  
  const sockets = await io.in(`user:${userId}`).fetchSockets();
  return sockets.map(socket => socket.id);
};