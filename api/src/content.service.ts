import { Injectable } from '@nestjs/common';
import { DataSource, QueryRunner } from 'typeorm';

export type ManagedContentBundle = {
  version: string;
  publishedAt: string;
  vocabulary: Record<string, any>[];
  flashcards: Record<string, any>[];
  pronunciation: Record<string, any>[];
  videos: Record<string, any>[];
  lessons: Record<string, any>[];
  readingSources: Record<string, any>[];
  grammar: Record<string, any>[];
  articles: Record<string, any>[];
  games: Record<string, any>[];
  aiSettings: Record<string, unknown>;
};

const CURATED_VIDEO_LESSONS: Record<string, any>[] = [
  {
    id: 'lf_hsk1_i_see',
    title: 'I See',
    titleCn: '我看到',
    level: 'HSK 1',
    youtubeId: 'VxAImi0LsS8',
    source: 'Little Fox Chinese',
    transcriptStatus: 'timed',
    transcriptSource: 'User supplied timed transcript',
    reviewStatus: 'reviewed',
    status: 'published',
    subtitles: [
      {
        start: 0.94,
        end: 10.28,
        cn: '小猴子，我看到。',
        py: 'Xiǎo hóuzi, wǒ kàn dào.',
        vi: 'Chú khỉ nhỏ, tôi nhìn thấy.',
      },
      {
        start: 24.24,
        end: 27.76,
        cn: '我看到石头。',
        py: 'Wǒ kàn dào shítou.',
        vi: 'Tôi nhìn thấy hòn đá.',
      },
      {
        start: 32.78,
        end: 36.34,
        cn: '我看到蚂蚁。',
        py: 'Wǒ kàn dào mǎyǐ.',
        vi: 'Tôi nhìn thấy con kiến.',
      },
      {
        start: 40.78,
        end: 47.4,
        cn: '我看到花。',
        py: 'Wǒ kàn dào huā.',
        vi: 'Tôi nhìn thấy bông hoa.',
      },
      {
        start: 55.95,
        end: 58.97,
        cn: '我看到蝴蝶。',
        py: 'Wǒ kàn dào húdié.',
        vi: 'Tôi nhìn thấy con bướm.',
      },
      {
        start: 65.16,
        end: 68.18,
        cn: '我看到蜜蜂。',
        py: 'Wǒ kàn dào mìfēng.',
        vi: 'Tôi nhìn thấy con ong.',
      },
      {
        start: 73.91,
        end: 81.68,
        cn: '我看到树。',
        py: 'Wǒ kàn dào shù.',
        vi: 'Tôi nhìn thấy cái cây.',
      },
      {
        start: 89.69,
        end: 92.67,
        cn: '我看到猫。',
        py: 'Wǒ kàn dào māo.',
        vi: 'Tôi nhìn thấy con mèo.',
      },
      {
        start: 95.31,
        end: 95.75,
        cn: '快跑！',
        py: 'Kuài pǎo!',
        vi: 'Chạy mau!',
      },
      {
        start: 109,
        end: 116.68,
        cn: '石头，我看到石头。',
        py: 'Shítou, wǒ kàn dào shítou.',
        vi: 'Hòn đá, tôi nhìn thấy hòn đá.',
      },
      {
        start: 118.86,
        end: 126.12,
        cn: '蚂蚁，我看到蚂蚁。',
        py: 'Mǎyǐ, wǒ kàn dào mǎyǐ.',
        vi: 'Con kiến, tôi nhìn thấy con kiến.',
      },
      {
        start: 128.7,
        end: 132.58,
        cn: '花，我看到花。',
        py: 'Huā, wǒ kàn dào huā.',
        vi: 'Bông hoa, tôi nhìn thấy bông hoa.',
      },
      {
        start: 136.4,
        end: 144.28,
        cn: '树，我看到树。',
        py: 'Shù, wǒ kàn dào shù.',
        vi: 'Cái cây, tôi nhìn thấy cái cây.',
      },
    ],
  },
];

const foundationReadingArticle = (
  id: string,
  level: string,
  title: string,
  titleVi: string,
  summaryVi: string,
  sentences: Array<{ cn: string; py: string; vi: string }>,
) => ({
  id,
  level,
  source: 'VNChinese',
  sourceType: 'seed_hsk',
  sourceLabel: 'Bài đọc HSK tự biên soạn',
  title,
  titleVi,
  summaryVi,
  content: sentences.map((sentence) => sentence.cn).join(''),
  status: 'published',
  sentences,
});

