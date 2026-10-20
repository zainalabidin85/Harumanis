# Sticker Size Reference Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `POST /detect/{tree_id}` can size a mango against a printed magenta circle or square sticker. The sticker always wins over the hand, and the hand is the fallback when the farmer has no sticker.

**Architecture:** Server-side only. A new `services/marker_service.py` finds the sticker with plain OpenCV: colour mask, contour, shape check, white-ring check. A pure `choose_reference()` in `services/size_estimator.py` picks sticker or hand. `routers/detection.py` runs MediaPipe only when no usable sticker is found. Which reference was used is stored in a new `detections.reference_type` column, so the planned statistical analysis can compare sticker and hand scans.

**Tech Stack:** FastAPI, OpenCV 4.13 (already installed), SQLAlchemy, Alembic, pytest (`mlharum-api/.venv`).

**Spec:** No separate spec doc. The design was agreed with Zainal in conversation on 2026-10-20 and is summarised here:
- Circle or square sticker, each with one fixed standard size (default 1.5 cm, reduced from 2.5 cm at Zainal's request), magenta on a 3 mm white ring.
- If both sticker and hand are in the photo, the sticker wins. The hand is the fallback when there is no sticker.
- The sticker may be pasted on the fruit skin. The small curvature and depth error is accepted and will be measured statistically against calipers. No geometric correction.
- No app changes in this patch. Old APKs must keep working.

## Global Constraints

- Work on branch `feat/sticker-reference` off `main`. Run tests with `cd mlharum-api && .venv/bin/python -m pytest`.
- Do not change the sizing formula: `size_cm = (mango_px / reference_px) × reference_cm`, where `mango_px = min(bbox_w, bbox_h)`.
- Sticker sizes and colour thresholds live in `config.py` settings (overridable from `.env`):
  `sticker_circle_diameter_cm = 1.5`, `sticker_square_side_cm = 1.5`, `sticker_hue_min = 140`, `sticker_hue_max = 175`, `sticker_sat_min = 120`, `sticker_val_min = 90`, `sticker_min_area_px = 400`. Hue uses the OpenCV 0–180 scale; print magenta `#E6007E` ≈ hue 163.
- Sticker plausibility: usable only when `0.1 ≤ sticker_px / mango_px ≤ 2.0`. A 1.5 cm sticker gives 0.375 on a 4 cm fruit and 0.125 on a 12 cm fruit.
- The `reference_type` values are exactly `"circle"`, `"square"` and `"hand"`. NULL means a scan from before this patch (hand).
- The 422 detail when no reference is found must still contain the substring `No hand`. Old APKs match on it (`mlharum-app/lib/screens/camera_screen.dart:53`) to show their localized message. New text: `"No hand or reference sticker detected. Hold your open palm or the sticker beside the fruit."`
- The response schema only gains an optional field. `hand_index_x/y` and `hand_pinky_x/y` are `None` on sticker scans.
- Alembic: new revision `025`, revising `024`, in `migrations/versions/` only.
- No app (`mlharum-app`) changes, version bump or deploy in this plan. The follow-up `cameraErrorNoHand` wording change waits for the next batched app release.

## Review Focus

1. **A magenta object that isn't a sticker** (flower, shirt, bag print) must not replace a good hand measurement. It needs the white ring, a circle or square shape, and a plausible size. Tests: `test_magenta_without_white_ring_ignored`, `test_irregular_magenta_shape_ignored`, `test_implausible_sticker_falls_back_to_hand`.
2. **Sticker partly covered** by a finger or leaf. Its outline is no longer a clean circle or square, so it must be ignored rather than measured short. Test: `test_partly_covered_circle_ignored`.
3. **Tilted or rotated sticker.** Measure the long axis of the ellipse, or the long side of the rotated rectangle. Tests: `test_tilted_circle_uses_long_axis`, `test_rotated_square_uses_long_side`.
4. **Old APK error mapping.** The no-reference 422 must still contain `No hand`. Test: `test_no_reference_detail_keeps_old_app_match`.
5. **Several stickers or a tiny distant sticker.** Pick the largest valid one, and ignore anything under the minimum area. Tests: `test_largest_sticker_wins`, `test_tiny_sticker_ignored`.

---

## File Structure

| File | Change | Responsibility |
|---|---|---|
| `mlharum-api/config.py` | modify | Sticker size and colour settings |
| `mlharum-api/services/marker_service.py` | create | `detect_sticker(image_bgr) -> StickerMarker \| None` |
| `mlharum-api/tests/test_marker_service.py` | create | Synthetic-image tests for the detector |
| `mlharum-api/services/size_estimator.py` | modify | `Reference`, `sticker_fits_mango()`, `choose_reference()` |
| `mlharum-api/tests/test_reference_choice.py` | create | Tests for sticker-wins and fallback logic |
| `mlharum-api/migrations/versions/025_add_reference_type.py` | create | `detections.reference_type` |
| `mlharum-api/models/fruit.py` | modify | `Detection.reference_type` column |
| `mlharum-api/schemas.py` | modify | `DetectionResponse.reference_type` |
| `mlharum-api/routers/detection.py` | modify | Sticker first, hand fallback, store the type |
| `mlharum-model/stickers/reference_stickers.svg` | create | Printable test sheet at true scale |
| `CLAUDE.md` | modify | Document the reference fallback |

---

### Task 1: Sticker detector

**Files:**
- Modify: `mlharum-api/config.py` (add the settings listed in Global Constraints after `bagging_max_size_cm`)
- Create: `mlharum-api/services/marker_service.py`
- Test: `mlharum-api/tests/test_marker_service.py`

**Interfaces:**
- Produces:
  ```python
  @dataclass
  class StickerMarker:
      kind: str          # "circle" | "square"
      width_px: float    # ellipse major axis, or long side of the min-area rect
      span_cm: float     # settings.sticker_circle_diameter_cm or sticker_square_side_cm
      center_x: float
      center_y: float

  def detect_sticker(image_bgr: np.ndarray) -> StickerMarker | None
  ```

- [ ] **Step 1: Write the failing tests** in `tests/test_marker_service.py`. Helpers: a 720×1280 leaf-green canvas `(40, 120, 40)` BGR, magenta `(126, 0, 230)` BGR, and a white ring 8 px wide drawn under each shape.

```python
def test_finds_circle_sticker():           # diameter 100 px
    m = detect_sticker(img)
    assert m.kind == "circle" and m.width_px == pytest.approx(100, abs=3) and m.span_cm == 1.5

def test_finds_square_sticker():           # side 100 px, axis-aligned
    assert (m.kind, round(m.width_px)) ...  # kind "square", width 100 ± 3, span_cm 1.5

def test_tilted_circle_uses_long_axis():   # cv2.ellipse axes (50, 30) → width 100 ± 3, kind "circle"
def test_rotated_square_uses_long_side():  # side 100 rotated 30° (cv2.boxPoints) → width 100 ± 4, kind "square"
def test_magenta_without_white_ring_ignored():   # circle d=100, no ring → None
def test_irregular_magenta_shape_ignored():      # triangle with ring → None
def test_partly_covered_circle_ignored():        # circle d=100 with ring, a green 60×120 rect over its right third → None
def test_tiny_sticker_ignored():                 # circle d=15 with ring → None
def test_largest_sticker_wins():                 # circle d=60 and square side 120 → kind "square"
def test_plain_image_returns_none():             # blank canvas → None
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `.venv/bin/python -m pytest tests/test_marker_service.py -v`
Expected: FAIL with `ModuleNotFoundError: No module named 'services.marker_service'`

- [ ] **Step 3: Implement `detect_sticker`.** Unlike `mediapipe_service`, there is no model to load, so it's a plain function.

Approach:
1. HSV mask using the colour settings, then `MORPH_OPEN` and `MORPH_CLOSE` with a 5×5 kernel. Run `findContours` with `RETR_EXTERNAL`.
2. Skip contours with area below `sticker_min_area_px`.
3. Check for a white ring: in the band 3–8 px outside the contour (dilated mask minus mask), at least 60% of pixels must have S < 60 and V > 170.
4. Classify the shape:
   - **Square:** `approxPolyDP(c, 0.04 × perimeter)` has 4 vertices and is convex, contour area / `minAreaRect` area ≥ 0.85, and the rect's aspect ratio ≤ 1.6. Width = long side.
   - **Circle:** at least 5 points, solidity (area / hull area) ≥ 0.95, contour area / ellipse area (π·a·b/4) within 0.92–1.08, and axis ratio ≤ 2.0. Width = major axis.
   - Anything else is rejected.
5. Return the valid candidate with the largest `width_px`, or `None`.

The thresholds above are starting values. Tune them only until every test passes, and record any change in the plan's PR description.

- [ ] **Step 4: Run the tests to verify they pass**

Run: `.venv/bin/python -m pytest tests/test_marker_service.py -v`
Expected: 10 passed

- [ ] **Step 5: Commit**

```bash
git add config.py services/marker_service.py tests/test_marker_service.py
git commit -m "feat(api): detect circle/square reference sticker"
```

---

### Task 2: Reference choice (sticker wins, hand fallback)

**Files:**
- Modify: `mlharum-api/services/size_estimator.py`
- Test: `mlharum-api/tests/test_reference_choice.py`

**Interfaces:**
- Consumes: `StickerMarker` (Task 1); `HandMarker` from `services/mediapipe_service.py` (`knuckle_width_px`); existing `resolve_hand_span_cm(user_span_cm)`.
- Produces:
  ```python
  @dataclass
  class Reference:
      width_px: float
      span_cm: float
      type: str  # "circle" | "square" | "hand"

  def sticker_fits_mango(sticker_px: float, mango_px: float) -> bool
  def choose_reference(sticker: StickerMarker | None, hand: HandMarker | None,
                       mango_px: float, user_span_cm) -> Reference | None
  ```
  `estimate_size()` is unchanged. The router calls `estimate_size(best, ref.width_px, ref.span_cm)`.

- [ ] **Step 1: Write the failing tests**

```python
def test_sticker_fits_mango_bounds():
    assert sticker_fits_mango(60, 160)         # 0.375: 1.5 cm sticker on a 4 cm fruit
    assert sticker_fits_mango(100, 50)         # 2.0 boundary
    assert sticker_fits_mango(100, 1000)       # 0.1 boundary
    assert not sticker_fits_mango(100, 40)     # 2.5: sticker far bigger than the fruit
    assert not sticker_fits_mango(100, 1200)   # 0.083: sticker far smaller

def test_sticker_wins_over_hand():
    ref = choose_reference(_sticker("circle", 60), _hand(80), 160, 6.5)
    assert (ref.type, ref.width_px, ref.span_cm) == ("circle", 60, 1.5)

def test_hand_used_when_no_sticker():
    assert choose_reference(None, _hand(80), 160, 6.5) == Reference(80, 6.5, "hand")

def test_hand_without_saved_span_uses_default():
    assert choose_reference(None, _hand(80), 160, None).span_cm == pytest.approx(DEFAULT_HAND_SPAN_CM)

def test_implausible_sticker_falls_back_to_hand():
    assert choose_reference(_sticker("square", 100), _hand(80), 40, 6.5).type == "hand"

def test_neither_returns_none():
    assert choose_reference(None, None, 160, 6.5) is None
    assert choose_reference(_sticker("circle", 100), None, 40, 6.5) is None

def test_size_from_sticker():
    # 160 px mango / 60 px sticker × 1.5 cm = 4.0 cm (Bagging lower bound)
    assert estimate_size(_mango(160, 200), 60, 1.5) == pytest.approx(4.0)
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `.venv/bin/python -m pytest tests/test_reference_choice.py -v`
Expected: FAIL with `ImportError: cannot import name 'choose_reference'`

- [ ] **Step 3: Implement** `Reference`, `sticker_fits_mango` (bounds 0.1–2.0, inclusive) and `choose_reference` in `size_estimator.py`.

- [ ] **Step 4: Run the full suite to verify it passes**

Run: `.venv/bin/python -m pytest -q`
Expected: all pass (106 existing + 10 + 7)

- [ ] **Step 5: Commit**

```bash
git add services/size_estimator.py tests/test_reference_choice.py
git commit -m "feat(api): choose sticker over hand as size reference"
```

---

### Task 3: Wire into /detect and record the reference type

**Files:**
- Create: `mlharum-api/migrations/versions/025_add_reference_type.py`
- Modify: `mlharum-api/models/fruit.py:14` (add `reference_type = Column(String(10), nullable=True)` after `reference_span_cm`)
- Modify: `mlharum-api/schemas.py:216` (add `reference_type: Optional[str] = None` to `DetectionResponse`)
- Modify: `mlharum-api/services/size_estimator.py` (add `NO_REFERENCE_DETAIL`)
- Modify: `mlharum-api/routers/detection.py:55-76` and the three `DetectionResponse(...)` returns
- Test: `mlharum-api/tests/test_reference_choice.py`

**Interfaces:**
- Consumes: `detect_sticker` (Task 1), `choose_reference`, `sticker_fits_mango` and `Reference` (Task 2).
- Produces: `NO_REFERENCE_DETAIL: str` constant in `services/size_estimator.py`, imported by the router. It lives there rather than in the router because `routers/detection.py` cannot be imported in the test venv (`slowapi` is not installed).

- [ ] **Step 1: Write the failing tests** (append to `tests/test_reference_choice.py`)

```python
def test_no_reference_detail_keeps_old_app_match():
    from services.size_estimator import NO_REFERENCE_DETAIL
    assert "No hand" in NO_REFERENCE_DETAIL

def test_detection_response_reference_type_optional():
    r = DetectionResponse(tree_id=1, tree_number="T01", detection_date=datetime.now(),
                          mango_count=1, ready_for_bagging=True, message="x")
    assert r.reference_type is None and r.hand_index_x is None
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `.venv/bin/python -m pytest tests/test_reference_choice.py -v`
Expected: FAIL with `ImportError: cannot import name 'NO_REFERENCE_DETAIL'`

- [ ] **Step 3: Write migration `025`** (`revision = "025"`, `down_revision = "024"`). It adds `detections.reference_type` `sa.String(10)`, nullable, with a comment that NULL means a hand scan from before 025. Downgrade drops the column. Follow the style of `023_add_knuckle_span.py`.

- [ ] **Step 4: Change the router flow**

```
sticker = run_in_executor(detect_sticker)
mango_detections = run_in_executor(detect_mangoes)  → existing "No mango" 422 if empty
best = highest confidence; mango_px = min(best.bbox_w, best.bbox_h)
hand = None if (sticker and sticker_fits_mango(sticker.width_px, mango_px))
       else run_in_executor(detect_knuckle_width)
ref = choose_reference(sticker, hand, mango_px, current_user.knuckle_span_cm)
ref is None → 422 NO_REFERENCE_DETAIL
size_cm = estimate_size(best, ref.width_px, ref.span_cm)
Detection(knuckle_width_px=ref.width_px, reference_span_cm=ref.span_cm, reference_type=ref.type)
```

- Keep the `knuckle_width_px` column name. It now holds the reference width in px; add a one-line comment saying so in `models/fruit.py`.
- Every `DetectionResponse` gets `reference_type=ref.type`. The `hand_*` fields come from `hand` when `ref.type == "hand"`, otherwise `None`. Build them once in a small dict, not three times.

- [ ] **Step 5: Run the full suite**

Run: `.venv/bin/python -m pytest -q`
Expected: all pass

- [ ] **Step 6: Smoke-test the endpoint locally with a real photo.** Start uvicorn against the dev DB after `alembic upgrade head`. POST three images to `/detect/{tree_id}`: one with the sheet from Task 4 next to a printed mango photo, one with a hand only, and one with neither.
Expected: `reference_type` is `"circle"` or `"square"`, then `"hand"`, then a 422 whose detail starts with `No hand or reference sticker`.

- [ ] **Step 7: Commit**

```bash
git add migrations/versions/025_add_reference_type.py models/fruit.py schemas.py services/size_estimator.py routers/detection.py tests/test_reference_choice.py
git commit -m "feat(api): sticker reference in /detect with hand fallback"
```

---

### Task 4: Printable sticker sheet and docs

**Files:**
- Create: `mlharum-model/stickers/reference_stickers.svg`
- Modify: `CLAUDE.md` (AI Detection Pipeline section and Key Configuration table)

- [ ] **Step 1: Create the SVG.** Use an A4 page in mm units (`width="210mm" height="297mm" viewBox="0 0 210 297"`). Draw a grid of 15 mm circles and 15 mm squares in `#E6007E`, each with a 3 mm white ring and a 0.3 mm grey cutting outline. Add a 50 mm black scale bar and the text "Print at 100% / Actual size. Check: bar = 50 mm".

- [ ] **Step 2: Verify the scale.** Run `.venv/bin/python -c` to rasterise the SVG at 10 px/mm (via `cairosvg` if installed; otherwise open it in a browser and measure). Run `detect_sticker` on a crop around one circle and one square.
Expected: `width_px ≈ 150` (15 mm × 10 px/mm) ± 4, with the correct `kind`.

- [ ] **Step 3: Update `CLAUDE.md`.** In the pipeline diagram, replace the MediaPipe line with: sticker (`services/marker_service.py`) first, MediaPipe hand fallback. Add a paragraph: "Sticker wins over hand; `detections.reference_type` records circle/square/hand; on-skin curvature/depth error is accepted pending caliper statistics." Add `STICKER_*` to the config table.

- [ ] **Step 4: Commit**

```bash
git add ../mlharum-model/stickers/reference_stickers.svg ../CLAUDE.md
git commit -m "docs: printable reference sticker sheet and sticker fallback notes"
```

---

## After this plan (not part of execution)

- **Deploy the API** following the API deploy mechanics memory: pull on the server, `alembic upgrade head`, restart uvicorn. This needs Zainal's go-ahead. Old APKs gain sticker support immediately.
- **Field photos:** print the sheet, then for about 20 fruits take caliper, sticker-on-skin and hand photos. Compare by `reference_type` for the statistical analysis, and tune the colour thresholds against real sunlight if needed.
- **Next batched app release:** reword `cameraErrorNoHand` in both `.arb` files to mention the sticker, and optionally show `reference_type` on the result screen.
