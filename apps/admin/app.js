const STORAGE_KEY = 'vnchinese_admin_state_v2';

const seedState = {
  vocabulary: [
    { id: uid(), simplified: '你好', pinyin: 'nǐ hǎo', meaningVi: 'xin chào', hsk: 'HSK 1', type: 'cụm từ', status: 'published' },
    { id: uid(), simplified: '学习', pinyin: 'xuéxí', meaningVi: 'học tập', hsk: 'HSK 1', type: 'động từ', status: 'published' },
    { id: uid(), simplified: '门', pinyin: 'mén', meaningVi: 'cửa', hsk: 'HSK 1', type: 'danh từ', status: 'published' },
    { id: uid(), simplified: '广告', pinyin: 'guǎnggào', meaningVi: 'quảng cáo', hsk: 'HSK 4', type: 'danh từ', status: 'published' },
    { id: uid(), simplified: '观众', pinyin: 'guānzhòng', meaningVi: 'khán giả', hsk: 'HSK 4', type: 'danh từ', status: 'published' },
    { id: uid(), simplified: '社会', pinyin: 'shèhuì', meaningVi: 'xã hội', hsk: 'HSK 4', type: 'danh từ', status: 'review' },
  ],
  flashcards: [
    {
      id: 'greeting',
      name: 'Chào hỏi',
      level: 'HSK 1',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/greeting/1681525453.jpg',
      words: [
        word('你好', 'nǐ hǎo', 'xin chào'),
        word('谢谢', 'xièxie', 'cảm ơn'),
        word('再见', 'zàijiàn', 'tạm biệt'),
        word('请', 'qǐng', 'mời, xin'),
      ],
    },
    {
      id: 'home',
      name: 'Nhà cửa',
      level: 'HSK 1',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/home/9bdfe95fda.jpg',
      words: [
        word('房间', 'fángjiān', 'phòng'),
        word('门', 'mén', 'cửa'),
        word('窗户', 'chuānghu', 'cửa sổ'),
        word('桌子', 'zhuōzi', 'cái bàn'),
      ],
    },
    {
      id: 'food',
      name: 'Ăn uống',
      level: 'HSK 1',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/food/edfec00f07.jpg',
      words: [
        word('米饭', 'mǐfàn', 'cơm trắng'),
        word('苹果', 'píngguǒ', 'táo'),
        word('茶', 'chá', 'trà'),
        word('水', 'shuǐ', 'nước'),
      ],
    },
    {
      id: 'school',
      name: 'Trường học',
      level: 'HSK 2',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/school/413b738061.jpg',
      words: [
        word('学校', 'xuéxiào', 'trường học'),
        word('老师', 'lǎoshī', 'giáo viên'),
        word('学生', 'xuésheng', 'học sinh'),
        word('考试', 'kǎoshì', 'thi cử'),
      ],
    },
    {
      id: 'transport',
      name: 'Giao thông',
      level: 'HSK 2',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/transport/fed19a817b.jpg',
      words: [
        word('飞机', 'fēijī', 'máy bay'),
        word('汽车', 'qìchē', 'ô tô'),
        word('地铁', 'dìtiě', 'tàu điện ngầm'),
        word('车站', 'chēzhàn', 'bến xe, ga'),
      ],
    },
    {
      id: 'media_society',
      name: 'Truyền thông và xã hội',
      level: 'HSK 4',
      status: 'published',
      imagePath: '../mobile/assets/images/flashcards/media_society/d2fb1e3e17.jpg',
      words: [
        word('新闻', 'xīnwén', 'tin tức', 'd2fb1e3e17.jpg'),
        word('广告', 'guǎnggào', 'quảng cáo', '70ceb33a9b.jpg'),
        word('观众', 'guānzhòng', 'khán giả', '1ff96246c4.jpg'),
        word('网络', 'wǎngluò', 'mạng internet', '95521bb744.jpg'),
        word('社会', 'shèhuì', 'xã hội', 'ce4ba240fb.jpg'),
        word('文化', 'wénhuà', 'văn hóa', 'f9f7bb6679.jpg'),
        word('服务', 'fúwù', 'dịch vụ', '47d68cd0f4.jpg'),
        word('电视', 'diànshì', 'tivi', '3a2f904027.jpg'),
        word('交通', 'jiāotōng', 'giao thông', 'c8ace4e283.jpg'),
        word('电影', 'diànyǐng', 'phim', '51e9743451.jpg'),
      ],
    },
    {
      id: 'health',
      name: 'Sức khỏe',
      level: 'HSK 2',
      status: 'draft',
      imagePath: '../mobile/assets/images/flashcards/health/7be627ccbd.jpg',
      words: [
        word('身体', 'shēntǐ', 'cơ thể'),
        word('医生', 'yīshēng', 'bác sĩ'),
        word('医院', 'yīyuàn', 'bệnh viện'),
      ],
    },
  ],
  lessons: [
    { id: uid(), type: 'Ngữ pháp', title: 'Câu hỏi với 吗', level: 'HSK 1', items: 6, status: 'published' },
    { id: uid(), type: 'Đọc hiểu', title: 'Một ngày ở trường', level: 'HSK 2', items: 12, status: 'published' },
    { id: uid(), type: 'Video', title: 'Hello Song', level: 'HSK 1', items: 4, status: 'review', youtubeId: 'm_rDIzj6DRE', transcriptStatus: 'untimed' },
    { id: uid(), type: 'Video', title: 'Weekend Travel Plans', level: 'HSK 3', items: 388, status: 'published', youtubeId: 'TlW4x4ExAws', transcriptStatus: 'timed' },
  ],
  grammar: [
    {
      id: 'grammar_ma_question',
      level: 'HSK 1',
      title: 'Câu hỏi với 吗',
      pattern: 'S + V/O + 吗？',
      explanation: 'Đặt 吗 ở cuối câu trần thuật để tạo câu hỏi có/không.',
      examples: [{ cn: '你好吗？', py: 'Nǐ hǎo ma?', vi: 'Bạn khỏe không?' }],
      note: 'Không dùng 吗 cùng từ nghi vấn như 什么, 谁.',
      status: 'published',
    },
  ],
  readingSources: [
    { id: 'chinanews', name: '中国新闻网', level: 'HSK 4', status: 'active', url: 'https://www.chinanews.com.cn/rss/scroll-news.xml' },
    { id: 'bbc', name: 'BBC 中文', level: 'HSK 4', status: 'active', url: 'https://feeds.bbci.co.uk/zhongwen/simp/rss.xml' },
    { id: 'rfi', name: 'RFI 中文', level: 'HSK 4', status: 'active', url: 'https://www.rfi.fr/cn/rss' },
  ],
  articles: [
    {
      id: 'article_school_day',
      level: 'HSK 2',
      source: 'VNChinese',
      title: '我的一天',
      titleVi: 'Một ngày của tôi',
      summaryVi: 'Bài đọc ngắn về lịch sinh hoạt hằng ngày.',
      content: '我每天早上七点起床。八点去学校。晚上我学习中文。',
      link: '',
      status: 'published',
      sentences: [],
    },
  ],
  pronunciation: [
    { id: 'h1_1', level: 'HSK 1', topic: 'Chào hỏi và phép lịch sự', cn: '你好！', py: 'Nǐ hǎo!', vi: 'Xin chào!', status: 'published' },
    { id: 'h2_23', level: 'HSK 2', topic: 'Học tập và du lịch', cn: '我坐飞机去北京。', py: 'Wǒ zuò fēijī qù Běijīng.', vi: 'Tôi đi máy bay đến Bắc Kinh.', status: 'published' },
    { id: 'h3_45', level: 'HSK 3', topic: 'Họp và xử lý công việc', cn: '这次会议非常重要。', py: 'Zhè cì huìyì fēicháng zhòngyào.', vi: 'Cuộc họp lần này rất quan trọng.', status: 'published' },
    { id: 'h4_75', level: 'HSK 4', topic: 'Công nghệ và truyền thông', cn: '网络改变了人们获得信息的方式。', py: 'Wǎngluò gǎibiàn le rénmen huòdé xìnxī de fāngshì.', vi: 'Internet đã thay đổi cách con người nhận thông tin.', status: 'published' },
  ],
  games: [
    { id: uid(), title: 'Quiz nghĩa từ', type: 'multiple_choice', scope: 'Theo chủ đề flashcard', status: 'published' },
    { id: uid(), title: 'Nghe và chọn từ', type: 'listening', scope: 'HSK 1-4', status: 'draft' },
    { id: uid(), title: 'Xếp câu đúng', type: 'sentence_order', scope: 'Ngữ pháp', status: 'draft' },
  ],
  aiSettings: {
    tutorEnabled: true,
    grammarEnabled: true,
    tutorPrompt: 'Gia sư tiếng Trung cho người Việt, luôn kèm pinyin và nghĩa Việt.',
    defaultLevel: 'HSK 2',
  },
  users: [
    { id: uid(), name: 'Nguyễn Minh Anh', email: 'minhanh@example.com', role: 'student', streak: 12, saved: 48, status: 'active' },
    { id: uid(), name: 'Content Editor', email: 'editor@vnchinese.local', role: 'editor', streak: 0, saved: 0, status: 'active' },
    { id: uid(), name: 'Demo Blocked', email: 'blocked@example.com', role: 'student', streak: 2, saved: 9, status: 'blocked' },
  ],
  review: [
    { id: uid(), area: 'Flashcard', title: 'Sức khỏe', issue: 'Topic đang ở trạng thái draft', severity: 'pending' },
    { id: uid(), area: 'Từ vựng', title: '社会', issue: 'Cần reviewer duyệt nghĩa Việt và ví dụ', severity: 'pending' },
  ],
  auditLogs: [],
  dashboard: null,
  settings: {
    apiBaseUrl: 'http://127.0.0.1:3001',
    contentVersion: '2026.06.04-admin',
    reviewerPolicy: 'Nội dung mới phải qua reviewer trước khi publish',
    exportTarget: 'apps/mobile/assets',
    mobileAssetRoot: '../mobile/assets',
  },
};

let state = loadState();
let activeView = 'dashboard';
let globalQuery = '';
let vocabularyFilter = 'Tất cả';
let lessonFilter = 'Tất cả';
let grammarFilter = 'Tất cả';
let articleFilter = 'Tất cả';
let userFilter = 'Tất cả';
let adminToken = sessionStorage.getItem('vnchinese_admin_token') || '';
let currentAdmin = JSON.parse(sessionStorage.getItem('vnchinese_admin_user') || 'null');