const CURATED_FOUNDATION_READING_LESSONS: Record<string, any>[] = [
  foundationReadingArticle(
    'seed_hsk1_daily_life',
    'HSK 1',
    '每天的生活',
    'Cuộc sống hằng ngày',
    'Bài đọc HSK 1 về giờ giấc, bữa sáng và việc học mỗi ngày.',
    [
      { cn: '我每天七点起床。', py: 'Wǒ měitiān qī diǎn qǐchuáng.', vi: 'Tôi thức dậy lúc bảy giờ mỗi ngày.' },
      { cn: '早上我喝一杯牛奶，吃一片面包。', py: 'Zǎoshang wǒ hē yì bēi niúnǎi, chī yí piàn miànbāo.', vi: 'Buổi sáng tôi uống một cốc sữa và ăn một lát bánh mì.' },
      { cn: '八点我去学校学习汉语。', py: 'Bā diǎn wǒ qù xuéxiào xuéxí Hànyǔ.', vi: 'Tám giờ tôi đến trường học tiếng Trung.' },
      { cn: '中午我和朋友一起吃饭。', py: 'Zhōngwǔ wǒ hé péngyou yìqǐ chīfàn.', vi: 'Buổi trưa tôi ăn cơm cùng bạn.' },
      { cn: '下午我回家做作业。', py: 'Xiàwǔ wǒ huí jiā zuò zuòyè.', vi: 'Buổi chiều tôi về nhà làm bài tập.' },
      { cn: '晚上十点我睡觉。', py: 'Wǎnshang shí diǎn wǒ shuìjiào.', vi: 'Mười giờ tối tôi đi ngủ.' },
    ],
  ),
  foundationReadingArticle(
    'seed_hsk1_my_family',
    'HSK 1',
    '我的家',
    'Gia đình của tôi',
    'Bài đọc HSK 1 giới thiệu các thành viên trong gia đình.',
    [
      { cn: '我家有四个人。', py: 'Wǒ jiā yǒu sì ge rén.', vi: 'Gia đình tôi có bốn người.' },
      { cn: '爸爸是医生，妈妈是老师。', py: 'Bàba shì yīshēng, māma shì lǎoshī.', vi: 'Bố là bác sĩ, mẹ là giáo viên.' },
      { cn: '我有一个姐姐。', py: 'Wǒ yǒu yí ge jiějie.', vi: 'Tôi có một chị gái.' },
      { cn: '姐姐也喜欢学习汉语。', py: 'Jiějie yě xǐhuan xuéxí Hànyǔ.', vi: 'Chị gái cũng thích học tiếng Trung.' },
      { cn: '晚上我们一起吃饭，也一起看电视。', py: 'Wǎnshang wǒmen yìqǐ chīfàn, yě yìqǐ kàn diànshì.', vi: 'Buổi tối chúng tôi cùng ăn cơm và xem tivi.' },
      { cn: '我的家很开心。', py: 'Wǒ de jiā hěn kāixīn.', vi: 'Gia đình tôi rất vui vẻ.' },
    ],
  ),
  foundationReadingArticle(
    'seed_hsk2_go_to_school',
    'HSK 2',
    '去学校',
    'Đi học',
    'Bài đọc HSK 2 về phương tiện đi lại và một buổi học ở trường.',
    [
      { cn: '我家离学校不远，所以我每天坐公共汽车去学校。', py: 'Wǒ jiā lí xuéxiào bù yuǎn, suǒyǐ wǒ měitiān zuò gōnggòng qìchē qù xuéxiào.', vi: 'Nhà tôi không xa trường nên mỗi ngày tôi đi xe buýt đến trường.' },
      { cn: '路上常常很忙，但是我不会迟到。', py: 'Lùshang chángcháng hěn máng, dànshì wǒ bú huì chídào.', vi: 'Trên đường thường đông nhưng tôi không bị muộn.' },
      { cn: '第一节课是汉语课。', py: 'Dì yī jié kè shì Hànyǔ kè.', vi: 'Tiết đầu tiên là tiết tiếng Trung.' },
      { cn: '老师让我们先复习昨天的生词。', py: 'Lǎoshī ràng wǒmen xiān fùxí zuótiān de shēngcí.', vi: 'Giáo viên bảo chúng tôi ôn từ mới của hôm qua trước.' },
      { cn: '然后两个人一起练习对话。', py: 'Ránhòu liǎng ge rén yìqǐ liànxí duìhuà.', vi: 'Sau đó hai người cùng luyện hội thoại.' },
      { cn: '下课以后，我觉得今天学得很好。', py: 'Xiàkè yǐhòu, wǒ juéde jīntiān xué de hěn hǎo.', vi: 'Sau giờ học, tôi thấy hôm nay mình học rất tốt.' },
    ],
  ),
  foundationReadingArticle(
    'seed_hsk2_shopping',
    'HSK 2',
    '买东西',
    'Mua đồ',
    'Bài đọc HSK 2 về mua sắm, giá cả và lời cảm ơn.',
    [
      { cn: '周末我和妈妈去商店买东西。', py: 'Zhōumò wǒ hé māma qù shāngdiàn mǎi dōngxi.', vi: 'Cuối tuần tôi và mẹ đi cửa hàng mua đồ.' },
      { cn: '妈妈想买一些水果，我想买一本汉语书。', py: 'Māma xiǎng mǎi yìxiē shuǐguǒ, wǒ xiǎng mǎi yì běn Hànyǔ shū.', vi: 'Mẹ muốn mua trái cây, còn tôi muốn mua một quyển sách tiếng Trung.' },
      { cn: '苹果很新鲜，也不太贵。', py: 'Píngguǒ hěn xīnxiān, yě bú tài guì.', vi: 'Táo rất tươi và cũng không quá đắt.' },
      { cn: '书店的店员告诉我，这本书正在打折。', py: 'Shūdiàn de diànyuán gàosu wǒ, zhè běn shū zhèngzài dǎzhé.', vi: 'Nhân viên nhà sách nói với tôi rằng quyển sách này đang giảm giá.' },
      { cn: '最后我们买了水果、牛奶和一本书。', py: 'Zuìhòu wǒmen mǎi le shuǐguǒ, niúnǎi hé yì běn shū.', vi: 'Cuối cùng chúng tôi mua trái cây, sữa và một quyển sách.' },
      { cn: '回家的时候，我对妈妈说今天买得很合适。', py: 'Huí jiā de shíhou, wǒ duì māma shuō jīntiān mǎi de hěn héshì.', vi: 'Trên đường về nhà, tôi nói với mẹ rằng hôm nay mua đồ rất hợp lý.' },
    ],
  ),
];

