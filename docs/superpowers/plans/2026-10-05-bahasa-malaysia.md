# Bahasa Malaysia Language Option Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Farmers can use the Ai-Harumanis app in Bahasa Malaysia (the default) or English, including scan result messages and harvest reminder notifications.

**Architecture:** The Flutter app (`mlharum-app`) uses Flutter's built-in `gen-l10n` with two ARB files and a `LocaleController` that persists the choice on the phone and syncs it to the user's account. The API (`mlharum-api`) gets a small pure-Python message catalog; scan messages follow the request's `Accept-Language` header and harvest reminders follow a new `users.language` column.

**Tech Stack:** Flutter 3.44 (`flutter_localizations`, `intl`, `flutter_secure_storage`, `dio`), FastAPI, SQLAlchemy, Alembic, pytest.

**Spec:** `docs/superpowers/specs/2026-10-05-bahasa-malaysia-design.md` — read it first; the glossary at its end is the source of truth for Malay terms.

## Global Constraints

- Supported languages are exactly `ms` and `en`. App default with nothing saved: `ms`.
- English wording stays exactly as it is today, in the app and in API responses.
- API with no `Accept-Language` header, or a user with `language IS NULL`, means English. The 1.9.0 APK must behave exactly as today against the new API.
- The `POST /detect/{tree_id}` response schema does not change.
- API error messages (`HTTPException` details) stay English. Announcements are not translated.
- Only `mlharum-app` and `mlharum-api` change. Do not touch `harumanis-app`, `mlharum-collector`, `mlharum-admin`.
- Language sync to the account must never block or fail login or startup: wrap in try/catch and ignore failure.
- No new Flutter storage dependency: the choice is stored with `flutter_secure_storage` under key `language`.
- Alembic migrations go in `mlharum-api/migrations/versions/` only. New revision is `022`, revising `021`.
- Malay terms come from the spec glossary: Awal, Pembalutan, Pra-tuai, Tuai, Ladang, Pokok, Buah, Imbas, Musim, Hasil, Pengumuman, Pesanan, Disahkan / Belum Disahkan, Profil, Log masuk / Log keluar, Kepejalan, Kematangan isi, Warna pusingan.
- No string concatenation of translated fragments: use ARB placeholders and plurals.
- Release version: app `1.10.0+17`; `/version` `ai_harumanis.latest` becomes `1.10.0`, `min_required` stays `1.6.1`.
- Do not deploy to the production server or upload an APK without Zainal's explicit go-ahead (Task 10).

## Review Focus

1. **Unusual `Accept-Language` values** (`en-US,ms;q=0.5`, `*`, surrounding spaces, empty): the scan must still succeed and answer in English unless the header starts with `ms`. Tested in Task 1.
2. **A user row whose `language` is NULL or an unexpected value**: the harvest reminder is still sent, in English. Tested in Task 1.
3. **Saving the language fails** (phone offline, storage error): the app still switches language immediately and does not show an error. Tested in Task 4.
4. **A corrupt saved language on the phone** (empty string, `fr`): the app starts in Malay instead of crashing or showing a blank locale. Tested in Task 4.
5. **`PATCH /auth/me` with an unsupported language, or with only `language`**: unsupported is rejected with a validation error; a language-only update changes no other profile field. Tested in Task 2.

## File Structure

API (`mlharum-api/`):

| File | Change | Responsibility |
|---|---|---|
| `services/i18n.py` | create | Message catalog, `resolve_language`, `t`, `harvest_reminder_text`. Pure Python. |
| `tests/test_i18n.py` | create | Tests for the catalog. |
| `tests/test_language_schema.py` | create | Tests for the `language` field on `UserProfileUpdate`. |
| `pytest.ini` | create | Makes `services`/`schemas` importable from tests. |
| `requirements.txt` | modify | Add `pytest`. |
| `migrations/versions/022_add_language_to_users.py` | create | `users.language` column. |
| `models/user.py` | modify | `language` column. |
| `schemas.py` | modify | `language` on `UserProfileUpdate` and `UserProfileResponse`. |
| `routers/auth.py` | modify | `GET /auth/me` returns `language`. |
| `routers/detection.py` | modify | Scan messages via catalog and header. |
| `services/harvest_reminder_job.py` | modify | Reminder text per owner language. |
| `main.py` | modify | `/version` bump (Task 10). |

App (`mlharum-app/`):

| File | Change | Responsibility |
|---|---|---|
| `lib/services/locale_service.dart` | create | `LocaleController`: current language, persistence, account sync. |
| `lib/services/api_service.dart` | modify | `Accept-Language` header, `updateLanguage`. |
| `lib/services/auth_service.dart` | modify | `logout` keeps the language key. |
| `l10n.yaml` | create | gen-l10n config. |
| `lib/l10n/app_en.arb`, `lib/l10n/app_ms.arb` | create | All UI strings. |
| `lib/l10n/l10n.dart` | create | `context.l10n` extension, `stageName` helper. |
| `lib/widgets/language_toggle.dart` | create | `BM | EN` toggle for the login screen. |
| `lib/main.dart` | modify | Load locale, wire `MaterialApp`, startup sync. |
| `lib/models/fruit.dart` | modify | Remove hardcoded `stageName` getters. |
| `lib/screens/*.dart`, `lib/widgets/*.dart` | modify | Replace hardcoded strings. |
| `test/arb_parity_test.dart`, `test/locale_controller_test.dart`, `test/language_toggle_test.dart` | create | App tests. |
| `pubspec.yaml` | modify | `flutter_localizations`, `intl: any`, `generate: true`, version. |

---

### Task 1: API message catalog

**Files:**
- Create: `mlharum-api/services/i18n.py`
- Create: `mlharum-api/tests/test_i18n.py`
- Create: `mlharum-api/pytest.ini`
- Modify: `mlharum-api/requirements.txt`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `resolve_language(value: Optional[str]) -> str` returns `"ms"` or `"en"`.
  - `t(key: str, lang: str, **params) -> str`.
  - `harvest_reminder_text(lang: Optional[str], labels: list[str]) -> tuple[str, str]` returns `(title, body)`.
  - Catalog keys: `detect.early` (`size`, `min_size`), `detect.late` (`size`, `label`, `days`), `detect.ready` (`size`, `days`), `reminder.title`, `reminder.one` (`label`), `reminder.many` (`count`).

- [ ] **Step 1: Set up pytest**

Append to `mlharum-api/requirements.txt`:

```
pytest==8.2.0
```

Create `mlharum-api/pytest.ini`:

```ini
[pytest]
pythonpath = .
testpaths = tests
```

Install it in the Python environment used for the API on this machine:

```bash
cd mlharum-api && python3 -m pip install pytest==8.2.0
```

If pip refuses with "externally-managed-environment", use `python3 -m pip install --user --break-system-packages pytest==8.2.0`.

- [ ] **Step 2: Write the failing tests**

Create `mlharum-api/tests/test_i18n.py`:

