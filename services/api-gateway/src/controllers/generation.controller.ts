import { Request, Response, NextFunction } from 'express';
import { queueService } from '../services/queue.service';
import prisma from '../utils/prisma';
import { logger } from '../utils/logger';
import { AppError } from '../utils/errors';

// Note: The original controller was a class, but no other controller is.
// To maintain consistency with other route handlers, I'm refactoring these
// into standalone async functions and removing the unused services for now.
// The Replicate and Storage services will be used by the queue worker, not the controller.

/**
 * Create a new generation and add it to the queue.
 */
export const createGeneration = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.id;
        const { prompt, style } = req.body;

        // For now, width and height are fixed to the POD standard.
        // This could be a feature for premium users later.
        const POD_WIDTH = 4500;
        const POD_HEIGHT = 5400;

        // TODO: Check user's subscription limits before creating the generation.

        // Create the generation record in the database first.
        const generation = await prisma.generation.create({
            data: {
                userId,
                prompt,
                style,
                status: 'PENDING',
                width: POD_WIDTH,
                height: POD_HEIGHT,
            },
        });

        // Add the generation task to our processing queue.
        await queueService.addGenerationJob({
            generationId: generation.id,
            userId,
            prompt,
            style,
        });

        logger.info(`Generation ${generation.id} has been queued for user ${userId}.`);

        // Respond to the user immediately.
        // The client will poll or use a WebSocket for status updates.
        res.status(202).json({
            success: true,
            message: 'Generation has been queued.',
            data: {
                generationId: generation.id,
                status: generation.status,
            },
        });
    } catch (error) {
        logger.error('Failed to create generation:', error);
        next(error);
    }
};

/**
 * Get the status of a specific generation.
 */
export const getGenerationStatus = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const userId = req.user!.id;

        const generation = await prisma.generation.findFirst({
            where: { id, userId },
        });

        if (!generation) {
            throw new AppError('Generation not found or you do not have permission to view it.', 404);
        }

        res.status(200).json({
            success: true,
            data: generation,
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get a paginated history of the user's generations.
 */
export const getGenerationHistory = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.id;
        const page = parseInt(req.query.page as string) || 1;
        const limit = parseInt(req.query.limit as string) || 10;
        const skip = (page - 1) * limit;

        const generations = await prisma.generation.findMany({
            where: { userId },
            orderBy: { createdAt: 'desc' },
            skip,
            take: limit,
        });

        const totalGenerations = await prisma.generation.count({
            where: { userId },
        });

        res.status(200).json({
            success: true,
            data: generations,
            pagination: {
                currentPage: page,
                totalPages: Math.ceil(totalGenerations / limit),
                totalGenerations,
            },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Delete a generation.
 */
export const deleteGeneration = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const { id } = req.params;
        const userId = req.user!.id;

        const generation = await prisma.generation.findFirst({
            where: { id, userId },
        });

        if (!generation) {
            throw new AppError('Generation not found or you do not have permission to delete it.', 404);
        }

        // TODO: Delete the associated image from R2 storage before deleting the record.
        // const storageService = new StorageService();
        // if (generation.storageKey) {
        //     await storageService.deleteFile(generation.storageKey);
        // }

        await prisma.generation.delete({
            where: { id },
        });

        res.status(200).json({
            success: true,
            message: 'Generation deleted successfully.',
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Get available art styles.
 */
export const getStyles = async (req: Request, res: Response, next: NextFunction) => {
    // This could be stored in the database in the future.
    const styles = [
        { id: 'VINTAGE_POSTER', name: 'Vintage Poster' },
        { id: 'MINIMALIST_LINE', name: 'Minimalist Line Art' },
        { id: 'WATERCOLOR_ART', name: 'Watercolor' },
        { id: 'COMIC_BOOK', name: 'Comic Book' },
        { id: 'PHOTO_REALISTIC', name: 'Realistic Photo' },
        { id: 'CYBERPUNK_NEON', name: 'Cyberpunk Neon' },
    ];

    res.status(200).json({
        success: true,
        data: styles,
    });
};
