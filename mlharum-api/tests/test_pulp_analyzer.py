import io

import numpy as np
import pytest
from PIL import Image

from services.pulp_analyzer import _STAGES, PulpNotDetected, analyze_pulp


def _image(rgb, size=100):
    buf = io.BytesIO()
    Image.new("RGB", (size, size), rgb).save(buf, format="PNG")
    return buf.getvalue()


def _image_from_array(arr):
    buf = io.BytesIO()
    Image.fromarray(arr.astype(np.uint8)).save(buf, format="PNG")
    return buf.getvalue()


@pytest.mark.parametrize("ref", _STAGES, ids=lambda s: f"stage{s['stage']}")
def test_reference_colours_keep_their_stage(ref):
    result = analyze_pulp(_image((ref["r"], ref["g"], ref["b"])))
    assert result["stage"] == ref["stage"]


@pytest.mark.parametrize("ref", _STAGES, ids=lambda s: f"stage{s['stage']}")
def test_dim_lighting_still_classifies(ref):
    dim = tuple(round(c * 0.6) for c in (ref["r"], ref["g"], ref["b"]))
    assert analyze_pulp(_image(dim))["stage"] == ref["stage"]


@pytest.mark.parametrize(
    "rgb",
    [
        (30, 60, 200),    # blue
        (40, 160, 40),    # green
        (200, 30, 30),    # red
        (240, 240, 240),  # white paper
        (128, 128, 128),  # grey
        (10, 10, 10),     # black
        (120, 150, 60),   # green mango skin
        (40, 35, 15),     # pulp colour but far too dark
    ],
    ids=["blue", "green", "red", "white", "grey", "black", "skin", "dark"],
)
def test_non_pulp_colours_are_rejected(rgb):
    with pytest.raises(PulpNotDetected):
        analyze_pulp(_image(rgb))


def test_checkerboard_averaging_to_yellow_is_rejected():
    # Red + green pixels average to a yellowish colour but neither is pulp.
    arr = np.zeros((100, 100, 3))
    arr[::2, ::2] = arr[1::2, 1::2] = (230, 40, 20)
    arr[::2, 1::2] = arr[1::2, ::2] = (60, 220, 20)
    with pytest.raises(PulpNotDetected):
        analyze_pulp(_image_from_array(arr))


def test_mostly_background_is_rejected():
    arr = np.full((100, 100, 3), 240.0)          # white
    arr[40:60, 40:50] = (210, 165, 26)           # pulp covers half the box
    with pytest.raises(PulpNotDetected):
        analyze_pulp(_image_from_array(arr))


def test_small_stray_patch_does_not_skew_stage():
    arr = np.full((100, 100, 3), (210, 165, 26), dtype=float)  # stage 4
    arr[40:46, 40:60] = (60, 90, 40)                             # 30% skin
    assert analyze_pulp(_image_from_array(arr))["stage"] == 4


def _client():
    from fastapi import FastAPI
    from fastapi.testclient import TestClient

    from routers import analyze

    app = FastAPI()
    app.include_router(analyze.router, prefix="/analyze")
    return TestClient(app)


def test_endpoint_rejects_non_pulp_in_malay():
    res = _client().post(
        "/analyze/pulp",
        files={"file": ("x.png", _image((30, 60, 200)), "image/png")},
        headers={"Accept-Language": "ms"},
    )
    assert res.status_code == 422
    assert res.json()["detail"].startswith("Isi mangga tidak dikesan")


def test_endpoint_still_classifies_pulp():
    res = _client().post(
        "/analyze/pulp",
        files={"file": ("x.png", _image((210, 165, 26)), "image/png")},
    )
    assert res.status_code == 200
    assert res.json()["stage"] == 4