const appShell = document.querySelector('#appShell');
const adminLogin = document.querySelector('#adminLogin');
const adminLoginForm = document.querySelector('#adminLoginForm');
const adminLoginError = document.querySelector('#adminLoginError');
const viewRoot = document.querySelector('#viewRoot');
const viewTitle = document.querySelector('#viewTitle');
const toast = document.querySelector('#toast');
const searchInput = document.querySelector('#globalSearch');
const importJsonInput = document.querySelector('#importJsonInput');
const dialog = document.querySelector('#editorDialog');
const dialogTitle = document.querySelector('#dialogTitle');
const dialogEyebrow = document.querySelector('#dialogEyebrow');
const dialogFields = document.querySelector('#dialogFields');
const editorForm = document.querySelector('#editorForm');
const imageUploadInput = document.querySelector('#imageUploadInput');
const apiStatus = document.querySelector('#apiStatus');
const publishContentButton = document.querySelector('#publishContentBtn');
const adminIdentity = document.querySelector('#adminIdentity');

document.querySelectorAll('.nav-item').forEach((button) => {
  button.addEventListener('click', () => {
    activeView = button.dataset.view;
    document.querySelectorAll('.nav-item').forEach((item) => item.classList.remove('is-active'));
    button.classList.add('is-active');
    render();
  });
});

searchInput.addEventListener('input', (event) => {
  globalQuery = event.target.value.trim().toLowerCase();
  render();
});

document.querySelector('#qaButton').addEventListener('click', () => {
  const issues = runQualityChecks();
  state.review = mergeReviewIssues(state.review, issues);
  saveState();
  activeView = 'review';
  setActiveNav();
  render();
  showToast(`Đã kiểm tra chất lượng: ${issues.length} cảnh báo.`);
});

document.querySelector('#resetButton').addEventListener('click', () => {
  if (!confirm('Khôi phục dữ liệu mẫu admin?')) return;
  state = structuredClone(seedState);
  saveState();
  render();
  showToast('Đã khôi phục dữ liệu mẫu.');
});

document.querySelector('#exportBundleBtn').addEventListener('click', exportContentBundle);
publishContentButton.addEventListener('click', publishContentToApi);
document.querySelector('#adminLogoutBtn').addEventListener('click', () => {
  adminToken = '';
  currentAdmin = null;
  sessionStorage.removeItem('vnchinese_admin_token');
  sessionStorage.removeItem('vnchinese_admin_user');
  appShell.classList.add('is-hidden');
  adminLogin.classList.remove('is-hidden');
});
importJsonInput.addEventListener('change', importJsonFile);

adminLoginForm.addEventListener('submit', loginAdmin);
document.querySelector('#offlineAdminBtn').addEventListener('click', () => enterAdmin(false));

if (adminToken) {
  enterAdmin(true);
} else {
  adminLogin.classList.remove('is-hidden');
}

