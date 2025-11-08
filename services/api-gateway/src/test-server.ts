/**
 * Simplified Test Server for PrintCraft AI
 * 
 * This is a temporary server implementation to bypass TypeScript compilation issues
 * in the main server.ts file. Use this for development until TypeScript errors are fixed.
 * 
 * IMPORTANT: This server lacks proper authentication, error handling, and validation.
 * DO NOT use in production!
 * 
 * To run: npm run dev:test
 * 
 * @author Claude (Anthropic)
 * @date November 8, 2025
 */

import express from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const prisma = new PrismaClient();
const PORT = process.env.PORT || 8000;

// Middleware
app.use(cors());
app.use(express.json());

// Test endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'PrintCraft AI API is running!',
    timestamp: new Date().toISOString(),
    endpoints: {
      health: '/health',
      testGeneration: '/test-generation'
    }
  });
});

// Health check
app.get('/health', async (req, res) => {
  try {
    // Test database connection
    await prisma.$queryRaw`SELECT 1`;
    
    res.json({
      status: 'healthy',
      database: 'connected',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    res.status(503).json({
      status: 'unhealthy',
      database: 'disconnected',
      error: error instanceof Error ? error.message : 'Unknown error'
    });
  }
});

// Test generation endpoint (mock)
app.post('/test-generation', (req, res) => {
  const { prompt, style } = req.body;
  
  res.json({
    success: true,
    data: {
      id: 'test-' + Date.now(),
      prompt: prompt || 'Test prompt',
      style: style || 'vintage_poster',
      status: 'processing',
      message: 'This is a test response. In production, this would trigger AI generation.'
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`
🚀 Test server running on http://localhost:${PORT}
📱 Ready for Android emulator testing
🔗 CORS enabled for all origins
  `);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  await prisma.$disconnect();
  process.exit(0);
});