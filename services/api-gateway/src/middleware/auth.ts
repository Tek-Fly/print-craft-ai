import { Request, Response, NextFunction } from 'express';
import { AuthenticationError, AuthorizationError } from '../utils/errors';
import { verifyAccessToken, verifyApiKey } from '../services/auth.service';
import { prisma } from '../server';

// Extend Request type to include user
declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        firebaseUid: string;
        email: string;
        role: string;
      };
      apiKey?: {
        id: string;
        name: string;
        scopes: string[];
      };
    }
  }
}

// Authenticate user via JWT token
export const authenticate = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      throw new AuthenticationError('No authorization header provided');
    }

    const [type, token] = authHeader.split(' ');
    
    if (type !== 'Bearer' || !token) {
      throw new AuthenticationError('Invalid authorization format');
    }

    // Verify JWT token
    const decoded = await verifyAccessToken(token);
    
    // Get user from database
    const user = await prisma.user.findUnique({
      where: { id: decoded.userId },
      select: {
        id: true,
        firebaseUid: true,
        email: true,
        role: true,
        status: true,
      },
    });

    if (!user) {
      throw new AuthenticationError('User not found');
    }

    if (user.status !== 'ACTIVE') {
      throw new AuthenticationError('User account is not active');
    }

    // Attach user to request
    req.user = user;
    next();
  } catch (error) {
    next(error);
  }
};

// Authenticate via API key
export const authenticateApiKey = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const apiKeyHeader = req.headers['x-api-key'] as string;
    
    if (!apiKeyHeader) {
      // If no API key, fall back to JWT authentication
      return authenticate(req, res, next);
    }

    // Verify API key
    const apiKeyData = await verifyApiKey(apiKeyHeader);
    
    if (!apiKeyData) {
      throw new AuthenticationError('Invalid API key');
    }

    // Get user from API key
    const apiKey = await prisma.apiKey.findUnique({
      where: { key: apiKeyHeader },
      include: {
        user: {
          select: {
            id: true,
            firebaseUid: true,
            email: true,
            role: true,
            status: true,
          },
        },
      },
    });

    if (!apiKey || !apiKey.isActive) {
      throw new AuthenticationError('API key is not active');
    }

    if (apiKey.expiresAt && new Date(apiKey.expiresAt) < new Date()) {
      throw new AuthenticationError('API key has expired');
    }

    if (apiKey.user.status !== 'ACTIVE') {
      throw new AuthenticationError('User account is not active');
    }

    // Update last used timestamp
    await prisma.apiKey.update({
      where: { id: apiKey.id },
      data: { lastUsedAt: new Date() },
    });

    // Attach user and API key info to request
    req.user = apiKey.user;
    req.apiKey = {
      id: apiKey.id,
      name: apiKey.name,
      scopes: apiKey.scopes,
    };

    next();
  } catch (error) {
    next(error);
  }
};

// Optional authentication (doesn't fail if no token)
export const optionalAuth = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return next();
    }

    const [type, token] = authHeader.split(' ');
    
    if (type !== 'Bearer' || !token) {
      return next();
    }

    // Try to verify token
    try {
      const decoded = await verifyAccessToken(token);
      
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        select: {
          id: true,
          firebaseUid: true,
          email: true,
          role: true,
          status: true,
        },
      });

      if (user && user.status === 'ACTIVE') {
        req.user = user;
      }
    } catch (error) {
      // Ignore token verification errors for optional auth
    }

    next();
  } catch (error) {
    next(error);
  }
};

// Require specific roles
export const requireRole = (...roles: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(new AuthenticationError('Authentication required'));
    }

    if (!roles.includes(req.user.role)) {
      return next(new AuthorizationError(`Role ${roles.join(' or ')} required`));
    }

    next();
  };
};

// Require specific API key scopes
export const requireScope = (...scopes: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    if (!req.apiKey) {
      return next(new AuthenticationError('API key authentication required'));
    }

    const hasScope = scopes.some(scope => req.apiKey!.scopes.includes(scope));
    
    if (!hasScope) {
      return next(new AuthorizationError(`API key scope ${scopes.join(' or ')} required`));
    }

    next();
  };
};

// Verify user owns the resource
export const verifyOwnership = (resourceIdParam: string = 'id') => {
  return async (req: Request, res: Response, next: NextFunction) => {
    if (!req.user) {
      return next(new AuthenticationError('Authentication required'));
    }

    // Admin can access any resource
    if (req.user.role === 'ADMIN') {
      return next();
    }

    const resourceId = req.params[resourceIdParam];
    const userId = req.user.id;

    // This is a generic example - you'll need to adapt this based on the resource type
    // For now, we'll assume the resource has a userId field
    try {
      // You would check the specific resource here
      // Example for generation:
      if (req.baseUrl.includes('/generation')) {
        const generation = await prisma.generation.findUnique({
          where: { id: resourceId },
          select: { userId: true },
        });

        if (!generation || generation.userId !== userId) {
          return next(new AuthorizationError('You do not have access to this resource'));
        }
      }

      next();
    } catch (error) {
      next(error);
    }
  };
};