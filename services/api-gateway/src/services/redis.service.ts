import { createClient, RedisClientType } from 'redis';
import { logger } from '../utils/logger';

let redisClient: RedisClientType | null = null;

export const initializeRedis = async (): Promise<RedisClientType> => {
  if (redisClient) {
    return redisClient;
  }

  redisClient = createClient({
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  });

  redisClient.on('error', (err) => {
    logger.error('Redis Client Error:', err);
  });

  redisClient.on('connect', () => {
    logger.info('Redis Client Connected');
  });

  await redisClient.connect();

  return redisClient;
};

export const getRedisClient = (): RedisClientType => {
  if (!redisClient) {
    throw new Error('Redis client not initialized');
  }
  return redisClient;
};

// Cache utilities
export const cache = {
  // Get cached value
  async get<T>(key: string): Promise<T | null> {
    const client = getRedisClient();
    const value = await client.get(key);
    
    if (!value) return null;
    
    try {
      return JSON.parse(value) as T;
    } catch {
      return value as T;
    }
  },

  // Set cached value with expiration
  async set(key: string, value: any, expirationSeconds?: number): Promise<void> {
    const client = getRedisClient();
    const stringValue = typeof value === 'string' ? value : JSON.stringify(value);
    
    if (expirationSeconds) {
      await client.setEx(key, expirationSeconds, stringValue);
    } else {
      await client.set(key, stringValue);
    }
  },

  // Delete cached value
  async del(key: string): Promise<void> {
    const client = getRedisClient();
    await client.del(key);
  },

  // Check if key exists
  async exists(key: string): Promise<boolean> {
    const client = getRedisClient();
    const result = await client.exists(key);
    return result === 1;
  },

  // Set expiration on existing key
  async expire(key: string, seconds: number): Promise<void> {
    const client = getRedisClient();
    await client.expire(key, seconds);
  },

  // Increment counter
  async incr(key: string): Promise<number> {
    const client = getRedisClient();
    return await client.incr(key);
  },

  // Decrement counter
  async decr(key: string): Promise<number> {
    const client = getRedisClient();
    return await client.decr(key);
  },

  // Get all keys matching pattern
  async keys(pattern: string): Promise<string[]> {
    const client = getRedisClient();
    return await client.keys(pattern);
  },

  // Clear all cache (use with caution)
  async flushAll(): Promise<void> {
    const client = getRedisClient();
    await client.flushAll();
  },
};

// Session management
export const sessionStore = {
  async get(sessionId: string): Promise<any> {
    return cache.get(`session:${sessionId}`);
  },

  async set(sessionId: string, data: any, ttl: number = 3600): Promise<void> {
    await cache.set(`session:${sessionId}`, data, ttl);
  },

  async destroy(sessionId: string): Promise<void> {
    await cache.del(`session:${sessionId}`);
  },
};

// Rate limiting helpers
export const rateLimiting = {
  async increment(key: string, windowSeconds: number): Promise<number> {
    const client = getRedisClient();
    const multi = client.multi();
    
    multi.incr(key);
    multi.expire(key, windowSeconds);
    
    const results = await multi.exec();
    return results[0] as number;
  },

  async get(key: string): Promise<number> {
    const value = await cache.get<string>(key);
    return value ? parseInt(value, 10) : 0;
  },
};

// Queue helpers
export const queueHelpers = {
  async addToQueue(queueName: string, data: any): Promise<void> {
    const client = getRedisClient();
    await client.lPush(`queue:${queueName}`, JSON.stringify(data));
  },

  async getFromQueue(queueName: string): Promise<any | null> {
    const client = getRedisClient();
    const value = await client.rPop(`queue:${queueName}`);
    
    if (!value) return null;
    
    try {
      return JSON.parse(value);
    } catch {
      return value;
    }
  },

  async getQueueLength(queueName: string): Promise<number> {
    const client = getRedisClient();
    return await client.lLen(`queue:${queueName}`);
  },
};

// Pub/Sub helpers
export const pubsub = {
  async publish(channel: string, message: any): Promise<void> {
    const client = getRedisClient();
    const stringMessage = typeof message === 'string' ? message : JSON.stringify(message);
    await client.publish(channel, stringMessage);
  },

  async subscribe(channel: string, handler: (message: string) => void): Promise<void> {
    const client = getRedisClient().duplicate();
    await client.connect();
    
    await client.subscribe(channel, (message) => {
      handler(message);
    });
  },
};