async function loginAdmin(event) {
  event.preventDefault();
  adminLoginError.textContent = '';
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  try {
    const response = await fetch(`${baseUrl}/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        email: document.querySelector('#adminEmail').value.trim(),
        password: document.querySelector('#adminPassword').value,
      }),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    if (data.user?.role !== 'admin') throw new Error('Tài khoản không có quyền admin.');
    adminToken = data.token;
    currentAdmin = data.user;
    sessionStorage.setItem('vnchinese_admin_token', adminToken);
    sessionStorage.setItem('vnchinese_admin_user', JSON.stringify(data.user));
    await enterAdmin(true);
  } catch (error) {
    adminLoginError.textContent = error.message;
  }
}

async function enterAdmin(syncUsers) {
  adminLogin.classList.add('is-hidden');
  appShell.classList.remove('is-hidden');
  if (syncUsers && adminToken) {
    await Promise.all([
      loadAdminDashboard(false),
      loadPublishedContent(false),
      loadBackendUsers(false),
      loadAuditLogs(false),
    ]);
  }
  render();
  refreshApiStatus();
}

function render() {
  const titles = {
    dashboard: 'Tổng quan',
    vocabulary: 'Quản lý từ vựng',
    flashcards: 'Quản lý flashcard',
    lessons: 'Quản lý bài học',
    videos: 'Video và transcript',
    reading: 'Nguồn báo và bài đọc',
    speaking: 'Tình huống luyện nói',
    games: 'Quiz và trò chơi',
    users: 'Quản lý người dùng',
    ai: 'Trung tâm AI',
    review: 'Kiểm duyệt nội dung',
    settings: 'Cấu hình hệ thống',
  };
  viewTitle.textContent = titles[activeView] || 'Admin';
  adminIdentity.textContent = currentAdmin
    ? `${currentAdmin.displayName || currentAdmin.email} · ${currentAdmin.role}`
    : adminToken
      ? 'Admin trực tuyến'
      : 'Offline admin';
  const renderer = {
    dashboard: renderDashboard,
    vocabulary: renderVocabulary,
    flashcards: renderFlashcards,
    lessons: renderLessons,
    videos: renderVideos,
    reading: renderReading,
    speaking: renderSpeaking,
    games: renderGames,
    users: renderUsers,
    ai: renderAiStudio,
    review: renderReview,
    settings: renderSettings,
  }[activeView];
  viewRoot.innerHTML = '';
  viewRoot.appendChild(renderer());
}

function renderDashboard() {
  const root = el('div', { class: 'view-root' });
  const topicWords = state.flashcards.reduce((sum, topic) => sum + topic.words.length, 0);
  const videos = state.lessons.filter((lesson) => lesson.type === 'Video');
  const dashboard = state.dashboard || {};
  const userStats = dashboard.users || {};
  const learning = dashboard.learning || {};
  const content = dashboard.content || {};
  const publishedContentCount = Number(dashboard.latestVersion?.itemCount || 0)
    || (content.vocabulary
      ? content.vocabulary + content.grammar + content.articles + content.pronunciation + content.videos
      : state.vocabulary.length + topicWords);
  root.appendChild(metricGrid([
    ['Người dùng', userStats.total ?? state.users.length, `${userStats.newThisWeek || 0} mới tuần này`],
    ['Học viên hoạt động', learning.learnersWeek ?? 0, `${learning.activeToday || 0} hôm nay`],
    ['Phút học tuần', learning.studyMinutesWeek ?? 0, `${learning.learnedWordsWeek || 0} từ mới`],
    ['Nội dung publish', publishedContentCount, `${content.pendingReview || 0} mục chờ duyệt`],
    ['Video đã khớp', videos.filter((video) => video.transcriptStatus === 'timed').length, `${content.videos || videos.length} video`],
  ]));

  const split = el('div', { class: 'split-grid' });
  split.appendChild(panel('Nhịp học 7 ngày', adminActivityChart(dashboard.activity || [])));
  split.appendChild(panel('Phân bổ HSK', hskDistribution(dashboard.hskDistribution || [])));
  root.appendChild(split);
  root.appendChild(toolbar('Thao tác nhanh', [
    button('↻ Đồng bộ dashboard', 'ghost-button', () => loadAdminDashboard(true)),
    button('↻ Tải lại nội dung DB', 'ghost-button', () => loadPublishedContent(true)),
    button('↻ Đồng bộ users', 'ghost-button', () => loadBackendUsers(true)),
  ]));
  const health = el('div', { class: 'split-grid' });
  health.appendChild(panel('Tình trạng nội dung', qualitySummary()));
  health.appendChild(panel('Luồng publish', publishFlow()));
  root.appendChild(health);
  root.appendChild(panel('Kết nối với app VNChinese', appConnectionSummary()));
  root.appendChild(panel('Kiểm tra nhanh AI ngữ pháp', grammarApiQuickPanel()));
  root.appendChild(renderRecentActivity());
  return root;
}

function renderVocabulary() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(toolbar('Danh sách từ vựng', [
    select(['Tất cả', 'HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'], vocabularyFilter, (value) => {
      vocabularyFilter = value;
      render();
    }),
    button('＋ Thêm từ', 'primary-button', () => openVocabularyEditor()),
  ]));

  const rows = state.vocabulary
    .filter((item) => vocabularyFilter === 'Tất cả' || item.hsk === vocabularyFilter)
    .filter((item) => matchesQuery([item.simplified, item.pinyin, item.meaningVi, item.hsk, item.type]));

  root.appendChild(tablePanel(['Từ', 'Pinyin', 'Nghĩa Việt', 'HSK', 'Loại', 'Trạng thái', ''], rows.map((item) => [
    strongText(item.simplified),
    item.pinyin,
    item.meaningVi,
    item.hsk,
    item.type,
    status(item.status),
    rowActions([
      ['Sửa', () => openVocabularyEditor(item)],
      ['Xóa', () => deleteItem('vocabulary', item.id)],
    ]),
  ])));
  return root;
}

function renderFlashcards() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(panel('Cách nạp chủ đề và flashcard', el('div', { class: 'admin-guide' }, [
    el('div', {}, [el('strong', {}, '1. Tạo chủ đề'), el('p', {}, 'Bấm “Thêm topic”, nhập mã không dấu, tên chủ đề, HSK và ảnh đại diện.')]),
    el('div', {}, [el('strong', {}, '2. Nhập từng từ'), el('p', {}, 'Mỗi dòng: Hán tự | pinyin có dấu | nghĩa Việt | tên ảnh | câu Trung | pinyin câu | dịch câu.')]),
    el('div', {}, [el('strong', {}, '3. Đưa sang app'), el('p', {}, 'Chuyển trạng thái published, xuất index rồi đặt file và ảnh vào assets/images/flashcards/<mã-topic>/.')]),
  ])));
  root.appendChild(toolbar('Chủ đề flashcard', [
    button('⇧ Import JSON', 'ghost-button', () => importJsonInput.click()),
    button('↻ Nạp từ app user', 'ghost-button', loadMobileFlashcardIndex),
    button('＋ Thêm topic', 'primary-button', () => openTopicEditor()),
    button('⇩ Xuất index', 'ghost-button', exportFlashcardIndex),
  ]));

  const grid = el('div', { class: 'topic-grid' });
  state.flashcards
    .filter((topic) => matchesQuery([topic.name, topic.level, topic.status, topic.words.map((w) => w.word).join(' ')]))
    .forEach((topic) => {
      const media = topicImage(topic);
      const meta = el('div', { class: 'topic-meta' }, [
        el('div', {}, [
          el('h3', {}, topic.name),
          el('p', {}, `${topic.level} · ${topic.words.length} từ`),
        ]),
        status(topic.status),
      ]);
      const words = el('ul', { class: 'word-list' }, topic.words.slice(0, 10).map((item) => el('li', {}, item.word)));
      const actions = el('div', { class: 'toolbar-group' }, [
        button('Sửa', 'ghost-button', () => openTopicEditor(topic)),
        button('Đăng ảnh', 'ghost-button', () => uploadTopicImage(topic.id)),
        button('Nhân bản', 'ghost-button', () => duplicateTopic(topic.id)),
        button('Xóa', 'ghost-button', () => deleteItem('flashcards', topic.id)),
      ]);
      grid.appendChild(el('article', { class: 'topic-tile' }, [
        media,
        meta,
        el('p', { class: 'topic-note' }, topic.imagePath ? `Ảnh: ${imageFileName(topic.imagePath) || 'data upload'}` : 'Chưa có ảnh đại diện'),
        words,
        actions,
      ]));
    });
  if (!grid.children.length) grid.appendChild(emptyState('Không có topic phù hợp.'));
  root.appendChild(grid);
  return root;
}

function renderLessons() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(toolbar('Bài học tổng hợp', [
    select(['Tất cả', 'Ngữ pháp', 'Đọc hiểu', 'Video'], lessonFilter, (value) => {
      lessonFilter = value;
      render();
    }),
    button('＋ Thêm bài', 'primary-button', () => openLessonEditor()),
  ]));
  const rows = state.lessons
    .filter((lesson) => lessonFilter === 'Tất cả' || lesson.type === lessonFilter)
    .filter((lesson) => matchesQuery([lesson.title, lesson.level, lesson.type, lesson.status]));
  root.appendChild(tablePanel(['Loại', 'Tiêu đề', 'Level', 'Số mục', 'Trạng thái', ''], rows.map((lesson) => [
    lesson.type,
    strongText(lesson.title),
    lesson.level,
    lesson.items,
    status(lesson.status),
    rowActions([
      ['Sửa', () => openLessonEditor(lesson)],
      ['Xóa', () => deleteItem('lessons', lesson.id)],
    ]),
  ])));
  root.appendChild(toolbar('Mẫu ngữ pháp HSK', [
    select(['Tất cả', 'HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6'], grammarFilter, (value) => {
      grammarFilter = value;
      render();
    }),
    button('＋ Thêm ngữ pháp', 'primary-button', () => openGrammarEditor()),
  ]));
  const grammarRows = (state.grammar || [])
    .filter((item) => grammarFilter === 'Tất cả' || item.level === grammarFilter)
    .filter((item) => matchesQuery([item.level, item.title, item.pattern, item.explanation, item.status]));
  root.appendChild(tablePanel(['HSK', 'Mẫu câu', 'Cấu trúc', 'Ví dụ', 'Trạng thái', ''], grammarRows.map((item) => [
    item.level,
    strongText(item.title),
    item.pattern || '',
    Array.isArray(item.examples) ? item.examples.length : 0,
    status(item.status),
    rowActions([
      ['Sửa', () => openGrammarEditor(item)],
      ['Lưu trữ', () => deleteItem('grammar', item.id)],
    ]),
  ])));
  return root;
}

function renderVideos() {
  const root = el('div', { class: 'view-root' });
  const videos = state.lessons.filter((lesson) => lesson.type === 'Video');
  const timed = videos.filter((video) => video.transcriptStatus === 'timed').length;
  root.appendChild(metricGrid([
    ['Video', videos.length, 'YouTube lessons'],
    ['Đã khớp câu', timed, 'có start/end'],
    ['Cần timing', videos.length - timed, 'không tự dừng'],
    ['Đang publish', videos.filter((video) => video.status === 'published').length, 'hiển thị cho user'],
  ]));
  root.appendChild(toolbar('Thư viện video shadowing', [
    button('⇩ Xuất video catalog', 'ghost-button', exportVideoCatalog),
    button('＋ Thêm video', 'primary-button', () => openVideoEditor()),
  ]));
  root.appendChild(tablePanel(
    ['Tiêu đề', 'YouTube ID', 'HSK', 'Phụ đề', 'Đồng bộ', 'Trạng thái', ''],
    videos.map((video) => [
      strongText(video.title),
      video.youtubeId || 'Chưa có',
      video.level,
      `${video.items || 0} câu`,
      status(video.transcriptStatus === 'timed' ? 'approved' : 'pending'),
      status(video.status),
      rowActions([
        ['Transcript', () => openVideoEditor(video)],
        ['Xóa', () => deleteItem('lessons', video.id)],
      ]),
    ]),
  ));
  root.appendChild(panel(
    'Định dạng transcript',
    el('p', { class: 'topic-note' }, 'Mỗi dòng: start giây | end giây | câu Trung | pinyin có dấu | nghĩa Việt. Chỉ video có timing đầy đủ mới bật tự dừng từng câu trong app.'),
  ));
  return root;
}

function renderReading() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(toolbar('Nguồn tin trực tuyến', [
    button('↻ Kiểm tra RSS', 'ghost-button', testReadingApi),
    button('＋ Thêm nguồn', 'primary-button', () => openReadingSourceEditor()),
  ]));
  root.appendChild(tablePanel(
    ['Nguồn', 'URL RSS/API', 'Cấp đọc', 'Trạng thái', ''],
    state.readingSources.map((source) => [
      strongText(source.name),
      source.url,
      source.level,
      status(source.status),
      rowActions([
        ['Sửa', () => openReadingSourceEditor(source)],
        ['Bật/tắt', () => {
          source.status = source.status === 'active' ? 'archived' : 'active';
          saveState();
          render();
        }],
      ]),
    ]),
  ));
  root.appendChild(panel(
    'Luồng đọc báo trong app',
    el('div', { class: 'admin-guide' }, [
      el('div', {}, [el('strong', {}, 'Lấy tin'), el('p', {}, 'Backend đọc RSS mới, lọc bài trống và trả tối đa 24 bài.')]),
      el('div', {}, [el('strong', {}, 'Hỗ trợ học'), el('p', {}, 'App tách câu, phát TTS, tạo pinyin gợi ý và cho chạm từ để tra nghĩa.')]),
      el('div', {}, [el('strong', {}, 'Kiểm duyệt'), el('p', {}, 'Nguồn lạ hoặc lỗi mã hóa cần tắt tại đây trước khi publish.')]),
    ]),
  ));
  root.appendChild(toolbar('Bài đọc trong PostgreSQL', [
    select(['Tất cả', 'HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6'], articleFilter, (value) => {
      articleFilter = value;
      render();
    }),
    button('＋ Thêm bài đọc', 'primary-button', () => openArticleEditor()),
  ]));
  const articles = (state.articles || [])
    .filter((item) => articleFilter === 'Tất cả' || item.level === articleFilter)
    .filter((item) => matchesQuery([item.source, item.level, item.title, item.titleVi, item.summaryVi, item.status]));
  root.appendChild(tablePanel(
    ['Nguồn', 'HSK', 'Tiêu đề', 'Tóm tắt', 'Trạng thái', ''],
    articles.map((item) => [
      item.source || 'VNChinese',
      item.level,
      strongText(item.title),
      item.summaryVi || item.titleVi || '',
      status(item.status),
      rowActions([
        ['Sửa', () => openArticleEditor(item)],
        ['Lưu trữ', () => deleteItem('articles', item.id)],
      ]),
    ]),
  ));
  return root;
}

function renderSpeaking() {
  const root = el('div', { class: 'view-root' });
  const published = state.pronunciation.filter((item) => item.status === 'published').length;
  const topics = new Set(state.pronunciation.map((item) => item.topic).filter(Boolean));
  root.appendChild(metricGrid([
    ['Câu luyện nói', state.pronunciation.length, 'HSK 1-4'],
    ['Đã xuất bản', published, 'hiển thị trong app'],
    ['Tình huống', topics.size, 'bộ lọc người học'],
    ['Thiếu dữ liệu', state.pronunciation.filter((item) => !item.cn || !item.py || !item.vi).length, 'cần bổ sung'],
  ]));
  root.appendChild(toolbar('Tình huống và câu luyện phát âm', [
    button('↻ Nạp từ app user', 'ghost-button', loadMobilePronunciation),
    button('＋ Thêm câu', 'primary-button', () => openSpeakingEditor()),
  ]));
  const rows = state.pronunciation
    .filter((item) => matchesQuery([item.level, item.topic, item.cn, item.py, item.vi, item.status]));
  root.appendChild(tablePanel(
    ['HSK', 'Tình huống', 'Câu Trung', 'Pinyin', 'Nghĩa Việt', 'Trạng thái', ''],
    rows.map((item) => [
      item.level,
      strongText(item.topic),
      strongText(item.cn),
      item.py,
      item.vi,
      status(item.status),
      rowActions([
        ['Sửa', () => openSpeakingEditor(item)],
        ['Xóa', () => deleteItem('pronunciation', item.id)],
      ]),
    ]),
  ));
  return root;
}

function renderGames() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(toolbar('Quiz và trò chơi ghi nhớ', [
    button('＋ Thêm trò chơi', 'primary-button', () => openGameEditor()),
  ]));
  root.appendChild(tablePanel(
    ['Tên', 'Loại', 'Phạm vi dữ liệu', 'Trạng thái', ''],
    state.games.map((game) => [
      strongText(game.title),
      game.type,
      game.scope,
      status(game.status),
      rowActions([
        ['Sửa', () => openGameEditor(game)],
        ['Xóa', () => deleteItem('games', game.id)],
      ]),
    ]),
  ));
  return root;
}

async function loadMobilePronunciation() {
  const root = String(state.settings.mobileAssetRoot || '../mobile/assets').replace(/[\\/]+$/, '');
  try {
    const response = await fetch(`${root}/data/reading_hsk.json`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    if (!Array.isArray(data)) throw new Error('Dữ liệu câu luyện không hợp lệ.');
    state.pronunciation = data.map((item) => ({
      id: item.id || uid(),
      level: item.level || 'HSK 1',
      topic: item.topic || 'Giao tiếp hằng ngày',
      cn: item.cn || '',
      py: item.py || '',
      vi: item.vi || '',
      status: item.status || 'published',
    }));
    saveState();
    activeView = 'speaking';
    setActiveNav();
    render();
    showToast(`Đã nạp ${state.pronunciation.length} câu luyện nói từ app user.`);
  } catch (error) {
    showToast(`Chưa nạp được câu luyện nói: ${error.message}`);
  }
}

function renderAiStudio() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(metricGrid([
    ['Ngữ pháp AI', state.aiSettings.grammarEnabled ? 'Bật' : 'Tắt', 'POST /grammar/check'],
    ['Gia sư AI', state.aiSettings.tutorEnabled ? 'Bật' : 'Tắt', 'POST /ai/chat'],
    ['Trình độ mặc định', state.aiSettings.defaultLevel, 'prompt context'],
    ['Nhà cung cấp', 'Gemini', 'backend giữ API key'],
  ]));
  const prompt = el('textarea', {}, state.aiSettings.tutorPrompt);
  prompt.addEventListener('change', () => {
    state.aiSettings.tutorPrompt = prompt.value.trim();
    saveState();
  });
  root.appendChild(panel('Prompt gia sư', el('div', { class: 'dialog-fields compact-fields' }, [
    el('div', { class: 'field' }, [el('label', {}, 'Quy tắc phản hồi'), prompt]),
  ])));
  root.appendChild(panel('Kiểm tra dịch vụ AI', el('div', { class: 'toolbar-group' }, [
    button('Test chấm ngữ pháp', 'primary-button', testGrammarApi),
    button('Test chatbot', 'ghost-button', testChatApi),
    button('Kiểm tra health', 'ghost-button', refreshApiStatus),
  ])));
  return root;
}

function renderUsers() {
  const root = el('div', { class: 'view-root' });
  const stats = state.dashboard?.users || {};
  root.appendChild(metricGrid([
    ['Tổng user', stats.total ?? state.users.length, `${stats.newThisWeek || 0} mới tuần này`],
    ['Đang hoạt động', stats.active ?? state.users.filter((user) => user.status === 'active').length, `${stats.loggedInThisWeek || 0} đăng nhập 7 ngày`],
    ['Bị khóa', stats.blocked ?? state.users.filter((user) => user.status === 'blocked').length, 'kiểm soát truy cập'],
    ['Admin', stats.admins ?? state.users.filter((user) => user.role === 'admin').length, 'quyền quản trị'],
  ]));
  root.appendChild(toolbar('Người dùng', [
    select(['Tất cả', 'active', 'blocked', 'admin', 'editor', 'reviewer', 'user'], userFilter, (value) => {
      userFilter = value;
      render();
    }),
    button('↻ Đồng bộ API', 'ghost-button', loadBackendUsers),
    button('＋ Thêm user', 'primary-button', () => openUserEditor()),
  ]));
  const rows = state.users
    .filter((user) => userFilter === 'Tất cả' || user.status === userFilter || user.role === userFilter)
    .filter((user) => matchesQuery([user.displayName || user.name, user.email, user.role, user.status, user.targetLevel]));
  root.appendChild(tablePanel(['Tên', 'Email', 'Vai trò', 'Mục tiêu', 'Tiến độ', 'Đăng nhập cuối', 'Trạng thái', ''], rows.map((user) => [
    strongText(user.displayName || user.name),
    user.email,
    user.role,
    user.targetLevel || 'HSK 1',
    `${user.progress?.learnedWords || 0} từ · ${user.progress?.studyMinutes || 0} phút · ${user.progress?.averageScore || 0}%`,
    user.lastLoginAt ? new Date(user.lastLoginAt).toLocaleString('vi-VN') : 'Chưa đăng nhập',
    status(user.status),
    rowActions([
      ['Chi tiết', () => openUserDetail(user.id)],
      ['Sửa', () => openUserEditor(user)],
      [user.status === 'blocked' ? 'Mở' : 'Khóa', () => toggleUserStatus(user.id)],
    ]),
  ])));
  return root;
}

async function apiFetch(path, options = {}) {
  if (!adminToken) throw new Error('Chưa đăng nhập admin.');
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  const response = await fetch(`${baseUrl}${path}`, {
    ...options,
    headers: {
      ...(options.body ? { 'Content-Type': 'application/json' } : {}),
      ...(options.headers || {}),
      Authorization: `Bearer ${adminToken}`,
    },
  });
  const data = await response.json().catch(() => ({}));
  if (response.status === 401 || response.status === 403) {
    adminToken = '';
    currentAdmin = null;
    sessionStorage.removeItem('vnchinese_admin_token');
    sessionStorage.removeItem('vnchinese_admin_user');
    appShell.classList.add('is-hidden');
    adminLogin.classList.remove('is-hidden');
    throw new Error(data.message || 'Phiên admin đã hết hạn.');
  }
  if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
  return data;
}

async function loadAdminDashboard(shouldRender = true) {
  if (!adminToken) return;
  try {
    state.dashboard = await apiFetch('/admin/dashboard');
    saveState();
    if (shouldRender) render();
  } catch (error) {
    showToast(`Chưa tải được dashboard: ${error.message}`);
  }
}

async function loadBackendUsers(shouldRender = true) {
  if (!adminToken) {
    showToast('Hãy đăng nhập admin để đồng bộ người dùng.');
    return;
  }
  try {
    const data = await apiFetch('/admin/users');
    state.users = Array.isArray(data) ? data : [];
    saveState();
    if (shouldRender) render();
    showToast(`Đã đồng bộ ${state.users.length} người dùng.`);
  } catch (error) {
    showToast(`Chưa đồng bộ được người dùng: ${error.message}`);
  }
}

async function loadAuditLogs(shouldRender = true) {
  if (!adminToken) return;
  try {
    const data = await apiFetch('/admin/audit-logs?limit=30');
    state.auditLogs = Array.isArray(data) ? data : [];
    saveState();
    if (shouldRender) render();
  } catch (error) {
    showToast(`Chưa tải được nhật ký admin: ${error.message}`);
  }
}

async function loadPublishedContent(shouldRender = true) {
  if (!adminToken) return;
  try {
    const data = await apiFetch('/admin/content');

    if (Array.isArray(data.vocabulary)) {
      state.vocabulary = data.vocabulary;
    }
    if (Array.isArray(data.flashcards) && data.flashcards.length) {
      state.flashcards = data.flashcards.map(topicFromFlashcardIndex);
    }
    if (Array.isArray(data.lessons) && data.lessons.length) {
      state.lessons = data.lessons;
    }
    if (Array.isArray(data.videos) && data.videos.length) {
      const nonVideoLessons = state.lessons.filter((lesson) => lesson.type !== 'Video');
      state.lessons = [
        ...nonVideoLessons,
        ...data.videos.map((video) => ({
          ...video,
          type: 'Video',
          status: video.status || 'published',
          items: Array.isArray(video.subtitles) ? video.subtitles.length : 0,
          transcript: Array.isArray(video.subtitles) ? video.subtitles : [],
        })),
      ];
    }
    if (Array.isArray(data.readingSources) && data.readingSources.length) {
      state.readingSources = data.readingSources;
    }
    if (Array.isArray(data.grammar)) {
      state.grammar = data.grammar;
    }
    if (Array.isArray(data.articles)) {
      state.articles = data.articles;
    }
    if (Array.isArray(data.pronunciation) && data.pronunciation.length) {
      state.pronunciation = data.pronunciation;
    }
    if (Array.isArray(data.games) && data.games.length) {
      state.games = data.games;
    }
    if (data.aiSettings && typeof data.aiSettings === 'object') {
      state.aiSettings = { ...state.aiSettings, ...data.aiSettings };
    }
    if (data.version && data.version !== 'unpublished') {
      state.settings.contentVersion = data.version;
    }
    saveState();
    if (shouldRender) render();
  } catch (error) {
    showToast(`Chưa tải được nội dung đã xuất bản: ${error.message}`);
  }
}

async function publishContentToApi() {
  if (!adminToken) {
    showToast('Hãy đăng nhập admin trực tuyến để xuất bản nội dung.');
    return;
  }
  const issues = runQualityChecks().filter((issue) => issue.severity === 'fail');
  if (issues.length && !confirm(`Nội dung còn ${issues.length} lỗi QA. Vẫn xuất bản?`)) return;

  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  const videos = state.lessons
    .filter((lesson) => lesson.type === 'Video')
    .map((video) => ({
      id: video.id,
      title: video.title,
      titleCn: video.titleCn || '',
      level: video.level,
      youtubeId: video.youtubeId,
      source: video.source || 'YouTube',
      status: video.status,
      transcriptStatus: video.transcriptStatus || 'untimed',
      subtitles: Array.isArray(video.transcript) ? video.transcript : [],
    }));
  const payload = {
    version: state.settings.contentVersion,
    vocabulary: state.vocabulary,
    flashcards: state.flashcards.map(topicToFlashcardIndex),
    pronunciation: state.pronunciation,
    videos,
    lessons: state.lessons.filter((lesson) => lesson.type !== 'Video'),
    grammar: state.grammar || [],
    articles: state.articles || [],
    readingSources: state.readingSources,
    games: state.games,
    aiSettings: state.aiSettings,
  };

  publishContentButton.disabled = true;
  publishContentButton.textContent = 'Đang xuất bản...';
  try {
    const response = await fetch(`${baseUrl}/admin/content`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${adminToken}`,
      },
      body: JSON.stringify(payload),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    showToast(
      `Đã đồng bộ ${data.counts?.flashcards || 0} topic, ${data.counts?.grammar || 0} ngữ pháp, ${data.counts?.articles || 0} bài đọc, ${data.counts?.videos || 0} video.`,
    );
    await Promise.all([loadAdminDashboard(false), loadPublishedContent(false), loadAuditLogs(false)]);
    render();
    refreshApiStatus();
  } catch (error) {
    showToast(`Xuất bản thất bại: ${error.message}`);
  } finally {
    publishContentButton.disabled = false;
    publishContentButton.textContent = 'Xuất bản';
  }
}

