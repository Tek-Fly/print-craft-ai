import rateLimit from 'express-rate-limit';
import { Request, Response } from 'express';
import { RateLimitError } from '../utils/errors';

// Default rate limiter
export const rateLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '60000'), // 1 minute
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100'), // 100 requests per window
  message: 'Too many requests, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  handler: (req: Request, res: Response) => {
    throw new RateLimitError('Too many requests from this IP, please try again later');
  },
  skip: (req: Request) => {
    // Skip rate limiting for webhooks
    return req.path.startsWith('/api/v1/webhook');
  },
});

// Strict rate limiter for auth endpoints
export const authRateLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 requests per window
  message: 'Too many authentication attempts, please try again later',
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Don't count successful requests
});

// Generation rate limiter
export const generationRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 10, // 10 generations per minute
  message: 'Generation rate limit exceeded, please wait before generating more images',
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req: Request) => {
    // Use user ID if authenticated, otherwise use IP
    return (req as any).user?.id || req.ip;
  },
});

// API key rate limiter (higher limits)
export const apiKeyRateLimiter = rateLimit({
  windowMs: 60 * 1000, // 1 minute
  max: 1000, // Much higher limit for API keys
  message: 'API rate limit exceeded',
  standardHeaders: true,
  legacyHeaders: false,
  keyGenerator: (req: Request) => {
    // Use API key as identifier
    return req.headers['x-api-key'] as string || req.ip;
  },
  skip: (req: Request) => {
    // Skip if no API key is provided (will use default rate limiter)
    return !req.headers['x-api-key'];
  },
});