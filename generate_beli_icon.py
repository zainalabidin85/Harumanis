#!/usr/bin/env python3
"""
Beli Harumanis app icon v3.
- Mango side-profile: big asymmetric belly on left, flatter right side, hooked stem
- Thousands of tiny outward arrows in mango colors
- Warm orange glow layer underneath for depth
- Variable arrow size (larger at centre, smaller at edge)
Output: beli_harumanis_icon.png  1024×1024
"""
import math
import numpy as np
from PIL import Image, ImageDraw, ImageFilter, ImageChops

W, H  = 1024, 1024
BG    = (8, 8, 20)
TILT  = 12          # degrees clockwise


# ── Bezier ───────────────────────────────────────────────────────────────────
def bez(p0, p1, p2, p3, n=60):
    out = []
    for i in range(n + 1):
        t = i / n; u = 1 - t
        x = u**3*p0[0] + 3*u**2*t*p1[0] + 3*u*t**2*p2[0] + t**3*p3[0]
        y = u**3*p0[1] + 3*u**2*t*p1[1] + 3*u*t**2*p2[1] + t**3*p3[1]
        out.append((x, y))
    return out


def rot(pts, cx, cy, deg):
    a = math.radians(deg); ca, sa = math.cos(a), math.sin(a)
    return [(int((x-cx)*ca-(y-cy)*sa+cx), int((x-cx)*sa+(y-cy)*ca+cy))
            for x, y in pts]


def rot1(x, y, cx, cy, deg):
    a = math.radians(deg); dx, dy = x-cx, y-cy
    return (dx*math.cos(a)-dy*math.sin(a)+cx, dx*math.sin(a)+dy*math.cos(a)+cy)


# ── Mango silhouette ─────────────────────────────────────────────────────────
# Side profile: left belly MUCH wider than right (ratio ~1.8:1)
# Width : Height ≈ 0.52  →  clearly elongated, not round
#
#            stem (hook)
#           /
#  l_top --·         ·-- r_top
#           \       /
#  l_bel ----·     ·---- r_eq      ← belly left = 295 px,  right = 165 px
#           /       \
#  l_bot --·         ·-- r_bot
#           \       /
#             bot (tip)

MX, MY = 505, 560

def mango_pts():
    stem  = (MX +  5, MY - 295)    # stem / hook top
    r_top = (MX + 160, MY - 215)   # right shoulder
    r_eq  = (MX + 165, MY +  10)   # right equator  ← intentionally narrow
    r_bot = (MX + 120, MY + 235)   # right lower
    bot   = (MX -  10, MY + 300)   # bottom tip
    l_bot = (MX - 215, MY + 215)   # left lower
    l_bel = (MX - 295, MY -  20)   # LEFT BELLY  ← dominant, wide
    l_top = (MX - 170, MY - 245)   # left shoulder

    s = []
    s += bez(stem,  (MX+75,  MY-335), (MX+145, MY-270), r_top, 45)[:-1]
    s += bez(r_top, (MX+220, MY-115), (MX+225, MY- 35), r_eq,  45)[:-1]
    s += bez(r_eq,  (MX+210, MY+135), (MX+165, MY+205), r_bot, 35)[:-1]
    s += bez(r_bot, (MX+ 55, MY+315), (MX+ 15, MY+325), bot,   30)[:-1]
    s += bez(bot,   (MX- 65, MY+325), (MX-185, MY+300), l_bot, 30)[:-1]
    s += bez(l_bot, (MX-310, MY+160), (MX-335, MY+ 55), l_bel, 50)[:-1]
    s += bez(l_bel, (MX-335, MY-155), (MX-255, MY-250), l_top, 50)[:-1]
    s += bez(l_top, (MX- 50, MY-300), (MX- 10, MY-315), stem,  30)
    return s

mango_poly = rot(mango_pts(), MX, MY, TILT)


# ── Leaf ─────────────────────────────────────────────────────────────────────
def leaf_pts():
    base = (MX + 5, MY - 295)
    tip  = (MX - 120, MY - 460)
    s = []
    s += bez(base, (MX- 90, MY-325), (MX-160, MY-410), tip, 30)[:-1]
    s += bez(tip,  (MX- 55, MY-415), (MX+ 25, MY-335), base, 30)
    return s

