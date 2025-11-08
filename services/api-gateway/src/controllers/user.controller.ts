import { Request, Response, NextFunction } from 'express';
import prisma from '../utils/prisma';
import { AppError } from '../utils/errors';

/**
 * Get the profile of the currently authenticated user.
 */
export const getProfile = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.id;
        const user = await prisma.user.findUnique({
            where: { id: userId },
            include: {
                subscription: true, // Include subscription details
            },
        });

        if (!user) {
            throw new AppError('User not found.', 404);
        }

        // Don't send sensitive data like password hashes, etc.
        const { id, email, displayName, photoUrl, subscription } = user;
        res.status(200).json({
            success: true,
            data: { id, email, displayName, photoUrl, subscription },
        });
    } catch (error) {
        next(error);
    }
};

/**
 * Update the profile of the currently authenticated user.
 */
export const updateProfile = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const userId = req.user!.id;
        const { displayName, photoUrl } = req.body;

        const updatedUser = await prisma.user.update({
            where: { id: userId },
            data: {
                displayName,
                photoUrl,
            },
        });
        
        const { id, email, subscription } = updatedUser;
        res.status(200).json({
            success: true,
            message: 'Profile updated successfully.',
            data: { id, email, displayName: updatedUser.displayName, photoUrl: updatedUser.photoUrl, subscription },
        });
    } catch (error) {
        next(error);
    }
};
