import dotenv from 'dotenv';
dotenv.config();

import { Job } from 'bull';
import { logger } from './utils/logger';
import { queueService, GenerationJobData } from './services/queue.service';
import { ReplicateService } from './services/replicate.service';
import { StorageService } from './services/storage.service';
import prisma from './utils/prisma';
import { GenerationStatus } from '@prisma/client';

const replicateService = new ReplicateService();
const storageService = new StorageService();

/**
 * Processes a single image generation job from the queue.
 */
const processGenerationJob = async (job: Job<GenerationJobData>): Promise<void> => {
    const { generationId, prompt, style, userId } = job.data;
    logger.info(`Processing generation ${generationId} for user ${userId}`);

    try {
        await prisma.generation.update({
            where: { id: generationId },
            data: { status: GenerationStatus.PROCESSING, startedAt: new Date() },
        });

        const generationRecord = await prisma.generation.findUnique({ where: { id: generationId }});

        const generationResult = await replicateService.generateImage({
            prompt,
            style,
            width: generationRecord?.width || 1024,
            height: generationRecord?.height || 1024,
        });

        const { url, key, size } = await storageService.uploadImage(
            // Fetch the image from the URL provided by Replicate
            Buffer.from(await (await fetch(generationResult.imageUrl)).arrayBuffer()),
            'generated-images'
        );

        await prisma.generation.update({
            where: { id: generationId },
            data: {
                status: GenerationStatus.COMPLETED,
                completedAt: new Date(),
                imageUrl: url, 
                storageKey: key,
                fileSize: size,
            },
        });

        logger.info(`Successfully completed and stored generation ${generationId}`);

    } catch (error: any) {
        logger.error(`Generation ${generationId} failed`, { error: error.message });
        await prisma.generation.update({
            where: { id: generationId },
            data: {
                status: GenerationStatus.FAILED,
                completedAt: new Date(),
                error: error.message || 'An unknown error occurred',
            },
        });
    }
};

/**
 * Starts the worker process.
 */
const startWorker = () => {
    logger.info('Worker process started. Listening for image generation jobs...');
    queueService.startProcessing(processGenerationJob);
};

startWorker();