leaf_poly = rot(leaf_pts(), MX, MY, TILT)

# Gradient reference centres (rotated)
gcx, gcy      = rot1(MX,    MY+15,   MX, MY, TILT)   # mango centre
l_gcx, l_gcy  = rot1(MX-58, MY-375,  MX, MY, TILT)   # leaf centre


# ── Masks ─────────────────────────────────────────────────────────────────────
def mask(poly):
    m = Image.new('L', (W, H), 0)
    ImageDraw.Draw(m).polygon(poly, fill=255)
    return np.array(m)

m_mango = mask(mango_poly)
m_leaf  = mask(leaf_poly)


# ── Colour ───────────────────────────────────────────────────────────────────
def mango_col(dx, dy):
    t = min(math.hypot(dx, dy) / 265, 1.0) ** 0.65
    return (
        int(255 + (205-255)*t),
        int(225 + ( 55-225)*t),
        int( 20 + (  0- 20)*t),
    )

def leaf_col(dx, dy):
    t = min(math.hypot(dx, dy) / 68, 1.0)
    return (
        int( 55 + ( 5- 55)*t),
        int(195 + (80-195)*t),
        int( 30 + ( 5- 30)*t),
    )


# ── Arrow ─────────────────────────────────────────────────────────────────────
def arrow(draw, x, y, ang, ln, col, w):
    ca, sa = math.cos(ang), math.sin(ang)
    tx, ty = x - ca*ln*.5, y - sa*ln*.5
    hx, hy = x + ca*ln*.5, y + sa*ln*.5
    draw.line([(tx,ty),(hx,hy)], fill=col, width=w)
    hl, ha = ln*.33, .40
    draw.polygon([
        (hx, hy),
        (hx - hl*math.cos(ang-ha), hy - hl*math.sin(ang-ha)),
        (hx - hl*math.cos(ang+ha), hy - hl*math.sin(ang+ha)),
    ], fill=col)


# ── Glow layer ────────────────────────────────────────────────────────────────
# Fill shape with warm orange, blur heavily → luminous halo behind arrows
glow_src = Image.new('RGB', (W, H), (0, 0, 0))
gd = ImageDraw.Draw(glow_src)
gd.polygon(mango_poly, fill=(190, 70, 5))
gd.polygon(leaf_poly,  fill=(15,  95, 8))
glow = glow_src.filter(ImageFilter.GaussianBlur(radius=32))


# ── Arrow layer ───────────────────────────────────────────────────────────────
arr_img = Image.new('RGB', (W, H), (0, 0, 0))
ad = ImageDraw.Draw(arr_img)

STEP = 17   # grid spacing — denser for denser arrow fill

for py in range(0, H, STEP):
    for px in range(0, W, STEP):
        if m_mango[py, px] > 128:
            dx, dy = px - gcx, py - gcy
            dist   = math.hypot(dx, dy)
            ang    = math.atan2(dy, dx)
            ang   += ((px*31 + py*17) % 21 - 10) * 0.033   # tiny jitter
            # Larger + thicker arrows near centre for depth
            ln = 17 - (dist / 265) * 5      # 17 px centre → 12 px edge
            ln = max(ln, 10)
            w  = 3 if dist < 90 else 2
            arrow(ad, px, py, ang, ln, mango_col(dx, dy), w)

for py in range(0, H, STEP):
    for px in range(0, W, STEP):
        if m_leaf[py, px] > 128:
            dx, dy = px - l_gcx, py - l_gcy
            ang    = math.atan2(dy, dx)
            arrow(ad, px, py, ang, 13, leaf_col(dx, dy), 2)


# ── Composite: BG + glow + arrows ────────────────────────────────────────────
img = Image.new('RGB', (W, H), BG)
img = ImageChops.screen(img, glow)      # warm halo over dark BG
img = ImageChops.screen(img, arr_img)   # arrows on top (screen keeps colours vivid)

out = '/home/zainal/innovation/MLharum/beli_harumanis_icon.png'
img.save(out)
print(f"Saved → {out}")
