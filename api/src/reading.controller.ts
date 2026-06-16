import { Controller, Get, Query } from '@nestjs/common';
import { ContentService } from './content.service';

type NewsSource = {
  id: string;
  name: string;
  level: string;
  url: string;
};

type NewsArticle = {
  id: string;
  level: string;
  source: string;
  title: string;
  titleVi: string;
  content: string;
  summaryVi: string;
  link: string;
  publishedAt: string;
  fetchedAt: string;
};

const SOURCES: NewsSource[] = [
  {
    id: 'chinanews',
    name: '中国新闻网',
    level: 'HSK 4',
    url: 'https://www.chinanews.com.cn/rss/scroll-news.xml',
  },
  {
    id: 'voa',
    name: 'VOA 中文',
    level: 'HSK 4',
    url: 'https://www.voachinese.com/api/zm_yql-vomx-tpeybti',
  },
  {
    id: 'bbc',
    name: 'BBC 中文',
    level: 'HSK 4',
    url: 'https://feeds.bbci.co.uk/zhongwen/simp/rss.xml',
  },
  {
    id: 'rfi',
    name: 'RFI 中文',
    level: 'HSK 4',
    url: 'https://www.rfi.fr/cn/rss',
  },
];

@Controller('reading')
export class ReadingController {
  private readonly articleCache = new Map<
    string,
    { content: string; expiresAt: number }
  >();

  constructor(private readonly contentService: ContentService) {}

  @Get('sources')
  async sources() {
    return (await this.availableSources()).map(({ id, name, level }) => ({
      id,
      name,
      level,
    }));
  }

  @Get('news')
  async news(@Query('source') sourceId?: string) {
    const sources = await this.availableSources();
    const selected = sourceId
      ? sources.filter((source) => source.id === sourceId)
      : sources;
    const articles = (
      await Promise.all(selected.map((source) => this.fetchSource(source)))
    ).flat();
    return articles
      .sort(
        (left, right) =>
          this.timestamp(right.publishedAt) - this.timestamp(left.publishedAt),
      )
      .slice(0, 24);
  }

  @Get('article')
  async article(@Query('url') rawUrl?: string) {
    const url = await this.validArticleUrl(rawUrl);
    if (!url) return { content: '' };
    return { content: await this.fetchArticleContent(url) };
  }

  private async availableSources(): Promise<NewsSource[]> {
    const managed = (await this.contentService.getReadingSources())
      .filter(
        (source): source is Record<string, unknown> =>
          Boolean(source) && typeof source === 'object',
      )
      .filter((source) => String(source.status || 'active') === 'active')
      .map((source) => ({
        id: String(source.id || '').trim(),
        name: String(source.name || '').trim(),
        level: String(source.level || 'HSK 4').trim(),
        url: String(source.url || '').trim(),
      }))
      .filter((source) => source.id && source.name && source.url);
    return managed.length ? managed : SOURCES;
  }

  private async fetchSource(source: NewsSource) {
    try {
      const response = await fetch(source.url, {
        signal: AbortSignal.timeout(5500),
        headers: {
          'user-agent': 'VNChinese-Learning-App/1.0',
          accept: 'application/rss+xml, application/xml, text/xml',
        },
      });
      if (!response.ok) return [];
      const xml = await response.text();
      return this.parseFeed(xml, source);
    } catch {
      return [];
    }
  }

  private async validArticleUrl(rawUrl?: string) {
    if (!rawUrl) return null;
    try {
      const url = new URL(rawUrl);
      if (!['http:', 'https:'].includes(url.protocol)) return null;
      const sources = await this.availableSources();
      const allowedHosts = new Set([
        'bbc.com',
        'chinanews.com.cn',
        'rfi.fr',
        'voachinese.com',
        ...sources.map((source) => new URL(source.url).hostname),
      ]);
      const host = url.hostname.toLowerCase();
      const allowed = [...allowedHosts].some(
        (allowedHost) =>
          host === allowedHost || host.endsWith(`.${allowedHost}`),
      );
      return allowed ? url : null;
    } catch {
      return null;
    }
  }

