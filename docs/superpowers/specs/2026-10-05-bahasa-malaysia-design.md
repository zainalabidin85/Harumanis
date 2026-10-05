# Bahasa Malaysia language option for Ai-Harumanis

Date: 2026-10-05
Status: draft for review

## Goal

Farmers and DOA officers can use the Ai-Harumanis app (`mlharum-app`) in Bahasa
Malaysia. Malay is the default; English remains available.

Success means a farmer who never touches the setting sees Malay on every screen,
in the scan result message, and in the harvest reminder notification.

## Scope

In scope:

- All UI text in `mlharum-app` (19 screens, shared widgets, the update dialog in `main.dart`).
- The three scan result messages returned by `POST /detect/{tree_id}`.
- The harvest reminder push notification.
- Date formatting in the app.

Out of scope:

- API error messages (`HTTPException` details) stay English.
- Announcements: title and body are typed by DOA/admin and are shown, and pushed, as written.
- The other apps: `harumanis-app` (buyer), `mlharum-collector`, `mlharum-admin`.
- iOS-specific localization settings (the app is Android-first).
- Languages other than English and Malay.

## Decisions already made

| Decision | Choice |
|---|---|
| What gets translated | App UI, scan result messages, push notifications |
| Default language on first launch | Bahasa Malaysia, regardless of phone language |
| Who translates server text | The server, based on the language the app sends |
| Existing users on old APKs | Unchanged: English everywhere |

## App design (`mlharum-app`)

### Localization mechanism

Flutter's built-in `gen-l10n`:

- Add `flutter_localizations` (SDK) to `pubspec.yaml` and set `flutter: generate: true`.
- `flutter_localizations` pins the `intl` version. The current `intl: ^0.19.0` must be
  raised to whatever the installed Flutter (3.44) requires; `flutter pub get` reports it.
- `l10n.yaml` at the app root: `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`,
  `output-localization-file: app_localizations.dart`.
- `lib/l10n/app_en.arb` (template) and `lib/l10n/app_ms.arb`.
- `MaterialApp` gets `localizationsDelegates`, `supportedLocales: [ms, en]` and `locale`.
  Flutter ships Material translations for `ms`, so date pickers and built-in buttons follow.

Strings with values use ARB placeholders, and counts use ARB plurals, for example
`treeCount`: "{count} pokok". No string concatenation of translated fragments.

### Language state

A new `lib/services/locale_service.dart` holding a `LocaleController` (`ChangeNotifier`):

- `locale`: the current `Locale`, `ms` or `en`.
- `load()`: reads the saved choice at startup, before `runApp`. No saved choice means `ms`.
- `setLocale(locale)`: updates state, saves to the phone, and, if logged in, saves to the account.

Storage on the phone uses the existing `flutter_secure_storage` under key `language`,
so no new dependency is needed.

`AuthService.logout()` currently calls `_storage.deleteAll()`, which would erase the
language choice. It changes to delete only the auth keys (`access_token`, `farm_id`,
`role`), so the language survives logout.

`main.dart` wraps `MaterialApp` in a listener on `LocaleController` so the whole app
rebuilds when the language changes. No restart is needed.

### Language switch

- Profile screen: a "Bahasa / Language" row showing the current language; tapping opens
  a two-option chooser (Bahasa Malaysia, English).
- Login screen: a small `BM | EN` toggle in a corner, for use before signing in.

### Telling the server

- `ApiService._dio()` and `_authDio()` add an `Accept-Language` header (`ms` or `en`)
  from `LocaleController`. This drives the scan result message language.
- After a successful login, and on app start when already logged in, the app sends
  `PATCH /auth/me {"language": "<code>"}`. `setLocale` does the same when logged in.
  This drives the push notification language.
- The sync call must never block or fail login or startup. It is wrapped in try/catch
  and its failure is ignored, the same rule as push token registration.

### Text that needs more than a string swap

- Stage names: `lib/models/fruit.dart` has two hardcoded maps
  `{1: 'Early', 2: 'Bagging', 3: 'Pre-harvest'}`. Models have no `BuildContext`, so the
  name getters are replaced by a helper `stageName(AppLocalizations l10n, int stage)`
  used from widgets.
- Dates: the 11 `DateFormat(...)` calls pass the current locale, for example
  `DateFormat('d MMM yyyy', locale)`. `initializeDateFormatting` is handled by
  `flutter_localizations`.
- Update dialog (`VersionGate` in `main.dart`): translated like any other screen.
- Foreground push display uses the title and body sent by the server, so needs no change.

### Conversion approach

Screen by screen: move each hardcoded string into `app_en.arb` with a descriptive key,
add the Malay value to `app_ms.arb`, and replace the literal with
`AppLocalizations.of(context)!.key`. `const` is removed from widgets whose text is now
looked up. English wording is kept exactly as it is today, so the English app is unchanged.

## API design (`mlharum-api`)

### User language

Migration `022_add_language_to_users.py` (revises `021`, in `migrations/versions/`):

- `users.language`: `String(5)`, nullable, no default.
- `NULL` means "never reported", which is treated as English. This keeps every user on
  an old APK in English, matching their English UI.

`models/user.py` gains the column. `schemas.UserProfileUpdate` gains
`language: Optional[Literal["en", "ms"]] = None`, so `PATCH /auth/me` accepts it with
no router change. `UserProfileResponse` gains `language: Optional[str] = None`.