```python
import pytest

from services.i18n import _CATALOG, harvest_reminder_text, resolve_language, t


@pytest.mark.parametrize(
    "value, expected",
    [
        (None, "en"),
        ("", "en"),
        ("en", "en"),
        ("ms", "ms"),
        ("ms-MY", "ms"),
        ("MS", "ms"),
        ("ms,en;q=0.8", "ms"),
        (" ms-MY ", "ms"),
        ("fr", "en"),
        ("*", "en"),
        ("en-US,ms;q=0.5", "en"),
    ],
)
def test_resolve_language(value, expected):
    assert resolve_language(value) == expected


def test_every_key_has_both_languages():
    for key, templates in _CATALOG.items():
        assert set(templates) == {"en", "ms"}, key


PARAMS = {
    "detect.early": {"size": "3.2", "min_size": 4.0},
    "detect.late": {"size": "5.1", "label": "T01-003", "days": 49},
    "detect.ready": {"size": "4.2", "days": 56},
    "reminder.title": {},
    "reminder.one": {"label": "T01-003"},
    "reminder.many": {"count": 3},
}


def test_params_cover_every_key():
    assert set(PARAMS) == set(_CATALOG)


@pytest.mark.parametrize("key", sorted(PARAMS))
@pytest.mark.parametrize("lang", ["en", "ms"])
def test_every_key_formats_in_both_languages(key, lang):
    text = t(key, lang, **PARAMS[key])
    assert text
    assert "{" not in text and "}" not in text


def test_english_wording_is_unchanged():
    assert t("detect.early", "en", size="3.2", min_size=4.0) == (
        "This mango is 3.2 cm — Early stage, not yet recorded (natural fruit drop "
        "risk is high at this size). Scan again once it reaches 4.0 cm to begin bagging."
    )
    assert t("detect.late", "en", size="5.1", label="T01-003", days=49) == (
        "This mango (5.1 cm) has passed the bagging window and been recorded as "
        "T01-003 — Pre-harvest / late-bagging. Estimated harvest in 49 days."
    )
    assert t("detect.ready", "en", size="4.2", days=56) == (
        "Ready for bagging — 4.2 cm. Estimated harvest in 56 days."
    )


def test_malay_ready_message():
    assert t("detect.ready", "ms", size="4.2", days=56) == (
        "Sedia untuk dibalut — 4.2 cm. Anggaran tuai dalam 56 hari."
    )


def test_unknown_language_falls_back_to_english():
    assert t("reminder.title", "fr") == t("reminder.title", "en")


def test_reminder_one_fruit():
    assert harvest_reminder_text("en", ["T01-003"]) == (
        "🥭 Harvest reminder",
        "T01-003 is ready for harvest soon.",
    )
    assert harvest_reminder_text("ms", ["T01-003"]) == (
        "🥭 Peringatan tuai",
        "T01-003 hampir sedia untuk dituai.",
    )


def test_reminder_many_fruits():
    labels = ["T01-001", "T01-002", "T02-001"]
    assert harvest_reminder_text("en", labels)[1] == (
        "3 of your Harumanis fruits are ready for harvest soon."
    )
    assert harvest_reminder_text("ms", labels)[1] == (
        "3 buah Harumanis anda hampir sedia untuk dituai."
    )


@pytest.mark.parametrize("lang", [None, "", "fr"])
def test_reminder_for_missing_or_unknown_language_is_english(lang):
    assert harvest_reminder_text(lang, ["T01-003"]) == harvest_reminder_text("en", ["T01-003"])
```

- [ ] **Step 3: Run the tests to verify they fail**

Run: `cd mlharum-api && python3 -m pytest tests/test_i18n.py -q`
Expected: collection error, `ModuleNotFoundError: No module named 'services.i18n'`.

- [ ] **Step 4: Write the implementation**

Create `mlharum-api/services/i18n.py`:

```python
"""Farmer-facing server text in English and Malay.

Only text the farmer reads in the app or in a push notification lives here.
HTTPException details stay English and are not routed through this module.
"""
from typing import Optional

DEFAULT_LANGUAGE = "en"

_CATALOG: dict[str, dict[str, str]] = {
    "detect.early": {
        "en": "This mango is {size} cm — Early stage, not yet recorded (natural fruit drop risk is high at this size). Scan again once it reaches {min_size} cm to begin bagging.",
        "ms": "Mangga ini berukuran {size} cm — peringkat Awal, belum direkodkan (risiko buah gugur secara semula jadi tinggi pada saiz ini). Imbas semula apabila mencapai {min_size} cm untuk mula membalut.",
    },
    "detect.late": {
        "en": "This mango ({size} cm) has passed the bagging window and been recorded as {label} — Pre-harvest / late-bagging. Estimated harvest in {days} days.",
        "ms": "Mangga ini ({size} cm) telah melepasi tempoh pembalutan dan direkodkan sebagai {label} — Pra-tuai / balut lewat. Anggaran tuai dalam {days} hari.",
    },
    "detect.ready": {
        "en": "Ready for bagging — {size} cm. Estimated harvest in {days} days.",
        "ms": "Sedia untuk dibalut — {size} cm. Anggaran tuai dalam {days} hari.",
    },
    "reminder.title": {
        "en": "🥭 Harvest reminder",
        "ms": "🥭 Peringatan tuai",
    },
    "reminder.one": {
        "en": "{label} is ready for harvest soon.",
        "ms": "{label} hampir sedia untuk dituai.",
    },
    "reminder.many": {
        "en": "{count} of your Harumanis fruits are ready for harvest soon.",
        "ms": "{count} buah Harumanis anda hampir sedia untuk dituai.",
    },
}


def resolve_language(value: Optional[str]) -> str:
    """Map an Accept-Language header or stored user language to 'ms' or 'en'."""
    if value and value.strip().lower().startswith("ms"):
        return "ms"
    return DEFAULT_LANGUAGE


def t(key: str, lang: str, **params) -> str:
    templates = _CATALOG[key]
    return templates.get(lang, templates[DEFAULT_LANGUAGE]).format(**params)


def harvest_reminder_text(lang: Optional[str], labels: list[str]) -> tuple[str, str]:
    """Title and body of the harvest reminder push for one owner's due fruits."""
    lang = resolve_language(lang)
    title = t("reminder.title", lang)
    if len(labels) == 1:
        body = t("reminder.one", lang, label=labels[0])
    else:
        body = t("reminder.many", lang, count=len(labels))
    return title, body
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `cd mlharum-api && python3 -m pytest tests/test_i18n.py -q`
Expected: all pass, 0 failures.

- [ ] **Step 6: Commit**

```bash
git add mlharum-api/services/i18n.py mlharum-api/tests/test_i18n.py mlharum-api/pytest.ini mlharum-api/requirements.txt
git commit -m "feat(api): add English/Malay message catalog"
```

---

### Task 2: `users.language` column and profile field

**Files:**
- Create: `mlharum-api/migrations/versions/022_add_language_to_users.py`
- Create: `mlharum-api/tests/test_language_schema.py`
- Modify: `mlharum-api/models/user.py` (after the `is_verified` column, line 24)
- Modify: `mlharum-api/schemas.py` (`UserProfileResponse` line 52, `UserProfileUpdate` line 69)
- Modify: `mlharum-api/routers/auth.py` (`get_me`, lines 65–80)

**Interfaces:**
- Consumes: nothing.
- Produces: `User.language` (`str | None`); `PATCH /auth/me` accepts `{"language": "ms" | "en"}`; `GET /auth/me` returns `language`.

- [ ] **Step 1: Write the failing tests**

Create `mlharum-api/tests/test_language_schema.py`:

```python
import pytest
from pydantic import ValidationError

from schemas import UserProfileResponse, UserProfileUpdate


@pytest.mark.parametrize("lang", ["en", "ms"])
def test_update_accepts_supported_languages(lang):
    assert UserProfileUpdate(language=lang).language == lang


@pytest.mark.parametrize("lang", ["fr", "", "MS", "ms-MY"])
def test_update_rejects_unsupported_languages(lang):
    with pytest.raises(ValidationError):
        UserProfileUpdate(language=lang)


def test_language_only_update_touches_no_other_field():
    # routers/auth.py applies model_dump(exclude_none=True) with setattr
    assert UserProfileUpdate(language="ms").model_dump(exclude_none=True) == {"language": "ms"}


