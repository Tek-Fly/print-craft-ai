import Bull from 'bull';
import { logger } from '../utils/logger';

// Define queue names
export enum QueueName {
  IMAGE_GENERATION = 'image-generation',
  EMAIL_NOTIFICATION = 'email-notification',
  ANALYTICS = 'analytics',
  CLEANUP = 'cleanup',
}

// Queue instances
const queues: Map<QueueName, Bull.Queue> = new Map();

// Queue configuration
const defaultQueueOptions: Bull.QueueOptions = {
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379'),
    password: process.env.REDIS_PASSWORD,
  },
  defaultJobOptions: {
    removeOnComplete: 100, // Keep last 100 completed jobs
    removeOnFail: 500, // Keep last 500 failed jobs
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 2000,
    },
  },
};

// Initialize queues
export const initializeQueue = async () => {
  try {
    // Initialize image generation queue
    const imageGenerationQueue = new Bull(QueueName.IMAGE_GENERATION, defaultQueueOptions);
    queues.set(QueueName.IMAGE_GENERATION, imageGenerationQueue);

    // Initialize email notification queue
    const emailQueue = new Bull(QueueName.EMAIL_NOTIFICATION, defaultQueueOptions);
    queues.set(QueueName.EMAIL_NOTIFICATION, emailQueue);

    // Initialize analytics queue
    const analyticsQueue = new Bull(QueueName.ANALYTICS, defaultQueueOptions);
    queues.set(QueueName.ANALYTICS, analyticsQueue);

    // Initialize cleanup queue
    const cleanupQueue = new Bull(QueueName.CLEANUP, defaultQueueOptions);
    queues.set(QueueName.CLEANUP, cleanupQueue);

    // Set up queue event listeners
    queues.forEach((queue, name) => {
      queue.on('completed', (job) => {
        logger.info(`Job ${job.id} completed in queue ${name}`);
      });

      queue.on('failed', (job, err) => {
        logger.error(`Job ${job.id} failed in queue ${name}:`, err);
      });

      queue.on('stalled', (job) => {
        logger.warn(`Job ${job.id} stalled in queue ${name}`);
      });
    });

    logger.info('All queues initialized successfully');
  } catch (error) {
    logger.error('Failed to initialize queues:', error);
    throw error;
  }
};

// Get queue instance
export const getQueue = (name: QueueName): Bull.Queue => {
  const queue = queues.get(name);
  if (!queue) {
    throw new Error(`Queue ${name} not found`);
  }
  return queue;
};

// Add job to queue
export const addJob = async <T>(
  queueName: QueueName,
  data: T,
  options?: Bull.JobOptions
): Promise<Bull.Job<T>> => {
  const queue = getQueue(queueName);
  return await queue.add(data, options);
};

// Image generation queue helpers
export const imageGenerationQueue = {
  async add(data: {
    generationId: string;
    userId: string;
    prompt: string;
    negativePrompt?: string;
    style: string;
    quality: string;
    settings: any;
  }, options?: Bull.JobOptions) {
    return addJob(QueueName.IMAGE_GENERATION, data, {
      priority: data.quality === 'ULTRA' ? 1 : 0,
      ...options,
    });
  },

  async getJob(jobId: string) {
    const queue = getQueue(QueueName.IMAGE_GENERATION);
    return await queue.getJob(jobId);
  },

  async getWaitingCount() {
    const queue = getQueue(QueueName.IMAGE_GENERATION);
    return await queue.getWaitingCount();
  },

  async getActiveCount() {
    const queue = getQueue(QueueName.IMAGE_GENERATION);
    return await queue.getActiveCount();
  },

  async getCompletedCount() {
    const queue = getQueue(QueueName.IMAGE_GENERATION);
    return await queue.getCompletedCount();
  },

  async getFailedCount() {
    const queue = getQueue(QueueName.IMAGE_GENERATION);
    return await queue.getFailedCount();
  },

  async clean(grace: number = 3600000) {
    const queue = getQueue(QueueName.IMAGE_GENERATION);
    await queue.clean(grace, 'completed');
    await queue.clean(grace, 'failed');
  },
};

// Email queue helpers
export const emailQueue = {
  async sendWelcomeEmail(data: {
    to: string;
    name: string;
    userId: string;
  }) {
    return addJob(QueueName.EMAIL_NOTIFICATION, {
      type: 'welcome',
      ...data,
    });
  },

  async sendGenerationComplete(data: {
    to: string;
    generationId: string;
    imageUrl: string;
  }) {
    return addJob(QueueName.EMAIL_NOTIFICATION, {
      type: 'generation-complete',
      ...data,
    });
  },

  async sendSubscriptionExpiring(data: {
    to: string;
    daysRemaining: number;
    subscriptionId: string;
  }) {
    return addJob(QueueName.EMAIL_NOTIFICATION, {
      type: 'subscription-expiring',
      ...data,
    });
  },
};

// Analytics queue helpers
export const analyticsQueue = {
  async trackEvent(data: {
    userId?: string;
    event: string;
    properties?: any;
  }) {
    return addJob(QueueName.ANALYTICS, data, {
      removeOnComplete: true,
      removeOnFail: false,
    });
  },

  async trackGeneration(data: {
    userId: string;
    generationId: string;
    style: string;
    quality: string;
    duration: number;
    cost: number;
  }) {
    return addJob(QueueName.ANALYTICS, {
      event: 'generation_completed',
      userId: data.userId,
      properties: data,
    });
  },
};

// Cleanup queue helpers
export const cleanupQueue = {
  async scheduleImageCleanup(data: {
    imageUrl: string;
    deleteAfter: Date;
  }) {
    const delay = data.deleteAfter.getTime() - Date.now();
    return addJob(QueueName.CLEANUP, {
      type: 'delete-image',
      imageUrl: data.imageUrl,
    }, {
      delay: delay > 0 ? delay : 0,
    });
  },

  async scheduleOrphanedJobCleanup() {
    return addJob(QueueName.CLEANUP, {
      type: 'cleanup-orphaned-jobs',
    }, {
      repeat: {
        cron: '0 2 * * *', // Run daily at 2 AM
      },
    });
  },
};

// Queue statistics
export const getQueueStats = async (queueName: QueueName) => {
  const queue = getQueue(queueName);
  
  const [
    waiting,
    active,
    completed,
    failed,
    delayed,
    paused,
  ] = await Promise.all([
    queue.getWaitingCount(),
    queue.getActiveCount(),
    queue.getCompletedCount(),
    queue.getFailedCount(),
    queue.getDelayedCount(),
    queue.isPaused(),
  ]);

  return {
    name: queueName,
    counts: {
      waiting,
      active,
      completed,
      failed,
      delayed,
    },
    isPaused: paused,
  };
};

// Get all queue statistics
export const getAllQueueStats = async () => {
  const stats = await Promise.all(
    Array.from(queues.keys()).map(name => getQueueStats(name))
  );
  
  return stats.reduce((acc, stat) => {
    acc[stat.name] = stat;
    return acc;
  }, {} as Record<string, any>);
};