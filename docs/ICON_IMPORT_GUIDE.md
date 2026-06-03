# ICON IMPORT GUIDE (Flaticon/Open Sources)

## 1) Recommended sources

1. Flaticon (check attribution / premium rules)
2. OpenMoji (CC BY-SA 4.0)
3. Twemoji (CC BY 4.0)

## 2) Asset folders

1. Topic cards: `apps/mobile/assets/images/topics/`
2. Word cards: `apps/mobile/assets/images/words/`
3. Lesson scene images: `apps/mobile/assets/images/flashcards/`

## 3) Naming convention

1. topic: `hsk1_food.png`, `hsk2_transport.png`
2. word: `word_买.png` or semantic name `buy.png`
3. flashcard scene: `scene_food_01.png`

## 4) Attribution metadata (required)

Create/update `docs/ASSET_ATTRIBUTION.md` with:
1. file name
2. source URL
3. author
4. license
5. attribution text

## 5) Quick checklist before commit

1. PNG/SVG is optimized.
2. File name mapped in code.
3. Asset declared in `pubspec.yaml`.
4. Attribution doc updated.