### Message catalog

A new `services/i18n.py`, with no dependencies on the DB or ML code:

- `resolve_language(value: str | None) -> str`: returns `"ms"` if the value starts with
  `ms` (case-insensitive, so `ms`, `ms-MY` and `ms,en;q=0.8` all work), otherwise `"en"`.
- `t(key: str, lang: str, **params) -> str`: looks up a template in a module-level dict
  and formats it. An unknown language falls back to English.

Catalog keys and wording:

| Key | English (unchanged from today) | Malay (draft) |
|---|---|---|
| `detect.early` | This mango is {size} cm — Early stage, not yet recorded (natural fruit drop risk is high at this size). Scan again once it reaches {min_size} cm to begin bagging. | Mangga ini berukuran {size} cm — peringkat Awal, belum direkodkan (risiko buah gugur secara semula jadi tinggi pada saiz ini). Imbas semula apabila mencapai {min_size} cm untuk mula membalut. |
| `detect.late` | This mango ({size} cm) has passed the bagging window and been recorded as {label} — Pre-harvest / late-bagging. Estimated harvest in {days} days. | Mangga ini ({size} cm) telah melepasi tempoh pembalutan dan direkodkan sebagai {label} — Pra-tuai / balut lewat. Anggaran tuai dalam {days} hari. |
| `detect.ready` | Ready for bagging — {size} cm. Estimated harvest in {days} days. | Sedia untuk dibalut — {size} cm. Anggaran tuai dalam {days} hari. |
| `reminder.title` | 🥭 Harvest reminder | 🥭 Peringatan tuai |
| `reminder.one` | {label} is ready for harvest soon. | {label} hampir sedia untuk dituai. |
| `reminder.many` | {count} of your Harumanis fruits are ready for harvest soon. | {count} buah Harumanis anda hampir sedia untuk dituai. |

### Scan result messages

`routers/detection.py`: the detect endpoint reads the `Accept-Language` header
(`Header(default=None)`), resolves it with `resolve_language`, and builds its three
messages with `t(...)`. No header means English, so old APKs behave exactly as today.
The response schema does not change.

### Harvest reminder

`services/harvest_reminder_job.py`: the job already groups due fruits by owner. It
additionally loads each owner's `language` and builds the title and body with `t(...)`
in that language. `push_service` is unchanged.

A phone shared by two accounts is not handled specially: the reminder follows the
language saved on the account that owns the fruit.

## Compatibility and rollout

1. Deploy the API: copy files, `alembic upgrade head` (021 → 022), restart
   `mlharum-api.service`. This is backward compatible with the 1.9.0 APK.
2. Release the app as 1.10.0 with `./deploy-apk.sh ai`, and bump `ai_harumanis.latest`
   in the `/version` endpoint. `min_required` is not raised; the update is optional.

Behaviour matrix:

| App | Server | Result |
|---|---|---|
| 1.9.0 | new | English everywhere, as today |
| 1.10.0 | new | Chosen language everywhere in scope |
| 1.10.0 | old | Malay UI, English scan messages and reminders (transient, only if rollout order is reversed) |

## Testing

Neither project has a test suite today, so this adds a minimal one on each side.

API (`mlharum-api/tests/`, `pytest` added to `requirements.txt`):

- `resolve_language`: `None`, empty, `en`, `ms`, `ms-MY`, `MS`, `ms,en;q=0.8`, `fr`.
- `t`: every catalog key has both `en` and `ms`; both format with the same parameters;
  unknown language falls back to English.
- Reminder text: one fruit and several fruits, in each language.

These are pure-function tests and need no database or ML models.

App (`mlharum-app/test/`):

- ARB parity: `app_en.arb` and `app_ms.arb` have the same keys and the same placeholders
  per key.
- `LocaleController`: defaults to `ms` with nothing saved; `setLocale` changes `locale`
  and notifies listeners.

Manual, on an Android phone:

- Walk every screen in Malay, then in English, checking for leftover English text and
  for text that overflows or is cut off (Malay strings are often longer).
- Switch language on the login screen and in Profile; confirm it survives logout and
  app restart.
- Scan a fruit in each language and check the result message.
- Trigger the harvest reminder for a test account set to each language.

## Glossary for review

Draft Malay terms for the words that recur across the app. These need checking against
what Perlis farmers and DOA actually say; corrections here are applied everywhere.

| English | Draft Malay | Note |
|---|---|---|
| Early (stage 1) | Awal | |
| Bagging (stage 2) | Pembalutan | |
| Pre-harvest (stage 3) | Pra-tuai | |
| Harvest | Tuai | |
| Days to harvest | Hari sebelum tuai | |
| Farm | Ladang | |
| Tree | Pokok | |
| Fruit | Buah | |
| Scan | Imbas | |
| Flush color | Warna pusingan | Unsure of the field term for a blooming flush |
| Season | Musim | |
| Yield | Hasil | |
| Pulp ripeness | Kematangan isi | |
| Brix (Sweetness) | Brix (Kemanisan) | |
| Firmness | Kepejalan | |
| Announcement | Pengumuman | |
| Order | Pesanan | |
| Verified / Not Verified | Disahkan / Belum Disahkan | |
| Profile | Profil | |
| Log in / Log out | Log masuk / Log keluar | |