function renderReview() {
  const root = el('div', { class: 'view-root' });
  root.appendChild(toolbar('Hàng chờ kiểm duyệt', [
    button('✓ Duyệt tất cả', 'primary-button', approveAllReview),
    button('↺ Chạy QA', 'ghost-button', () => {
      state.review = mergeReviewIssues(state.review, runQualityChecks());
      saveState();
      render();
    }),
  ]));

  const list = el('div', { class: 'qa-list' });
  state.review
    .filter((item) => matchesQuery([item.area, item.title, item.issue, item.severity]))
    .forEach((item) => {
      list.appendChild(el('div', { class: 'qa-item' }, [
        el('span', { class: `qa-dot ${item.severity === 'fail' ? 'fail' : 'warn'}` }, item.severity === 'fail' ? '!' : '?'),
        el('div', {}, [
          el('strong', {}, `${item.area}: ${item.title}`),
          el('p', {}, item.issue),
        ]),
        rowActions([
          ['Duyệt', () => approveReview(item.id)],
          ['Ẩn', () => dismissReview(item.id)],
        ]),
      ]));
    });
  if (!list.children.length) list.appendChild(emptyState('Không còn nội dung chờ duyệt.'));
  root.appendChild(list);
  return root;
}

function renderSettings() {
  const root = el('div', { class: 'view-root' });
  const rows = [
    ['API base URL', 'apiBaseUrl'],
    ['Content version', 'contentVersion'],
    ['Reviewer policy', 'reviewerPolicy'],
    ['Export target', 'exportTarget'],
    ['Mobile asset root', 'mobileAssetRoot'],
  ];
  rows.forEach(([label, key]) => {
    const input = el('input', { value: state.settings[key] || '' });
    input.addEventListener('change', () => {
      state.settings[key] = input.value.trim();
      saveState();
      showToast('Đã lưu cấu hình.');
    });
    root.appendChild(el('div', { class: 'setting-row' }, [
      el('div', {}, [el('h3', {}, label), el('p', {}, settingHint(key))]),
      input,
    ]));
  });
  root.appendChild(panel('Quản lý dữ liệu', el('div', { class: 'toolbar-group' }, [
    button('Kiểm tra API', 'ghost-button', testApiConnection),
    button('Test AI ngữ pháp', 'ghost-button', testGrammarApi),
    button('⇩ Xuất content bundle', 'primary-button', exportContentBundle),
    button('⇩ Xuất flashcard index', 'ghost-button', exportFlashcardIndex),
    button('↺ Khôi phục mẫu', 'ghost-button', () => document.querySelector('#resetButton').click()),
  ])));
  return root;
}

