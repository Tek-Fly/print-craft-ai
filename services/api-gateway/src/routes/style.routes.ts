import { Router } from 'express';
import { optionalAuth } from '../middleware/auth';

const router = Router();

// Get available styles (public endpoint with optional auth)
router.get('/list', optionalAuth, async (req, res, next) => {
  try {
    res.json({
      success: true,
      data: {
        message: 'Styles list endpoint - To be implemented',
      },
    });
  } catch (error) {
    next(error);
  }
});

// Get style details
router.get('/details/:id', optionalAuth, async (req, res, next) => {
  try {
    res.json({
      success: true,
      data: {
        message: 'Style details endpoint - To be implemented',
        styleId: req.params.id,
      },
    });
  } catch (error) {
    next(error);
  }
});

export default router;