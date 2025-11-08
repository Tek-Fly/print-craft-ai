import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { v4 as uuidv4 } from 'uuid';
import admin from '../config/firebase'; // Import initialized Firebase Admin
import prisma from '../utils/prisma';
import { AuthenticationError } from '../utils/errors';
import { logger } from '../utils/logger';
import { DecodedIdToken } from 'firebase-admin/auth';

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
  return jwt.sign(payload, process.env.JWT_SECRET!, {
    expiresIn: '15m',
  });
};

// Generate refresh token
export const generateRefreshToken = (userId: string, email: string): string => {
  const payload: TokenPayload = {
    userId,
    email,
    type: 'refresh',
  };
  return jwt.sign(payload, process.env.JWT_SECRET!, {
    expiresIn: process.env.JWT_EXPIRY || '7d',
  });
};

// Generate both tokens
export const generateTokens = (userId: string, email: string) => {
  return {
    accessToken: generateAccessToken(userId, email),
    refreshToken: generateRefreshToken(userId, email),
  };
};

// ... (verifyAccessToken and verifyRefreshToken remain the same)

// Create or update user from Firebase
export const createOrUpdateUserFromFirebase = async (firebaseUser: DecodedIdToken) => {
    const { uid, email, name, picture } = firebaseUser;
  
    if (!email) {
      throw new AuthenticationError('Email not available from Firebase token.');
    }

    const user = await prisma.user.upsert({
      where: { firebaseUid: uid },
      update: {
        email,
        displayName: name,
        photoUrl: picture,
        lastLoginAt: new Date(),
      },
      create: {
        firebaseUid: uid,
        email,
        displayName: name,
        photoUrl: picture,
        // New users get a default FREE subscription
        subscription: {
          create: {
            plan: 'FREE',
            status: 'ACTIVE',
            // Free plan details...
          },
        },
      },
      include: {
        subscription: true,
      },
    });
  
    return user;
};

/**
 * Validates a Firebase ID token using the Firebase Admin SDK.
 * @param idToken The Firebase ID token from the client.
 * @returns The decoded token if valid.
 */
export const validateFirebaseToken = async (idToken: string): Promise<DecodedIdToken> => {
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return decodedToken;
  } catch (error: any) {
    logger.error('Firebase token validation error', { code: error.code, message: error.message });
    throw new AuthenticationError(`Invalid Firebase token: ${error.message}`);
  }
};
// ... (the rest of the file remains the same: hashPassword, comparePassword, etc.)

// Verify access token
export const verifyAccessToken = async (token: string): Promise<DecodedToken> => {
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as DecodedToken;
    
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
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as DecodedToken;
    
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
