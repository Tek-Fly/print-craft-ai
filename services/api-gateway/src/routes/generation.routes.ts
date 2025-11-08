import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import { generationRateLimiter } from '../middleware/rateLimiter';
import { validateRequest } from '../middleware/validation.middleware';
import { asyncHandler } from '../utils/asyncHandler';
import { GenerationController } from '../controllers/generation.controller';
import { generationSchemas } from '../validations/generation.validation';

const router = Router();
const generationController = new GenerationController();

// All generation routes require authentication
router.use(authenticate);

// Create new generation
router.post(
  '/create',
  generationRateLimiter,
  validateRequest(generationSchemas.create),
  asyncHandler(generationController.create.bind(generationController))
);

// Get generation status
router.get(
  '/status/:id',
  validateRequest(generationSchemas.getStatus),
  asyncHandler(generationController.getStatus.bind(generationController))
);

// Get user's generations
router.get(
  '/user',
  validateRequest(generationSchemas.getUserGenerations),
  asyncHandler(generationController.getUserGenerations.bind(generationController))
);

// Delete generation
router.delete(
  '/:id',
  validateRequest(generationSchemas.delete),
  asyncHandler(generationController.delete.bind(generationController))
);

// Regenerate image
router.post(
  '/regenerate/:id',
  generationRateLimiter,
  validateRequest(generationSchemas.regenerate),
  asyncHandler(generationController.regenerate.bind(generationController))
);

// Download generated image
router.get(
  '/download/:id',
  validateRequest(generationSchemas.download),
  asyncHandler(generationController.download.bind(generationController))
);

// Get available styles
router.get(
  '/styles',
  asyncHandler(generationController.getStyles.bind(generationController))
);

// Get generation statistics
router.get(
  '/stats',
  asyncHandler(generationController.getStats.bind(generationController))
);

export default router;