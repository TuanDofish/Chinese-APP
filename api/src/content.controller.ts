import { Body, Controller, Get, Headers, Put, Query } from '@nestjs/common';
import { AuthService } from './auth.service';
import { ContentService, ManagedContentBundle } from './content.service';

@Controller()
export class ContentController {
  constructor(
    private readonly contentService: ContentService,
    private readonly authService: AuthService,
  ) {}

  @Get('content/catalog')
  catalog() {
    return this.contentService.getCatalog();
  }

  @Get('content/flashcards')
  async flashcards() {
    return { topics: await this.contentService.getFlashcards() };
  }

  @Get('content/videos')
  videos() {
    return this.contentService.getVideos();
  }

  @Get('content/grammar')
  grammar() {
    return this.contentService.getGrammar();
  }

  @Get('content/articles')
  articles() {
    return this.contentService.getArticles();
  }

  @Get('content/pronunciation')
  pronunciation() {
    return this.contentService.getPronunciation();
  }

  @Get('content/games')
  games() {
    return this.contentService.getGames();
  }

  @Get('admin/content')
  async adminContent(@Headers('authorization') authorization = '') {
    await this.authService.requireAdmin(
      this.authService.tokenFromAuthorization(authorization),
    );
    return this.contentService.getCatalog(false);
  }

  @Get('admin/audit-logs')
  async auditLogs(
    @Headers('authorization') authorization = '',
    @Query('limit') limit = '50',
  ) {
    await this.authService.requireAdmin(
      this.authService.tokenFromAuthorization(authorization),
    );
    return this.contentService.getAuditLogs(Number(limit) || 50);
  }

  @Put('admin/content')
  async publish(
    @Headers('authorization') authorization = '',
    @Body() body: Partial<ManagedContentBundle>,
  ) {
    const admin = await this.authService.requireAdmin(
      this.authService.tokenFromAuthorization(authorization),
    );
    return this.contentService.publish(body, admin.id);
  }
}