async function testApiConnection() {
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  if (!baseUrl) {
    showToast('Chưa có API base URL.');
    return;
  }
  try {
    const response = await fetch(`${baseUrl}/health`, { method: 'GET' });
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    showToast('API VNChinese đang kết nối được.');
  } catch (error) {
    showToast(`Chưa kết nối được API: ${error.message}`);
  }
}

async function testGrammarApi() {
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  if (!baseUrl) {
    showToast('Chưa có API base URL.');
    return;
  }
  try {
    const response = await fetch(`${baseUrl}/grammar/check`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ text: '我不学校去学习' }),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    showToast(`AI grammar OK: ${data.provider || 'AI'} ${data.model || ''} · ${data.score}/100`);
  } catch (error) {
    showToast(`AI ngữ pháp chưa sẵn sàng: ${error.message}`);
  }
}

async function refreshApiStatus() {
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  try {
    const response = await fetch(`${baseUrl}/health`);
    const data = await response.json();
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const aiReady = data.ai?.configured && data.ai?.keyFormat === 'valid-pattern';
    apiStatus.textContent = aiReady ? 'API & AI sẵn sàng' : 'API chạy · AI cần key';
    apiStatus.className = `api-status ${aiReady ? 'is-online' : 'is-warning'}`;
  } catch (_) {
    apiStatus.textContent = 'API ngoại tuyến';
    apiStatus.className = 'api-status is-offline';
  }
}

async function testReadingApi() {
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  try {
    const response = await fetch(`${baseUrl}/reading/news`);
    const data = await response.json();
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    showToast(`Đọc báo trực tuyến hoạt động: ${Array.isArray(data) ? data.length : 0} bài mới.`);
  } catch (error) {
    showToast(`Nguồn báo chưa sẵn sàng: ${error.message}`);
  }
}

async function testChatApi() {
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  try {
    const response = await fetch(`${baseUrl}/ai/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ message: 'Tạo một câu chào hỏi HSK 1.', level: 'HSK 1' }),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    showToast(`Chatbot hoạt động: ${String(data.reply || '').slice(0, 80)}`);
  } catch (error) {
    showToast(`Chatbot chưa sẵn sàng: ${error.message}`);
  }
}

function openVideoEditor(video) {
  const values = video || {
    title: '',
    level: 'HSK 1',
    youtubeId: '',
    source: 'YouTube',
    status: 'draft',
    transcriptText: '',
  };
  values.transcriptText = (video?.transcript || []).map((line) => [
    line.start,
    line.end,
    line.cn,
    line.py,
    line.vi,
  ].join('|')).join('\n');
  openEditor({
    title: video ? 'Sửa video và transcript' : 'Thêm video shadowing',
    area: 'Video',
    values,
    fields: [
      ['title', 'Tiêu đề'],
      ['youtubeId', 'YouTube video ID'],
      ['source', 'Nguồn'],
      ['level', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4']],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
      ['transcriptText', 'Transcript: start | end | Trung | pinyin | Việt', 'textarea'],
    ],
    onSave(raw) {
      const transcript = parseTranscript(raw.transcriptText);
      upsert('lessons', {
        ...video,
        id: video?.id || uid(),
        type: 'Video',
        title: raw.title,
        youtubeId: raw.youtubeId.trim(),
        source: raw.source,
        level: raw.level,
        status: raw.status,
        transcript,
        items: transcript.length,
        transcriptStatus: transcript.length && transcript.every((line) => line.end > line.start)
          ? 'timed'
          : 'untimed',
      });
    },
  });
}

function openReadingSourceEditor(source) {
  openEditor({
    title: source ? 'Sửa nguồn báo' : 'Thêm nguồn báo',
    area: 'Reading',
    values: source || { name: '', url: '', level: 'HSK 4', status: 'active' },
    fields: [
      ['name', 'Tên nguồn'],
      ['url', 'URL RSS/API'],
      ['level', 'Cấp đọc', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4']],
      ['status', 'Trạng thái', 'select', ['active', 'archived']],
    ],
    onSave(values) {
      upsert('readingSources', { ...values, id: source?.id || slug(values.name) });
    },
  });
}

function openArticleEditor(article) {
  const values = {
    id: article?.id || '',
    source: article?.source || 'VNChinese',
    level: article?.level || 'HSK 3',
    title: article?.title || '',
    titleVi: article?.titleVi || '',
    summaryVi: article?.summaryVi || '',
    content: article?.content || '',
    link: article?.link || '',
    status: article?.status || 'draft',
  };
  openEditor({
    title: article ? 'Sửa bài đọc' : 'Thêm bài đọc',
    area: 'Reading',
    values,
    fields: [
      ['source', 'Nguồn'],
      ['level', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6']],
      ['title', 'Tiêu đề tiếng Trung'],
      ['titleVi', 'Tiêu đề tiếng Việt'],
      ['summaryVi', 'Tóm tắt tiếng Việt', 'textarea'],
      ['content', 'Nội dung tiếng Trung', 'textarea'],
      ['link', 'Link nguồn'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('articles', {
        ...article,
        ...values,
        id: article?.id || slug(values.title || `article-${Date.now()}`),
        sentences: article?.sentences || [],
      });
    },
  });
}

function openSpeakingEditor(item) {
  openEditor({
    title: item ? 'Sửa câu luyện nói' : 'Thêm câu luyện nói',
    area: 'Speaking',
    values: item || {
      level: 'HSK 1',
      topic: 'Giao tiếp hằng ngày',
      cn: '',
      py: '',
      vi: '',
      status: 'draft',
    },
    fields: [
      ['level', 'Cấp độ', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4']],
      ['topic', 'Tình huống'],
      ['cn', 'Câu tiếng Trung'],
      ['py', 'Pinyin có dấu'],
      ['vi', 'Nghĩa tiếng Việt'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('pronunciation', { ...item, ...values, id: item?.id || uid() });
    },
  });
}

function openGameEditor(game) {
  openEditor({
    title: game ? 'Sửa trò chơi' : 'Thêm trò chơi',
    area: 'Game',
    values: game || { title: '', type: 'multiple_choice', scope: 'Theo chủ đề', status: 'draft' },
    fields: [
      ['title', 'Tên trò chơi'],
      ['type', 'Kiểu', 'select', ['multiple_choice', 'listening', 'sentence_order', 'matching']],
      ['scope', 'Phạm vi dữ liệu'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('games', { ...values, id: game?.id || uid() });
    },
  });
}

function parseTranscript(text) {
  return String(text || '')
    .split(/\n+/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [start = '0', end = '0', cn = '', py = '', vi = ''] = line.split('|').map((part) => part.trim());
      return { start: Number(start), end: Number(end), cn, py, vi };
    })
    .filter((line) => line.cn);
}

function parseExamples(text) {
  return String(text || '')
    .split(/\n+/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [cn = '', py = '', vi = ''] = line.split('|').map((part) => part.trim());
      return { cn, py, vi };
    })
    .filter((example) => example.cn);
}

function openVocabularyEditor(item) {
  openEditor({
    title: item ? 'Sửa từ vựng' : 'Thêm từ vựng',
    area: 'Vocabulary',
    values: item || { simplified: '', pinyin: '', meaningVi: '', hsk: 'HSK 1', type: 'danh từ', status: 'draft' },
    fields: [
      ['simplified', 'Hán tự'],
      ['pinyin', 'Pinyin'],
      ['meaningVi', 'Nghĩa Việt'],
      ['hsk', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6']],
      ['type', 'Loại từ'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('vocabulary', { ...values, id: item?.id || uid() });
    },
  });
}

function openGrammarEditor(item) {
  const values = {
    id: item?.id || '',
    level: item?.level || 'HSK 1',
    title: item?.title || '',
    pattern: item?.pattern || '',
    explanation: item?.explanation || '',
    examplesText: (item?.examples || []).map((example) => [
      example.cn || '',
      example.py || '',
      example.vi || '',
    ].join('|')).join('\n'),
    note: item?.note || '',
    status: item?.status || 'draft',
  };
  openEditor({
    title: item ? 'Sửa mẫu ngữ pháp' : 'Thêm mẫu ngữ pháp',
    area: 'Grammar',
    values,
    fields: [
      ['level', 'HSK', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6']],
      ['title', 'Tên mẫu câu'],
      ['pattern', 'Cấu trúc'],
      ['explanation', 'Giải thích', 'textarea'],
      ['examplesText', 'Ví dụ: Trung | pinyin | Việt', 'textarea'],
      ['note', 'Ghi chú'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('grammar', {
        ...item,
        ...values,
        id: item?.id || slug(values.title || `grammar-${Date.now()}`),
        examples: parseExamples(values.examplesText),
      });
    },
  });
}

function openTopicEditor(topic) {
  const values = topic || {
    id: slug(`topic-${Date.now()}`),
    name: '',
    level: 'HSK 1',
    status: 'draft',
    imagePath: assetPath('images/flashcards/family/427034659a.jpg'),
    wordsText: '',
  };
  values.wordsText = (topic?.words || []).map((item) => {
    const example = item.examples?.[0] || {};
    return [
      item.word,
      item.pinyin,
      item.meaning,
      item.image || '',
      example.cn || '',
      example.py || '',
      example.vi || '',
    ].join('|');
  }).join('\n');
  openEditor({
    title: topic ? 'Sửa topic flashcard' : 'Thêm topic flashcard',
    area: 'Flashcard',
    values,
    fields: [
      ['id', 'Mã topic'],
      ['name', 'Tên topic'],
      ['level', 'Level'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
      ['imagePath', 'Ảnh đại diện'],
      ['wordsText', 'Từ trong topic: Hán tự | pinyin | nghĩa | ảnh | câu ví dụ | pinyin câu | dịch câu', 'textarea'],
    ],
    onSave(raw) {
      const next = {
        id: slug(raw.id || raw.name),
        name: raw.name,
        level: raw.level,
        status: raw.status,
        imagePath: raw.imagePath,
        uploadedImageName: topic?.imagePath === raw.imagePath ? topic.uploadedImageName : '',
        words: parseWords(raw.wordsText),
      };
      upsert('flashcards', next);
    },
  });
}

function openLessonEditor(lesson) {
  openEditor({
    title: lesson ? 'Sửa bài học' : 'Thêm bài học',
    area: 'Lessons',
    values: lesson || { type: 'Ngữ pháp', title: '', level: 'HSK 1', items: 1, status: 'draft' },
    fields: [
      ['type', 'Loại', 'select', ['Ngữ pháp', 'Đọc hiểu', 'Video']],
      ['title', 'Tiêu đề'],
      ['level', 'Level'],
      ['items', 'Số mục'],
      ['status', 'Trạng thái', 'select', ['draft', 'review', 'published', 'archived']],
    ],
    onSave(values) {
      upsert('lessons', { ...values, id: lesson?.id || uid(), items: Number(values.items || 0) });
    },
  });
}

function openUserEditor(user) {
  openEditor({
    title: user ? 'Sửa người dùng' : 'Thêm người dùng',
    area: 'Users',
    values: user || { displayName: '', email: '', password: '', role: 'user', targetLevel: 'HSK 1', status: 'active' },
    fields: [
      ['displayName', 'Tên hiển thị'],
      ['email', 'Email'],
      ['password', user ? 'Mật khẩu mới (để trống nếu giữ nguyên)' : 'Mật khẩu'],
      ['role', 'Vai trò', 'select', ['user', 'editor', 'reviewer', 'admin']],
      ['targetLevel', 'Mục tiêu', 'select', ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4', 'HSK 5', 'HSK 6']],
      ['status', 'Trạng thái', 'select', ['active', 'blocked']],
    ],
    async onSave(values) {
      await saveAdminUser(user, values);
    },
  });
}

async function saveAdminUser(user, values) {
  if (!adminToken) {
    upsert('users', { ...user, ...values, id: user?.id || uid() });
    return;
  }
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  const payload = { ...values };
  if (!payload.password) delete payload.password;
  const response = await fetch(
    user ? `${baseUrl}/admin/users/${user.id}` : `${baseUrl}/admin/users`,
    {
      method: user ? 'PATCH' : 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${adminToken}`,
      },
      body: JSON.stringify(payload),
    },
  );
  const data = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
  await loadBackendUsers();
}