const CURATED_READING_LESSONS: Record<string, any>[] = [
  {
    id: 'reading_hsk1_school_day',
    level: 'HSK 1',
    source: 'VNChinese Easy News',
    title: '学校今天有中文活动',
    titleVi: 'Hôm nay trường có hoạt động tiếng Trung',
    summaryVi:
      'Bài học HSK 1 về lớp học, giáo viên và hoạt động nói tiếng Trung.',
    content:
      '今天学校有中文活动。早上八点，学生们来到教室。老师先教大家读新词。每个学生说一句中文。有的学生读得很慢。老师说，慢慢读没有关系。下课以后，大家一起唱中文歌。这个活动让学生更喜欢学习中文。',
    status: 'published',
    publishedAt: '2026-06-19T00:00:00.000Z',
    sentences: [
      { cn: '今天学校有中文活动。', py: 'Jīntiān xuéxiào yǒu Zhōngwén huódòng.', vi: 'Hôm nay trường có hoạt động tiếng Trung.' },
      { cn: '早上八点，学生们来到教室。', py: 'Zǎoshang bā diǎn, xuéshengmen lái dào jiàoshì.', vi: 'Tám giờ sáng, học sinh đến lớp học.' },
      { cn: '老师先教大家读新词。', py: 'Lǎoshī xiān jiāo dàjiā dú xīn cí.', vi: 'Giáo viên trước tiên dạy mọi người đọc từ mới.' },
      { cn: '每个学生说一句中文。', py: 'Měi ge xuésheng shuō yí jù Zhōngwén.', vi: 'Mỗi học sinh nói một câu tiếng Trung.' },
      { cn: '有的学生读得很慢。', py: 'Yǒu de xuésheng dú de hěn màn.', vi: 'Có học sinh đọc khá chậm.' },
      { cn: '老师说，慢慢读没有关系。', py: 'Lǎoshī shuō, màn man dú méiyǒu guānxi.', vi: 'Giáo viên nói đọc chậm cũng không sao.' },
      { cn: '下课以后，大家一起唱中文歌。', py: 'Xiàkè yǐhòu, dàjiā yìqǐ chàng Zhōngwén gē.', vi: 'Sau giờ học, mọi người cùng hát bài tiếng Trung.' },
      { cn: '这个活动让学生更喜欢学习中文。', py: 'Zhège huódòng ràng xuésheng gèng xǐhuan xuéxí Zhōngwén.', vi: 'Hoạt động này khiến học sinh thích học tiếng Trung hơn.' },
    ],
  },
  {
    id: 'reading_hsk2_weekend_market',
    level: 'HSK 2',
    source: 'VNChinese Life',
    title: '周末市场和公园都很热闹',
    titleVi: 'Cuối tuần chợ và công viên đều nhộn nhịp',
    summaryVi:
      'Bài học HSK 2 về sinh hoạt cuối tuần, mua sắm, thời tiết và gia đình.',
    content:
      '这个周末天气很好。很多人早上去市场买东西。水果比平时便宜一点。一位妈妈买了苹果和蔬菜。她说晚上要给家人做饭。下午，孩子们在公园跑步。老人坐在树下喝茶聊天。大家觉得这样的周末很舒服。',
    status: 'published',
    publishedAt: '2026-06-19T00:00:00.000Z',
    sentences: [
      { cn: '这个周末天气很好。', py: 'Zhège zhōumò tiānqì hěn hǎo.', vi: 'Cuối tuần này thời tiết rất đẹp.' },
      { cn: '很多人早上去市场买东西。', py: 'Hěn duō rén zǎoshang qù shìchǎng mǎi dōngxi.', vi: 'Nhiều người buổi sáng đi chợ mua đồ.' },
      { cn: '水果比平时便宜一点。', py: 'Shuǐguǒ bǐ píngshí piányi yìdiǎn.', vi: 'Trái cây rẻ hơn bình thường một chút.' },
      { cn: '一位妈妈买了苹果和蔬菜。', py: 'Yí wèi māma mǎi le píngguǒ hé shūcài.', vi: 'Một người mẹ đã mua táo và rau.' },
      { cn: '她说晚上要给家人做饭。', py: 'Tā shuō wǎnshang yào gěi jiārén zuò fàn.', vi: 'Cô ấy nói tối sẽ nấu cơm cho gia đình.' },
      { cn: '下午，孩子们在公园跑步。', py: 'Xiàwǔ, háizimen zài gōngyuán pǎobù.', vi: 'Buổi chiều, trẻ em chạy bộ trong công viên.' },
      { cn: '老人坐在树下喝茶聊天。', py: 'Lǎorén zuò zài shù xià hē chá liáotiān.', vi: 'Người lớn tuổi ngồi dưới cây uống trà nói chuyện.' },
      { cn: '大家觉得这样的周末很舒服。', py: 'Dàjiā juéde zhèyàng de zhōumò hěn shūfu.', vi: 'Mọi người thấy cuối tuần như vậy rất dễ chịu.' },
    ],
  },
  {
    id: 'reading_hsk3_library_corner',
    level: 'HSK 3',
    source: 'VNChinese Culture',
    title: '城市图书馆开设中文角',
    titleVi: 'Thư viện thành phố mở góc tiếng Trung',
    summaryVi:
      'Bài học HSK 3 về góc tiếng Trung, luyện nói và cộng đồng học tập.',
    content:
      '城市图书馆最近开设了一个中文角。这个活动每个周六下午举行。参加的人有学生，也有上班族。大家先听一段短新闻。然后老师带大家一句一句地读。志愿者会帮助学习者改正发音。很多人说，跟别人一起练习更有动力。图书馆希望以后增加更多语言活动。',
    status: 'published',
    publishedAt: '2026-06-19T00:00:00.000Z',
    sentences: [
      { cn: '城市图书馆最近开设了一个中文角。', py: 'Chéngshì túshūguǎn zuìjìn kāishè le yí ge Zhōngwén jiǎo.', vi: 'Thư viện thành phố gần đây đã mở một góc tiếng Trung.' },
      { cn: '这个活动每个周六下午举行。', py: 'Zhège huódòng měi ge zhōuliù xiàwǔ jǔxíng.', vi: 'Hoạt động này diễn ra vào chiều thứ Bảy hằng tuần.' },
      { cn: '参加的人有学生，也有上班族。', py: 'Cānjiā de rén yǒu xuésheng, yě yǒu shàngbānzú.', vi: 'Người tham gia có học sinh và cả người đi làm.' },
      { cn: '大家先听一段短新闻。', py: 'Dàjiā xiān tīng yí duàn duǎn xīnwén.', vi: 'Mọi người trước tiên nghe một đoạn tin ngắn.' },
      { cn: '然后老师带大家一句一句地读。', py: 'Ránhòu lǎoshī dài dàjiā yí jù yí jù de dú.', vi: 'Sau đó giáo viên dẫn mọi người đọc từng câu một.' },
      { cn: '志愿者会帮助学习者改正发音。', py: 'Zhìyuànzhě huì bāngzhù xuéxízhě gǎizhèng fāyīn.', vi: 'Tình nguyện viên sẽ giúp người học sửa phát âm.' },
      { cn: '很多人说，跟别人一起练习更有动力。', py: 'Hěn duō rén shuō, gēn biérén yìqǐ liànxí gèng yǒu dònglì.', vi: 'Nhiều người nói luyện cùng người khác có động lực hơn.' },
      { cn: '图书馆希望以后增加更多语言活动。', py: 'Túshūguǎn xīwàng yǐhòu zēngjiā gèng duō yǔyán huódòng.', vi: 'Thư viện hy vọng sau này tăng thêm nhiều hoạt động ngôn ngữ.' },
    ],
  },
  {
    id: 'reading_hsk4_online_learning',
    level: 'HSK 4',
    source: 'VNChinese Focus',
    title: '网络课程改变学生的学习方式',
    titleVi: 'Khóa học trực tuyến thay đổi cách học của học sinh',
    summaryVi:
      'Bài học HSK 4 về giáo dục trực tuyến, tính tự giác và hiệu quả học tập.',
    content:
      '近年来，网络课程正在改变学生获得知识的方式。学生可以根据自己的时间安排学习计划。有些课程还提供视频、练习题和自动评分。老师认为，这种方式可以帮助学生反复复习。不过，网络学习也需要更强的自律。如果没有计划，学生容易被手机和游戏影响。专家建议每天固定一个时间学习。只要坚持使用正确的方法，学习效果会越来越好。',
    status: 'published',
    publishedAt: '2026-06-19T00:00:00.000Z',
    sentences: [
      { cn: '近年来，网络课程正在改变学生获得知识的方式。', py: 'Jìnnián lái, wǎngluò kèchéng zhèngzài gǎibiàn xuésheng huòdé zhīshi de fāngshì.', vi: 'Những năm gần đây, khóa học trực tuyến đang thay đổi cách học sinh tiếp nhận kiến thức.' },
      { cn: '学生可以根据自己的时间安排学习计划。', py: 'Xuésheng kěyǐ gēnjù zìjǐ de shíjiān ānpái xuéxí jìhuà.', vi: 'Học sinh có thể sắp xếp kế hoạch học theo thời gian của mình.' },
      { cn: '有些课程还提供视频、练习题和自动评分。', py: 'Yǒuxiē kèchéng hái tígōng shìpín, liànxítí hé zìdòng píngfēn.', vi: 'Một số khóa còn cung cấp video, bài tập và chấm điểm tự động.' },
      { cn: '老师认为，这种方式可以帮助学生反复复习。', py: 'Lǎoshī rènwéi, zhè zhǒng fāngshì kěyǐ bāngzhù xuésheng fǎnfù fùxí.', vi: 'Giáo viên cho rằng cách này có thể giúp học sinh ôn tập nhiều lần.' },
      { cn: '不过，网络学习也需要更强的自律。', py: 'Búguò, wǎngluò xuéxí yě xūyào gèng qiáng de zìlǜ.', vi: 'Tuy vậy, học trực tuyến cũng cần tính tự giác cao hơn.' },
      { cn: '如果没有计划，学生容易被手机和游戏影响。', py: 'Rúguǒ méiyǒu jìhuà, xuésheng róngyì bèi shǒujī hé yóuxì yǐngxiǎng.', vi: 'Nếu không có kế hoạch, học sinh dễ bị điện thoại và trò chơi ảnh hưởng.' },
      { cn: '专家建议每天固定一个时间学习。', py: 'Zhuānjiā jiànyì měitiān gùdìng yí ge shíjiān xuéxí.', vi: 'Chuyên gia khuyên mỗi ngày cố định một thời gian để học.' },
      { cn: '只要坚持使用正确的方法，学习效果会越来越好。', py: 'Zhǐyào jiānchí shǐyòng zhèngquè de fāngfǎ, xuéxí xiàoguǒ huì yuè lái yuè hǎo.', vi: 'Chỉ cần kiên trì dùng phương pháp đúng, hiệu quả học sẽ ngày càng tốt.' },
    ],
  },
];

