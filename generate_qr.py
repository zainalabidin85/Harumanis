import qrcode
from qrcode.image.styledpil import StyledPilImage
from qrcode.image.styles.moduledrawers import RoundedModuleDrawer
from PIL import Image, ImageDraw, ImageFont
import os

APK_URL = "https://mlharum.unitani.com/storage/apk/AiHarumanis.apk"
OUTPUT_PATH = "/home/zainal/innovation/MLharum/demo-output/ai-harumanis-qr.png"

os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)

qr = qrcode.QRCode(
    version=1,
    error_correction=qrcode.constants.ERROR_CORRECT_H,
    box_size=12,
    border=4,
)
qr.add_data(APK_URL)
qr.make(fit=True)

qr_img = qr.make_image(
    image_factory=StyledPilImage,
    module_drawer=RoundedModuleDrawer(),
    fill_color="#1B5E20",
    back_color="white",
)

# Canvas with label
CANVAS_W, CANVAS_H = 600, 720
canvas = Image.new("RGB", (CANVAS_W, CANVAS_H), "#FFFFFF")

qr_w, qr_h = qr_img.size
qr_x = (CANVAS_W - qr_w) // 2
qr_y = 80
canvas.paste(qr_img, (qr_x, qr_y))

draw = ImageDraw.Draw(canvas)

try:
    font_title = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 32)
    font_sub   = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20)
    font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 16)
except OSError:
    font_title = ImageFont.load_default()
    font_sub   = font_title
    font_small = font_title

title = "Ai-Harumanis"
bbox = draw.textbbox((0, 0), title, font=font_title)
tw = bbox[2] - bbox[0]
draw.text(((CANVAS_W - tw) // 2, 24), title, fill="#1B5E20", font=font_title)

sub = "Imbas untuk muat turun aplikasi"
bbox2 = draw.textbbox((0, 0), sub, font=font_sub)
sw = bbox2[2] - bbox2[0]
draw.text(((CANVAS_W - sw) // 2, qr_y + qr_h + 24), sub, fill="#333333", font=font_sub)

note = "Android • Percuma"
bbox3 = draw.textbbox((0, 0), note, font=font_small)
nw = bbox3[2] - bbox3[0]
draw.text(((CANVAS_W - nw) // 2, qr_y + qr_h + 60), note, fill="#888888", font=font_small)

canvas.save(OUTPUT_PATH, dpi=(300, 300))
print(f"Saved: {OUTPUT_PATH}")
print(f"URL:   {APK_URL}")
