import { Router } from 'express';
import { body, validationResult } from 'express-validator';
import { 
  createOrUpdateUserFromFirebase, 
  generateTokens,
  verifyRefreshToken,
  validateFirebaseToken 
} from '../services/auth.service';
import prisma from '../utils/prisma';
import { authenticate } from '../middleware/auth';
import { authRateLimiter } from '../middleware/rateLimiter';
import { ValidationError, AuthenticationError } from '../utils/errors';
import { logger } from '../utils/logger';

const router = Router();

// Validation middleware
const validate = (req: any, res: any, next: any) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    throw new ValidationError(errors.array()[0].msg);
  }
  next();
};

// Login with Firebase
router.post('/login',
  authRateLimiter,
  [
    body('idToken').notEmpty().withMessage('Firebase ID token is required'),
  ],
  validate,
  async (req, res, next) => {
    try {
      const { idToken } = req.body;

      // Validate Firebase token
      const firebaseUser = await validateFirebaseToken(idToken);

      // Create or update user in our database
      const user = await createOrUpdateUserFromFirebase(firebaseUser);

      // Generate JWT tokens
      const tokens = generateTokens(user.id, user.email);

      res.json({
        success: true,
        data: {
          user: {
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoUrl,
            role: user.role,
            subscription: user.subscription,
          },
          tokens,
        },
      });
    } catch (error) {
      next(error);
    }
  }
);

// Refresh token
router.post('/refresh',
  [
    body('refreshToken').notEmpty().withMessage('Refresh token is required'),
  ],
  validate,
  async (req, res, next) => {
    try {
      const { refreshToken } = req.body;

      // Verify refresh token
      const decoded = await verifyRefreshToken(refreshToken);

      // Get user
      const user = await prisma.user.findUnique({
        where: { id: decoded.userId },
        include: { subscription: true },
      });

      if (!user || user.status !== 'ACTIVE') {
        throw new AuthenticationError('User not found or inactive');
      }

      // Generate new tokens
      const tokens = generateTokens(user.id, user.email);

      res.json({
        success: true,
        data: {
          tokens,
        },
      });
    } catch (error) {
      next(error);
    }
  }
);

// Logout
router.post('/logout',
  authenticate,
  async (req, res, next) => {
    try {
      // In a production app, you might want to:
      // 1. Invalidate the refresh token in a blacklist
      // 2. Clear any server-side session
      // 3. Log the logout event

      logger.info(`User ${req.user!.id} logged out`);

      res.json({
        success: true,
        message: 'Logged out successfully',
      });
    } catch (error)_ {
      next(error);
    }
  }
);

// Verify token (for client-side token validation)
router.get('/verify',
  authenticate,
  async (req, res) => {
    res.json({
      success: true,
      data: {
        user: req.user,
      },
    });
  }
);

// Request password reset
router.post('/reset-password',
  authRateLimiter,
  [
    body('email').isEmail().withMessage('Valid email is required'),
  ],
  validate,
  async (req, res, next) => {
    try {
      const { email } = req.body;

      // This is a placeholder - implement with Firebase Auth
      // await sendPasswordResetEmail(email);

      // Always return success to prevent email enumeration
      res.json({
        success: true,
        message: 'If an account exists with this email, a password reset link has been sent.',
      });
    } catch (error) {
      next(error);
    }
  }
);

// Verify email
router.post('/verify-email',
  authenticate,
  async (req, res, next) => {
    try {
      // This is a placeholder - implement with Firebase Auth
      // await sendEmailVerification(req.user.firebaseUid);

      res.json({
        success: true,
        message: 'Verification email sent',
      });
    } catch (error) {
      next(error);
    }
  }
);

export default router;