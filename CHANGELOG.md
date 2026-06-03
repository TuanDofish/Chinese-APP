# CHANGELOG

## 2026-05-22

### Added
1. New product governance doc updates in `docs/APP_PROFESSIONAL_CONSTITUTION.md`:
- Added mandatory data-source ingestion section for vocabulary, grammar, and reading.
- Added MVP smoothness plan and phased build strategy.
2. New execution plan file: `docs/plans/BUILD_EXECUTION_PLAN.md`.
3. New mobile runtime config: `apps/mobile/lib/app_config.dart`.

### Changed
1. Removed hard-coded backend host from mobile key flows; now uses `AppConfig.apiBaseUrl`.
2. Dictionary lookup now has local bundled fallback to improve resilience when API is unavailable.
3. Vocabulary lesson topic list UX improved:
- optional progress-based sort toggle
- richer fallback visuals for missing topic images
- clearer lesson mode tags (`Flashcard`, `Quiz`).
4. Example sentence flow optimized for speed:
- mobile now prefers fast local/template examples before external fallback
- backend `/dictionary/examples` now returns local corpus first, then curated template
- avoids repeated slow Tatoeba-style fallback in main learning flow.
5. Improved vocab detail rendering:
- better pinyin/meaning fallback extraction from local data
- reduced timeout for translate/example fetch requests
- richer lesson illustration card for common country words and icon fallback visuals.
6. Added mojibake/font corruption recovery layer:
- mobile `TextSanitizer` now repairs likely UTF-8/latin1 broken text before rendering
- dictionary autocomplete/detail now sanitize and normalize pinyin/meaning fields.
7. Backend dictionary/grammar responses now sanitize text before returning API payload:
- fixes common broken strings in `search`, `autocomplete`, `detail`, `examples`, and grammar lessons.
8. Replaced `assets/data/grammar_hsk.json` with clean UTF-8 curated HSK1-HSK4 grammar resources.
9. Rebuilt `PinyinUtils` tone conversion using unicode-safe code points to avoid corrupted tone marks.

### Added
4. New backend utility `api/src/utils/text-normalizer.ts` for text cleanup and mojibake recovery.
5. Extended product constitution with section 13:
- image source strategy (Flaticon/Open licenses)
- reading topic architecture
- YouTube/news integration notes and compliance checklist.
6. New icon import guideline: `docs/ICON_IMPORT_GUIDE.md`.
7. New reading architecture blueprint: `docs/READING_TOPIC_BLUEPRINT.md`.

### Notes
1. Formatting/analyze commands timed out in this environment, so verification was done by code inspection.
