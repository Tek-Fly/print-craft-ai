import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import { prisma } from '../server';
import { AuthenticationError } from '../utils/errors';
import { logger } from '../utils/logger';

interface TokenPayload {
  userId: string;
  email: string;
  type: 'access' | 'refresh';
}

interface DecodedToken extends TokenPayload {
  iat: number;
  exp: number;
}

// Generate access token
export const generateAccessToken = (userId: string, email: string): string => {
  const payload: TokenPayload = {
    userId,
    email,
    type: 'access',
  };

  return jwt.sign(payload, process.env.JWT_ACCESS_SECRET!, {
    expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '15m',
  });
};

// Generate refresh token
export const generateRefreshToken = (userId: string, email: string): string => {
  const payload: TokenPayload = {
    userId,
    email,
    type: 'refresh',
  };

  return jwt.sign(payload, process.env.JWT_REFRESH_SECRET!, {
    expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  });
};

// Generate both tokens
export const generateTokens = (userId: string, email: string) => {
  return {
    accessToken: generateAccessToken(userId, email),
    refreshToken: generateRefreshToken(userId, email),
  };
};

// Verify access token
export const verifyAccessToken = async (token: string): Promise<DecodedToken> => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_ACCESS_SECRET!) as DecodedToken;
    
    if (decoded.type !== 'access') {
      throw new AuthenticationError('Invalid token type');
    }

    return decoded;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new AuthenticationError('Token has expired');
    } else if (error instanceof jwt.JsonWebTokenError) {
      throw new AuthenticationError('Invalid token');
    }
    throw error;
  }
};

// Verify refresh token
export const verifyRefreshToken = async (token: string): Promise<DecodedToken> => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET!) as DecodedToken;
    
    if (decoded.type !== 'refresh') {
      throw new AuthenticationError('Invalid token type');
    }

    return decoded;
  } catch (error) {
    if (error instanceof jwt.TokenExpiredError) {
      throw new AuthenticationError('Refresh token has expired');
    } else if (error instanceof jwt.JsonWebTokenError) {
      throw new AuthenticationError('Invalid refresh token');
    }
    throw error;
  }
};

// Hash password
export const hashPassword = async (password: string): Promise<string> => {
  const saltRounds = 10;
  return bcrypt.hash(password, saltRounds);
};

// Compare password
export const comparePassword = async (password: string, hash: string): Promise<boolean> => {
  return bcrypt.compare(password, hash);
};

// Generate API key
export const generateApiKey = (): string => {
  // Generate a secure API key with prefix
  const prefix = 'sk_live';
  const key = uuidv4().replace(/-/g, '');
  return `${prefix}_${key}`;
};

// Hash API key for storage
export const hashApiKey = async (apiKey: string): Promise<string> => {
  // We'll store a hash of the API key for security
  return bcrypt.hash(apiKey, 12);
};

// Verify API key
export const verifyApiKey = async (apiKey: string): Promise<any> => {
  try {
    // For now, we'll do a simple lookup
    // In production, you might want to cache this
    const apiKeyRecord = await prisma.apiKey.findUnique({
      where: { key: apiKey },
      include: {
        user: true,
      },
    });

    if (!apiKeyRecord || !apiKeyRecord.isActive) {
      return null;
    }

    if (apiKeyRecord.expiresAt && new Date(apiKeyRecord.expiresAt) < new Date()) {
      return null;
    }

    return apiKeyRecord;
  } catch (error) {
    logger.error('Error verifying API key:', error);
    return null;
  }
};

// Create or update user from Firebase
export const createOrUpdateUserFromFirebase = async (firebaseUser: any) => {
  const { uid, email, displayName, photoURL } = firebaseUser;

  try {
    const user = await prisma.user.upsert({
      where: { firebaseUid: uid },
      update: {
        email: email || undefined,
        displayName: displayName || undefined,
        photoUrl: photoURL || undefined,
        lastLoginAt: new Date(),
      },
      create: {
        firebaseUid: uid,
        email: email!,
        displayName: displayName || undefined,
        photoUrl: photoURL || undefined,
        lastLoginAt: new Date(),
        subscription: {
          create: {
            plan: 'FREE',
            status: 'ACTIVE',
            currentPeriodStart: new Date(),
            currentPeriodEnd: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000), // 30 days
            monthlyGenerationLimit: 10,
            resetAt: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000),
            features: {
              watermark: true,
              premiumStyles: false,
              batchGeneration: false,
              priorityQueue: false,
            },
          },
        },
      },
      include: {
        subscription: true,
      },
    });

    return user;
  } catch (error) {
    logger.error('Error creating/updating user from Firebase:', error);
    throw error;
  }
};

// Validate Firebase token (you'll need to implement Firebase Admin SDK)
export const validateFirebaseToken = async (idToken: string): Promise<any> => {
  // This is a placeholder - you'll need to implement Firebase Admin SDK
  // For now, we'll throw an error
  throw new AuthenticationError('Firebase validation not implemented yet');
  
  // Example implementation:
  // try {
  //   const decodedToken = await admin.auth().verifyIdToken(idToken);
  //   return decodedToken;
  // } catch (error) {
  //   throw new AuthenticationError('Invalid Firebase token');
  // }
};