def test_update_without_language_does_not_clear_it():
    assert "language" not in UserProfileUpdate(name="Ali").model_dump(exclude_none=True)


def test_response_language_defaults_to_none():
    r = UserProfileResponse(id=1, name="Ali", email="ali@example.com", phone=None, whatsapp=None, role="farmer")
    assert r.language is None
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd mlharum-api && python3 -m pytest tests/test_language_schema.py -q`
Expected: failures; `UserProfileUpdate(language="fr")` does not raise and `r.language` raises `AttributeError`.

- [ ] **Step 3: Add the schema fields**

In `mlharum-api/schemas.py`, make sure `Literal` is imported from `typing` (add it to the existing `from typing import ...` line).

In `UserProfileResponse`, add after `bank_account_name`:

```python
    language: Optional[str] = None
```

In `UserProfileUpdate`, add after `bank_account_name`:

```python
    language: Optional[Literal["en", "ms"]] = None
```

- [ ] **Step 4: Add the model column**

In `mlharum-api/models/user.py`, add after the `is_verified` line:

```python
    language            = Column(String(5),   nullable=True)
```

- [ ] **Step 5: Return the language from `GET /auth/me`**

In `mlharum-api/routers/auth.py`, in `get_me`, add to the `UserProfileResponse(...)` call after `bank_account_name=current_user.bank_account_name,`:

```python
        language=current_user.language,
```

`update_me` needs no change: it already applies every non-null field of the payload with `setattr`.

- [ ] **Step 6: Write the migration**

Create `mlharum-api/migrations/versions/022_add_language_to_users.py`:

```python
"""add language to users

Revision ID: 022
Revises: 021
Create Date: 2026-10-05
"""
from alembic import op
import sqlalchemy as sa

revision = "022"
down_revision = "021"
branch_labels = None
depends_on = None


def upgrade() -> None:
    # NULL = never reported by the app; treated as English everywhere.
    op.add_column("users", sa.Column("language", sa.String(length=5), nullable=True))


def downgrade() -> None:
    op.drop_column("users", "language")
```

- [ ] **Step 7: Verify**

Run: `cd mlharum-api && python3 -m pytest -q`
Expected: all tests pass.

Run: `cd mlharum-api && alembic heads`
Expected: `022 (head)` and nothing else. If a local database is configured in `.env`, also run `alembic upgrade head` and expect `Running upgrade 021 -> 022`.

- [ ] **Step 8: Commit**

```bash
git add mlharum-api/migrations/versions/022_add_language_to_users.py mlharum-api/models/user.py mlharum-api/schemas.py mlharum-api/routers/auth.py mlharum-api/tests/test_language_schema.py
git commit -m "feat(api): store preferred language on users"
```

---

### Task 3: Scan messages and harvest reminder use the catalog

**Files:**
- Modify: `mlharum-api/routers/detection.py` (imports lines 1–18, signature lines 31–37, messages at lines 86, 139, 153)
- Modify: `mlharum-api/services/harvest_reminder_job.py` (imports, loop at lines 44–57)

**Interfaces:**
- Consumes: `resolve_language`, `t`, `harvest_reminder_text` from Task 1; `User.language` from Task 2.
- Produces: no new interface. `POST /detect/{tree_id}` honours `Accept-Language`; the reminder job sends per-owner language.

The logic under test already has tests in Task 1 (`t` and `harvest_reminder_text`). The two files changed here load ML models and the database, so this task is verified by the Task 1 suite, an import check, and the manual checks in Task 10.

- [ ] **Step 1: Update the detection router imports and signature**

In `mlharum-api/routers/detection.py`, change the FastAPI import line to add `Header`, and add the two new imports:

```python
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Request, Header
```

```python
from services.i18n import resolve_language, t
```

Add a parameter to `run_detection` after `current_user`:

```python
    current_user: User = Depends(get_current_user),
    accept_language: Optional[str] = Header(default=None),
):
```

FastAPI maps `accept_language` to the `Accept-Language` header automatically.

- [ ] **Step 2: Replace the three messages**

Directly after the lines that set `min_size` and `max_size`, add:

```python
    lang = resolve_language(accept_language)
    size_text = f"{size_cm:.1f}"
```

Replace the early-stage message (currently an f-string starting `This mango is {size_cm:.1f} cm — Early stage`):

```python
            message=t("detect.early", lang, size=size_text, min_size=min_size),
```

Replace the late-bagging message (currently starting `This mango ({size_cm:.1f} cm) has passed the bagging window`):

```python
            message=t("detect.late", lang, size=size_text, label=label, days=days_to_harvest),
```

Replace the ready message (currently starting `Ready for bagging —`):

```python
        message=t("detect.ready", lang, size=size_text, days=days_to_harvest),
```

- [ ] **Step 3: Update the harvest reminder job**

In `mlharum-api/services/harvest_reminder_job.py`, add imports:

```python
from models.user import User
from services.i18n import harvest_reminder_text
```

Replace the whole `for owner_id, fruits in by_owner.items():` loop with:

```python
    languages = dict(
        db.query(User.id, User.language).filter(User.id.in_(list(by_owner.keys()))).all()
    )

    for owner_id, fruits in by_owner.items():
        title, body = harvest_reminder_text(
            languages.get(owner_id), [f.label for f in fruits]
        )
        push_service.send_to_user(
            db,
            owner_id,
            title=title,
            body=body,
            data={"type": "harvest_reminder"},
        )
```

- [ ] **Step 4: Verify**

Run: `cd mlharum-api && python3 -m pytest -q`
Expected: all pass.

Run: `cd mlharum-api && python3 -m py_compile routers/detection.py services/harvest_reminder_job.py && echo OK`
Expected: `OK`.

Run: `cd mlharum-api && grep -n "message=f\"" routers/detection.py; grep -n "Harvest reminder" services/harvest_reminder_job.py`
Expected: no output (no English literals left in either file).

- [ ] **Step 5: Commit**

```bash
git add mlharum-api/routers/detection.py mlharum-api/services/harvest_reminder_job.py
git commit -m "feat(api): localize scan messages and harvest reminders"
```

---

### Task 4: App language state (`LocaleController`)

**Files:**
- Create: `mlharum-app/lib/services/locale_service.dart`
- Create: `mlharum-app/test/locale_controller_test.dart`
- Modify: `mlharum-app/lib/services/api_service.dart` (lines 12–20, and add a method after `updateMe`)
- Modify: `mlharum-app/lib/services/auth_service.dart` (`logout`, lines 32–34)

**Interfaces:**
- Consumes: `PATCH /auth/me {"language": ...}` from Task 2.
- Produces:
  - `LocaleController.instance` (singleton), `LocaleController({required read, required write, required sync})` for tests.
  - `String get code` (`'ms'` or `'en'`), `Locale get locale`.
  - `Future<void> load()`, `Future<void> setLocale(String code)`, `Future<void> syncToAccount()`.
  - `ApiService.updateLanguage(String code)`.

- [ ] **Step 1: Write the failing tests**

Create `mlharum-app/test/locale_controller_test.dart`:

```dart
import 'package:ai_harum/services/locale_service.dart';
import 'package:flutter_test/flutter_test.dart';

LocaleController make({
  String? saved,
  bool readFails = false,
  bool writeFails = false,
  bool syncFails = false,
  List<String>? written,
  List<String>? synced,
}) {
  return LocaleController(
    read: () async {
      if (readFails) throw Exception('storage unavailable');
      return saved;
    },
    write: (code) async {
      if (writeFails) throw Exception('storage unavailable');
      written?.add(code);
    },
    sync: (code) async {
      if (syncFails) throw Exception('offline');
      synced?.add(code);
    },
  );
}

