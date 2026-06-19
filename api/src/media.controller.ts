import {
  BadRequestException,
  Controller,
  Post,
  UploadedFile,
  UseGuards,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { randomUUID } from 'node:crypto';
import { existsSync, mkdirSync } from 'node:fs';
import { extname, join } from 'node:path';
import { AdminAuthGuard } from './admin-auth.guard';

const { diskStorage } = require('multer');

const uploadRoot = process.env.UPLOAD_DIR || join(process.cwd(), 'uploads');
const flashcardUploadDir = join(uploadRoot, 'flashcards');
const allowedExtensions = new Set(['.jpg', '.jpeg', '.png', '.webp']);

function ensureUploadDir() {
  if (!existsSync(flashcardUploadDir)) {
    mkdirSync(flashcardUploadDir, { recursive: true });
  }
}

function publicApiUrl() {
  return String(
    process.env.PUBLIC_API_URL || `http://localhost:${process.env.PORT || 3001}`,
  ).replace(/\/+$/, '');
}

@Controller()
export class MediaController {
  @Post('admin/media/flashcard')
  @UseGuards(AdminAuthGuard)
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: (_request: any, _file: any, callback: any) => {
          ensureUploadDir();
          callback(null, flashcardUploadDir);
        },
        filename: (_request: any, file: any, callback: any) => {
          const extension = extname(file.originalname || '').toLowerCase();
          callback(null, `${Date.now()}-${randomUUID()}${extension}`);
        },
      }),
      limits: { fileSize: 5 * 1024 * 1024 },
      fileFilter: (_request: any, file: any, callback: any) => {
        const extension = extname(file.originalname || '').toLowerCase();
        const isImage = String(file.mimetype || '').startsWith('image/');
        if (!isImage || !allowedExtensions.has(extension)) {
          callback(
            new BadRequestException('Only jpg, jpeg, png and webp images are allowed.'),
            false,
          );
          return;
        }
        callback(null, true);
      },
    }),
  )
  uploadFlashcardImage(@UploadedFile() file: any) {
    if (!file) {
      throw new BadRequestException('No image file was uploaded.');
    }

    const path = `/uploads/flashcards/${file.filename}`;
    return {
      url: `${publicApiUrl()}${path}`,
      path,
      filename: file.filename,
      mimeType: file.mimetype,
      size: file.size,
    };
  }
}
