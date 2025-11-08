import * as admin from 'firebase-admin';
import { logger } from '../utils/logger';

const initializeFirebase = () => {
  try {
    const projectId = process.env.FIREBASE_PROJECT_ID;
    const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
    // The private key might have escaped newlines; replace them.
    const privateKey = (process.env.FIREBASE_PRIVATE_KEY || '').replace(/\\n/g, '\n');

    if (!projectId || !clientEmail || !privateKey) {
      logger.warn('Firebase Admin SDK credentials are not fully set in environment variables. Firebase auth will not work.');
      return;
    }

    admin.initializeApp({
      credential: admin.credential.cert({
        projectId,
        clientEmail,
        privateKey,
      }),
    });

    logger.info('Firebase Admin SDK initialized successfully.');
  } catch (error: any) {
    logger.error('Failed to initialize Firebase Admin SDK:', {
      message: error.message,
      code: error.code,
    });
  }
};

initializeFirebase();

export default admin;