@Injectable()
export class ContentService {
  constructor(private readonly dataSource: DataSource) {}

  async getCatalog(publishedOnly = true): Promise<ManagedContentBundle> {
    const [
      version,
      vocabulary,
      flashcards,
      pronunciation,
      videos,
      lessons,
      readingSources,
      grammar,
      articles,
      metadata,
    ] = await Promise.all([
      this.getCurrentVersion(),
      this.getVocabulary(publishedOnly),
      this.getFlashcards(publishedOnly),
      this.getPronunciation(publishedOnly),
      this.getVideos(publishedOnly),
      this.getLessons(publishedOnly),
      this.getReadingSources(publishedOnly),
      this.getGrammar(publishedOnly),
      this.getArticles(publishedOnly),
      this.getPublishedMetadata(),
    ]);
    return {
      version: version?.version_code || 'database',
      publishedAt: version?.published_at || '',
      vocabulary,
      flashcards,
      pronunciation,
      videos,
      lessons,
      readingSources,
      grammar,
      articles,
      games: this.catalogGames(metadata, publishedOnly),
      aiSettings:
        metadata.aiSettings &&
        typeof metadata.aiSettings === 'object' &&
        !Array.isArray(metadata.aiSettings)
          ? metadata.aiSettings
          : {},
    };
  }

