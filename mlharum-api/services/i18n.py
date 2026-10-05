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