void main() {
  test('defaults to Malay when nothing is saved', () async {
    final c = make();
    await c.load();
    expect(c.code, 'ms');
    expect(c.locale.languageCode, 'ms');
  });

  test('loads a saved English choice', () async {
    final c = make(saved: 'en');
    await c.load();
    expect(c.code, 'en');
  });

  for (final bad in ['', 'fr', 'EN', 'ms-MY']) {
    test('falls back to Malay for corrupt saved value "$bad"', () async {
      final c = make(saved: bad);
      await c.load();
      expect(c.code, 'ms');
    });
  }

  test('falls back to Malay when storage cannot be read', () async {
    final c = make(readFails: true);
    await c.load();
    expect(c.code, 'ms');
  });

  test('setLocale changes the language, notifies, saves and syncs', () async {
    final written = <String>[];
    final synced = <String>[];
    final c = make(written: written, synced: synced);
    await c.load();
    var notified = 0;
    c.addListener(() => notified++);

    await c.setLocale('en');

    expect(c.code, 'en');
    expect(notified, 1);
    expect(written, ['en']);
    expect(synced, ['en']);
  });

  test('setLocale ignores unsupported codes', () async {
    final c = make();
    await c.load();
    var notified = 0;
    c.addListener(() => notified++);

    await c.setLocale('fr');

    expect(c.code, 'ms');
    expect(notified, 0);
  });

  test('setLocale to the current language does nothing', () async {
    final synced = <String>[];
    final c = make(synced: synced);
    await c.load();
    await c.setLocale('ms');
    expect(synced, isEmpty);
  });

  test('language still switches when saving and syncing fail', () async {
    final c = make(writeFails: true, syncFails: true);
    await c.load();
    await c.setLocale('en');
    expect(c.code, 'en');
  });

  test('syncToAccount swallows failures', () async {
    final c = make(syncFails: true);
    await c.load();
    await c.syncToAccount();
  });
}
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `cd mlharum-app && flutter test test/locale_controller_test.dart`
Expected: compile error, `locale_service.dart` not found.

- [ ] **Step 3: Write `LocaleController`**

Create `mlharum-app/lib/services/locale_service.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_service.dart';
import 'auth_service.dart';

class LocaleController extends ChangeNotifier {
  static const supportedCodes = ['ms', 'en'];
  static const defaultCode = 'ms';

  static const _storage = FlutterSecureStorage();
  static const _key = 'language';

  static final LocaleController instance = LocaleController(
    read: () => _storage.read(key: _key),
    write: (code) => _storage.write(key: _key, value: code),
    sync: _saveToAccount,
  );

  LocaleController({
    required this.read,
    required this.write,
    required this.sync,
  });

  final Future<String?> Function() read;
  final Future<void> Function(String code) write;
  final Future<void> Function(String code) sync;

  String _code = defaultCode;

  String get code => _code;
  Locale get locale => Locale(_code);

  /// Call once before runApp. Anything unreadable or unsupported means Malay.
  Future<void> load() async {
    try {
      final saved = await read();
      _code = supportedCodes.contains(saved) ? saved! : defaultCode;
    } catch (_) {
      _code = defaultCode;
    }
  }

  Future<void> setLocale(String code) async {
    if (!supportedCodes.contains(code) || code == _code) return;
    _code = code;
    notifyListeners();
    try {
      await write(code);
    } catch (_) {}
    await syncToAccount();
  }

  /// Saves the language to the account so push notifications follow it.
  /// Must never block or fail login/startup — same rule as push registration.
  Future<void> syncToAccount() async {
    try {
      await sync(_code);
    } catch (_) {}
  }

  static Future<void> _saveToAccount(String code) async {
    if (!await AuthService.isLoggedIn()) return;
    await ApiService.updateLanguage(code);
  }
}
```

- [ ] **Step 4: Send the language to the API**

In `mlharum-app/lib/services/api_service.dart`, add the import:

```dart
import 'locale_service.dart';
```

Replace `_dio()` and `_authDio()` (lines 12–20) with:

```dart
  static Dio _dio() => Dio(BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Accept-Language': LocaleController.instance.code},
      ));

  static Future<Dio> _authDio() async {
    final token = await AuthService.getToken();
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept-Language': LocaleController.instance.code,
      },
    ));
  }
```

Add this method directly after `updateMe`:

```dart
  static Future<void> updateLanguage(String code) async {
    final dio = await _authDio();
    await dio.patch('/auth/me', data: {'language': code});
  }
```

- [ ] **Step 5: Keep the language across logout**

In `mlharum-app/lib/services/auth_service.dart`, replace `logout`:

```dart
  static Future<void> logout() async {
    // Not deleteAll(): the language choice is stored alongside and must survive logout.
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _farmIdKey);
    await _storage.delete(key: _roleKey);
  }
```

- [ ] **Step 6: Verify**

Run: `cd mlharum-app && flutter test test/locale_controller_test.dart`
Expected: all tests pass.

Run: `cd mlharum-app && flutter analyze lib/services`
Expected: no new errors.

- [ ] **Step 7: Commit**

```bash
git add mlharum-app/lib/services/locale_service.dart mlharum-app/lib/services/api_service.dart mlharum-app/lib/services/auth_service.dart mlharum-app/test/locale_controller_test.dart
git commit -m "feat(app): add LocaleController and send language to API"
```

---

### Task 5: Localization scaffolding and app wiring

**Files:**
- Create: `mlharum-app/l10n.yaml`
- Create: `mlharum-app/lib/l10n/app_en.arb`, `mlharum-app/lib/l10n/app_ms.arb`
- Create: `mlharum-app/lib/l10n/l10n.dart`
- Create: `mlharum-app/test/arb_parity_test.dart`
- Modify: `mlharum-app/pubspec.yaml`
- Modify: `mlharum-app/lib/main.dart`
- Modify: `mlharum-app/lib/screens/login_screen.dart` (`_login`, after line 78)

**Interfaces:**
- Consumes: `LocaleController.instance` (`load`, `locale`, `syncToAccount`) from Task 4.
- Produces:
  - Generated `AppLocalizations` class in `lib/l10n/app_localizations.dart`.
  - `context.l10n` (`AppLocalizations`) and `stageName(AppLocalizations l10n, int stage) -> String`, both from `lib/l10n/l10n.dart`.
  - ARB keys: `languageRowTitle`, `languageMalay`, `languageEnglish`, `stageEarly`, `stageBagging`, `stagePreHarvest`, `stageUnknown`, `updateRequiredTitle`, `updateAvailableTitle`, `updateRequiredBody(version)`, `updateAvailableBody(version)`, `updateLater`, `updateExit`, `updateOk`, `updateDownload`.

- [ ] **Step 1: Write the ARB parity test**

Create `mlharum-app/test/arb_parity_test.dart`:

```dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String name) =>
    jsonDecode(File('lib/l10n/$name').readAsStringSync()) as Map<String, dynamic>;

Iterable<String> _messageKeys(Map<String, dynamic> arb) =>
    arb.keys.where((k) => !k.startsWith('@'));

void main() {
  final en = _load('app_en.arb');
  final ms = _load('app_ms.arb');

  test('English and Malay have the same keys', () {
    expect(_messageKeys(ms).toSet(), _messageKeys(en).toSet());
  });

  test('no Malay value is empty', () {
    for (final key in _messageKeys(ms)) {
      expect((ms[key] as String).trim(), isNotEmpty, reason: key);
    }
  });

  test('every placeholder declared in English is used in both languages', () {
    for (final key in _messageKeys(en)) {
      final meta = en['@$key'] as Map<String, dynamic>?;
      final placeholders = (meta?['placeholders'] as Map<String, dynamic>?)?.keys ?? const <String>[];
      for (final name in placeholders) {
        final pattern = RegExp('\\{$name[,}]');
        expect(pattern.hasMatch(en[key] as String), isTrue, reason: 'en $key missing {$name}');
        expect(pattern.hasMatch(ms[key] as String), isTrue, reason: 'ms $key missing {$name}');
      }
    }
  });
}
```