async function openUserDetail(id) {
  if (!adminToken) {
    showToast('Chi tiết tiến độ cần đăng nhập admin trực tuyến.');
    return;
  }
  try {
    const detail = await apiFetch(`/admin/users/${id}`);
    document.querySelector('#saveDialogBtn').style.display = 'none';
    dialogEyebrow.textContent = 'User analytics';
    dialogTitle.textContent = detail.profile.displayName || detail.profile.email;
    dialogFields.innerHTML = '';
    const profile = detail.profile;
    const overview = metricGrid([
      ['Từ đã học', profile.progress?.learnedWords || 0, `${profile.progress?.masteredWords || 0} từ đã vững`],
      ['Phút học', profile.progress?.studyMinutes || 0, `${profile.progress?.activeDays || 0} ngày hoạt động`],
      ['Bài luyện', profile.progress?.attempts || 0, `${profile.progress?.averageScore || 0}% trung bình`],
      ['Cần ôn', profile.progress?.dueReview || 0, 'theo lịch SRS'],
    ]);
    const activity = tablePanel(
      ['Ngày', 'Phút', 'Từ mới', 'Quiz', 'Đọc', 'AI'],
      (detail.activity || []).slice(-14).map((day) => [
        new Date(`${day.date}T00:00:00`).toLocaleDateString('vi-VN'),
        day.studyMinutes,
        day.learnedWords,
        day.quizzes,
        day.reading,
        day.aiInteractions,
      ]),
    );
    const attempts = tablePanel(
      ['Loại', 'Điểm', 'Đúng/Tổng', 'Thời gian'],
      (detail.recentAttempts || []).slice(0, 8).map((attempt) => [
        attempt.type,
        `${attempt.score}%`,
        `${attempt.correctCount}/${attempt.totalCount}`,
        new Date(attempt.completedAt).toLocaleString('vi-VN'),
      ]),
    );
    dialogFields.appendChild(overview);
    dialogFields.appendChild(el('div', { class: 'profile-summary' }, [
      el('strong', {}, profile.email),
      el('span', {}, `${profile.role} · ${profile.status} · ${profile.targetLevel}`),
    ]));
    dialogFields.appendChild(panel('Hoạt động 14 ngày', activity));
    dialogFields.appendChild(panel('Bài luyện gần đây', attempts));
    dialog.showModal();
  } catch (error) {
    showToast(`Chưa tải được chi tiết user: ${error.message}`);
  }
}

function openEditor(config) {
  document.querySelector('#saveDialogBtn').style.display = '';
  dialogEyebrow.textContent = config.area;
  dialogTitle.textContent = config.title;
  dialogFields.innerHTML = '';
  const controls = {};
  config.fields.forEach(([key, label, type = 'input', options = []]) => {
    const field = el('label', { class: 'field' }, [el('span', {}, label)]);
    let control;
    if (type === 'select') {
      control = select(options, config.values[key] ?? options[0], null);
    } else if (type === 'textarea') {
      control = el('textarea', {}, config.values[key] ?? '');
    } else {
      control = el('input', { value: config.values[key] ?? '', type: key === 'password' ? 'password' : 'text' });
    }
    field.appendChild(control);
    dialogFields.appendChild(field);
    controls[key] = control;
  });
  editorForm.onsubmit = async (event) => {
    event.preventDefault();
    const values = {};
    Object.entries(controls).forEach(([key, control]) => {
      values[key] = control.value;
    });
    try {
      await config.onSave(values);
      dialog.close();
      saveState();
      render();
      showToast('Đã lưu thay đổi.');
    } catch (error) {
      showToast(`Chưa lưu được: ${error.message}`);
    }
  };
  dialog.showModal();
}

function upsert(collection, item) {
  const list = state[collection];
  const index = list.findIndex((entry) => entry.id === item.id);
  if (index >= 0) list[index] = item;
  else list.unshift(item);
}

function deleteItem(collection, id) {
  if (!confirm('Lưu trữ mục này? Mục archived sẽ không hiển thị trong app user sau khi publish.')) return;
  const item = state[collection]?.find((entry) => entry.id === id);
  if (item && 'status' in item) {
    item.status = collection === 'readingSources' ? 'archived' : 'archived';
  } else {
    state[collection] = state[collection].filter((entry) => entry.id !== id);
  }
  saveState();
  render();
  showToast('Đã chuyển mục sang trạng thái lưu trữ.');
}

function duplicateTopic(id) {
  const topic = state.flashcards.find((item) => item.id === id);
  if (!topic) return;
  const copy = structuredClone(topic);
  copy.id = `${topic.id}-copy-${Date.now().toString(36)}`;
  copy.name = `${topic.name} bản sao`;
  copy.status = 'draft';
  state.flashcards.unshift(copy);
  saveState();
  render();
  showToast('Đã nhân bản topic.');
}

function topicImage(topic) {
  const wrapper = el('div', { class: 'topic-media' });
  if (!topic.imagePath) {
    wrapper.appendChild(el('div', { class: 'image-placeholder' }, 'Chưa có ảnh. Bấm Đăng ảnh để preview trong admin.'));
    return wrapper;
  }

  const img = el('img', { src: topic.imagePath, alt: topic.name, loading: 'lazy' });
  img.addEventListener('error', () => {
    wrapper.innerHTML = '';
    wrapper.appendChild(el('div', { class: 'image-placeholder' }, `Không xem được ảnh: ${imageFileName(topic.imagePath) || 'đường dẫn chưa hợp lệ'}`));
  });
  wrapper.appendChild(img);
  return wrapper;
}

function uploadTopicImage(topicId) {
  const topic = state.flashcards.find((item) => item.id === topicId);
  if (!topic || !imageUploadInput) return;

  imageUploadInput.value = '';
  imageUploadInput.onchange = (event) => {
    const file = event.target.files?.[0];
    event.target.value = '';
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      topic.imagePath = String(reader.result || '');
      topic.uploadedImageName = sanitizeFileName(file.name);
      saveState();
      render();
      showToast('Đã đăng ảnh preview cho topic. Khi publish thật, hãy đưa file ảnh vào thư mục assets hoặc backend media.');
    };
    reader.onerror = () => showToast('Không đọc được file ảnh.');
    reader.readAsDataURL(file);
  };
  imageUploadInput.click();
}

async function toggleUserStatus(id) {
  const user = state.users.find((item) => item.id === id);
  if (!user) return;
  const nextStatus = user.status === 'blocked' ? 'active' : 'blocked';
  if (!adminToken) {
    user.status = nextStatus;
    saveState();
    render();
    return;
  }
  const baseUrl = String(state.settings.apiBaseUrl || '').replace(/\/+$/, '');
  try {
    const response = await fetch(`${baseUrl}/admin/users/${id}/status`, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        Authorization: `Bearer ${adminToken}`,
      },
      body: JSON.stringify({ status: nextStatus }),
    });
    const data = await response.json().catch(() => ({}));
    if (!response.ok) throw new Error(data.message || `HTTP ${response.status}`);
    await loadBackendUsers();
  } catch (error) {
    showToast(`Chưa đổi được trạng thái: ${error.message}`);
  }
}

function approveReview(id) {
  state.review = state.review.filter((item) => item.id !== id);
  saveState();
  render();
  showToast('Đã duyệt mục kiểm duyệt.');
}

function dismissReview(id) {
  state.review = state.review.filter((item) => item.id !== id);
  saveState();
  render();
}

function approveAllReview() {
  state.review = [];
  saveState();
  render();
  showToast('Đã duyệt toàn bộ hàng chờ.');
}

