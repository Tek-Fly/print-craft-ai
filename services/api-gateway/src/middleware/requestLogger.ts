import { Request, Response, NextFunction } from 'express';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';

// Extend Request type to include requestId
declare global {
  namespace Express {
    interface Request {
      requestId: string;
      startTime: number;
    }
  }
}

export const requestLogger = (req: Request, res: Response, next: NextFunction) => {
  // Generate unique request ID
  req.requestId = uuidv4();
  req.startTime = Date.now();

  // Log request
  logger.info({
    type: 'request',
    requestId: req.requestId,
    method: req.method,
    url: req.originalUrl,
    ip: req.ip,
    userAgent: req.get('user-agent'),
  });

  // Log response when finished
  res.on('finish', () => {
    const duration = Date.now() - req.startTime;
    
    logger.info({
      type: 'response',
      requestId: req.requestId,
      method: req.method,
      url: req.originalUrl,
      statusCode: res.statusCode,
      duration: `${duration}ms`,
      contentLength: res.get('content-length'),
    });
  });

  // Add request ID to response headers
  res.setHeader('X-Request-ID', req.requestId);

  next();
};