Run: `cd mlharum-app && flutter test test/arb_parity_test.dart`
Expected: FAIL, `app_en.arb` not found.

- [ ] **Step 2: Enable gen-l10n in `pubspec.yaml`**

Under `dependencies:`, directly after the `flutter: sdk: flutter` entry, add:

```yaml
  flutter_localizations:
    sdk: flutter
```

Change the `intl` line to (the version is pinned by `flutter_localizations`):

```yaml
  intl: any
```

Under the top-level `flutter:` section, add `generate: true`:

```yaml
flutter:
  uses-material-design: true
  generate: true
  assets:
    - assets/images/
```

Create `mlharum-app/l10n.yaml`:

```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

- [ ] **Step 3: Create the seed ARB files**

Create `mlharum-app/lib/l10n/app_en.arb`:

```json
{
  "@@locale": "en",
  "languageRowTitle": "Language",
  "languageMalay": "Bahasa Malaysia",
  "languageEnglish": "English",
  "stageEarly": "Early",
  "stageBagging": "Bagging",
  "stagePreHarvest": "Pre-harvest",
  "stageUnknown": "Unknown",
  "updateRequiredTitle": "Update Required",
  "updateAvailableTitle": "Update Available",
  "updateRequiredBody": "Ai-Harumanis v{version} is required. Download the latest APK to continue.",
  "@updateRequiredBody": {"placeholders": {"version": {"type": "String"}}},
  "updateAvailableBody": "Ai-Harumanis v{version} is available with new features and fixes.",
  "@updateAvailableBody": {"placeholders": {"version": {"type": "String"}}},
  "updateLater": "Later",
  "updateExit": "Exit",
  "updateOk": "OK",
  "updateDownload": "Download"
}
```

Create `mlharum-app/lib/l10n/app_ms.arb`:

```json
{
  "@@locale": "ms",
  "languageRowTitle": "Bahasa",
  "languageMalay": "Bahasa Malaysia",
  "languageEnglish": "English",
  "stageEarly": "Awal",
  "stageBagging": "Pembalutan",
  "stagePreHarvest": "Pra-tuai",
  "stageUnknown": "Tidak diketahui",
  "updateRequiredTitle": "Kemas Kini Diperlukan",
  "updateAvailableTitle": "Kemas Kini Tersedia",
  "updateRequiredBody": "Ai-Harumanis v{version} diperlukan. Muat turun APK terkini untuk meneruskan.",
  "updateAvailableBody": "Ai-Harumanis v{version} kini tersedia dengan ciri baharu dan pembaikan.",
  "updateLater": "Nanti",
  "updateExit": "Keluar",
  "updateOk": "OK",
  "updateDownload": "Muat turun"
}
```

- [ ] **Step 4: Generate and add the helper**

Run: `cd mlharum-app && flutter pub get && flutter gen-l10n`
Expected: `lib/l10n/app_localizations.dart`, `app_localizations_en.dart` and `app_localizations_ms.dart` are created. These generated files are committed.

Create `mlharum-app/lib/l10n/l10n.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'app_localizations.dart';

export 'app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Growth stage number (1–3) to its display name. Models have no BuildContext,
/// so stage names are resolved here instead of on Fruit/ActiveFruit.
String stageName(AppLocalizations l10n, int stage) {
  switch (stage) {
    case 1:
      return l10n.stageEarly;
    case 2:
      return l10n.stageBagging;
    case 3:
      return l10n.stagePreHarvest;
    default:
      return l10n.stageUnknown;
  }
}
```

- [ ] **Step 5: Wire `main.dart`**

Add imports at the top of `mlharum-app/lib/main.dart`:

```dart
import 'dart:async';
import 'l10n/l10n.dart';
import 'services/locale_service.dart';
```

In `main()`, replace the two lines that compute `loggedIn` and call `runApp` with:

```dart
  await LocaleController.instance.load();
  final loggedIn = await AuthService.isLoggedIn();
  if (loggedIn) unawaited(LocaleController.instance.syncToAccount());
  runApp(AiHarumApp(loggedIn: loggedIn));
```

Replace `AiHarumApp.build` with:

```dart
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LocaleController.instance,
      builder: (context, _) => MaterialApp(
        title: 'Ai-Harumanis',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        navigatorKey: navigatorKey,
        locale: LocaleController.instance.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: VersionGate(
          child: loggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      ),
    );
  }
```

In `_VersionGateState._showDialog`, add `final l10n = context.l10n;` as the first line, then replace the strings:

| Old | New |
|---|---|
| `force ? 'Update Required' : 'Update Available'` | `force ? l10n.updateRequiredTitle : l10n.updateAvailableTitle` |
| the two-branch `'Ai-Harumanis v$latest is ...'` expression | `force ? l10n.updateRequiredBody(latest) : l10n.updateAvailableBody(latest)` |
| `const Text('Later')` | `Text(l10n.updateLater)` |
| `Text(force ? 'Exit' : 'OK')` | `Text(force ? l10n.updateExit : l10n.updateOk)` |
| `const Text('Download')` | `Text(l10n.updateDownload)` |

- [ ] **Step 6: Sync the language after login**

In `mlharum-app/lib/screens/login_screen.dart`, add imports:

```dart
import 'dart:async';
import '../services/locale_service.dart';
```

In `_login()`, directly after the line `if (farmId != null) await AuthService.saveFarmId(farmId);`, add:

```dart
      unawaited(LocaleController.instance.syncToAccount());
```

It is not awaited and `syncToAccount` swallows its own errors, so it cannot delay or fail login.

- [ ] **Step 7: Verify**

Run: `cd mlharum-app && flutter test`
Expected: all tests pass, including `arb_parity_test.dart`.

Run: `cd mlharum-app && flutter analyze`
Expected: no new errors.

Run: `cd mlharum-app && flutter build apk --debug`
Expected: build succeeds.

- [ ] **Step 8: Commit**

```bash
git add mlharum-app/pubspec.yaml mlharum-app/pubspec.lock mlharum-app/l10n.yaml mlharum-app/lib/l10n mlharum-app/lib/main.dart mlharum-app/lib/screens/login_screen.dart mlharum-app/test/arb_parity_test.dart
git commit -m "feat(app): add gen-l10n scaffolding with Malay default"
```

---

### Task 6: Language switch UI

**Files:**
- Create: `mlharum-app/lib/widgets/language_toggle.dart`
- Create: `mlharum-app/test/language_toggle_test.dart`
- Modify: `mlharum-app/lib/screens/login_screen.dart` (`build`, the `SafeArea` child at line 122)
- Modify: `mlharum-app/lib/screens/profile_screen.dart` (after the "Personal Info" card, which ends near line 300)

**Interfaces:**
- Consumes: `LocaleController` (`code`, `setLocale`) from Task 4; `context.l10n` and keys `languageRowTitle`, `languageMalay`, `languageEnglish` from Task 5.
- Produces: `LanguageToggle({LocaleController? controller})` widget.

- [ ] **Step 1: Write the failing widget test**

Create `mlharum-app/test/language_toggle_test.dart`:

```dart
import 'package:ai_harum/services/locale_service.dart';
import 'package:ai_harum/widgets/language_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('tapping EN then BM switches the language', (tester) async {
    final controller = LocaleController(
      read: () async => null,
      write: (_) async {},
      sync: (_) async {},
    );
    await controller.load();

    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: LanguageToggle(controller: controller)),
    ));

    expect(controller.code, 'ms');

    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(controller.code, 'en');

    await tester.tap(find.text('BM'));
    await tester.pumpAndSettle();
    expect(controller.code, 'ms');
  });
}
```

Run: `cd mlharum-app && flutter test test/language_toggle_test.dart`
Expected: compile error, `language_toggle.dart` not found.

- [ ] **Step 2: Write the toggle**

Create `mlharum-app/lib/widgets/language_toggle.dart`:

```dart
import 'package:flutter/material.dart';
import '../services/locale_service.dart';

