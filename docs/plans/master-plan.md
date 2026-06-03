# MASTER PLAN - CHINESE APP

Updated: `2026-05-22`

## Phase P0 - Foundation Stability

- [x] Add environment-based API config for mobile.
- [x] Remove hard-coded localhost from core mobile flows.
- [x] Add dictionary local fallback when API/network fails.
- [x] Reduce dictionary latency by local/template examples (no Tatoeba dependency in main flow).
- [x] Add fast meaning/pinyin fallback extraction from local dataset.
- [x] Add runtime mojibake/font-corruption sanitizer for dictionary and grammar payloads.
- [ ] Route AI grammar check through backend proxy.
- [ ] Replace hard-coded dashboard/profile metrics with real progress data.

## Phase P1 - Professional Learning Experience

- [x] Improve topic lesson cards (progress, clearer mode labels).
- [x] Keep full lesson flow: topic -> flashcard -> quiz -> completion.
- [x] Add richer vocabulary illustration fallback (word image/icon visual card).
- [x] Upgrade grammar fallback dataset to full HSK1-HSK4 UTF-8 clean lessons.
- [ ] Add mixed quiz modes (listening + meaning + sentence order).
- [ ] Add per-topic result summary and review suggestions.
- [ ] Save topic history and replay mode.

## Phase P2 - Data and Sync

- [x] Define data-source ingestion strategy in product constitution.
- [ ] Backend cache for reading RSS articles.
- [ ] Cloud sync for notebook/progress/goals.
- [ ] AI check history and pronunciation history persistence.
- [ ] Build reading topic selector + source/topic/HSK filters for reading module.
