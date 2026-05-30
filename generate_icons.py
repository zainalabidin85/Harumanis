"""
Generate app icons for all three MLharum apps.
Layout: colored gradient background → mango centered → label text overlaid on mango center.
"""
import requests
import os
from PIL import Image, ImageDraw, ImageFont

SIZE = 1024
FONT_PATH = "/tmp/BebasNeue.ttf"

# Download Bebas Neue if not cached
if not os.path.exists(FONT_PATH):
    url = "https://github.com/dharmatype/Bebas-Neue/raw/master/fonts/BebasNeue(2018)ByDhamraType/ttf/BebasNeue-Regular.ttf"
    r = requests.get(url, timeout=15)
    r.raise_for_status()
    with open(FONT_PATH, "wb") as f:
        f.write(r.content)
    print("Font downloaded.")

APPS = [
    {
        "label": "Manager",
        "bg_top":    (180,  83,   9),   # amber dark  #B45309
        "bg_bottom": ( 78,  33,   0),   # amber darker #4E2100
        "out":       "/home/zainal/innovation/MLharum/mlharum-app/assets/images/app_icon.png",
    },
    {
        "label": "R&D",
        "bg_top":    ( 13, 148, 136),   # teal        #0D9488
        "bg_bottom": (  6,  78,  59),   # teal dark   #064E3B
        "out":       "/home/zainal/innovation/MLharum/mlharum-collector/assets/images/app_icon.png",
    },
    {
        "label": "Harumanis",
        "bg_top":    ( 22, 163,  74),   # green       #16A34A
        "bg_bottom": ( 20, 83,   45),   # green dark  #14532D
        "out":       "/home/zainal/innovation/MLharum/harumanis-app/assets/images/app_icon.png",
    },
]

# Load source mango (transparent background)
MANGO_SRC = "/home/zainal/innovation/MLharum/mlharum-app/assets/images/app_icon.png"
mango_orig = Image.open(MANGO_SRC).convert("RGBA")


def make_gradient(size, top_color, bottom_color):
    img = Image.new("RGBA", (size, size))
    draw = ImageDraw.Draw(img)
    for y in range(size):
        t = y / size
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * t)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * t)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * t)
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    return img


def draw_text_with_stroke(draw, text, font, cx, cy, fill, stroke_color, stroke_width):
    # Draw stroke by rendering text offset in all directions
    for dx in range(-stroke_width, stroke_width + 1):
        for dy in range(-stroke_width, stroke_width + 1):
            if dx == 0 and dy == 0:
                continue
            draw.text((cx + dx, cy + dy), text, font=font, fill=stroke_color, anchor="mm")
    # Draw main text on top
    draw.text((cx, cy), text, font=font, fill=fill, anchor="mm")


def generate_icon(app):
    label = app["label"]
    bg = make_gradient(SIZE, app["bg_top"], app["bg_bottom"])

    # Paste mango — scale to 78% of canvas, centered
    mango_size = int(SIZE * 0.78)
    mango = mango_orig.resize((mango_size, mango_size), Image.LANCZOS)
    offset = (SIZE - mango_size) // 2
    bg.paste(mango, (offset, offset), mango)

    draw = ImageDraw.Draw(bg)

    # Pick font size based on label length
    if len(label) <= 3:
        font_size = 200
    elif len(label) <= 7:
        font_size = 160
    else:
        font_size = 110

    font = ImageFont.truetype(FONT_PATH, font_size)

    cx = SIZE // 2
    cy = SIZE // 2 + 30  # slightly below center of mango body

    # White text with dark stroke
    draw_text_with_stroke(draw, label, font, cx, cy,
                          fill=(255, 255, 255, 255),
                          stroke_color=(0, 0, 0, 180),
                          stroke_width=6)

    # Ensure output directory exists
    os.makedirs(os.path.dirname(app["out"]), exist_ok=True)
    bg.save(app["out"])
    print(f"  Saved: {app['out']}")


print("Generating icons...")
for app in APPS:
    print(f"  [{app['label']}]")
    generate_icon(app)

print("Done.")
