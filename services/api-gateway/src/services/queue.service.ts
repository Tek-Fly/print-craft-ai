import Bull, { Job, DoneCallback } from 'bull';
import { logger } from '../utils/logger';

enum QueueName {
    IMAGE_GENERATION = 'image-generation',
}

export interface GenerationJobData {
    generationId: string;
    userId: string;
    prompt: string;
    style: string;
}

class QueueService {
    private imageGenerationQueue: Bull.Queue;

    constructor() {
        const redisConfig = {
            host: process.env.REDIS_HOST || '127.0.0.1',
            port: parseInt(process.env.REDIS_PORT || '6379'),
        };

        this.imageGenerationQueue = new Bull<GenerationJobData>(QueueName.IMAGE_GENERATION, {
            redis: redisConfig,
            defaultJobOptions: {
                attempts: 3,
                backoff: {
                    type: 'exponential',
                    delay: 5000,
                },
                removeOnComplete: true,
                removeOnFail: 50,
            },
        });

        this.setupEventListeners();
    }

    private setupEventListeners() {
        this.imageGenerationQueue.on('completed', (job, result) => {
            logger.info(`Job ${job.id} (generationId: ${job.data.generationId}) completed successfully.`);
        });

        this.imageGenerationQueue.on('failed', (job, err) => {
            logger.error(`Job ${job.id} (generationId: ${job.data.generationId}) failed: ${err.message}`);
        });
    }

    public async addGenerationJob(data: GenerationJobData): Promise<Bull.Job<GenerationJobData>> {
        try {
            const job = await this.imageGenerationQueue.add(data);
            logger.info(`Added generation job ${job.id} for generationId: ${data.generationId} to the queue.`);
            return job;
        } catch (error) {
            logger.error('Failed to add generation job to the queue', { error, data });
            throw new Error('Could not add job to the queue.');
        }
    }

    /**
     * Registers a processor function to handle jobs from the image generation queue.
     * @param processor The async function to process a job.
     */
    public startProcessing(processor: (job: Job<GenerationJobData>) => Promise<void>) {
        const concurrency = parseInt(process.env.QUEUE_CONCURRENCY || '1');
        
        this.imageGenerationQueue.process(concurrency, async (job: Job<GenerationJobData>, done: DoneCallback) => {
            try {
                await processor(job);
                done();
            } catch (error: any) {
                logger.error(`Unhandled error in job processor for job ${job.id}`, { error: error.message });
                done(error);
            }
        });
    }
}

// Export a singleton instance of the QueueService
export const queueService = new QueueService();
