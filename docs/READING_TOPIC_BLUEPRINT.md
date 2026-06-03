# READING BLUEPRINT - Topic First + News + YouTube

Updated: 2026-05-22

## 1) Product Goal

Build tab `Doc` theo huong user chu dong:
1. Chon nguon noi dung.
2. Chon chu de.
3. Chon level HSK.
4. Doc + nghe + shadowing + luu tu.

## 2) Information Architecture

### 2.1 Entry tabs

1. `Chu de`
2. `Bao`
3. `Video`
4. `Da luu`

### 2.2 Filter bar

1. `HSK`: HSK1, HSK2, HSK3, HSK4+
2. `Chu de`: Gia dinh, Truong hoc, Du lich, Cong nghe, Van hoa, Suc khoe...
3. `Do dai`: ngan / vua / dai

## 3) Data Source Strategy

### 3.1 Topic stories (curated)

Nguon:
1. Dataset noi bo (`assets/data/reading_hsk.json`) + DB `articles`.
2. Curate bo stories ngan theo HSK (uu tien quality).

### 3.2 Chinese news

Nguon RSS khuyen nghi:
1. BBC Chinese
2. VOA Chinese
3. RFI Chinese

Production flow:
1. Backend cron fetch RSS -> normalize -> cache DB.
2. Mobile chi goi backend `/reading/news` (khong parse RSS truc tiep tren client).

### 3.3 Video learning (Little Fox style)

Flow hop le:
1. Luu `youtube_video_id`, `title`, `level`, `topic`.
2. Phat qua YouTube embed/player API.
3. Transcript:
- uu tien transcript duoc phep su dung
- neu khong co transcript duoc phep thi chi hien meta + link/embedded playback

## 4) UX Spec (Baolingo-like)

## 4.1 Reader screen

1. Header: title, source, level, estimated reading time.
2. Toggle: Hanzi / Pinyin / Dich.
3. Sentence cards:
- tap de nghe TTS
- tap tu de tra nghia nhanh
- save word vao so tay
4. Shadowing panel:
- nghe cau
- ghi am
- cham do tuong dong

## 4.2 Video screen

1. Player embed.
2. Transcript side panel:
- segment theo cau
- click cau de nhay timestamp
- hien hanzi / pinyin / viet
3. Learning tools:
- save sentence
- save word
- repeat current sentence

## 5) API Design Draft

### 5.1 Reading

1. `GET /reading/topics`
2. `GET /reading/articles?topic=&level=&source=&page=`
3. `GET /reading/articles/:id`
4. `POST /reading/progress`

### 5.2 Video

1. `GET /video/topics`
2. `GET /video/items?topic=&level=`
3. `GET /video/items/:id/transcript`
4. `POST /video/shadow-score`

## 6) DB Tables (minimum)

1. `reading_topics`
2. `reading_articles`
3. `reading_sentences`
4. `video_lessons`
5. `video_transcripts`
6. `reading_progress`

## 7) Compliance Checklist

1. Kiem tra license va terms cua tung nguon.
2. Khong scrape noi dung co ban quyen trai phep.
3. Luu metadata `source`, `license`, `author`, `retrieved_at`.
4. Co co che takedown/noi dung vi pham.

## 8) Sprint Plan

### Sprint 1

1. Them topic filter UI trong tab Doc.
2. Chuyen fetch RSS sang backend cache endpoint.
3. Hoan thien article reader sentence-level.

### Sprint 2

1. Them video lesson list + embed player.
2. Them transcript sentence panel.
3. Them save word/save sentence.

### Sprint 3

1. Shadowing score per sentence.
2. Recommendation bai tiep theo theo topic + level.
3. Analytics retention theo topic.
