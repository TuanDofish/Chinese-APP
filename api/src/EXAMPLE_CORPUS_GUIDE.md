# Example Corpus Guide (HSK 1-4, local-first)

This guide explains how to build a large sentence corpus so runtime dictionary lookup is fast and does not depend on Tatoeba latency.

## 1) Target format

Use JSONL (one JSON per line):

```json
{"word":"朋友","hskLevel":1,"cn":"他是我的好朋友。","py":"Tā shì wǒ de hǎo péngyou.","vi":"Anh ấy là bạn tốt của tôi.","source":"HSK Textbook","quality":"curated","tags":["hsk1"]}
```

Required: `word`, `cn`  
Optional: `hskLevel`, `py`, `vi`, `source`, `quality`, `tags`

## 2) Import command

```bash
npm run seed:examples -- src/data/example_corpus_hsk14.jsonl
```

Optional level range:

```bash
HSK_MIN_LEVEL=1 HSK_MAX_LEVEL=6 npm run seed:examples -- src/data/example_corpus_hsk16.jsonl
```

If no file is provided, script defaults to:

`src/data/example_corpus_hsk14.jsonl`

## 3) Recommended data sources (for large scale)

- Your existing HSK textbook / exam prep sentences (highest quality, curated).
- Tatoeba bulk exports (offline download + nightly import), not runtime calls.
- Open-licensed subtitle/news corpora that allow redistribution.
- Internal teacher-reviewed sentence bank.

## 4) Suggested pipeline for "huge corpus"

1. Collect raw sentences to a staging table/file.
2. Normalize punctuation, remove duplicates.
3. Keep only rows where sentence contains target HSK word.
4. Attach `hskLevel` from your `vocabularies` table.
5. Score quality:
   - curated > seeded > community
6. Export JSONL and import via `seed:examples`.

## 5) Runtime policy

- UI lookup should call: `GET /dictionary/examples-local`
- External APIs are fallback only when local DB has zero rows.
- Cache the API result (Redis/in-memory) for hot words.