/// Compact BM | EN switch for the login screen (dark background).
/// Plain TextStyle (font comes from the app theme) so it runs in widget tests
/// without google_fonts trying to load fonts.
class LanguageToggle extends StatelessWidget {
  final LocaleController? controller;
  const LanguageToggle({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller ?? LocaleController.instance;
    return ListenableBuilder(
      listenable: c,
      builder: (context, _) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _option(c, 'ms', 'BM'),
          const Text('|', style: TextStyle(color: Colors.white38, fontSize: 13)),
          _option(c, 'en', 'EN'),
        ],
      ),
    );
  }

  Widget _option(LocaleController c, String code, String label) {
    final selected = c.code == code;
    return TextButton(
      onPressed: () => c.setLocale(code),
      style: TextButton.styleFrom(
        minimumSize: const Size(44, 40),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? Colors.white : Colors.white60,
        ),
      ),
    );
  }
}
```

Run: `cd mlharum-app && flutter test test/language_toggle_test.dart`
Expected: PASS.

- [ ] **Step 3: Put the toggle on the login screen**

In `mlharum-app/lib/screens/login_screen.dart`, add the import:

```dart
import '../widgets/language_toggle.dart';
```

In `build`, the `SafeArea` at line 122 has `child: Column(children: [...])`. Wrap that `Column` in a `Stack` so the toggle sits in the top-right corner:

```dart
          child: SafeArea(
            bottom: false,
            child: Stack(
              children: [
                Column(
                  children: [
                    // ... existing children, unchanged ...
                  ],
                ),
                const Positioned(top: 4, right: 8, child: LanguageToggle()),
              ],
            ),
          ),
```

- [ ] **Step 4: Add the language row to Profile**

In `mlharum-app/lib/screens/profile_screen.dart`, add imports:

```dart
import '../l10n/l10n.dart';
import '../services/locale_service.dart';
```

Add this method to the screen's `State` class:

```dart
  void _chooseLanguage() {
    final l10n = context.l10n;
    final current = LocaleController.instance.code;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in [
              ('ms', l10n.languageMalay),
              ('en', l10n.languageEnglish),
            ])
              ListTile(
                title: Text(option.$2, style: GoogleFonts.poppins(fontSize: 14)),
                trailing: current == option.$1
                    ? const Icon(Icons.check_rounded, color: kGreenPrimary)
                    : null,
                onTap: () {
                  Navigator.pop(sheetContext);
                  LocaleController.instance.setLocale(option.$1);
                },
              ),
          ],
        ),
      ),
    );
  }
```

In `build`, directly after the "Personal Info" card (the `Container` whose first child is `Text('Personal Info', ...)`) and before the next sibling in the `Column`, insert:

```dart
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: kCard,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: kCardShadow,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.language_rounded, color: kGreenPrimary),
                      title: Text(context.l10n.languageRowTitle,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: kText1)),
                      subtitle: Text(
                          LocaleController.instance.code == 'ms'
                              ? context.l10n.languageMalay
                              : context.l10n.languageEnglish,
                          style: GoogleFonts.poppins(fontSize: 12, color: kText2)),
                      trailing: const Icon(Icons.chevron_right_rounded, color: kText3),
                      onTap: _chooseLanguage,
                    ),
                  ),
```

The whole app rebuilds when the language changes (Task 5), so the subtitle updates without extra state.

- [ ] **Step 5: Verify**

Run: `cd mlharum-app && flutter test && flutter analyze`
Expected: all tests pass, no new analyzer errors.

Run on a device (`flutter run`): the login screen shows `BM | EN` top-right; Profile shows the language row; choosing English changes the row's own title immediately.

- [ ] **Step 6: Commit**

```bash
git add mlharum-app/lib/widgets/language_toggle.dart mlharum-app/test/language_toggle_test.dart mlharum-app/lib/screens/login_screen.dart mlharum-app/lib/screens/profile_screen.dart
git commit -m "feat(app): add language switch to login and profile"
```

---

## String conversion (Tasks 7–9)

Tasks 7–9 move every remaining hardcoded UI string into the ARB files. The strings are not listed here one by one: there are several hundred, and the source files are the authoritative list. Each task names its files and ends with a check that proves none were missed. Tasks 7–9 each repeat the procedure below so they can be read alone.

**Worked example** (from `login_screen.dart`):

Before:

```dart
setState(() => _error = 'Invalid email or password');
```

`app_en.arb` (wording copied exactly):

```json
  "loginErrorInvalidCredentials": "Invalid email or password",
```

`app_ms.arb`:

```json
  "loginErrorInvalidCredentials": "E-mel atau kata laluan tidak sah",
```

After:

```dart
setState(() => _error = context.l10n.loginErrorInvalidCredentials);
```

**Example with a value** (from `tree_detail_screen.dart` line 209):

Before:

```dart
'Earliest harvest: ${DateFormat('d MMM yyyy').format(earliest)}',
```

`app_en.arb`:

```json
  "treeDetailEarliestHarvest": "Earliest harvest: {date}",
  "@treeDetailEarliestHarvest": {"placeholders": {"date": {"type": "String"}}},
```

`app_ms.arb`:

```json
  "treeDetailEarliestHarvest": "Tuaian terawal: {date}",
```

After:

```dart
context.l10n.treeDetailEarliestHarvest(
    DateFormat('d MMM yyyy', Localizations.localeOf(context).languageCode).format(earliest)),
```

**Example with a count** (plural):

```json
  "homeTreeCount": "{count, plural, =1{1 tree} other{{count} trees}}",
  "@homeTreeCount": {"placeholders": {"count": {"type": "int"}}},
```

```json
  "homeTreeCount": "{count, plural, other{{count} pokok}}",