function runQualityChecks() {
  const issues = [];
  state.flashcards.forEach((topic) => {
    if (!topic.imagePath) issues.push(reviewIssue('Flashcard', topic.name, 'Thiếu ảnh đại diện topic', 'fail'));
    if (topic.status !== 'published') issues.push(reviewIssue('Flashcard', topic.name, `Topic đang ở trạng thái ${topic.status}`, 'pending'));
    topic.words.forEach((item) => {
      if (!item.pinyin || !item.meaning) issues.push(reviewIssue('Từ flashcard', item.word, 'Thiếu pinyin hoặc nghĩa Việt', 'fail'));
      if (looksBroken([item.word, item.pinyin, item.meaning].join(' '))) issues.push(reviewIssue('Từ flashcard', item.word, 'Có dấu hiệu mojibake', 'fail'));
    });
  });
  state.vocabulary.forEach((item) => {
    if (!item.pinyin || !item.meaningVi) issues.push(reviewIssue('Từ vựng', item.simplified, 'Thiếu pinyin hoặc nghĩa Việt', 'fail'));
    if (item.status !== 'published') issues.push(reviewIssue('Từ vựng', item.simplified, `Trạng thái ${item.status}`, 'pending'));
  });
  state.pronunciation.forEach((item) => {
    if (!item.topic || !item.cn || !item.py || !item.vi) {
      issues.push(reviewIssue('Luyện nói', item.cn || item.id, 'Thiếu tình huống, câu Trung, pinyin hoặc nghĩa Việt', 'fail'));
    }
    if (item.status !== 'published') {
      issues.push(reviewIssue('Luyện nói', item.cn || item.id, `Trạng thái ${item.status}`, 'pending'));
    }
  });
  (state.grammar || []).forEach((item) => {
    if (!item.title || !item.pattern || !item.explanation) {
      issues.push(reviewIssue('Ngữ pháp', item.title || item.id, 'Thiếu tên mẫu, cấu trúc hoặc giải thích', 'fail'));
    }
    if (item.status !== 'published') {
      issues.push(reviewIssue('Ngữ pháp', item.title || item.id, `Trạng thái ${item.status}`, 'pending'));
    }
  });
  (state.articles || []).forEach((item) => {
    if (!item.title || !item.content || !item.summaryVi) {
      issues.push(reviewIssue('Bài đọc', item.title || item.id, 'Thiếu tiêu đề, nội dung hoặc tóm tắt tiếng Việt', 'fail'));
    }
    if (looksBroken([item.title, item.titleVi, item.summaryVi].join(' '))) {
      issues.push(reviewIssue('Bài đọc', item.title || item.id, 'Có dấu hiệu lỗi mã hóa', 'fail'));
    }
    if (item.status !== 'published') {
      issues.push(reviewIssue('Bài đọc', item.title || item.id, `Trạng thái ${item.status}`, 'pending'));
    }
  });
  state.lessons.filter((lesson) => lesson.type === 'Video').forEach((video) => {
    if (!video.youtubeId) issues.push(reviewIssue('Video', video.title, 'Thiếu YouTube ID', 'fail'));
    if (video.transcriptStatus !== 'timed') {
      issues.push(reviewIssue('Video', video.title, 'Chưa có start/end đầy đủ nên app không thể tự dừng theo câu', 'pending'));
    }
  });
  state.flashcards.forEach((topic) => {
    if (/[A-Za-z]\b/.test(topic.name) && !/[À-ỹ]/.test(topic.name)) {
      issues.push(reviewIssue('Flashcard', topic.name, 'Tên chủ đề có thể đang thiếu dấu tiếng Việt', 'pending'));
    }
  });
  return issues;
}

function qualitySummary() {
  const issues = runQualityChecks();
  const list = el('div', { class: 'qa-list' });
  const cleanCount = Math.max(0, state.vocabulary.length + state.flashcards.length - issues.length);
  [
    ['✓', `${cleanCount} mục sạch`, 'Không thiếu nghĩa/pinyin trong dữ liệu đang publish.', 'ok'],
    ['?', `${issues.filter((item) => item.severity === 'pending').length} mục chờ duyệt`, 'Nội dung draft/review cần reviewer xác nhận.', 'warn'],
    ['!', `${issues.filter((item) => item.severity === 'fail').length} lỗi cần sửa`, 'Thiếu trường bắt buộc hoặc có dấu hiệu lỗi mã hóa.', 'fail'],
  ].forEach(([mark, title, desc, type]) => {
    list.appendChild(el('div', { class: 'qa-item' }, [
      el('span', { class: `qa-dot ${type === 'warn' ? 'warn' : type === 'fail' ? 'fail' : ''}` }, mark),
      el('div', {}, [el('strong', {}, title), el('p', {}, desc)]),
      el('span', { class: 'status' }, type),
    ]));
  });
  return list;
}

function publishFlow() {
  const steps = [
    ['Draft', 'Editor nhập từ, ảnh, ví dụ và topic.'],
    ['Review', 'Reviewer chạy QA, sửa lỗi nghĩa/pinyin/ảnh trùng.'],
    ['Publish', 'Admin xuất bundle JSON và cập nhật app/backend.'],
    ['Monitor', 'Theo dõi từ lỗi, topic học nhiều, phản hồi người dùng.'],
  ];
  return el('div', { class: 'qa-list' }, steps.map(([title, desc], index) => el('div', { class: 'qa-item' }, [
    el('span', { class: 'qa-dot' }, String(index + 1)),
    el('div', {}, [el('strong', {}, title), el('p', {}, desc)]),
    el('span', { class: 'status approved' }, 'ready'),
  ])));
}

function adminActivityChart(days) {
  const values = Array.isArray(days) && days.length ? days : Array.from({ length: 7 }, (_, index) => ({
    date: new Date(Date.now() - (6 - index) * 86400000).toISOString().slice(0, 10),
    studyMinutes: 0,
    learnedWords: 0,
    activeUsers: 0,
  }));
  const peak = Math.max(1, ...values.map((item) => Number(item.studyMinutes || 0)));
  return el('div', { class: 'admin-chart' }, values.map((item) => {
    const minutes = Number(item.studyMinutes || 0);
    const date = new Date(`${item.date}T00:00:00`);
    return el('div', { class: 'chart-day' }, [
      el('strong', {}, minutes ? `${minutes}p` : '0'),
      el('span', { class: 'chart-bar', style: `height:${Math.max(6, (minutes / peak) * 96)}px` }),
      el('small', {}, date.toLocaleDateString('vi-VN', { weekday: 'short' })),
      el('em', {}, `${item.activeUsers || 0} user`),
    ]);
  }));
}

function hskDistribution(rows) {
  const values = Array.isArray(rows) && rows.length ? rows : ['HSK 1', 'HSK 2', 'HSK 3', 'HSK 4'].map((level) => ({ level, users: 0 }));
  const peak = Math.max(1, ...values.map((item) => Number(item.users || 0)));
  return el('div', { class: 'hsk-bars' }, values.map((item) => el('div', { class: 'hsk-row' }, [
    el('span', {}, item.level),
    el('div', { class: 'hsk-track' }, [
      el('span', { style: `width:${Math.max(4, (Number(item.users || 0) / peak) * 100)}%` }),
    ]),
    el('strong', {}, item.users || 0),
  ])));
}

function appConnectionSummary() {
  const publishedTopics = state.flashcards.filter((topic) => topic.status === 'published').length;
  const imageReady = state.flashcards.filter((topic) => Boolean(topic.imagePath)).length;
  const version = state.dashboard?.latestVersion;
  return el('div', { class: 'connection-grid' }, [
    el('div', { class: 'connection-card' }, [
      el('strong', {}, 'Nguồn flashcard mobile'),
      el('code', {}, 'apps/mobile/assets/images/flashcards/index.json'),
    ]),
    el('div', { class: 'connection-card' }, [
      el('strong', {}, `${publishedTopics}/${state.flashcards.length} topic publish`),
      el('p', {}, `${imageReady} topic có ảnh đại diện admin preview.`),
    ]),
    el('div', { class: 'connection-card' }, [
      el('strong', {}, 'Backend API'),
      el('code', {}, state.settings.apiBaseUrl || 'Chưa cấu hình'),
    ]),
    el('div', { class: 'connection-card' }, [
      el('strong', {}, 'Phiên bản dữ liệu'),
      el('p', {}, version ? `${version.code} · ${version.itemCount} mục` : state.settings.contentVersion),
    ]),
    el('div', { class: 'connection-card' }, [
      el('strong', {}, 'AI ngữ pháp'),
      el('p', {}, 'POST /grammar/check · Gemini backend · không chấm mặc định ở frontend.'),
    ]),
  ]);
}

function grammarApiQuickPanel() {
  return el('div', { class: 'toolbar-group' }, [
    button('Test câu sai mẫu', 'primary-button', testGrammarApi),
    el('p', { class: 'topic-note' }, 'Admin dùng cùng endpoint với app user để kiểm tra trạng thái AI và chất lượng prompt.'),
  ]);
}

function renderRecentActivity() {
  const rows = (state.auditLogs || []).slice(0, 8).map((item) => [
    item.entityType || 'system',
    `${item.adminName || 'System'} · ${item.action || 'UPDATE'} · ${item.entityId || ''}`,
    new Date(item.createdAt).toLocaleString('vi-VN'),
  ]);
  return panel(
    'Hoạt động gần đây',
    tablePanel(
      ['Khu vực', 'Thao tác', 'Thời gian'],
      rows.length
        ? rows
        : [['Hệ thống', 'Chưa có thao tác quản trị được ghi nhận', '—']],
    ),
  );
}

