import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
  ListObjectsV2Command,
  HeadObjectCommand
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import { logger } from '../utils/logger';
import { v4 as uuidv4 } from 'uuid';
import sharp from 'sharp';
import { Readable } from 'stream';

export interface StorageUploadOptions {
  contentType?: string;
  metadata?: Record<string, string>;
  expiresIn?: number;
}

export interface StorageObject {
  key: string;
  size: number;
  lastModified: Date;
  etag?: string;
  contentType?: string;
}

export class StorageService {
  private s3Client: S3Client;
  private bucketName: string;

  constructor() {
    // Configure for Cloudflare R2
    this.s3Client = new S3Client({
      endpoint: process.env.R2_ENDPOINT!,
      region: process.env.AWS_REGION || 'auto',
      credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!
      }
    });
    
    this.bucketName = process.env.CLOUDFLARE_R2_BUCKET || 'printcraft-images';
  }

  /**
   * Upload a file to storage
   */
  async uploadFile(
    buffer: Buffer,
    key: string,
    options: StorageUploadOptions = {}
  ): Promise<string> {
    try {
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: key,
        Body: buffer,
        ContentType: options.contentType || 'application/octet-stream',
        Metadata: options.metadata || {}
      });

      await this.s3Client.send(command);
      logger.info('File uploaded successfully', { key, bucket: this.bucketName });

      // Return the public URL
      return this.getPublicUrl(key);
    } catch (error) {
      logger.error('Failed to upload file', { error, key });
      throw error;
    }
  }

  /**
   * Upload an image with automatic optimization
   */
  async uploadImage(
    buffer: Buffer,
    folder: string = 'generated',
    options: {
      quality?: number;
      format?: 'webp' | 'jpeg' | 'png';
      maxWidth?: number;
      maxHeight?: number;
    } = {}
  ): Promise<{ url: string; key: string; size: number }> {
    try {
      // Process image with sharp
      let processedImage = sharp(buffer);
      
      // Resize if needed
      if (options.maxWidth || options.maxHeight) {
        processedImage = processedImage.resize(
          options.maxWidth,
          options.maxHeight,
          { fit: 'inside', withoutEnlargement: true }
        );
      }

      // Convert format
      const format = options.format || 'webp';
      const quality = options.quality || 85;
      
      switch (format) {
        case 'webp':
          processedImage = processedImage.webp({ quality });
          break;
        case 'jpeg':
          processedImage = processedImage.jpeg({ quality });
          break;
        case 'png':
          processedImage = processedImage.png({ quality });
          break;
      }

      const optimizedBuffer = await processedImage.toBuffer();
      const key = `${folder}/${uuidv4()}.${format}`;
      
      // Upload the optimized image
      const url = await this.uploadFile(optimizedBuffer, key, {
        contentType: `image/${format}`
      });

      return {
        url,
        key,
        size: optimizedBuffer.length
      };
    } catch (error) {
      logger.error('Failed to upload image', { error });
      throw error;
    }
  }

  /**
   * Download a file from storage
   */
  async downloadFile(key: string): Promise<Buffer> {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucketName,
        Key: key
      });

      const response = await this.s3Client.send(command);
      
      if (!response.Body) {
        throw new Error('Empty response body');
      }

      // Convert stream to buffer
      const stream = response.Body as Readable;
      const chunks: Uint8Array[] = [];
      
      for await (const chunk of stream) {
        chunks.push(chunk);
      }

      return Buffer.concat(chunks);
    } catch (error) {
      logger.error('Failed to download file', { error, key });
      throw error;
    }
  }

  /**
   * Delete a file from storage
   */
  async deleteFile(key: string): Promise<void> {
    try {
      const command = new DeleteObjectCommand({
        Bucket: this.bucketName,
        Key: key
      });

      await this.s3Client.send(command);
      logger.info('File deleted successfully', { key });
    } catch (error) {
      logger.error('Failed to delete file', { error, key });
      throw error;
    }
  }

  /**
   * Generate a presigned URL for direct upload
   */
  async getPresignedUploadUrl(
    key: string,
    expiresIn: number = 3600
  ): Promise<string> {
    try {
      const command = new PutObjectCommand({
        Bucket: this.bucketName,
        Key: key
      });

      const url = await getSignedUrl(this.s3Client, command, { expiresIn });
      return url;
    } catch (error) {
      logger.error('Failed to generate presigned URL', { error, key });
      throw error;
    }
  }

  /**
   * Generate a presigned URL for download
   */
  async getPresignedDownloadUrl(
    key: string,
    expiresIn: number = 3600
  ): Promise<string> {
    try {
      const command = new GetObjectCommand({
        Bucket: this.bucketName,
        Key: key
      });

      const url = await getSignedUrl(this.s3Client, command, { expiresIn });
      return url;
    } catch (error) {
      logger.error('Failed to generate download URL', { error, key });
      throw error;
    }
  }

  /**
   * List files in a folder
   */
  async listFiles(
    prefix: string,
    maxKeys: number = 100
  ): Promise<StorageObject[]> {
    try {
      const command = new ListObjectsV2Command({
        Bucket: this.bucketName,
        Prefix: prefix,
        MaxKeys: maxKeys
      });

      const response = await this.s3Client.send(command);
      
      return (response.Contents || []).map(item => ({
        key: item.Key!,
        size: item.Size!,
        lastModified: item.LastModified!,
        etag: item.ETag
      }));
    } catch (error) {
      logger.error('Failed to list files', { error, prefix });
      throw error;
    }
  }

  /**
   * Check if a file exists
   */
  async fileExists(key: string): Promise<boolean> {
    try {
      const command = new HeadObjectCommand({
        Bucket: this.bucketName,
        Key: key
      });

      await this.s3Client.send(command);
      return true;
    } catch (error: any) {
      if (error.name === 'NotFound' || error.$metadata?.httpStatusCode === 404) {
        return false;
      }
      throw error;
    }
  }

  /**
   * Get public URL for a file
   */
  getPublicUrl(key: string): string {
    // For Cloudflare R2, construct the public URL
    // This assumes you have a custom domain or using R2 dev domain
    const baseUrl = process.env.R2_PUBLIC_URL || `${process.env.R2_ENDPOINT}/${this.bucketName}`;
    return `${baseUrl}/${key}`;
  }

  /**
   * Download image from URL and upload to storage
   */
  async uploadFromUrl(
    imageUrl: string,
    folder: string = 'external'
  ): Promise<{ url: string; key: string }> {
    try {
      const axios = (await import('axios')).default;
      
      // Download image
      const response = await axios.get(imageUrl, {
        responseType: 'arraybuffer'
      });

      const buffer = Buffer.from(response.data);
      const contentType = response.headers['content-type'] || 'image/jpeg';
      
      // Determine extension from content type
      const extension = contentType.split('/')[1] || 'jpg';
      const key = `${folder}/${uuidv4()}.${extension}`;

      // Upload to storage
      const url = await this.uploadFile(buffer, key, { contentType });

      return { url, key };
    } catch (error) {
      logger.error('Failed to upload from URL', { error, imageUrl });
      throw error;
    }
  }
}