```

**Rules:**

- Key names are `<screen><Purpose>` in camelCase: `loginEmailLabel`, `ordersEmptyState`, `resultScanAgainButton`. A string used on several screens gets a `common` prefix (`commonCancel`, `commonSave`, `commonRetry`) and is defined once.
- The English value is the existing text, character for character.
- Malay follows the spec glossary. Keep it short; Malay runs longer than English and buttons are narrow.
- Remove `const` from a widget once its text comes from `context.l10n`.
- In a method with no `BuildContext` in scope (for example a helper that builds an error string), pass the `AppLocalizations` in as a parameter, as `stageName` does.
- Every `DateFormat('pattern')` becomes `DateFormat('pattern', Localizations.localeOf(context).languageCode)`.
- Do **not** translate: JSON keys, API values (`'farmer'`, `'pending'`), route names, asset paths, `print`/log text, storage keys, the brand names "Ai-Harumanis", "Beli Harumanis" and "DOA Perlis", units (`cm`, `RM`, `kg`), fruit labels (`T01-001`), emoji-only strings, and text that comes from the server (`result.message`, announcement title/body, error `detail`).
- Status values from the API (order status, flush color names) are mapped to an ARB key by a `switch` in the widget; unknown values are shown as received.

---

### Task 7: Convert entry screens (login, home, profile)

**Files:**
- Modify: `mlharum-app/lib/screens/login_screen.dart`, `home_screen.dart`, `profile_screen.dart`
- Modify: `mlharum-app/lib/l10n/app_en.arb`, `app_ms.arb`

**Interfaces:**
- Consumes: `context.l10n` from Task 5.
- Produces: ARB keys prefixed `login`, `home`, `profile`, and shared `common*` keys (`commonCancel`, `commonSave`, `commonRetry`, `commonOk`, `commonDelete`, `commonConfirm`, `commonError`) that Tasks 8–9 reuse.

- [ ] **Step 1: Convert `login_screen.dart`**

Read the whole file. For each user-visible string (labels, hints, buttons, headings, the error messages set in `_login` and the register/forgot-password flows, snackbars, dialog text): add the key to both ARB files following the worked examples and rules above, then replace the literal with `context.l10n.<key>`. Add `import '../l10n/l10n.dart';` if not already present.

- [ ] **Step 2: Convert `home_screen.dart`**

Same procedure. This file has the five home cards, the DOA Monitor card, the logout confirmation and greeting text. Card titles and subtitles each get their own key.

- [ ] **Step 3: Convert `profile_screen.dart`**

Same procedure, including `'My Profile'`, `'Farmer Account'`, `'Personal Info'`, every `labelText`/`hintText`/`helperText`, the bank details section and save/validation messages. Example hints such as `'e.g. 0123456789'` become `'cth. 0123456789'` in Malay.

- [ ] **Step 4: Regenerate and verify nothing was missed**

Run: `cd mlharum-app && flutter gen-l10n && flutter test && flutter analyze`
Expected: tests pass (the parity test confirms every new key exists in both files), no new analyzer errors.

Run:

```bash
cd mlharum-app && grep -nE "'[^'\$]*[A-Za-z]{3,} [A-Za-z][^']*'" lib/screens/login_screen.dart lib/screens/home_screen.dart lib/screens/profile_screen.dart | grep -vE "import |print\(|^\S+:\s*//"
```

Expected: every remaining line is a string the rules say not to translate (log text, API value, brand name). Fix any that is UI text.

- [ ] **Step 5: Commit**

```bash
git add mlharum-app/lib/screens/login_screen.dart mlharum-app/lib/screens/home_screen.dart mlharum-app/lib/screens/profile_screen.dart mlharum-app/lib/l10n
git commit -m "feat(app): localize login, home and profile screens"
```

---

### Task 8: Convert the tree and scan flow

**Files:**
- Modify: `mlharum-app/lib/screens/tree_list_screen.dart`, `tree_detail_screen.dart`, `camera_screen.dart`, `result_screen.dart`, `dashboard_screen.dart`
- Modify: `mlharum-app/lib/widgets/fruit_card.dart`, `harvest_badge.dart`, `tree_marker.dart`, `page_route.dart`
- Modify: `mlharum-app/lib/models/fruit.dart` (remove both `stageName` getters, lines 42–45 and 86–89)
- Modify: `mlharum-app/lib/l10n/app_en.arb`, `app_ms.arb`

**Interfaces:**
- Consumes: `context.l10n`, `stageName(AppLocalizations, int)` from Task 5; `common*` keys from Task 7.
- Produces: ARB keys prefixed `treeList`, `treeDetail`, `camera`, `result`, `dashboard`, `fruitCard`, `harvestBadge`; `flushColor*` keys (`flushColorRed`, `flushColorYellow`, `flushColorBlue`, `flushColorGreen`, `flushColorOrange`, `flushColorPurple`).

- [ ] **Step 1: Replace the model stage-name getters**

Delete both `String get stageName { ... }` getters from `mlharum-app/lib/models/fruit.dart`.

Update the four call sites to use the helper (add `import '../l10n/l10n.dart';` to each file):

| File and line | Old | New |
|---|---|---|
| `lib/widgets/fruit_card.dart:49` | `${fruit.stageName}` | `${stageName(context.l10n, fruit.growthStage)}` |
| `lib/screens/tree_detail_screen.dart:309` | `${fruit.stageName}` | `${stageName(context.l10n, fruit.growthStage)}` |
| `lib/screens/tree_detail_screen.dart:407` | `${fruit.stageName}` | `${stageName(context.l10n, fruit.growthStage)}` |
| `lib/screens/result_screen.dart:656` | `${fruit.stageName}` | `${stageName(context.l10n, fruit.growthStage)}` |

If a call site is in a method without `context`, pass `AppLocalizations l10n` into that method.

Run: `cd mlharum-app && flutter analyze`
Expected: no `stageName` undefined-getter errors.

- [ ] **Step 2: Convert the five screens**

Read each file in full and apply the conversion procedure and rules from the "String conversion" section. Specific points:

- `tree_detail_screen.dart:407` contains `'... days to harvest'`: make it one ARB message with placeholders for size, stage and days (`treeDetailFruitSummary`), not three concatenated pieces.
- `result_screen.dart` shows `result.message` from the server at lines 316 and 422: leave those as they are. The surrounding headings, buttons, the flush color picker title and the six color names are translated.
- `camera_screen.dart`: the on-screen capture instructions (open palm beside the fruit) are the most-read text in the app; keep the Malay direct and short.
- The `DateFormat` calls at `tree_detail_screen.dart:209` and `:258` take the locale.

- [ ] **Step 3: Convert the four widgets**

`fruit_card.dart`, `harvest_badge.dart` (`DateFormat` at line 43, and the `d` days suffix becomes a placeholder message), `tree_marker.dart` (`DateFormat` at line 26), `page_route.dart`.

- [ ] **Step 4: Regenerate and verify nothing was missed**

Run: `cd mlharum-app && flutter gen-l10n && flutter test && flutter analyze`
Expected: tests pass, no new analyzer errors.

Run:

```bash
cd mlharum-app && grep -nE "'[^'\$]*[A-Za-z]{3,} [A-Za-z][^']*'" lib/screens/tree_list_screen.dart lib/screens/tree_detail_screen.dart lib/screens/camera_screen.dart lib/screens/result_screen.dart lib/screens/dashboard_screen.dart lib/widgets/*.dart lib/models/fruit.dart | grep -vE "import |print\(|^\S+:\s*//"
```

Expected: only non-UI strings remain.

Run: `cd mlharum-app && grep -n "DateFormat('[^']*')" lib/screens/tree_detail_screen.dart lib/widgets/*.dart`
Expected: no output (every `DateFormat` now has a locale argument).

- [ ] **Step 5: Commit**

```bash
git add mlharum-app/lib/screens/tree_list_screen.dart mlharum-app/lib/screens/tree_detail_screen.dart mlharum-app/lib/screens/camera_screen.dart mlharum-app/lib/screens/result_screen.dart mlharum-app/lib/screens/dashboard_screen.dart mlharum-app/lib/widgets mlharum-app/lib/models/fruit.dart mlharum-app/lib/l10n
git commit -m "feat(app): localize tree and scan flow"
```

---

### Task 9: Convert the remaining screens

**Files:**
- Modify: `mlharum-app/lib/screens/pulp_camera_screen.dart`, `pulp_result_screen.dart`, `announcements_screen.dart`, `announcement_detail_screen.dart`, `announcement_editor_screen.dart`, `doa_report_screen.dart`, `orders_screen.dart`, `order_detail_screen.dart`, `farm_photos_screen.dart`, `qr_screen.dart`
- Modify: `mlharum-app/lib/l10n/app_en.arb`, `app_ms.arb`

**Interfaces:**
- Consumes: `context.l10n`, `stageName` from Task 5; `common*` keys from Task 7.
- Produces: ARB keys prefixed `pulp`, `announcements`, `announcementDetail`, `announcementEditor`, `doaReport`, `orders`, `orderDetail`, `farmPhotos`, `qr`; `orderStatus*` keys.

- [ ] **Step 1: Convert the pulp screens**

`pulp_camera_screen.dart` and `pulp_result_screen.dart`. Glossary terms: "Brix (Sweetness)" → "Brix (Kemanisan)", "Firmness" → "Kepejalan", ripeness → "Kematangan isi". `'Stage ${r.stage} reference'` at `pulp_result_screen.dart:275` becomes one message with a `stage` placeholder. If the ripeness stage descriptions or firmness values arrive from the server as English text, leave them as received and note it in the commit message; do not translate server text in this task.

- [ ] **Step 2: Convert the announcement screens**

`announcements_screen.dart`, `announcement_detail_screen.dart`, `announcement_editor_screen.dart`. The announcement title and body are user-written and are never translated. `'Posted ${...} · DOA Perlis'` at `announcement_detail_screen.dart:151` becomes a message with a `date` placeholder, keeping "DOA Perlis" literal. The four `DateFormat` calls (`announcements_screen.dart:276`, `announcement_detail_screen.dart:138` and `:151`, `announcement_editor_screen.dart:197`) take the locale.

- [ ] **Step 3: Convert the DOA report screen**

`doa_report_screen.dart`. The farm-card pill stays terse, per earlier feedback: "Verified" → "Disahkan", "Not Verified" → "Belum Disahkan". Stage count labels use `stageName`.

- [ ] **Step 4: Convert the order screens**

`orders_screen.dart` and `order_detail_screen.dart`. Order status values come from the API as English identifiers; map each known value to an `orderStatus<Value>` key with a `switch` in the widget and show unknown values as received. Read the status values actually handled in these two files and create one key per value. The three `DateFormat` calls (`orders_screen.dart:220`, `order_detail_screen.dart:115` and `:116`) take the locale.

- [ ] **Step 5: Convert `farm_photos_screen.dart` and `qr_screen.dart`**

Same procedure.

- [ ] **Step 6: Regenerate and verify the whole app**

Run: `cd mlharum-app && flutter gen-l10n && flutter test && flutter analyze`
Expected: tests pass, no new analyzer errors.

Run:

```bash
cd mlharum-app && grep -rnE "'[^'\$]*[A-Za-z]{3,} [A-Za-z][^']*'" lib/screens lib/widgets lib/main.dart | grep -vE "import |print\(|^\S+:\s*//"
```

Expected: only non-UI strings remain, across the whole app.

Run: `cd mlharum-app && grep -rn "DateFormat('[^']*')" lib`
Expected: no output.

Run: `cd mlharum-app && flutter build apk --debug`
Expected: build succeeds.

- [ ] **Step 7: Commit**

```bash
git add mlharum-app/lib/screens mlharum-app/lib/l10n
git commit -m "feat(app): localize pulp, announcement, DOA, order and farm screens"
```

---

### Task 10: Manual verification and release

**Files:**
- Modify: `mlharum-app/pubspec.yaml` (line 3)
- Modify: `mlharum-api/main.py` (`/version`, line 104)
- Modify: `CLAUDE.md` (local-only, not tracked in git)

**Interfaces:**
- Consumes: everything above.
- Produces: app 1.10.0, deployed API.

- [ ] **Step 1: Bump versions**

`mlharum-app/pubspec.yaml`:

```yaml
version: 1.10.0+17
```

`mlharum-api/main.py`, in `version()`:

```python
        "ai_harumanis":   {"latest": "1.10.0", "min_required": "1.6.1"},