async function loadMobileFlashcardIndex() {
  const root = String(state.settings.mobileAssetRoot || '../mobile/assets').replace(/[\\/]+$/, '');
  try {
    const response = await fetch(`${root}/images/flashcards/index.json`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    const data = await response.json();
    if (!Array.isArray(data.topics)) throw new Error('Không thấy topics trong index.json');
    state.flashcards = data.topics.map(topicFromFlashcardIndex);
    saveState();
    activeView = 'flashcards';
    setActiveNav();
    render();
    showToast(`Đã nạp ${state.flashcards.length} topic từ app user.`);
  } catch (error) {
    showToast(`Chưa nạp được index mobile: ${error.message}`);
  }
}

function importJsonFile(event) {
  const file = event.target.files?.[0];
  event.target.value = '';
  if (!file) return;
  const reader = new FileReader();
  reader.onload = () => {
    try {
      const data = JSON.parse(String(reader.result || '{}'));
      if (Array.isArray(data.topics)) {
        state.flashcards = data.topics.map(topicFromFlashcardIndex);
        saveState();
        activeView = 'flashcards';
        setActiveNav();
        render();
        showToast(`Đã import ${state.flashcards.length} topic flashcard.`);
      } else if (data.flashcards || data.vocabulary) {
        state = { ...state, ...data, settings: { ...state.settings, ...(data.settings || {}) } };
        saveState();
        render();
        showToast('Đã import content bundle.');
      } else {
        showToast('File JSON chưa đúng định dạng admin.');
      }
    } catch (error) {
      showToast(`Không đọc được JSON: ${error.message}`);
    }
  };
  reader.readAsText(file, 'utf-8');
}

function exportContentBundle() {
  downloadJson(`vnchinese-content-${dateStamp()}.json`, {
    version: state.settings.contentVersion,
    exportedAt: new Date().toISOString(),
    vocabulary: state.vocabulary,
    flashcards: state.flashcards,
    pronunciation: state.pronunciation,
    lessons: state.lessons,
    grammar: state.grammar || [],
    readingSources: state.readingSources,
    articles: state.articles || [],
    games: state.games,
    aiSettings: state.aiSettings,
    users: state.users,
    review: state.review,
    settings: state.settings,
  });
}

function exportFlashcardIndex() {
  downloadJson('flashcard-index.admin-export.json', {
    version: state.settings.contentVersion,
    topics: state.flashcards.map(topicToFlashcardIndex),
  });
}

function exportVideoCatalog() {
  downloadJson('video_lessons.admin-export.json', state.lessons
    .filter((lesson) => lesson.type === 'Video' && lesson.status !== 'archived')
    .map((video) => ({
      id: video.id,
      title: video.title,
      titleCn: video.titleCn || '',
      level: video.level,
      youtubeId: video.youtubeId,
      source: video.source || 'YouTube',
      transcriptStatus: video.transcriptStatus || 'untimed',
      subtitles: video.transcript || [],
    })));
}

function topicFromFlashcardIndex(topic) {
  const id = String(topic.id || slug(topic.name || 'topic'));
  const words = Array.isArray(topic.words)
    ? topic.words.map((item) => word(
        item.word,
        item.pinyin,
        item.meaning,
        item.image || '',
        item.query || '',
        item.examples || [],
      ))
    : [];
  const firstImage = words.find((item) => item.image)?.image || '';
  return {
    id,
    name: String(topic.name || id),
    level: topic.level || levelForTopic(id),
    status: topic.status || 'published',
    imagePath: firstImage ? assetPath(`images/flashcards/${id}/${firstImage}`) : '',
    words,
  };
}

function levelForTopic(id) {
  const hsk1 = ['animals', 'body', 'colors', 'family', 'food', 'greeting', 'home', 'weather'];
  const hsk2 = ['clothes', 'daily_life', 'health', 'nature', 'places', 'school', 'shopping', 'transport'];
  const hsk3 = ['city_life', 'entertainment', 'sports'];
  if (hsk1.includes(id)) return 'HSK 1';
  if (hsk2.includes(id)) return 'HSK 2';
  if (hsk3.includes(id)) return 'HSK 3';
  if (id === 'media_society') return 'HSK 4';
  return 'HSK 2';
}

function topicToFlashcardIndex(topic) {
  return {
    id: topic.id,
    name: topic.name,
    level: topic.level,
    status: topic.status,
    words: topic.words.map((item) => ({
      word: item.word,
      pinyin: item.pinyin,
      meaning: item.meaning,
      image: item.image || topicImageName(topic),
      query: item.query || `${item.meaning} ${item.word}`.trim(),
      examples: item.examples || [],
    })),
  };
}

function mergeReviewIssues(current, issues) {
  const existing = new Set(current.map((item) => `${item.area}|${item.title}|${item.issue}`));
  const next = [...current];
  issues.forEach((item) => {
    const key = `${item.area}|${item.title}|${item.issue}`;
    if (!existing.has(key)) next.push(item);
  });
  return next;
}

function metricGrid(items) {
  return el('div', { class: 'metric-grid' }, items.map(([label, value, hint]) => el('div', { class: 'metric' }, [
    el('span', {}, label),
    el('strong', {}, formatMetricValue(value)),
    el('small', {}, hint),
  ])));
}

function formatMetricValue(value) {
  if (typeof value === 'number' && Number.isFinite(value)) {
    return new Intl.NumberFormat('vi-VN').format(value);
  }
  return String(value);
}

function toolbar(title, controls) {
  return el('div', { class: 'toolbar' }, [
    el('div', {}, [el('h2', {}, title)]),
    el('div', { class: 'toolbar-group' }, controls),
  ]);
}

function panel(title, content) {
  return el('section', { class: 'panel' }, [el('h2', {}, title), content]);
}

function tablePanel(headers, rows) {
  if (!rows.length) return el('div', { class: 'table-panel' }, [emptyState('Không có dữ liệu phù hợp.')]);
  return el('div', { class: 'table-panel' }, [
    el('table', {}, [
      el('thead', {}, [el('tr', {}, headers.map((head) => el('th', {}, head)))]),
      el('tbody', {}, rows.map((row) => el('tr', {}, row.map((cell, index) => {
        const node = el('td', { 'data-label': headers[index] || '' });
        append(node, cell);
        return node;
      })))),
    ]),
  ]);
}

function rowActions(actions) {
  return el('span', { class: 'row-actions' }, actions.map(([label, handler]) => button(label, 'ghost-button', handler)));
}

function button(label, className, onClick) {
  const node = el('button', { class: className, type: 'button' }, label);
  node.addEventListener('click', onClick);
  return node;
}

function select(options, selected, onChange) {
  const node = el('select', { class: 'filter-select' }, options.map((option) => el('option', { value: option }, option)));
  node.value = selected;
  if (onChange) node.addEventListener('change', () => onChange(node.value));
  return node;
}

function status(value) {
  return el('span', { class: `status ${String(value).toLowerCase()}` }, value);
}

function strongText(text) {
  return el('strong', {}, text);
}

function emptyState(message) {
  return el('div', { class: 'empty' }, message);
}

function settingHint(key) {
  return {
    apiBaseUrl: 'Endpoint backend NestJS mà admin sẽ gọi khi bật đồng bộ online.',
    contentVersion: 'Phiên bản gắn vào bundle export để mobile/backend kiểm soát cập nhật.',
    reviewerPolicy: 'Quy tắc duyệt nội dung trước khi publish.',
    exportTarget: 'Gợi ý nơi đặt bundle sau khi export.',
    mobileAssetRoot: 'Đường dẫn tương đối từ apps/admin/index.html tới thư mục assets của mobile.',
  }[key] || '';
}

function parseWords(text) {
  return String(text || '')
    .split(/\n+/)
    .map((line) => line.trim())
    .filter(Boolean)
    .map((line) => {
      const [
        hanzi = '',
        pinyin = '',
        meaning = '',
        image = '',
        exampleCn = '',
        examplePy = '',
        exampleVi = '',
      ] = line.split('|').map((part) => part.trim());
      const examples = exampleCn && exampleVi
        ? [{ cn: exampleCn, py: examplePy, vi: exampleVi }]
        : [];
      return word(hanzi, pinyin, meaning, image, '', examples);
    });
}

function word(wordValue, pinyin = '', meaning = '', image = '', query = '', examples = []) {
  return {
    word: String(wordValue || ''),
    pinyin: String(pinyin || ''),
    meaning: String(meaning || ''),
    image,
    query,
    examples: Array.isArray(examples) ? examples : [],
  };
}

function reviewIssue(area, title, issue, severity) {
  return { id: uid(), area, title, issue, severity };
}

function matchesQuery(values) {
  if (!globalQuery) return true;
  return values.join(' ').toLowerCase().includes(globalQuery);
}

function looksBroken(text) {
  return /[ÃÄÂ]|ï¿½|�/.test(text);
}

function slug(text) {
  return String(text || 'item')
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '') || 'item';
}

function uid() {
  return Math.random().toString(36).slice(2, 10);
}

function dateStamp() {
  return new Date().toISOString().slice(0, 10);
}

function imageFileName(path) {
  const value = String(path || '');
  if (!value || value.startsWith('data:')) return '';
  return value.split(/[\\/]/).pop() || '';
}

function topicImageName(topic) {
  return topic.uploadedImageName || imageFileName(topic.imagePath);
}

function assetPath(path) {
  const root = String(state.settings?.mobileAssetRoot || '../mobile/assets').replace(/[\\/]+$/, '');
  return `${root}/${String(path || '').replace(/^[\\/]+/, '')}`;
}

function sanitizeFileName(name) {
  const cleaned = String(name || 'flashcard-image.jpg')
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-zA-Z0-9._-]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return cleaned || 'flashcard-image.jpg';
}

function loadState() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    return saved ? normalizeState(JSON.parse(saved)) : structuredClone(seedState);
  } catch (_) {
    return structuredClone(seedState);
  }
}

function normalizeState(next) {
  const source = next && typeof next === 'object' ? next : {};
  return {
    ...structuredClone(seedState),
    ...source,
    settings: { ...seedState.settings, ...(source.settings || {}) },
    vocabulary: Array.isArray(source.vocabulary) ? source.vocabulary : seedState.vocabulary,
    flashcards: Array.isArray(source.flashcards) ? source.flashcards : seedState.flashcards,
    pronunciation: Array.isArray(source.pronunciation) ? source.pronunciation : seedState.pronunciation,
    lessons: Array.isArray(source.lessons) ? source.lessons : seedState.lessons,
    grammar: Array.isArray(source.grammar) ? source.grammar : seedState.grammar,
    readingSources: Array.isArray(source.readingSources) ? source.readingSources : seedState.readingSources,
    articles: Array.isArray(source.articles) ? source.articles : seedState.articles,
    games: Array.isArray(source.games) ? source.games : seedState.games,
    aiSettings: { ...seedState.aiSettings, ...(source.aiSettings || {}) },
    users: Array.isArray(source.users) ? source.users : seedState.users,
    review: Array.isArray(source.review) ? source.review : seedState.review,
    auditLogs: Array.isArray(source.auditLogs) ? source.auditLogs : [],
    dashboard: source.dashboard || null,
  };
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function downloadJson(filename, data) {
  const blob = new Blob([JSON.stringify(data, null, 2)], { type: 'application/json;charset=utf-8' });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  link.click();
  URL.revokeObjectURL(url);
  showToast(`Đã xuất ${filename}.`);
}

function showToast(message) {
  toast.textContent = message;
  toast.classList.add('is-visible');
  clearTimeout(showToast.timer);
  showToast.timer = setTimeout(() => toast.classList.remove('is-visible'), 2600);
}

function setActiveNav() {
  document.querySelectorAll('.nav-item').forEach((item) => {
    item.classList.toggle('is-active', item.dataset.view === activeView);
  });
}

function el(tag, attrs = {}, children = []) {
  const node = document.createElement(tag);
  Object.entries(attrs).forEach(([key, value]) => {
    if (key === 'class') node.className = value;
    else if (key === 'value') node.value = value;
    else node.setAttribute(key, value);
  });
  append(node, children);
  return node;
}

function append(node, children) {
  const list = Array.isArray(children) ? children : [children];
  list.filter((child) => child !== null && child !== undefined).forEach((child) => {
    if (child instanceof Node) node.appendChild(child);
    else node.appendChild(document.createTextNode(String(child)));
  });
}
