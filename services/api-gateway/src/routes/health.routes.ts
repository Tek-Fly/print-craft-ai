import { Router } from 'express';
import prisma from '../utils/prisma';
import { logger } from '../utils/logger';

const router = Router();

// Basic health check
router.get('/', async (req, res) => {
  res.json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'api-gateway',
    version: process.env.npm_package_version || '1.0.0',
  });
});

// Detailed health check
router.get('/detailed', async (req, res) => {
  const checks = {
    database: { status: 'checking' },
    redis: { status: 'checking' },
    replicate: { status: 'checking' },
  };

  // Check database
  try {
    await prisma.$queryRaw`SELECT 1`;
    checks.database = { status: 'healthy' };
  } catch (error) {
    logger.error('Database health check failed:', error);
    checks.database = { status: 'unhealthy', error: (error as Error).message };
  }

  // Check Redis (placeholder)
  try {
    // TODO: Implement Redis ping
    checks.redis = { status: 'healthy' };
  } catch (error) {
    logger.error('Redis health check failed:', error);
    checks.redis = { status: 'unhealthy', error: (error as Error).message };
  }

  // Check Replicate API (placeholder)
  try {
    // TODO: Implement Replicate API check
    checks.replicate = { status: 'healthy' };
  } catch (error) {
    logger.error('Replicate API health check failed:', error);
    checks.replicate = { status: 'unhealthy', error: (error as Error).message };
  }

  const allHealthy = Object.values(checks).every(check => check.status === 'healthy');
  const status = allHealthy ? 200 : 503;

  res.status(status).json({
    status: allHealthy ? 'healthy' : 'degraded',
    timestamp: new Date().toISOString(),
    checks,
  });
});

// Readiness check
router.get('/ready', async (req, res) => {
  try {
    // Check if database is ready
    await prisma.$queryRaw`SELECT 1`;
    
    res.json({
      ready: true,
      timestamp: new Date().toISOString(),
    });
  } catch (error) {
    res.status(503).json({
      ready: false,
      timestamp: new Date().toISOString(),
      error: (error as Error).message,
    });
  }
});

// Liveness check
router.get('/live', (req, res) => {
  res.json({
    alive: true,
    timestamp: new Date().toISOString(),
  });
});

export default router;