```

- [ ] **Step 2: Document the feature in `CLAUDE.md`**

Add under "Flutter App Structure":

```markdown
- **Languages**: Bahasa Malaysia (default) and English via Flutter `gen-l10n` — strings live in `mlharum-app/lib/l10n/app_en.arb` and `app_ms.arb`; never hardcode UI text in a widget. `LocaleController` (`lib/services/locale_service.dart`) holds the choice, sends it as `Accept-Language`, and saves it to `users.language`. Server-side farmer-facing text (scan messages, harvest reminder) lives in `mlharum-api/services/i18n.py`; a missing header or NULL `users.language` means English so old APKs are unaffected.
```

- [ ] **Step 3: Commit**

```bash
git add mlharum-app/pubspec.yaml mlharum-api/main.py
git commit -m "chore: bump Ai-Harumanis to 1.10.0, sync /version endpoint"
```

- [ ] **Step 4: Manual pass on an Android phone, against a local or staging API**

Run the API locally (`uvicorn main:app --host 0.0.0.0 --port 8000 --reload` after `alembic upgrade head`), point `_baseUrl` in `lib/services/api_service.dart` at it temporarily (do not commit that change), and `flutter run`.

Check each item and record the result:

- Fresh install opens in Malay.
- `BM | EN` on the login screen switches the login screen text both ways.
- Log in. Every screen reachable from Home is in Malay with no English left and no clipped or overflowing text: Home, tree list, tree detail, camera, scan result, dashboard, pulp camera, pulp result, announcements list/detail/editor, DOA Monitor, orders list/detail, farm photos, QR, Profile.
- Dates show Malay month names (for example "5 Okt 2026").
- Scan a fruit: the result message is in Malay. Switch to English in Profile and scan again: the message is in English.
- The `users.language` value for the test account changes when the language is switched (`SELECT language FROM users WHERE email = '<test account>';`).
- Log out and back in: the language is unchanged. Force-stop and reopen the app: the language is unchanged.
- Harvest reminder: set a test fruit's `harvest_date` to today and `harvest_reminder_sent_at` to NULL, run `run_harvest_reminder_check` once for an account set to `ms` and once for one set to `en`; the push arrives in the matching language.
- Old-app compatibility: `curl` the detect endpoint without an `Accept-Language` header and confirm the English message is byte-for-byte what 1.9.0 shows today.

Fix anything found (overflowing Malay text is usually solved by a shorter translation) and commit before continuing.

- [ ] **Step 5: Stop and ask Zainal before deploying**

Deployment touches the production server and replaces the public APK. Do not proceed without explicit go-ahead. Present the manual-pass results and wait.

- [ ] **Step 6: Deploy the API first (after go-ahead)**

Follow the established server procedure (production host over Tailscale, service `mlharum-api.service`):

1. Back up the database with `pg_dump` before migrating; unlike in July, real farmer accounts may now exist.
2. Copy the changed API files: `services/i18n.py`, `routers/detection.py`, `routers/auth.py`, `services/harvest_reminder_job.py`, `models/user.py`, `schemas.py`, `migrations/versions/022_add_language_to_users.py`. Do **not** copy `main.py` yet: it carries the `/version` bump, and advertising 1.10.0 before the APK is on R2 would send 1.9.0 users into a download loop.
3. Run `alembic upgrade head`; expect `Running upgrade 021 -> 022`.
4. Restart `mlharum-api.service`.
5. Verify: `/health` responds; `curl https://mlharum.unitani.com/version` still shows `1.9.0`; the installed 1.9.0 app still logs in and scans in English.

- [ ] **Step 7: Release the APK**

Run from the repo root: `./deploy-apk.sh ai`
Expected: release APK builds and uploads to R2 as `Ai-Harumanis.apk`.

Only then copy `main.py` to the server and restart `mlharum-api.service`. Verify `curl https://mlharum.unitani.com/version` shows `1.10.0`; a phone on 1.9.0 then shows the optional update prompt.
