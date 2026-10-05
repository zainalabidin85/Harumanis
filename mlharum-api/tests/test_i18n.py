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
