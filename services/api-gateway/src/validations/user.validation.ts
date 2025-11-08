import Joi from 'joi';

const updateProfile = Joi.object({
    body: Joi.object({
        displayName: Joi.string().min(2).max(50).optional().messages({
            'string.min': 'Display name must be at least 2 characters long.',
            'string.max': 'Display name cannot be more than 50 characters long.',
        }),
        photoUrl: Joi.string().uri().optional().messages({
            'string.uri': 'Please provide a valid URL for the photo.',
        }),
    }).or('displayName', 'photoUrl'), // At least one of the keys must be present
});

export const userSchemas = {
    updateProfile,
};