  private async fetchArticleContent(url: URL) {
    const cacheKey = url.toString();
    const cached = this.articleCache.get(cacheKey);
    if (cached && cached.expiresAt > Date.now()) return cached.content;

    try {
      const response = await fetch(url, {
        signal: AbortSignal.timeout(8000),
        headers: {
          'user-agent': 'VNChinese-Learning-App/1.0',
          accept: 'text/html,application/xhtml+xml',
          'accept-language': 'zh-CN,zh-TW;q=0.9,vi;q=0.8',
        },
      });
      if (!response.ok) return '';
      const bytes = new Uint8Array(await response.arrayBuffer());
      const contentType = response.headers.get('content-type') || '';
      const head = new TextDecoder('ascii').decode(bytes.slice(0, 4096));
      const charset =
        contentType.match(/charset=([^;\s]+)/i)?.[1] ||
        head.match(/charset\s*=\s*["']?([^\s"'/>;]+)/i)?.[1] ||
        'utf-8';
      let html: string;
      try {
        html = new TextDecoder(charset).decode(bytes);
      } catch {
        html = new TextDecoder('utf-8').decode(bytes);
      }
      const content = this.extractArticleText(html);
      if (content) {
        this.articleCache.set(cacheKey, {
          content,
          expiresAt: Date.now() + 10 * 60 * 1000,
        });
      }
      return content;
    } catch {
      return '';
    }
  }

  private extractArticleText(html: string) {
    const paragraphs: string[] = [];
    const seen = new Set<string>();
    const matches = html.matchAll(/<p\b[^>]*>([\s\S]*?)<\/p>/gi);
    for (const match of matches) {
      let text = this.cleanXml(
        match[1]
          .replace(/<script\b[\s\S]*?<\/script>/gi, '')
          .replace(/<style\b[\s\S]*?<\/style>/gi, ''),
      );
      if (!text) continue;

      const stopMarker = text.search(
        /【编辑:|更多精彩内容请进入|发表评论\s*文明上网|电邮新闻|下载法广应用程序|©\s*\d{4}/i,
      );
      if (stopMarker === 0) break;
      if (stopMarker > 0) text = text.slice(0, stopMarker).trim();
      const finishedAt = text.search(/[（(]完[）)]/);
      if (finishedAt >= 0) text = text.slice(0, finishedAt + 3).trim();

      const chineseCharacters =
        text.match(/[\u3400-\u4dbf\u4e00-\u9fff]/g)?.length ?? 0;
      if (
        chineseCharacters < 8 ||
        /^(图像来源|圖片來源|版权所有|版權所有|您尝试访问的内容)/.test(text) ||
        seen.has(text)
      ) {
        continue;
      }
      seen.add(text);
      paragraphs.push(text);
      if (finishedAt >= 0 || paragraphs.length >= 80) break;
    }
    return paragraphs.join('\n').slice(0, 20000);
  }

  private parseFeed(xml: string, source: NewsSource): NewsArticle[] {
    const items =
      xml.match(/<item[\s\S]*?<\/item>/g) ??
      xml.match(/<entry[\s\S]*?<\/entry>/g) ??
      [];
    return items
      .slice(0, 10)
      .map((item, index) => {
        const title = this.cleanXml(this.pick(item, 'title'));
        const description = this.cleanXml(
          this.pick(item, 'description') ||
            this.pick(item, 'summary') ||
            this.pick(item, 'content'),
        );
        const link = this.cleanXml(this.pickLink(item));
        const pubDate = this.cleanXml(
          this.pick(item, 'pubDate') ||
            this.pick(item, 'published') ||
            this.pick(item, 'updated'),
        );
        const publishedAt = this.normalizeDate(pubDate);
        const content = description || title;
        return {
          id: `${source.id}_${index}_${Buffer.from(title).toString('base64url').slice(0, 8)}`,
          level: source.level,
          source: source.name,
          title,
          titleVi: '',
          content,
          summaryVi: pubDate
            ? `Tin mới từ ${source.name} · ${pubDate}`
            : source.name,
          link,
          publishedAt,
          fetchedAt: new Date().toISOString(),
        };
      })
      .filter(
        (article) =>
          article.title &&
          article.content &&
          article.content.replace(/\s/g, '').length >= 60,
      );
  }

  private normalizeDate(value: string) {
    if (!value) return '';
    const date = new Date(value);
    return Number.isNaN(date.getTime()) ? '' : date.toISOString();
  }

  private timestamp(value: string) {
    const time = Date.parse(value);
    return Number.isNaN(time) ? 0 : time;
  }

  private pick(xml: string, tag: string) {
    const match = xml.match(
      new RegExp(`<${tag}[^>]*>([\\s\\S]*?)<\\/${tag}>`, 'i'),
    );
    return match?.[1] ?? '';
  }

  private pickLink(xml: string) {
    const linkText = this.pick(xml, 'link');
    if (linkText) return linkText;
    const href = xml.match(/<link[^>]+href=["']([^"']+)["'][^>]*>/i);
    return href?.[1] ?? '';
  }

  private cleanXml(value: string) {
    return value
      .replace(/<!\[CDATA\[([\s\S]*?)\]\]>/g, '$1')
      .replace(/<[^>]+>/g, '')
      .replace(/&nbsp;/g, ' ')
      .replace(/&amp;/g, '&')
      .replace(/&quot;/g, '"')
      .replace(/&apos;|&#39;/g, "'")
      .replace(/&lt;/g, '<')
      .replace(/&gt;/g, '>')
      .replace(/&#x([0-9a-f]+);/gi, (_, code) =>
        String.fromCharCode(parseInt(code, 16)),
      )
      .replace(/&#(\d+);/g, (_, code) => String.fromCharCode(Number(code)))
      .replace(/\s+/g, ' ')
      .trim();
  }
}
