export enum GenerationStyle {
  VINTAGE_POSTER = 'vintage_poster',
  MINIMALIST_LINE = 'minimalist_line',
  WATERCOLOR_ART = 'watercolor_art',
  COMIC_BOOK = 'comic_book',
  RETRO_GAMING = 'retro_gaming',
  ABSTRACT_GEOMETRIC = 'abstract_geometric',
  PHOTO_REALISTIC = 'photo_realistic',
  GRAFFITI_STREET = 'graffiti_street',
  JAPANESE_ANIME = 'japanese_anime',
  ART_DECO = 'art_deco',
  CYBERPUNK_NEON = 'cyberpunk_neon',
  BOTANICAL_VINTAGE = 'botanical_vintage',
  POP_ART = 'pop_art',
  TRIBAL_PATTERN = 'tribal_pattern',
  GOTHIC_DARK = 'gothic_dark'
}

export interface GenerationRequest {
  prompt: string;
  style: GenerationStyle;
  width?: number;
  height?: number;
  additionalParams?: Record<string, any>;
}

export interface GenerationResult {
  imageUrl: string;
  prompt: string;
  style: GenerationStyle;
  metadata: {
    model: string;
    width: number;
    height: number;
    timestamp: string;
  };
}

export interface GenerationJob {
  id: string;
  userId: string;
  request: GenerationRequest;
  status: 'pending' | 'processing' | 'completed' | 'failed';
  result?: GenerationResult;
  error?: string;
  createdAt: Date;
  updatedAt: Date;
}

export interface GenerationStats {
  totalGenerations: number;
  successfulGenerations: number;
  failedGenerations: number;
  averageGenerationTime: number;
  popularStyles: Array<{
    style: GenerationStyle;
    count: number;
  }>;
}