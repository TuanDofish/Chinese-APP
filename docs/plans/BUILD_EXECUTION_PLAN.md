# BUILD EXECUTION PLAN - MVP LESSON EXPERIENCE

Version: `v1.0`  
Date: `2026-05-22`

## Goal

Build an MVP that is not fully complete but runs smooth for real users:

1. Learning topic list with clear progress.
2. Flashcard lesson flow with image + audio + meaning.
3. Mini-game quiz after each topic.
4. Reliable fallback when API/network is down.

## Scope for current build

### In scope

1. Standardize mobile API config (`--dart-define`).
2. Remove hard-coded localhost in key mobile flows.
3. Improve lesson list UI to feel closer to modern language apps.
4. Keep end-to-end flow: `Topic -> Flashcard -> Quiz -> Progress`.
5. Update product constitution with data source ingestion for DB.

### Out of scope (next sprint)

1. Full backend auth and cloud sync.
2. Production-grade pronunciation scoring model.
3. Full admin CMS screens.
4. Full analytics dashboard.

## Delivery phases

## Phase 1 (done in this iteration)

1. Add `app_config.dart` with:
- `API_BASE_URL`
- `GEMINI_API_KEY`
2. Wire dictionary + grammar helper to config base URL.
3. Add offline/local fallback for dictionary lookup.
4. Improve topic card UX with:
- progress-aware sorting
- visual fallback image style
- clear `Flashcard + Quiz` tags
5. Update constitution doc with database content sources and ingestion strategy.

## Phase 2 (next)

1. Add 2-3 quiz modes in one lesson:
- listen and choose hanzi
- choose meaning
- arrange simple sentence
2. Add lesson completion summary:
- score
- mistakes
- suggested review words
3. Save per-topic history and replay.

## Phase 3 (next)

1. Move AI grammar check to backend proxy.
2. Cache RSS to backend `articles` for stability.
3. Sync user progress and notebook across devices.

## Acceptance criteria for MVP smoothness

1. No critical button in lesson flow is dead.
2. Topic cards open lesson within expected local speed.
3. User can finish at least one full topic with no crash.
4. If API fails, app still shows useful local content.

## Test checklist (manual)

1. Open app -> `Tu vung` -> `Bai hoc`.
2. Switch HSK tabs and confirm topic list updates.
3. Open one topic, navigate several flashcards.
4. Use audio buttons normal/slow.
5. Complete quiz to the end and see completion feedback.
6. Disable backend and confirm dictionary still has fallback behavior.
7. Reopen app and verify learned/favorite states are retained.
