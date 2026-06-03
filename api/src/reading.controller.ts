import { Controller, Get, Query } from '@nestjs/common';

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
  @Get('sources')
  sources() {
    return SOURCES.map(({ id, name, level }) => ({ id, name, level }));
  }

  @Get('news')
  async news(@Query('source') sourceId?: string) {
    const selected = sourceId
      ? SOURCES.filter((source) => source.id === sourceId)
      : SOURCES;
    const articles = (
      await Promise.all(selected.map((source) => this.fetchSource(source)))
    ).flat();
    return articles.slice(0, 24);
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
        };
      })
      .filter(
        (article) =>
          article.title &&
          article.content &&
          article.content.replace(/\s/g, '').length >= 60,
      );
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