  async getVocabulary(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT id, simplified, pinyin, meaning_vi, hsk_level,
              COALESCE(part_of_speech, word_type, '') AS word_type,
              LOWER(COALESCE(status::text, 'PUBLISHED')) AS status
       FROM vocabularies
       WHERE meaning_vi IS NOT NULL
         AND BTRIM(meaning_vi) <> ''
         AND hsk_level BETWEEN 1 AND 6
         AND ($1::boolean = FALSE OR status = 'PUBLISHED')
       ORDER BY hsk_level, simplified
       LIMIT 5000`,
      [publishedOnly],
    );
    return rows.map((row: any) => ({
      id: row.id,
      simplified: row.simplified,
      pinyin: row.pinyin || '',
      meaningVi: row.meaning_vi || '',
      hsk: `HSK ${row.hsk_level}`,
      type: row.word_type || '',
      status: row.status,
    }));
  }

  async getFlashcards(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT t.id AS topic_pk, t.code, t.name, t.name_cn, t.hsk_level,
              t.color_hex, t.image_path AS topic_image_path,
              LOWER(t.status::text) AS topic_status,
              v.id AS vocabulary_id, v.simplified, v.pinyin, v.meaning_vi,
              tv.image_path, tv.display_order,
              COALESCE((
                SELECT JSONB_AGG(
                  JSONB_BUILD_OBJECT(
                    'cn', ve.example_cn,
                    'py', COALESCE(ve.example_pinyin, ''),
                    'vi', COALESCE(ve.example_vi, '')
                  )
                  ORDER BY ve.display_order, ve.id
                )
                FROM vocabulary_examples ve
                WHERE ve.vocabulary_id = v.id
              ), '[]'::JSONB) AS examples
       FROM topics t
       LEFT JOIN topic_vocabularies tv ON tv.topic_id = t.id
       LEFT JOIN vocabularies v ON v.id = tv.vocabulary_id
       WHERE ($1::boolean = FALSE OR t.status = 'PUBLISHED')
       ORDER BY t.display_order, t.id, tv.display_order, v.id`,
      [publishedOnly],
    );
    const topics = new Map<string, Record<string, any>>();
    for (const row of rows) {
      let topic = topics.get(row.code);
      if (!topic) {
        topic = {
          id: row.code,
          name: row.name,
          nameCn: row.name_cn || '',
          level: `HSK ${row.hsk_level}`,
          color: row.color_hex || '',
          status: row.topic_status,
          imagePath: row.topic_image_path || '',
          words: [],
        };
        topics.set(row.code, topic);
      }
      if (!row.vocabulary_id) continue;
      topic.words.push({
        id: row.vocabulary_id,
        word: row.simplified,
        pinyin: row.pinyin || '',
        meaning: row.meaning_vi || '',
        image: this.fileName(row.image_path),
        imagePath: row.image_path || '',
        examples: Array.isArray(row.examples) ? row.examples : [],
      });
    }
    return [...topics.values()];
  }

  async getVideos(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT l.id, l.code, l.title, l.title_cn, l.content_json,
              cl.level_number, LOWER(l.status::text) AS status,
              vtl.line_number, vtl.start_seconds, vtl.end_seconds,
              vtl.sentence_cn, vtl.sentence_pinyin, vtl.sentence_vi
       FROM lessons l
       JOIN course_levels cl ON cl.id = l.course_level_id
       LEFT JOIN video_transcript_lines vtl ON vtl.lesson_id = l.id
       WHERE l.lesson_type = 'VIDEO'
         AND ($1::boolean = FALSE OR l.status = 'PUBLISHED')
       ORDER BY l.display_order, l.id, vtl.line_number`,
      [publishedOnly],
    );
    const videos = new Map<number, Record<string, any>>();
    for (const row of rows) {
      let video = videos.get(row.id);
      if (!video) {
        const meta = this.objectValue(row.content_json);
        video = {
          id: meta.externalId || String(row.code).replace(/^video_/, ''),
          lessonId: row.id,
          title: row.title,
          titleCn: row.title_cn || '',
          level: `HSK ${row.level_number}`,
          youtubeId: meta.youtubeId || '',
          source: meta.source || 'YouTube',
          transcriptStatus: meta.transcriptStatus || 'timed',
          transcriptSource: meta.transcriptSource || '',
          reviewStatus: meta.reviewStatus || '',
          status: row.status,
          subtitles: [],
        };
        videos.set(row.id, video);
      }
      if (row.line_number === null) continue;
      video.subtitles.push({
        start: Number(row.start_seconds || 0),
        end: Number(row.end_seconds || 0),
        cn: row.sentence_cn,
        py: row.sentence_pinyin || '',
        vi: row.sentence_vi || '',
      });
    }
    return this.withCuratedVideoLessons([...videos.values()], publishedOnly);
  }

  private withCuratedVideoLessons(
    videos: Record<string, any>[],
    publishedOnly: boolean,
  ) {
    const byYoutubeId = new Map<string, Record<string, any>>();
    for (const video of videos) {
      const youtubeId = String(video.youtubeId || '').trim();
      if (youtubeId) byYoutubeId.set(youtubeId, video);
    }
    for (const curated of CURATED_VIDEO_LESSONS) {
      if (publishedOnly && curated.status !== 'published') continue;
      const youtubeId = String(curated.youtubeId || '').trim();
      const current = byYoutubeId.get(youtubeId);
      if (!current) {
        videos.push(curated);
        if (youtubeId) byYoutubeId.set(youtubeId, curated);
        continue;
      }
      if (this.videoQualityScore(curated) > this.videoQualityScore(current)) {
        Object.assign(current, curated);
      }
    }
    return videos;
  }

  private videoQualityScore(video: Record<string, any>) {
    const subtitles = this.arrayValue(video.subtitles);
    const starts = subtitles
      .map((line) => Number(line.start))
      .filter((value) => Number.isFinite(value));
    const ends = subtitles
      .map((line) => Number(line.end))
      .filter((value) => Number.isFinite(value));
    const span = starts.length && ends.length ? Math.max(...ends) - Math.min(...starts) : 0;
    return subtitles.length * 1000 + span;
  }

  async getPronunciation(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT ps.id, ps.external_id, ps.hsk_level, ps.topic,
              ps.sentence_cn, ps.sentence_pinyin, ps.sentence_vi,
              LOWER(ps.status::text) AS status
       FROM pronunciation_sentences ps
       WHERE ($1::boolean = FALSE OR ps.status = 'PUBLISHED')
       ORDER BY ps.hsk_level, ps.display_order, ps.id`,
      [publishedOnly],
    );
    return rows.map((row: any) => ({
      id: row.external_id || String(row.id),
      databaseId: row.id,
      level: `HSK ${row.hsk_level}`,
      topic: row.topic || 'Giao tiếp hằng ngày',
      cn: row.sentence_cn,
      py: row.sentence_pinyin || '',
      vi: row.sentence_vi || '',
      status: row.status,
    }));
  }

  async getGrammar(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT id, external_id, hsk_level, title, pattern_text, explanation,
              examples_json, note, LOWER(status::text) AS status
       FROM grammar_lessons
       WHERE ($1::boolean = FALSE OR status = 'PUBLISHED')
       ORDER BY hsk_level, id`,
      [publishedOnly],
    );
    return rows.map((row: any) => ({
      id: row.external_id || String(row.id),
      databaseId: row.id,
      level: `HSK ${row.hsk_level}`,
      title: row.title,
      pattern: row.pattern_text || row.title,
      explanation: row.explanation,
      examples: Array.isArray(row.examples_json) ? row.examples_json : [],
      note: row.note || '',
      status: row.status,
    }));
  }

  async getReadingSources(activeOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT id, name, source_type, source_url, default_hsk_level, active
       FROM article_sources
       WHERE ($1::boolean = FALSE OR active = TRUE)
       ORDER BY name`,
      [activeOnly],
    );
    return rows.map((row: any) => ({
      id: String(row.id),
      name: row.name,
      type: String(row.source_type || 'MANUAL').toLowerCase(),
      url: row.source_url || '',
      level: `HSK ${row.default_hsk_level || 4}`,
      status: row.active ? 'active' : 'archived',
    }));
  }

  async getArticles(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT a.id, a.external_id, a.title, a.title_vi, a.summary_vi,
              a.content, a.sentences_json, a.link, a.hsk_level,
              a.published_at, LOWER(a.status::text) AS status,
              COALESCE(s.name, a.source, 'VNChinese') AS source
       FROM articles a
       LEFT JOIN article_sources s ON s.id = a.source_id
       WHERE ($1::boolean = FALSE OR a.status = 'PUBLISHED')
       ORDER BY a.hsk_level, a.id`,
      [publishedOnly],
    );
    const articles = rows.map((row: any) => ({
      id: row.external_id || String(row.id),
      databaseId: row.id,
      level: this.levelLabel(row.hsk_level),
      source: row.source,
      title: row.title,
      titleVi: row.title_vi || '',
      summaryVi: row.summary_vi || '',
      content: row.content,
      sentences: Array.isArray(row.sentences_json) ? row.sentences_json : [],
      link: row.link || '',
      publishedAt: row.published_at || '',
      status: row.status,
    }));
    return this.withCuratedReadingLessons(articles, publishedOnly);
  }

  private withCuratedReadingLessons(
    articles: Record<string, any>[],
    publishedOnly: boolean,
  ) {
    const known = new Set(articles.map((article) => String(article.id || '')));
    for (const curated of [
      ...CURATED_FOUNDATION_READING_LESSONS,
      ...CURATED_READING_LESSONS,
    ]) {
      if (publishedOnly && curated.status !== 'published') continue;
      if (!known.has(curated.id)) articles.push(curated);
    }
    return articles;
  }

  async getLessons(publishedOnly = true) {
    const rows = await this.dataSource.query(
      `SELECT l.id, l.code, l.title, l.title_cn, l.lesson_type,
              l.content_json, l.display_order, LOWER(l.status::text) AS status,
              cl.level_number,
              CASE
                WHEN l.lesson_type = 'VIDEO' THEN
                  (SELECT COUNT(*) FROM video_transcript_lines x WHERE x.lesson_id = l.id)
                WHEN l.lesson_type = 'QUIZ' THEN
                  (SELECT COUNT(*) FROM quiz_questions x WHERE x.lesson_id = l.id)
                ELSE 1
              END::int AS items
       FROM lessons l
       JOIN course_levels cl ON cl.id = l.course_level_id
       WHERE ($1::boolean = FALSE OR l.status = 'PUBLISHED')
       ORDER BY cl.level_number, l.display_order, l.id`,
      [publishedOnly],
    );
    return rows.map((row: any) => {
      const metadata = this.objectValue(row.content_json);
      return {
        id: row.id,
        code: row.code,
        type: this.lessonTypeLabel(row.lesson_type),
        lessonType: row.lesson_type,
        title: row.title,
        titleCn: row.title_cn || '',
        level: `HSK ${row.level_number}`,
        items: Number(row.items || 0),
        status: row.status,
        youtubeId: metadata.youtubeId || '',
        source: metadata.source || '',
        transcriptStatus: metadata.transcriptStatus || '',
      };
    });
  }

  async getGames() {
    const metadata = await this.getPublishedMetadata();
    return this.catalogGames(metadata, true);
  }

  private catalogGames(metadata: Record<string, any>, publishedOnly: boolean) {
    if (Array.isArray(metadata.games) && metadata.games.length) {
      return metadata.games.filter(
        (game: any) =>
          !publishedOnly ||
          String(game?.status || 'published').toLowerCase() === 'published',
      );
    }
    return [
      {
        id: 'flashcard_quiz',
        title: 'Quiz nghĩa từ',
        type: 'multiple_choice',
        level: 'HSK 1-4',
        source: 'Flashcard đã published',
        scope: 'Theo chủ đề flashcard',
        generation: 'auto',
        questionCount: 10,
        status: 'published',
      },
      {
        id: 'listening_pick_word',
        title: 'Nghe và chọn từ',
        type: 'listening',
        level: 'HSK 1-4',
        source: 'Từ vựng đã published',
        scope: 'HSK 1-4',
        generation: 'auto',
        questionCount: 10,
        status: publishedOnly ? 'published' : 'draft',
      },
      {
        id: 'sentence_order',
        title: 'Xếp câu đúng',
        type: 'sentence_order',
        level: 'HSK 1-4',
        source: 'Ngữ pháp đã published',
        scope: 'Ngữ pháp',
        generation: 'auto',
        questionCount: 8,
        status: publishedOnly ? 'published' : 'draft',
      },
    ];
  }

  async getAuditLogs(limit = 50) {
    const safeLimit = Math.max(1, Math.min(200, Math.round(limit)));
    const rows = await this.dataSource.query(
      `SELECT aal.id, aal.action, aal.entity_type, aal.entity_id,
              aal.change_data, aal.created_at,
              COALESCE(u.display_name, u."displayName", u.email, 'System') AS admin_name
       FROM admin_audit_logs aal
       LEFT JOIN users u ON u.id = aal.admin_id
       ORDER BY aal.created_at DESC, aal.id DESC
       LIMIT $1`,
      [safeLimit],
    );
    return rows.map((row: any) => ({
      id: row.id,
      action: row.action,
      entityType: row.entity_type,
      entityId: row.entity_id,
      changeData: this.objectValue(row.change_data),
      adminName: row.admin_name,
      createdAt: row.created_at,
    }));
  }

  async publish(
    input: Partial<ManagedContentBundle>,
    adminId: number,
  ): Promise<Record<string, any>> {
    const runner = this.dataSource.createQueryRunner();
    await runner.connect();
    await runner.startTransaction();
    try {
      const counts = {
        vocabulary: await this.publishVocabulary(
          runner,
          this.arrayValue(input.vocabulary),
        ),
        flashcards: await this.publishFlashcards(
          runner,
          this.arrayValue(input.flashcards),
        ),
        pronunciation: await this.publishPronunciation(
          runner,
          this.arrayValue(input.pronunciation),
        ),
        videos: await this.publishVideos(runner, this.arrayValue(input.videos)),
        lessons: await this.publishLessons(
          runner,
          this.arrayValue(input.lessons),
        ),
        readingSources: await this.publishReadingSources(
          runner,
          this.arrayValue(input.readingSources),
        ),
        grammar: await this.publishGrammar(
          runner,
          this.arrayValue(input.grammar),
        ),
        articles: await this.publishArticles(
          runner,
          this.arrayValue(input.articles),
        ),
        games: this.arrayValue(input.games).length,
      };
      const version =
        String(input.version || '').trim() ||
        `admin-${new Date().toISOString().replace(/[:.]/g, '-')}`;
      const published = await runner.query(
        `INSERT INTO content_versions
          (version_code, content_type, description, item_count, status,
           published_by, published_at, metadata)
         VALUES ($1, 'CATALOG', $2, $3, 'PUBLISHED', $4, NOW(), $5::jsonb)
         ON CONFLICT (version_code) DO UPDATE SET
           description = EXCLUDED.description,
           item_count = EXCLUDED.item_count,
           status = 'PUBLISHED',
           published_by = EXCLUDED.published_by,
           published_at = NOW(),
           metadata = EXCLUDED.metadata
         RETURNING version_code, published_at`,
        [
          version,
          'Xuất bản từ VNChinese Admin vào PostgreSQL.',
          Object.values(counts).reduce((sum, value) => sum + value, 0),
          adminId,
          JSON.stringify({
            games: this.arrayValue(input.games),
            aiSettings: this.objectValue(input.aiSettings),
          }),
        ],
      );
      await this.audit(runner, adminId, 'PUBLISH', 'content_catalog', version, {
        counts,
      });
      await runner.commitTransaction();
      return {
        ok: true,
        version: published[0].version_code,
        publishedAt: published[0].published_at,
        counts,
      };
    } catch (error) {
      await runner.rollbackTransaction();
      throw error;
    } finally {
      await runner.release();
    }
  }

  private async publishVocabulary(
    runner: QueryRunner,
    items: Record<string, any>[],
  ) {
    let count = 0;
    for (const item of items) {
      const simplified = String(item.simplified || item.word || '').trim();
      if (!simplified) continue;
      const level = this.levelNumber(item.hsk || item.level || item.hskLevel);
      const status = this.contentStatus(item.status);
      await runner.query(
        `INSERT INTO vocabularies
          (simplified, pinyin, meaning_vi, hsk_level, word_type,
           part_of_speech, status, updated_at)
         VALUES ($1, $2, $3, $4, $5, $5, $6::content_status, NOW())
         ON CONFLICT (simplified) DO UPDATE SET
           pinyin = EXCLUDED.pinyin,
           meaning_vi = EXCLUDED.meaning_vi,
           hsk_level = EXCLUDED.hsk_level,
           word_type = EXCLUDED.word_type,
           part_of_speech = EXCLUDED.part_of_speech,
           status = EXCLUDED.status,
           updated_at = NOW()`,
        [
          simplified,
          String(item.pinyin || '').trim() || null,
          String(item.meaningVi || item.meaning || '').trim() || null,
          level,
          String(item.type || item.wordType || '').trim() || null,
          status,
        ],
      );
      count += 1;
    }
    return count;
  }

  private async publishFlashcards(
    runner: QueryRunner,
    topics: Record<string, any>[],
  ) {
    let count = 0;
    for (const [topicOrder, topic] of topics.entries()) {
      const code = String(topic.id || topic.code || '').trim();
      if (!code) continue;
      const level = this.levelNumber(topic.level || topic.hsk);
      const status = this.contentStatus(topic.status);
      const topicRows = await runner.query(
        `INSERT INTO topics
          (code, name, name_cn, hsk_level, color_hex, image_path,
           display_order, status, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8::content_status, NOW())
         ON CONFLICT (code) DO UPDATE SET
           name = EXCLUDED.name,
           name_cn = EXCLUDED.name_cn,
           hsk_level = EXCLUDED.hsk_level,
           color_hex = EXCLUDED.color_hex,
           image_path = EXCLUDED.image_path,
           display_order = EXCLUDED.display_order,
           status = EXCLUDED.status,
           updated_at = NOW()
         RETURNING id`,
        [
          code,
          String(topic.name || code).trim(),
          String(topic.nameCn || '').trim() || null,
          level,
          String(topic.color || '').trim() || null,
          String(topic.imagePath || '').trim() || null,
          topicOrder,
          status,
        ],
      );
      const topicId = Number(topicRows[0].id);
      await runner.query('DELETE FROM topic_vocabularies WHERE topic_id = $1', [
        topicId,
      ]);
      for (const [wordOrder, word] of this.arrayValue(topic.words).entries()) {
        const simplified = String(word.word || word.simplified || '').trim();
        if (!simplified) continue;
        const vocabRows = await runner.query(
          `INSERT INTO vocabularies
            (simplified, pinyin, meaning_vi, hsk_level, status, updated_at)
           VALUES ($1, $2, $3, $4, 'PUBLISHED', NOW())
           ON CONFLICT (simplified) DO UPDATE SET
             pinyin = COALESCE(NULLIF(EXCLUDED.pinyin, ''), vocabularies.pinyin),
             meaning_vi = COALESCE(NULLIF(EXCLUDED.meaning_vi, ''), vocabularies.meaning_vi),
             hsk_level = EXCLUDED.hsk_level,
             updated_at = NOW()
           RETURNING id`,
          [
            simplified,
            String(word.pinyin || '').trim(),
            String(word.meaning || word.meaningVi || '').trim(),
            level,
          ],
        );
        const vocabularyId = Number(vocabRows[0].id);
        const imagePath =
          String(word.imagePath || '').trim() ||
          (word.image
            ? `assets/images/flashcards/${code}/${this.fileName(word.image)}`
            : null);
        await runner.query(
          `INSERT INTO topic_vocabularies
            (topic_id, vocabulary_id, image_path, display_order)
           VALUES ($1, $2, $3, $4)`,
          [topicId, vocabularyId, imagePath, wordOrder],
        );
        for (const [exampleOrder, example] of this.arrayValue(
          word.examples,
        ).entries()) {
          const cn = String(example.cn || '').trim();
          if (!cn) continue;
          await runner.query(
            `INSERT INTO vocabulary_examples
              (vocabulary_id, example_cn, example_pinyin, example_vi,
               source, display_order)
             VALUES ($1, $2, $3, $4, 'admin', $5)
             ON CONFLICT (vocabulary_id, example_cn) DO UPDATE SET
               example_pinyin = EXCLUDED.example_pinyin,
               example_vi = EXCLUDED.example_vi,
               source = 'admin',
               display_order = EXCLUDED.display_order`,
            [
              vocabularyId,
              cn,
              String(example.py || '').trim() || null,
              String(example.vi || '').trim() || null,
              exampleOrder,
            ],
          );
        }
      }
      count += 1;
    }
    return count;
  }

  private async publishPronunciation(
    runner: QueryRunner,
    items: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, item] of items.entries()) {
      const cn = String(item.cn || item.sentenceCn || '').trim();
      if (!cn) continue;
      const level = this.levelNumber(item.level);
      const lessonId = await this.ensureLesson(
        runner,
        `pronunciation_hsk${level}`,
        level,
        `Phát âm HSK ${level}`,
        'PRONUNCIATION',
      );
      const externalId =
        String(item.id || '').trim() ||
        `admin_pron_${level}_${Buffer.from(cn).toString('base64url').slice(0, 16)}`;
      await runner.query(
        `INSERT INTO pronunciation_sentences
          (lesson_id, external_id, hsk_level, topic, sentence_cn,
           sentence_pinyin, sentence_vi, difficulty, display_order, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $3, $8, $9::content_status)
         ON CONFLICT (external_id) DO UPDATE SET
           lesson_id = EXCLUDED.lesson_id,
           hsk_level = EXCLUDED.hsk_level,
           topic = EXCLUDED.topic,
           sentence_cn = EXCLUDED.sentence_cn,
           sentence_pinyin = EXCLUDED.sentence_pinyin,
           sentence_vi = EXCLUDED.sentence_vi,
           display_order = EXCLUDED.display_order,
           status = EXCLUDED.status`,
        [
          lessonId,
          externalId,
          level,
          String(item.topic || 'Giao tiếp hằng ngày').trim(),
          cn,
          String(item.py || item.pinyin || '').trim() || null,
          String(item.vi || item.meaningVi || '').trim() || null,
          order,
          this.contentStatus(item.status),
        ],
      );
      count += 1;
    }
    return count;
  }

  private async publishVideos(
    runner: QueryRunner,
    videos: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, video] of videos.entries()) {
      const externalId = String(video.id || '').trim();
      const youtubeId = String(video.youtubeId || '').trim();
      const title = String(video.title || '').trim();
      if (!externalId || !title) continue;
      const level = this.levelNumber(video.level);
      const lessonId = await this.ensureLesson(
        runner,
        `video_${externalId}`,
        level,
        title,
        'VIDEO',
        {
          externalId,
          youtubeId,
          source: video.source || 'YouTube',
          transcriptStatus: video.transcriptStatus || 'untimed',
          transcriptSource: video.transcriptSource || 'admin',
          reviewStatus: video.reviewStatus || '',
        },
        order,
        video.titleCn,
        video.status,
      );
      await runner.query(
        'DELETE FROM video_transcript_lines WHERE lesson_id = $1',
        [lessonId],
      );
      for (const [lineNumber, line] of this.arrayValue(
        video.subtitles || video.transcript,
      ).entries()) {
        const cn = String(line.cn || '').trim();
        if (!cn) continue;
        await runner.query(
          `INSERT INTO video_transcript_lines
            (lesson_id, line_number, start_seconds, end_seconds,
             sentence_cn, sentence_pinyin, sentence_vi)
           VALUES ($1, $2, $3, $4, $5, $6, $7)`,
          [
            lessonId,
            lineNumber,
            Number(line.start || 0),
            Number(line.end || 0),
            cn,
            String(line.py || '').trim() || null,
            String(line.vi || '').trim() || null,
          ],
        );
      }
      count += 1;
    }
    return count;
  }

  private async publishLessons(
    runner: QueryRunner,
    lessons: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, lesson] of lessons.entries()) {
      const title = String(lesson.title || '').trim();
      if (!title || this.lessonType(lesson) === 'VIDEO') continue;
      const type = this.lessonType(lesson);
      const level = this.levelNumber(lesson.level);
      const code =
        String(lesson.code || '').trim() ||
        `admin_${type.toLowerCase()}_${String(lesson.id || order)}`;
      await this.ensureLesson(
        runner,
        code,
        level,
        title,
        type,
        { adminItems: Number(lesson.items || 0) },
        order,
        lesson.titleCn,
        lesson.status,
      );
      count += 1;
    }
    return count;
  }

  private async publishReadingSources(
    runner: QueryRunner,
    sources: Record<string, any>[],
  ) {
    let count = 0;
    for (const source of sources) {
      const name = String(source.name || '').trim();
      if (!name) continue;
      await runner.query(
        `INSERT INTO article_sources
          (name, source_type, source_url, default_hsk_level, active, updated_at)
         VALUES ($1, $2::article_source_type, $3, $4, $5, NOW())
         ON CONFLICT (name) DO UPDATE SET
           source_type = EXCLUDED.source_type,
           source_url = EXCLUDED.source_url,
           default_hsk_level = EXCLUDED.default_hsk_level,
           active = EXCLUDED.active,
           updated_at = NOW()`,
        [
          name,
          this.sourceType(source.type),
          String(source.url || '').trim() || null,
          this.levelNumber(source.level),
          String(source.status || 'active').toLowerCase() !== 'archived',
        ],
      );
      count += 1;
    }
    return count;
  }

  private async publishGrammar(
    runner: QueryRunner,
    items: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, item] of items.entries()) {
      const title = String(item.title || '').trim();
      const explanation = String(item.explanation || '').trim();
      if (!title || !explanation) continue;
      const level = this.levelNumber(item.level || item.hskLevel);
      const externalId =
        String(item.id || item.externalId || '').trim() ||
        `admin_grammar_${level}_${order}`;
      const lessonId = await this.ensureLesson(
        runner,
        `grammar_${externalId}`,
        level,
        title,
        'GRAMMAR',
        {},
        order,
        '',
        item.status,
      );
      await runner.query(
        `INSERT INTO grammar_lessons
          (lesson_id, external_id, hsk_level, title, pattern_text,
           explanation, examples_json, note, status, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7::jsonb, $8,
                 $9::content_status, NOW())
         ON CONFLICT (external_id) DO UPDATE SET
           lesson_id = EXCLUDED.lesson_id,
           hsk_level = EXCLUDED.hsk_level,
           title = EXCLUDED.title,
           pattern_text = EXCLUDED.pattern_text,
           explanation = EXCLUDED.explanation,
           examples_json = EXCLUDED.examples_json,
           note = EXCLUDED.note,
           status = EXCLUDED.status,
           updated_at = NOW()`,
        [
          lessonId,
          externalId,
          level,
          title,
          String(item.pattern || item.patternText || title).trim(),
          explanation,
          JSON.stringify(this.arrayValue(item.examples)),
          String(item.note || '').trim() || null,
          this.contentStatus(item.status),
        ],
      );
      count += 1;
    }
    return count;
  }

  private async publishArticles(
    runner: QueryRunner,
    items: Record<string, any>[],
  ) {
    let count = 0;
    for (const [order, item] of items.entries()) {
      const title = String(item.title || '').trim();
      const content = String(item.content || '').trim();
      if (!title || !content) continue;
      const sourceName = String(item.source || 'VNChinese').trim();
      const sourceRows = await runner.query(
        `INSERT INTO article_sources
          (name, source_type, default_hsk_level, active, updated_at)
         VALUES ($1, 'MANUAL', $2, TRUE, NOW())
         ON CONFLICT (name) DO UPDATE SET updated_at = NOW()
         RETURNING id`,
        [sourceName, this.levelNumber(item.level)],
      );
      const externalId =
        String(item.id || item.externalId || '').trim() ||
        `admin_article_${Date.now()}_${order}`;
      await runner.query(
        `INSERT INTO articles
          (external_id, source_id, source, title, title_vi, summary_vi,
           content, sentences_json, link, hsk_level, published_at,
           status, updated_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8::jsonb, $9, $10,
                 COALESCE($11::timestamptz, NOW()), $12::content_status, NOW())
         ON CONFLICT (external_id) DO UPDATE SET
           source_id = EXCLUDED.source_id,
           source = EXCLUDED.source,
           title = EXCLUDED.title,
           title_vi = EXCLUDED.title_vi,
           summary_vi = EXCLUDED.summary_vi,
           content = EXCLUDED.content,
           sentences_json = EXCLUDED.sentences_json,
           link = EXCLUDED.link,
           hsk_level = EXCLUDED.hsk_level,
           published_at = EXCLUDED.published_at,
           status = EXCLUDED.status,
           updated_at = NOW()`,
        [
          externalId,
          Number(sourceRows[0].id),
          sourceName,
          title,
          String(item.titleVi || '').trim() || null,
          String(item.summaryVi || '').trim() || null,
          content,
          JSON.stringify(this.arrayValue(item.sentences)),
          String(item.link || '').trim() || null,
          this.levelNumber(item.level),
          String(item.publishedAt || '').trim() || null,
          this.contentStatus(item.status),
        ],
      );
      count += 1;
    }
    return count;
  }

  private async ensureLesson(
    runner: QueryRunner,
    code: string,
    level: number,
    title: string,
    type: string,
    metadata: Record<string, any> = {},
    order = 0,
    titleCn?: string,
    status?: string,
  ): Promise<number> {
    const levels = await runner.query(
      'SELECT id FROM course_levels WHERE level_number = $1 LIMIT 1',
      [level],
    );
    if (!levels.length) {
      throw new Error(`Không tìm thấy cấp độ HSK ${level}.`);
    }
    const levelId = Number(levels[0].id);
    const rows = await runner.query(
      `INSERT INTO lessons
        (course_level_id, "courseLevelId", code, title, title_cn,
         lesson_type, content_json, display_order, order_index, status,
         updated_at)
       VALUES ($1::bigint, $1::integer, $2, $3, $4, $5::lesson_type,
               $6::jsonb, $7, $7, $8::content_status, NOW())
       ON CONFLICT (code) DO UPDATE SET
         course_level_id = EXCLUDED.course_level_id,
         "courseLevelId" = EXCLUDED."courseLevelId",
         title = EXCLUDED.title,
         title_cn = EXCLUDED.title_cn,
         lesson_type = EXCLUDED.lesson_type,
         content_json = EXCLUDED.content_json,
         display_order = EXCLUDED.display_order,
         order_index = EXCLUDED.order_index,
         status = EXCLUDED.status,
         updated_at = NOW()
       RETURNING id`,
      [
        levelId,
        code,
        title,
        String(titleCn || '').trim() || null,
        type,
        JSON.stringify(metadata),
        order,
        this.contentStatus(status),
      ],
    );
    return Number(rows[0].id);
  }

  private async getCurrentVersion() {
    const rows = await this.dataSource.query(
      `SELECT version_code, published_at
       FROM content_versions
       WHERE status = 'PUBLISHED'
       ORDER BY published_at DESC NULLS LAST, id DESC
       LIMIT 1`,
    );
    return rows[0] || null;
  }

  private async getPublishedMetadata(): Promise<Record<string, any>> {
    const rows = await this.dataSource.query(
      `SELECT metadata
       FROM content_versions
       WHERE status = 'PUBLISHED'
       ORDER BY published_at DESC NULLS LAST, id DESC
       LIMIT 1`,
    );
    return this.objectValue(rows[0]?.metadata);
  }

  private async audit(
    runner: QueryRunner,
    adminId: number,
    action: string,
    entityType: string,
    entityId: string,
    changeData: Record<string, unknown>,
  ) {
    await runner.query(
      `INSERT INTO admin_audit_logs
        (admin_id, action, entity_type, entity_id, change_data)
       VALUES ($1, $2, $3, $4, $5::jsonb)`,
      [adminId, action, entityType, entityId, JSON.stringify(changeData)],
    );
  }

  private arrayValue(value: unknown): Record<string, any>[] {
    return Array.isArray(value)
      ? value.filter(
          (item): item is Record<string, any> =>
            Boolean(item) && typeof item === 'object' && !Array.isArray(item),
        )
      : [];
  }

  private objectValue(value: unknown): Record<string, any> {
    return value && typeof value === 'object' && !Array.isArray(value)
      ? (value as Record<string, any>)
      : {};
  }

  private levelNumber(value: unknown) {
    const match = String(value || '').match(/[1-6]/);
    return match ? Number(match[0]) : 1;
  }

  private levelLabel(value: unknown) {
    const raw = String(value || '').trim();
    return /^HSK\s*[1-6]$/i.test(raw)
      ? `HSK ${this.levelNumber(raw)}`
      : `HSK ${this.levelNumber(value)}`;
  }

  private contentStatus(value: unknown) {
    const status = String(value || 'published')
      .trim()
      .toUpperCase();
    return ['DRAFT', 'REVIEW', 'PUBLISHED', 'ARCHIVED'].includes(status)
      ? status
      : 'PUBLISHED';
  }

  private sourceType(value: unknown) {
    const type = String(value || 'MANUAL')
      .trim()
      .toUpperCase();
    return ['MANUAL', 'RSS', 'API'].includes(type) ? type : 'MANUAL';
  }

  private lessonType(lesson: Record<string, any>) {
    const raw = String(lesson.lessonType || lesson.type || '')
      .trim()
      .toUpperCase();
    const map: Record<string, string> = {
      'NGỮ PHÁP': 'GRAMMAR',
      'ĐỌC HIỂU': 'READING',
      'PHÁT ÂM': 'PRONUNCIATION',
      'TỪ VỰNG': 'VOCABULARY',
      VIDEO: 'VIDEO',
      QUIZ: 'QUIZ',
    };
    const type = map[raw] || raw;
    return [
      'VOCABULARY',
      'GRAMMAR',
      'READING',
      'PRONUNCIATION',
      'VIDEO',
      'QUIZ',
    ].includes(type)
      ? type
      : 'VOCABULARY';
  }

  private lessonTypeLabel(value: string) {
    return (
      {
        VOCABULARY: 'Từ vựng',
        GRAMMAR: 'Ngữ pháp',
        READING: 'Đọc hiểu',
        PRONUNCIATION: 'Phát âm',
        VIDEO: 'Video',
        QUIZ: 'Quiz',
      }[value] || value
    );
  }

  private fileName(value: unknown) {
    return (
      String(value || '')
        .split(/[\\/]/)
        .pop() || ''
    );
  }
}
