import Replicate from 'replicate';
import { logger } from '../utils/logger';
import { GenerationStyle, GenerationRequest, GenerationResult } from '../types/generation';

interface ReplicateOutput {
  output?: string | string[];
  error?: string;
}

export class ReplicateService {
  private replicate: Replicate;
  
  constructor() {
    this.replicate = new Replicate({
      auth: process.env.REPLICATE_API_TOKEN!
    });
  }

  /**
   * Generate an image using Replicate's SDXL model
   */
  async generateImage(request: GenerationRequest): Promise<GenerationResult> {
    try {
      logger.info('Starting image generation', { 
        style: request.style,
        prompt: request.prompt.substring(0, 50) + '...'
      });

      // Build the full prompt with style
      const fullPrompt = this.buildPrompt(request.prompt, request.style);
      
      // Model configuration based on style
      const modelConfig = this.getModelConfig(request.style);
      
      // Run the model
      const output = await this.replicate.run(
        modelConfig.model,
        {
          input: {
            prompt: fullPrompt,
            negative_prompt: modelConfig.negativePrompt,
            width: request.width || 1024,
            height: request.height || 1024,
            num_inference_steps: modelConfig.steps,
            guidance_scale: modelConfig.guidanceScale,
            scheduler: modelConfig.scheduler,
            ...request.additionalParams
          }
        }
      ) as ReplicateOutput;

      if (output.error) {
        throw new Error(output.error);
      }

      const imageUrl = Array.isArray(output.output) ? output.output[0] : output.output;
      
      if (!imageUrl) {
        throw new Error('No image generated');
      }

      logger.info('Image generation successful', { imageUrl });

      return {
        imageUrl,
        prompt: fullPrompt,
        style: request.style,
        metadata: {
          model: modelConfig.model,
          width: request.width || 1024,
          height: request.height || 1024,
          timestamp: new Date().toISOString()
        }
      };
    } catch (error) {
      logger.error('Image generation failed', { error });
      throw error;
    }
  }

  /**
   * Build a prompt with style-specific enhancements
   */
  private buildPrompt(basePrompt: string, style: GenerationStyle): string {
    const stylePrompts: Record<GenerationStyle, string> = {
      [GenerationStyle.VINTAGE_POSTER]: `${basePrompt}, vintage poster style, retro design, classic typography, aged paper texture, nostalgic color palette`,
      [GenerationStyle.MINIMALIST_LINE]: `${basePrompt}, minimalist line art, simple design, clean lines, monochromatic, white background`,
      [GenerationStyle.WATERCOLOR_ART]: `${basePrompt}, watercolor painting, soft brushstrokes, flowing colors, artistic, paper texture`,
      [GenerationStyle.COMIC_BOOK]: `${basePrompt}, comic book style, bold outlines, halftone dots, vibrant colors, speech bubbles`,
      [GenerationStyle.RETRO_GAMING]: `${basePrompt}, pixel art, 8-bit style, retro gaming, nostalgic, limited color palette`,
      [GenerationStyle.ABSTRACT_GEOMETRIC]: `${basePrompt}, abstract geometric art, shapes, modern design, bold colors, mathematical precision`,
      [GenerationStyle.PHOTO_REALISTIC]: `${basePrompt}, photorealistic, high detail, professional photography, natural lighting, sharp focus`,
      [GenerationStyle.GRAFFITI_STREET]: `${basePrompt}, graffiti art, street art style, spray paint, urban, bold tags, concrete wall`,
      [GenerationStyle.JAPANESE_ANIME]: `${basePrompt}, anime style, manga art, Japanese animation, cel shading, expressive eyes`,
      [GenerationStyle.ART_DECO]: `${basePrompt}, art deco style, 1920s design, geometric patterns, gold accents, elegant`,
      [GenerationStyle.CYBERPUNK_NEON]: `${basePrompt}, cyberpunk style, neon lights, futuristic, dark city, glowing effects`,
      [GenerationStyle.BOTANICAL_VINTAGE]: `${basePrompt}, vintage botanical illustration, scientific drawing, detailed plants, aged paper`,
      [GenerationStyle.POP_ART]: `${basePrompt}, pop art style, Andy Warhol inspired, bold colors, Ben Day dots, commercial art`,
      [GenerationStyle.TRIBAL_PATTERN]: `${basePrompt}, tribal pattern, ethnic design, traditional motifs, symmetrical, cultural art`,
      [GenerationStyle.GOTHIC_DARK]: `${basePrompt}, gothic style, dark aesthetic, medieval, ornate details, mysterious atmosphere`
    };

    return stylePrompts[style] || basePrompt;
  }

  /**
   * Get model configuration based on style
   */
  private getModelConfig(style: GenerationStyle): {
    model: string;
    negativePrompt: string;
    steps: number;
    guidanceScale: number;
    scheduler: string;
  } {
    // Base configuration
    const baseConfig = {
      model: "stability-ai/sdxl:39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b",
      negativePrompt: "low quality, blurry, pixelated, ugly, distorted, disfigured, poor composition",
      steps: 30,
      guidanceScale: 7.5,
      scheduler: "K_EULER"
    };

    // Style-specific overrides
    const styleConfigs: Partial<Record<GenerationStyle, any>> = {
      [GenerationStyle.PHOTO_REALISTIC]: {
        steps: 50,
        guidanceScale: 8.5,
        negativePrompt: "cartoon, anime, illustration, painting, drawing, art, sketch, 3d, render"
      },
      [GenerationStyle.MINIMALIST_LINE]: {
        steps: 20,
        guidanceScale: 6,
        negativePrompt: "complex, detailed, colorful, shaded, gradient"
      },
      [GenerationStyle.WATERCOLOR_ART]: {
        guidanceScale: 6.5,
        negativePrompt: "digital art, 3d render, photograph, sharp lines"
      }
    };

    return {
      ...baseConfig,
      ...(styleConfigs[style] || {})
    };
  }

  /**
   * Check generation status (for async generations)
   */
  async checkStatus(predictionId: string): Promise<any> {
    try {
      const prediction = await this.replicate.predictions.get(predictionId);
      return prediction;
    } catch (error) {
      logger.error('Failed to check prediction status', { error, predictionId });
      throw error;
    }
  }

  /**
   * Cancel a running generation
   */
  async cancelGeneration(predictionId: string): Promise<void> {
    try {
      await this.replicate.predictions.cancel(predictionId);
      logger.info('Generation cancelled', { predictionId });
    } catch (error) {
      logger.error('Failed to cancel generation', { error, predictionId });
      throw error;
    }
  }

  /**
   * Validate API token
   */
  async validateApiToken(): Promise<boolean> {
    try {
      // Try to list models as a health check
      await this.replicate.models.list();
      return true;
    } catch (error) {
      logger.error('Replicate API token validation failed', { error });
      return false;
    }
  }
}