import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { generationRateLimiter } from '../middleware/rateLimiter';
import { validateRequest } from '../middleware/validation.middleware';
import { asyncHandler } from '../utils/asyncHandler';
import { 
    createGeneration,
    getGenerationStatus,
    getGenerationHistory,
    deleteGeneration,
    getStyles 
} from '../controllers/generation.controller';
import { generationSchemas } from '../validations/generation.validation';

const router = Router();

// All generation routes require a valid JWT token.
router.use(authenticate);

// Create a new generation
router.post(
  '/',
  generationRateLimiter,
  validateRequest(generationSchemas.create),
  asyncHandler(createGeneration)
);

// Get a list of available art styles
router.get('/styles', asyncHandler(getStyles));

// Get the user's generation history
router.get(
    '/history', 
    validateRequest(generationSchemas.getUserGenerations),
    asyncHandler(getGenerationHistory)
);

// Get the status of a specific generation by its ID
router.get(
  '/:id',
  validateRequest(generationSchemas.getStatus),
  asyncHandler(getGenerationStatus)
);

// Delete a specific generation
router.delete(
  '/:id',
  validateRequest(generationSchemas.delete),
  asyncHandler(deleteGeneration)
);

export default router;