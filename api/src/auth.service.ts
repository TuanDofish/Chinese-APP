import {
  BadRequestException,
  ConflictException,
  ForbiddenException,
  Injectable,
  OnModuleInit,
  ServiceUnavailableException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import {
  createHmac,
  randomBytes,
  scryptSync,
  timingSafeEqual,
} from 'node:crypto';
import { OAuth2Client } from 'google-auth-library';
import { Repository } from 'typeorm';
import { DataSource } from 'typeorm';
import { User } from './entities/user.entity';

type AuthPayload = {
  email?: string;
  password?: string;
  displayName?: string;
  targetLevel?: string;
};

type GoogleAuthPayload = {
  idToken?: string;
  targetLevel?: string;
};

type UserPatch = {
  email?: string;
  password?: string;
  displayName?: string;
  role?: string;
  status?: string;
  targetLevel?: string;
  avatarUrl?: string;
};

type TokenPayload = {
  sub: number;
  email: string;
  role: string;
  iat: number;
  exp: number;
};

@Injectable()
export class AuthService implements OnModuleInit {
  private readonly googleClient = new OAuth2Client();

  constructor(
    @InjectRepository(User)
    private readonly users: Repository<User>,
    private readonly dataSource: DataSource,
  ) {}

  async onModuleInit() {
    if (!this.dataSource.isInitialized) return;
    await this.ensureDefaultAdmin();
  }

  async register(body: AuthPayload) {
    const email = this.normalizeEmail(body.email);
    const password = String(body.password || '');
    const displayName = String(body.displayName || '').trim();
    const targetLevel = this.normalizeLevel(body.targetLevel);

    this.assertEmail(email);
    this.assertPassword(password);
    if (displayName.length < 2) {
      throw new BadRequestException('Hãy nhập họ tên tối thiểu 2 ký tự.');
    }

    const existing = await this.users.findOne({ where: { email } });
    if (existing) {
      throw new ConflictException('Email này đã được đăng ký.');
    }

    const user = this.users.create({
      email,
      passwordHash: this.hashPassword(password),
      displayName,
      role: 'user',
      status: 'active',
      targetLevel,
    });
    await this.users.save(user);
    await this.syncNormalizedUser(user);
    return this.authResponse(user);
  }

  async login(body: AuthPayload) {
    const email = this.normalizeEmail(body.email);
    const password = String(body.password || '');

    this.assertEmail(email);
    this.assertPassword(password);
    this.assertDatabaseReady();

    if (email === this.defaultAdminEmail()) {
      await this.ensureDefaultAdmin();
    }

    const user = await this.users.findOne({ where: { email } });
    if (!user || !this.verifyPassword(password, user.passwordHash)) {
      throw new UnauthorizedException('Email hoặc mật khẩu chưa đúng.');
    }
    if (user.status === 'blocked') {
      throw new ForbiddenException('Tài khoản này đang bị khóa.');
    }

    user.lastLoginAt = new Date();
    await this.users.save(user);
    return this.authResponse(user);
  }

  async loginWithGoogle(body: GoogleAuthPayload) {
    this.assertDatabaseReady();
    const idToken = String(body.idToken || '').trim();
    if (!idToken) {
      throw new BadRequestException('Thiếu mã xác thực Google.');
    }
    const audiences = this.googleClientIds();
    if (!audiences.length) {
      throw new ServiceUnavailableException(
        'Đăng nhập Google chưa được cấu hình trên máy chủ.',
      );
    }

    let payload: Record<string, any> | undefined;
    try {
      const ticket = await this.googleClient.verifyIdToken({
        idToken,
        audience: audiences,
      });
      payload = ticket.getPayload() as Record<string, any> | undefined;
    } catch (_) {
      throw new UnauthorizedException(
        'Không thể xác thực tài khoản Google. Hãy chọn lại tài khoản rồi thử lại.',
      );
    }

    const email = this.normalizeEmail(payload?.email);
    if (!email || payload?.email_verified !== true) {
      throw new UnauthorizedException(
        'Google chưa xác nhận email của tài khoản này.',
      );
    }

    let user = await this.users.findOne({ where: { email } });
    if (user?.status === 'blocked') {
      throw new ForbiddenException('Tài khoản này đang bị khóa.');
    }

    const displayName = String(
      payload?.name || email.split('@').at(0) || 'Người học VNChinese',
    ).trim();
    const avatarUrl = String(payload?.picture || '').trim();
    if (!user) {
      user = this.users.create({
        email,
        passwordHash: this.hashPassword(randomBytes(32).toString('hex')),
        displayName,
        avatarUrl,
        role: 'user',
        status: 'active',
        targetLevel: this.normalizeLevel(body.targetLevel),
      });
    } else {
      if (displayName) user.displayName = displayName;
      if (avatarUrl) user.avatarUrl = avatarUrl;
      if (body.targetLevel) {
        user.targetLevel = this.normalizeLevel(body.targetLevel);
      }
    }
    user.lastLoginAt = new Date();
    await this.users.save(user);
    await this.syncNormalizedUser(user);
    return this.authResponse(user);
  }

  async me(token: string) {
    const user = await this.getUserFromToken(token);
    return { user: this.publicUser(user) };
  }

  async requireAdmin(token: string) {
    const user = await this.getUserFromToken(token);
    if (user.role !== 'admin') {
      throw new ForbiddenException(
        'Bạn cần quyền admin để thực hiện thao tác này.',
      );
    }
    return user;
  }

  async requireUser(token: string) {
    return this.getUserFromToken(token);
  }

  async listUsers(token: string) {
    await this.requireAdmin(token);
    const rows = await this.dataSource.query(
      `SELECT u.id, u.email,
              COALESCE(u.display_name, u."displayName", u.email) AS display_name,
              COALESCE(u.avatar_url, u."avatarUrl", '') AS avatar_url,
              LOWER(COALESCE(u.role::text, 'user')) AS role,
              LOWER(COALESCE(u.status, 'active')) AS status,
              CONCAT(
                'HSK ',
                COALESCE(
                  u.target_hsk_level,
                  NULLIF(REGEXP_REPLACE(u."targetLevel", '\\D', '', 'g'), '')::smallint,
                  1
                )
              ) AS target_level,
              u.last_login_at, u.created_at, u.updated_at,
              COALESCE(progress.learned_words, 0)::int AS learned_words,
              COALESCE(progress.mastered_words, 0)::int AS mastered_words,
              COALESCE(progress.due_review, 0)::int AS due_review,
              COALESCE(activity.study_minutes, 0)::int AS study_minutes,
              COALESCE(activity.active_days, 0)::int AS active_days,
              activity.last_study_at,
              COALESCE(attempts.attempts, 0)::int AS attempts,
              COALESCE(attempts.average_score, 0)::int AS average_score
       FROM users u
       LEFT JOIN LATERAL (
         SELECT
           COUNT(*) FILTER (WHERE mastery_level > 0) AS learned_words,
           COUNT(*) FILTER (WHERE mastery_level >= 4) AS mastered_words,
           COUNT(*) FILTER (
             WHERE mastery_level > 0 AND next_review_at <= NOW()
           ) AS due_review
         FROM user_word_progress
         WHERE user_id = u.id
       ) progress ON TRUE
       LEFT JOIN LATERAL (
         SELECT ROUND(COALESCE(SUM(study_seconds), 0) / 60.0) AS study_minutes,
                COUNT(*) FILTER (
                  WHERE learned_words_count + reviewed_words_count +
                    lessons_completed_count + quiz_count +
                    pronunciation_count + reading_count +
                    ai_interaction_count + study_seconds > 0
                ) AS active_days,
                MAX(study_date) AS last_study_at
         FROM daily_learning_stats
         WHERE user_id = u.id
       ) activity ON TRUE
       LEFT JOIN LATERAL (
         SELECT COUNT(*) AS attempts,
                ROUND(COALESCE(AVG(score), 0)) AS average_score
         FROM practice_attempts
         WHERE user_id = u.id
       ) attempts ON TRUE
       ORDER BY u.created_at DESC, u.id DESC`,
    );
    return rows.map((row: any) => ({
      id: Number(row.id),
      email: row.email || '',
      displayName: row.display_name || 'Người học VNChinese',
      avatarUrl: row.avatar_url || '',
      role: this.adminRole(row.role),
      status: this.adminStatus(row.status),
      targetLevel: row.target_level || 'HSK 1',
      createdAt: row.created_at,
      updatedAt: row.updated_at,
      lastLoginAt: row.last_login_at,
      progress: {
        learnedWords: Number(row.learned_words || 0),
        masteredWords: Number(row.mastered_words || 0),
        dueReview: Number(row.due_review || 0),
        studyMinutes: Number(row.study_minutes || 0),
        activeDays: Number(row.active_days || 0),
        attempts: Number(row.attempts || 0),
        averageScore: Number(row.average_score || 0),
        lastStudyAt: row.last_study_at,
      },
    }));
  }

  async userDetail(token: string, id: number) {
    await this.requireAdmin(token);
    const users = await this.listUsers(token);
    const profile = users.find((user) => user.id === id);
    if (!profile) throw new BadRequestException('Không tìm thấy người dùng.');
    const [roadmapRows, activityRows, attemptRows, readingRows] =
      await Promise.all([
        this.dataSource.query(
          `SELECT v.hsk_level,
                  COUNT(*) FILTER (WHERE uwp.mastery_level > 0)::int AS learned_words,
                  COUNT(*) FILTER (WHERE uwp.mastery_level >= 4)::int AS mastered_words,
                  COUNT(*) FILTER (
                    WHERE uwp.mastery_level > 0 AND uwp.next_review_at <= NOW()
                  )::int AS due_review
           FROM user_word_progress uwp
           JOIN vocabularies v ON v.id = uwp.vocabulary_id
           WHERE uwp.user_id = $1
           GROUP BY v.hsk_level
           ORDER BY v.hsk_level`,
          [id],
        ),
        this.dataSource.query(
          `SELECT study_date, learned_words_count, reviewed_words_count,
                  lessons_completed_count, quiz_count, pronunciation_count,
                  reading_count, ai_interaction_count, study_seconds
           FROM daily_learning_stats
           WHERE user_id = $1
             AND study_date >= CURRENT_DATE - INTERVAL '29 days'
           ORDER BY study_date`,
          [id],
        ),
        this.dataSource.query(
          `SELECT attempt_type::text AS type, target_type, target_id, score,
                  correct_count, total_count, duration_seconds, completed_at
           FROM practice_attempts
           WHERE user_id = $1
           ORDER BY completed_at DESC
           LIMIT 20`,
          [id],
        ),
        this.dataSource.query(
          `SELECT a.title, rs.completed, rs.time_spent_seconds, rs.last_read_at
           FROM reading_sessions rs
           JOIN articles a ON a.id = rs.article_id
           WHERE rs.user_id = $1
           ORDER BY rs.last_read_at DESC
           LIMIT 10`,
          [id],
        ),
      ]);
    return {
      profile,
      roadmap: roadmapRows.map((row: any) => ({
        level: `HSK ${row.hsk_level}`,
        learnedWords: Number(row.learned_words || 0),
        masteredWords: Number(row.mastered_words || 0),
        dueReview: Number(row.due_review || 0),
      })),
      activity: activityRows.map((row: any) => ({
        date: this.dateKey(row.study_date),
        learnedWords: Number(row.learned_words_count || 0),
        reviewedWords: Number(row.reviewed_words_count || 0),
        lessons: Number(row.lessons_completed_count || 0),
        quizzes: Number(row.quiz_count || 0),
        pronunciation: Number(row.pronunciation_count || 0),
        reading: Number(row.reading_count || 0),
        aiInteractions: Number(row.ai_interaction_count || 0),
        studyMinutes: Math.round(Number(row.study_seconds || 0) / 60),
      })),
      recentAttempts: attemptRows.map((row: any) => ({
        type: row.type,
        targetType: row.target_type || '',
        targetId: row.target_id || '',
        score: Math.round(Number(row.score || 0)),
        correctCount: Number(row.correct_count || 0),
        totalCount: Number(row.total_count || 0),
        durationSeconds: Number(row.duration_seconds || 0),
        completedAt: row.completed_at,
      })),
      recentReading: readingRows.map((row: any) => ({
        title: row.title,
        completed: Boolean(row.completed),
        timeSpentSeconds: Number(row.time_spent_seconds || 0),
        lastReadAt: row.last_read_at,
      })),
    };
  }

  async adminDashboard(token: string) {
    await this.requireAdmin(token);
    const [
      userRows,
      learningRows,
      contentRows,
      activityRows,
      hskRows,
      recentUsers,
      versionRows,
      aiRows,
    ] = await Promise.all([
      this.dataSource.query(
        `SELECT COUNT(*)::int AS total,
                COUNT(*) FILTER (
                  WHERE LOWER(COALESCE(status, 'active')) = 'active'
                )::int AS active,
                COUNT(*) FILTER (
                  WHERE LOWER(COALESCE(status, 'active')) IN ('blocked', 'locked')
                )::int AS blocked,
                COUNT(*) FILTER (
                  WHERE LOWER(COALESCE(role::text, 'user')) = 'admin'
                )::int AS admins,
                COUNT(*) FILTER (
                  WHERE created_at >= CURRENT_DATE - INTERVAL '6 days'
                )::int AS new_this_week,
                COUNT(*) FILTER (
                  WHERE last_login_at >= NOW() - INTERVAL '7 days'
                )::int AS logged_in_this_week
         FROM users`,
      ),
      this.dataSource.query(
        `SELECT
           COALESCE(SUM(study_seconds) FILTER (
             WHERE study_date >= CURRENT_DATE - INTERVAL '6 days'
           ), 0)::int AS study_seconds_week,
           COALESCE(SUM(learned_words_count) FILTER (
             WHERE study_date >= CURRENT_DATE - INTERVAL '6 days'
           ), 0)::int AS learned_words_week,
           COUNT(DISTINCT user_id) FILTER (
             WHERE study_date = CURRENT_DATE AND
               learned_words_count + reviewed_words_count +
               lessons_completed_count + quiz_count +
               pronunciation_count + reading_count +
               ai_interaction_count + study_seconds > 0
           )::int AS active_today,
           COUNT(DISTINCT user_id) FILTER (
             WHERE study_date >= CURRENT_DATE - INTERVAL '6 days' AND
               learned_words_count + reviewed_words_count +
               lessons_completed_count + quiz_count +
               pronunciation_count + reading_count +
               ai_interaction_count + study_seconds > 0
           )::int AS learners_week
         FROM daily_learning_stats`,
      ),
      this.dataSource.query(
        `SELECT
           (SELECT COUNT(*) FROM vocabularies)::int AS vocabulary,
           (SELECT COUNT(*) FROM topics)::int AS topics,
           (SELECT COUNT(*) FROM lessons)::int AS lessons,
           (SELECT COUNT(*) FROM grammar_lessons)::int AS grammar,
           (SELECT COUNT(*) FROM articles)::int AS articles,
           (SELECT COUNT(*) FROM pronunciation_sentences)::int AS pronunciation,
           (SELECT COUNT(*) FROM lessons WHERE lesson_type = 'VIDEO')::int AS videos,
           (
             SELECT COUNT(*) FROM (
               SELECT status::text FROM vocabularies
               UNION ALL SELECT status::text FROM topics
               UNION ALL SELECT status::text FROM lessons
               UNION ALL SELECT status::text FROM grammar_lessons
               UNION ALL SELECT status::text FROM articles
               UNION ALL SELECT status::text FROM pronunciation_sentences
             ) content WHERE status IN ('DRAFT', 'REVIEW')
           )::int AS pending_review`,
      ),
      this.dataSource.query(
        `SELECT day::date AS study_date,
                COALESCE(SUM(dls.study_seconds), 0)::int AS study_seconds,
                COALESCE(SUM(dls.learned_words_count), 0)::int AS learned_words,
                COUNT(DISTINCT dls.user_id) FILTER (
                  WHERE dls.learned_words_count + dls.reviewed_words_count +
                    dls.lessons_completed_count + dls.quiz_count +
                    dls.pronunciation_count + dls.reading_count +
                    dls.ai_interaction_count + dls.study_seconds > 0
                )::int AS active_users
         FROM GENERATE_SERIES(
           CURRENT_DATE - INTERVAL '6 days',
           CURRENT_DATE,
           INTERVAL '1 day'
         ) day
         LEFT JOIN daily_learning_stats dls ON dls.study_date = day::date
         GROUP BY day
         ORDER BY day`,
      ),
      this.dataSource.query(
        `SELECT CONCAT(
                  'HSK ',
                  COALESCE(
                    target_hsk_level,
                    NULLIF(REGEXP_REPLACE("targetLevel", '\\D', '', 'g'), '')::smallint,
                    1
                  )
                ) AS level,
                COUNT(*)::int AS users
         FROM users
         WHERE LOWER(COALESCE(role::text, 'user')) <> 'admin'
         GROUP BY level
         ORDER BY level`,
      ),
      this.dataSource.query(
        `SELECT id, email,
                COALESCE(display_name, "displayName", email) AS display_name,
                created_at
         FROM users
         ORDER BY created_at DESC
         LIMIT 5`,
      ),
      this.dataSource.query(
        `SELECT version_code, item_count, published_at
         FROM content_versions
         WHERE status = 'PUBLISHED'
         ORDER BY published_at DESC NULLS LAST, id DESC
         LIMIT 1`,
      ),
      this.dataSource.query(
        `SELECT COUNT(*) FILTER (
                  WHERE status = 'SUCCESS' AND created_at >= NOW() - INTERVAL '7 days'
                )::int AS success_week,
                COUNT(*) FILTER (
                  WHERE status = 'ERROR' AND created_at >= NOW() - INTERVAL '7 days'
                )::int AS errors_week,
                COALESCE(ROUND(AVG(score) FILTER (
                  WHERE status = 'SUCCESS' AND score IS NOT NULL
                    AND created_at >= NOW() - INTERVAL '7 days'
                )), 0)::int AS average_score
         FROM ai_interactions`,
      ),
    ]);
    const users = userRows[0] || {};
    const learning = learningRows[0] || {};
    const content = contentRows[0] || {};
    const ai = aiRows[0] || {};
    const latestVersion = versionRows[0] || null;
    return {
      users: {
        total: Number(users.total || 0),
        active: Number(users.active || 0),
        blocked: Number(users.blocked || 0),
        admins: Number(users.admins || 0),
        newThisWeek: Number(users.new_this_week || 0),
        loggedInThisWeek: Number(users.logged_in_this_week || 0),
      },
      learning: {
        studyMinutesWeek: Math.round(
          Number(learning.study_seconds_week || 0) / 60,
        ),
        learnedWordsWeek: Number(learning.learned_words_week || 0),
        activeToday: Number(learning.active_today || 0),
        learnersWeek: Number(learning.learners_week || 0),
      },
      content: {
        vocabulary: Number(content.vocabulary || 0),
        topics: Number(content.topics || 0),
        lessons: Number(content.lessons || 0),
        grammar: Number(content.grammar || 0),
        articles: Number(content.articles || 0),
        pronunciation: Number(content.pronunciation || 0),
        videos: Number(content.videos || 0),
        pendingReview: Number(content.pending_review || 0),
      },
      ai: {
        successWeek: Number(ai.success_week || 0),
        errorsWeek: Number(ai.errors_week || 0),
        averageScore: Number(ai.average_score || 0),
      },
      activity: activityRows.map((row: any) => ({
        date: this.dateKey(row.study_date),
        studyMinutes: Math.round(Number(row.study_seconds || 0) / 60),
        learnedWords: Number(row.learned_words || 0),
        activeUsers: Number(row.active_users || 0),
      })),
      hskDistribution: hskRows.map((row: any) => ({
        level: row.level,
        users: Number(row.users || 0),
      })),
      recentUsers: recentUsers.map((row: any) => ({
        id: Number(row.id),
        email: row.email,
        displayName: row.display_name,
        createdAt: row.created_at,
      })),
      latestVersion: latestVersion
        ? {
            code: latestVersion.version_code,
            itemCount: Number(latestVersion.item_count || 0),
            publishedAt: latestVersion.published_at,
          }
        : null,
    };
  }

  async createUser(token: string, body: UserPatch) {
    const admin = await this.requireAdmin(token);
    const email = this.normalizeEmail(body.email);
    const password = String(body.password || '');
    const displayName = String(body.displayName || '').trim();

    this.assertEmail(email);
    this.assertPassword(password);
    if (displayName.length < 2) {
      throw new BadRequestException('Hãy nhập họ tên tối thiểu 2 ký tự.');
    }
    const existing = await this.users.findOne({ where: { email } });
    if (existing) throw new ConflictException('Email này đã tồn tại.');

    const user = this.users.create({
      email,
      passwordHash: this.hashPassword(password),
      displayName,
      avatarUrl: String(body.avatarUrl || '').trim(),
      role: this.normalizeRole(body.role),
      status: this.normalizeStatus(body.status),
      targetLevel: this.normalizeLevel(body.targetLevel),
    });
    await this.users.save(user);
    await this.syncNormalizedUser(user);
    await this.auditUser(admin.id, 'CREATE', user.id, {
      email: user.email,
      role: user.role,
      status: user.status,
    });
    return { user: this.publicUser(user) };
  }

  async updateUser(token: string, id: number, body: UserPatch) {
    const admin = await this.requireAdmin(token);
    const user = await this.users.findOne({ where: { id } });
    if (!user) throw new BadRequestException('Không tìm thấy người dùng.');
    const requestedRole =
      body.role === undefined ? user.role : this.normalizeRole(body.role);
    const requestedStatus =
      body.status === undefined
        ? user.status
        : this.normalizeStatus(body.status);
    if (
      admin.id === user.id &&
      (requestedRole !== 'admin' || requestedStatus === 'blocked')
    ) {
      throw new BadRequestException(
        'Bạn không thể tự hạ quyền hoặc khóa tài khoản admin đang đăng nhập.',
      );
    }
    if (user.role === 'admin' && requestedRole !== 'admin') {
      const adminCount = await this.users.count({ where: { role: 'admin' } });
      if (adminCount <= 1) {
        throw new BadRequestException(
          'Hệ thống phải luôn còn ít nhất một tài khoản admin.',
        );
      }
    }

    if (body.email !== undefined) {
      const email = this.normalizeEmail(body.email);
      this.assertEmail(email);
      const duplicate = await this.users.findOne({ where: { email } });
      if (duplicate && duplicate.id !== user.id) {
        throw new ConflictException('Email này đã tồn tại.');
      }
      user.email = email;
    }
    if (body.password) {
      this.assertPassword(body.password);
      user.passwordHash = this.hashPassword(body.password);
    }
    if (body.displayName !== undefined) {
      const displayName = String(body.displayName || '').trim();
      if (displayName.length < 2) {
        throw new BadRequestException('Hãy nhập họ tên tối thiểu 2 ký tự.');
      }
      user.displayName = displayName;
    }
    if (body.role !== undefined) user.role = requestedRole;
    if (body.status !== undefined) user.status = requestedStatus;
    if (body.targetLevel !== undefined) {
      user.targetLevel = this.normalizeLevel(body.targetLevel);
    }
    if (body.avatarUrl !== undefined) {
      user.avatarUrl = String(body.avatarUrl || '').trim();
    }

    await this.users.save(user);
    await this.syncNormalizedUser(user);
    await this.auditUser(admin.id, 'UPDATE', user.id, {
      email: user.email,
      role: user.role,
      status: user.status,
      targetLevel: user.targetLevel,
    });
    return { user: this.publicUser(user) };
  }

  async setUserStatus(token: string, id: number, status: string) {
    return this.updateUser(token, id, { status });
  }

  async userStats(token: string) {
    await this.requireAdmin(token);
    const [total, active, blocked, admins] = await Promise.all([
      this.users.count(),
      this.users.count({ where: { status: 'active' } }),
      this.users.count({ where: { status: 'blocked' } }),
      this.users.count({ where: { role: 'admin' } }),
    ]);
    return { total, active, blocked, admins };
  }

  tokenFromAuthorization(authorization = '') {
    const value = authorization.trim();
    if (value.toLowerCase().startsWith('bearer ')) return value.slice(7).trim();
    return value;
  }

  private async getUserFromToken(token: string) {
    const payload = this.verifyToken(token);
    const user = await this.users.findOne({
      where: { id: Number(payload.sub) },
    });
    if (!user) throw new UnauthorizedException('Phiên đăng nhập không hợp lệ.');
    if (user.status === 'blocked') {
      throw new ForbiddenException('Tài khoản này đang bị khóa.');
    }
    return user;
  }

  private async ensureDefaultAdmin() {
    const email = this.defaultAdminEmail();
    const password = process.env.ADMIN_PASSWORD || 'admin123456';
    const displayName = process.env.ADMIN_NAME || 'VNChinese Admin';
    const existing = await this.users.findOne({ where: { email } });
    if (existing) {
      existing.role = 'admin';
      existing.status = 'active';
      existing.displayName = displayName;
      if (!this.verifyPassword(password, existing.passwordHash)) {
        existing.passwordHash = this.hashPassword(password);
      }
      await this.users.save(existing);
      await this.syncNormalizedUser(existing);
      return;
    }

    const admin = this.users.create({
      email,
      passwordHash: this.hashPassword(password),
      displayName,
      role: 'admin',
      status: 'active',
      targetLevel: 'HSK 6',
    });
    await this.users.save(admin);
    await this.syncNormalizedUser(admin);
  }

  private assertDatabaseReady() {
    if (this.dataSource.isInitialized) return;
    throw new ServiceUnavailableException(
      'Database chua san sang. Hay bat PostgreSQL/Docker roi thu lai.',
    );
  }

  private defaultAdminEmail() {
    return this.normalizeEmail(
      process.env.ADMIN_EMAIL || 'admin@vnchinese.local',
    );
  }

  private googleClientIds() {
    return String(
      process.env.GOOGLE_OAUTH_CLIENT_IDS ||
        process.env.GOOGLE_WEB_CLIENT_ID ||
        '',
    )
      .split(',')
      .map((value) => value.trim())
      .filter(Boolean);
  }

  private authResponse(user: User) {
    const accessToken = this.signToken(user);
    return {
      success: true,
      user: this.publicUser(user),
      accessToken,
      // Backward compatibility for existing admin/mobile clients.
      token: accessToken,
    };
  }

  private publicUser(user: User) {
    return {
      id: user.id,
      email: user.email,
      displayName: user.displayName || 'Người học VNChinese',
      avatarUrl: user.avatarUrl || '',
      role: user.role || 'user',
      status: user.status || 'active',
      targetLevel: user.targetLevel || 'HSK 1',
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastLoginAt: user.lastLoginAt,
    };
  }

  private normalizeEmail(email?: string) {
    return String(email || '')
      .trim()
      .toLowerCase();
  }

  private assertEmail(email: string) {
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new BadRequestException('Email chưa đúng định dạng.');
    }
  }

  private assertPassword(password: string) {
    if (password.length < 6) {
      throw new BadRequestException('Mật khẩu cần tối thiểu 6 ký tự.');
    }
  }

  private normalizeRole(role?: string) {
    const value = String(role || 'user')
      .trim()
      .toLowerCase();
    return ['admin', 'editor', 'reviewer'].includes(value) ? value : 'user';
  }

  private normalizeStatus(status?: string) {
    const value = String(status || 'active')
      .trim()
      .toLowerCase();
    return value === 'blocked' ? 'blocked' : 'active';
  }

  private adminRole(value: unknown) {
    const role = String(value || 'user').toLowerCase();
    if (role === 'learner') return 'user';
    return ['admin', 'editor', 'reviewer'].includes(role) ? role : 'user';
  }

  private adminStatus(value: unknown) {
    const status = String(value || 'active').toLowerCase();
    return ['blocked', 'locked'].includes(status) ? 'blocked' : 'active';
  }

  private dateKey(value: unknown) {
    if (value instanceof Date) return value.toISOString().slice(0, 10);
    return String(value || '').slice(0, 10);
  }

  private normalizeLevel(level?: string) {
    const value = String(level || 'HSK 1')
      .trim()
      .toUpperCase();
    return /^HSK [1-6]$/.test(value) ? value : 'HSK 1';
  }

  private hashPassword(password: string) {
    const salt = randomBytes(16).toString('hex');
    const hash = scryptSync(password, salt, 64).toString('hex');
    return `scrypt$${salt}$${hash}`;
  }

  private verifyPassword(password: string, encoded: string) {
    const [scheme, salt, hash] = String(encoded || '').split('$');
    if (scheme !== 'scrypt' || !salt || !hash) return false;
    const expected = Buffer.from(hash, 'hex');
    const actual = scryptSync(password, salt, 64);
    return (
      expected.length === actual.length && timingSafeEqual(expected, actual)
    );
  }

  private signToken(user: User) {
    const issuedAt = Math.floor(Date.now() / 1000);
    const payload = Buffer.from(
      JSON.stringify({
        sub: user.id,
        email: user.email,
        role: user.role || 'user',
        iat: issuedAt,
        exp: issuedAt + 7 * 24 * 60 * 60,
      }),
    ).toString('base64url');
    const signature = createHmac('sha256', this.tokenSecret())
      .update(payload)
      .digest('base64url');
    return `${payload}.${signature}`;
  }

  private verifyToken(token: string): TokenPayload {
    const [payload, signature] = String(token || '').split('.');
    if (!payload || !signature) {
      throw new UnauthorizedException('Thiếu phiên đăng nhập.');
    }
    const expected = createHmac('sha256', this.tokenSecret())
      .update(payload)
      .digest('base64url');
    const actualBuffer = Buffer.from(signature);
    const expectedBuffer = Buffer.from(expected);
    if (
      actualBuffer.length !== expectedBuffer.length ||
      !timingSafeEqual(actualBuffer, expectedBuffer)
    ) {
      throw new UnauthorizedException('Phiên đăng nhập không hợp lệ.');
    }
    let parsed: TokenPayload;
    try {
      parsed = JSON.parse(
        Buffer.from(payload, 'base64url').toString('utf8'),
      ) as TokenPayload;
    } catch {
      throw new UnauthorizedException('Phiên đăng nhập không hợp lệ.');
    }
    if (!parsed.exp || parsed.exp <= Math.floor(Date.now() / 1000)) {
      throw new UnauthorizedException('Phiên đăng nhập đã hết hạn.');
    }
    return parsed;
  }

  private tokenSecret() {
    return (
      process.env.AUTH_TOKEN_SECRET ||
      process.env.JWT_SECRET ||
      'vnchinese-dev-secret-change-me'
    );
  }

  private async syncNormalizedUser(user: User) {
    await this.dataSource.query(
      `UPDATE users SET
         password_hash = "passwordHash",
         display_name = "displayName",
         avatar_url = "avatarUrl",
         target_hsk_level = $2
       WHERE id = $1`,
      [
        user.id,
        Number(String(user.targetLevel || 'HSK 1').match(/[1-6]/)?.[0] || 1),
      ],
    );
  }

  private async auditUser(
    adminId: number,
    action: string,
    userId: number,
    changeData: Record<string, unknown>,
  ) {
    await this.dataSource.query(
      `INSERT INTO admin_audit_logs
        (admin_id, action, entity_type, entity_id, change_data)
       VALUES ($1, $2, 'users', $3, $4::jsonb)`,
      [adminId, action, String(userId), JSON.stringify(changeData)],
    );
  }
}
