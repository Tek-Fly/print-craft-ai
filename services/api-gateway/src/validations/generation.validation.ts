import Joi from 'joi';
import { GenerationStyle } from '../types/generation';

export const generationSchemas = {
  create: {
    body: Joi.object({
      prompt: Joi.string().min(3).max(500).required()
        .messages({
          'string.min': 'Prompt must be at least 3 characters long',
          'string.max': 'Prompt must not exceed 500 characters',
          'any.required': 'Prompt is required'
        }),
      style: Joi.string().valid(...Object.values(GenerationStyle)).required()
        .messages({
          'any.only': 'Invalid style selected',
          'any.required': 'Style is required'
        }),
      width: Joi.number().valid(512, 768, 1024, 1280, 1536).default(1024),
      height: Joi.number().valid(512, 768, 1024, 1280, 1536).default(1024),
      additionalParams: Joi.object().optional()
    })
  },

  getStatus: {
    params: Joi.object({
      id: Joi.string().uuid().required()
        .messages({
          'string.guid': 'Invalid generation ID format',
          'any.required': 'Generation ID is required'
        })
    })
  },

  getUserGenerations: {
    query: Joi.object({
      page: Joi.number().min(1).default(1),
      limit: Joi.number().min(1).max(100).default(20),
      status: Joi.string().valid('pending', 'processing', 'completed', 'failed').optional(),
      style: Joi.string().valid(...Object.values(GenerationStyle)).optional()
    })
  },

  delete: {
    params: Joi.object({
      id: Joi.string().uuid().required()
        .messages({
          'string.guid': 'Invalid generation ID format',
          'any.required': 'Generation ID is required'
        })
    })
  },

  regenerate: {
    params: Joi.object({
      id: Joi.string().uuid().required()
        .messages({
          'string.guid': 'Invalid generation ID format',
          'any.required': 'Generation ID is required'
        })
    })
  },

  download: {
    params: Joi.object({
      id: Joi.string().uuid().required()
        .messages({
          'string.guid': 'Invalid generation ID format',
          'any.required': 'Generation ID is required'
        })
    })
  }
};