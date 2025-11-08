import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { asyncHandler } from '../utils/asyncHandler';
import { getProfile, updateProfile } from '../controllers/user.controller';
import { validateRequest } from '../middleware/validation.middleware';
import { userSchemas } from '../validations/user.validation';


const router = Router();

// All user routes require authentication
router.use(authenticate);

// Get user profile
router.get(
    '/profile', 
    asyncHandler(getProfile)
);

// Update user profile
router.put(
    '/profile', 
    validateRequest(userSchemas.updateProfile),
    asyncHandler(updateProfile)
);

export default router;
