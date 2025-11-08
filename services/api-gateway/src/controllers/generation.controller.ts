import { Request, Response } from 'express';
import { ReplicateService } from '../services/replicate.service';
import { StorageService } from '../services/storage.service';
import { QueueService } from '../services/queue.service';
import { prisma } from '../utils/prisma';
import { logger } from '../utils/logger';
import { GenerationStyle } from '../types/generation';
import { AppError } from '../utils/errors';

export class GenerationController {
  private replicateService: ReplicateService;
  private storageService: StorageService;
  private queueService: QueueService;

  constructor() {
    this.replicateService = new ReplicateService();
    this.storageService = new StorageService();
    this.queueService = new QueueService();
  }

  /**
   * Create a new generation
   */
  async create(req: Request, res: Response) {
    const userId = req.user!.id;
    const { prompt, style, width, height, additionalParams } = req.body;

    // Check user's subscription limits
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { subscription: true }
    });

    if (!user) {
      throw new AppError('User not found', 404);
    }

    // Check generation limits
    const monthlyGenerations = await prisma.generation.count({
      where: {
        userId,
        createdAt: {
          gte: new Date(new Date().setDate(1)) // First day of current month
        }
      }
    });

    const limit = user.subscription?.generationLimit || 10; // Free tier default
    if (monthlyGenerations >= limit) {
      throw new AppError('Monthly generation limit exceeded', 403);
    }

    // Create generation record
    const generation = await prisma.generation.create({
      data: {
        userId,
        prompt,
        style,
        status: 'pending',
        metadata: {
          width: width || 1024,
          height: height || 1024,
          additionalParams
        }
      }
    });

    // Add to queue
    await this.queueService.addGenerationJob({
      generationId: generation.id,
      userId,
      prompt,
      style,
      width,
      height,
      additionalParams
    });

    logger.info('Generation created and queued', { 
      generationId: generation.id,
      userId 
    });

    res.status(201).json({
      success: true,
      data: {
        id: generation.id,
        status: generation.status,
        message: 'Generation queued successfully'
      }
    });
  }

  /**
   * Get generation status
   */
  async getStatus(req: Request, res: Response) {
    const { id } = req.params;
    const userId = req.user!.id;

    const generation = await prisma.generation.findFirst({
      where: { id, userId },
      include: {
        product: true
      }
    });

    if (!generation) {
      throw new AppError('Generation not found', 404);
    }

    // Get queue position if pending
    let queuePosition = null;
    if (generation.status === 'pending') {
      queuePosition = await this.queueService.getQueuePosition(id);
    }

    res.json({
      success: true,
      data: {
        id: generation.id,
        status: generation.status,
        prompt: generation.prompt,
        style: generation.style,
        imageUrl: generation.imageUrl,
        error: generation.error,
        queuePosition,
        createdAt: generation.createdAt,
        completedAt: generation.completedAt,
        product: generation.product
      }
    });
  }

  /**
   * Get user's generations
   */
  async getUserGenerations(req: Request, res: Response) {
    const userId = req.user!.id;
    const { page = 1, limit = 20, status, style } = req.query;

    const skip = (Number(page) - 1) * Number(limit);
    const where: any = { userId };

    if (status) {
      where.status = status;
    }

    if (style) {
      where.style = style;
    }

    const [generations, total] = await Promise.all([
      prisma.generation.findMany({
        where,
        skip,
        take: Number(limit),
        orderBy: { createdAt: 'desc' },
        include: {
          product: true
        }
      }),
      prisma.generation.count({ where })
    ]);

    res.json({
      success: true,
      data: {
        generations,
        pagination: {
          page: Number(page),
          limit: Number(limit),
          total,
          pages: Math.ceil(total / Number(limit))
        }
      }
    });
  }

  /**
   * Delete generation
   */
  async delete(req: Request, res: Response) {
    const { id } = req.params;
    const userId = req.user!.id;

    const generation = await prisma.generation.findFirst({
      where: { id, userId }
    });

    if (!generation) {
      throw new AppError('Generation not found', 404);
    }

    // Delete image from storage if exists
    if (generation.imageUrl && generation.storageKey) {
      try {
        await this.storageService.deleteFile(generation.storageKey);
      } catch (error) {
        logger.error('Failed to delete image from storage', { error });
      }
    }

    // Delete generation record
    await prisma.generation.delete({
      where: { id }
    });

    res.json({
      success: true,
      message: 'Generation deleted successfully'
    });
  }

  /**
   * Regenerate image
   */
  async regenerate(req: Request, res: Response) {
    const { id } = req.params;
    const userId = req.user!.id;

    const originalGeneration = await prisma.generation.findFirst({
      where: { id, userId }
    });

    if (!originalGeneration) {
      throw new AppError('Generation not found', 404);
    }

    // Check limits
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: { subscription: true }
    });

    const monthlyGenerations = await prisma.generation.count({
      where: {
        userId,
        createdAt: {
          gte: new Date(new Date().setDate(1))
        }
      }
    });

    const limit = user!.subscription?.generationLimit || 10;
    if (monthlyGenerations >= limit) {
      throw new AppError('Monthly generation limit exceeded', 403);
    }

    // Create new generation with same parameters
    const newGeneration = await prisma.generation.create({
      data: {
        userId,
        prompt: originalGeneration.prompt,
        style: originalGeneration.style,
        status: 'pending',
        metadata: originalGeneration.metadata,
        parentId: originalGeneration.id
      }
    });

    // Add to queue
    await this.queueService.addGenerationJob({
      generationId: newGeneration.id,
      userId,
      prompt: originalGeneration.prompt,
      style: originalGeneration.style as GenerationStyle,
      ...(originalGeneration.metadata as any)
    });

    res.status(201).json({
      success: true,
      data: {
        id: newGeneration.id,
        status: newGeneration.status,
        message: 'Regeneration queued successfully'
      }
    });
  }

  /**
   * Download generated image
   */
  async download(req: Request, res: Response) {
    const { id } = req.params;
    const userId = req.user!.id;

    const generation = await prisma.generation.findFirst({
      where: { id, userId }
    });

    if (!generation) {
      throw new AppError('Generation not found', 404);
    }

    if (!generation.imageUrl || !generation.storageKey) {
      throw new AppError('Image not available', 404);
    }

    // Generate presigned download URL
    const downloadUrl = await this.storageService.getPresignedDownloadUrl(
      generation.storageKey,
      3600 // 1 hour expiry
    );

    res.json({
      success: true,
      data: {
        downloadUrl,
        filename: `printcraft-${generation.style}-${generation.id}.webp`
      }
    });
  }

  /**
   * Get available styles
   */
  async getStyles(req: Request, res: Response) {
    const styles = Object.values(GenerationStyle).map(style => ({
      id: style,
      name: style.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
      description: this.getStyleDescription(style),
      example: `/examples/${style}.webp`
    }));

    res.json({
      success: true,
      data: styles
    });
  }

  /**
   * Get generation statistics
   */
  async getStats(req: Request, res: Response) {
    const userId = req.user!.id;
    
    const [
      totalGenerations,
      successfulGenerations,
      failedGenerations,
      styleStats
    ] = await Promise.all([
      prisma.generation.count({ where: { userId } }),
      prisma.generation.count({ where: { userId, status: 'completed' } }),
      prisma.generation.count({ where: { userId, status: 'failed' } }),
      prisma.generation.groupBy({
        by: ['style'],
        where: { userId },
        _count: { style: true },
        orderBy: { _count: { style: 'desc' } }
      })
    ]);

    const popularStyles = styleStats.map(stat => ({
      style: stat.style,
      count: stat._count.style
    }));

    res.json({
      success: true,
      data: {
        totalGenerations,
        successfulGenerations,
        failedGenerations,
        successRate: totalGenerations > 0 
          ? (successfulGenerations / totalGenerations * 100).toFixed(2) + '%'
          : '0%',
        popularStyles
      }
    });
  }

  /**
   * Get style description
   */
  private getStyleDescription(style: GenerationStyle): string {
    const descriptions: Record<GenerationStyle, string> = {
      [GenerationStyle.VINTAGE_POSTER]: 'Classic retro poster design with aged textures',
      [GenerationStyle.MINIMALIST_LINE]: 'Simple, clean line art with minimal details',
      [GenerationStyle.WATERCOLOR_ART]: 'Soft, flowing watercolor painting style',
      [GenerationStyle.COMIC_BOOK]: 'Bold comic book art with halftone effects',
      [GenerationStyle.RETRO_GAMING]: 'Pixel art inspired by classic video games',
      [GenerationStyle.ABSTRACT_GEOMETRIC]: 'Modern geometric patterns and shapes',
      [GenerationStyle.PHOTO_REALISTIC]: 'Highly detailed, realistic photography style',
      [GenerationStyle.GRAFFITI_STREET]: 'Urban street art and graffiti style',
      [GenerationStyle.JAPANESE_ANIME]: 'Japanese anime and manga art style',
      [GenerationStyle.ART_DECO]: 'Elegant 1920s Art Deco design',
      [GenerationStyle.CYBERPUNK_NEON]: 'Futuristic cyberpunk with neon lights',
      [GenerationStyle.BOTANICAL_VINTAGE]: 'Vintage botanical scientific illustrations',
      [GenerationStyle.POP_ART]: 'Andy Warhol-inspired pop art style',
      [GenerationStyle.TRIBAL_PATTERN]: 'Traditional tribal patterns and motifs',
      [GenerationStyle.GOTHIC_DARK]: 'Dark, gothic aesthetic with ornate details'
    };

    return descriptions[style] || 'Unique artistic style';
  }
}