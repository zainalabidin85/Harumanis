from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware
from routers import auth, farms, detection, dashboard, training, analyze, marketplace, orders, admin, fruits
from routers import farm_images, testimonials, doa, announcements
from services.yolo_service import load_model as load_yolo
from services.mediapipe_service import load_model as load_mediapipe
from services import push_service
from services.harvest_reminder_job import run_harvest_reminder_check
from apscheduler.schedulers.background import BackgroundScheduler
from limiter import limiter
from database import get_db, SessionLocal
from models.farm import Farm
from sqlalchemy.orm import Session
import fcntl
import os

app = FastAPI(title="MLharum API", version="2.0.0")
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)
app.add_middleware(SlowAPIMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(farms.router, prefix="/farms", tags=["farms"])
app.include_router(detection.router, prefix="/detect", tags=["detection"])
app.include_router(dashboard.router, prefix="/dashboard", tags=["dashboard"])
app.include_router(training.router, prefix="/training", tags=["training"])
app.include_router(analyze.router, prefix="/analyze", tags=["analyze"])
app.include_router(marketplace.router, prefix="/marketplace", tags=["marketplace"])
app.include_router(orders.router, prefix="/orders", tags=["orders"])
app.include_router(farm_images.router, prefix="/farms", tags=["farm-images"])
app.include_router(admin.router, prefix="/admin", tags=["admin"])
app.include_router(fruits.router, prefix="/trees", tags=["fruits"])
app.include_router(testimonials.router, prefix="/farms", tags=["reviews"])
app.include_router(doa.router, prefix="/doa", tags=["doa"])
app.include_router(announcements.router, prefix="/announcements", tags=["announcements"])


def _harvest_reminder_tick():
    db = SessionLocal()
    try:
        run_harvest_reminder_check(db)
    finally:
        db.close()


# Held open for the lifetime of the process (never closed/released) so the
# flock survives as the single way to pick one scheduler owner among
# multiple uvicorn workers on this host.
_scheduler_lock_file = None


def _acquire_scheduler_lock() -> bool:
    global _scheduler_lock_file
    lock_path = os.path.join(os.path.dirname(__file__), ".harvest_reminder_scheduler.lock")
    f = open(lock_path, "w")
    try:
        fcntl.flock(f, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except OSError:
        f.close()
        return False
    _scheduler_lock_file = f  # keep a reference so the lock isn't released on GC
    return True


@app.on_event("startup")
async def startup():
    load_yolo()
    load_mediapipe()
    os.makedirs("./storage/images/farms", exist_ok=True)
    os.makedirs("./storage/images/announcements", exist_ok=True)

    push_service.init_firebase()

    # Multiple uvicorn workers run on this host; only the worker that wins
    # the flock runs the scheduler, so the daily job fires exactly once.
    if _acquire_scheduler_lock():
        scheduler = BackgroundScheduler()
        scheduler.add_job(_harvest_reminder_tick, "cron", hour=8, minute=0)
        scheduler.start()

os.makedirs("./storage", exist_ok=True)
app.mount("/storage", StaticFiles(directory="./storage"), name="storage")


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/version")
def version():
    return {
        "ai_harumanis":   {"latest": "1.7.2", "min_required": "1.6.1"},
        "beli_harumanis": {"latest": "1.9.5", "min_required": "1.9.5"},
    }


@app.get("/", response_class=HTMLResponse)
def landing():
    landing_path = os.path.join(os.path.dirname(__file__), "landing.html")
    with open(landing_path, "r") as f:
        return f.read()


@app.get("/farm/{farm_id}", response_class=HTMLResponse)
def farm_landing(farm_id: int, db: Session = Depends(get_db)):
    from models.farm_image import FarmImage
    farm = db.query(Farm).filter(Farm.id == farm_id).first()
    farm_name = farm.name if farm else "Harumanis Farm"
    deep_link = f"harumanis://farm/{farm_id}"
    apk_url = "https://pub-09d17b214a8449658a27e1cbecccb5ab.r2.dev/BeliHarumanis.apk"
    base_url = "https://mlharum.unitani.com"

    thumb = None
    if farm:
        img = db.query(FarmImage).filter(FarmImage.farm_id == farm_id).order_by(FarmImage.id).first()
        if img:
            thumb = f"{base_url}/storage/images/farms/{img.filename}"

    hero_style = (
        f"background-image: linear-gradient(to bottom, rgba(120,53,15,.72) 0%, rgba(69,26,3,.92) 100%), url('{thumb}'); background-size: cover; background-position: center;"
        if thumb else
        "background: linear-gradient(160deg, #78350F 0%, #92400E 50%, #451a03 100%);"
    )

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <meta name="theme-color" content="#B45309"/>
  <title>{farm_name} — Beli Harumanis</title>
  <link rel="preconnect" href="https://fonts.googleapis.com"/>
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after {{ box-sizing: border-box; margin: 0; padding: 0; }}

    :root {{
      --amber-dark:    #78350F;
      --amber-primary: #B45309;
      --amber-mid:     #D97706;
      --amber-light:   #FEF3C7;
      --amber-tint:    #FFFBEB;
      --ivory:         #FFFAF0;
      --green:         #16A34A;
      --text1:         #111827;
      --text2:         #6B7280;
      --text3:         #9CA3AF;
      --divider:       #E5E7EB;
      --white:         #FFFFFF;
    }}

    body {{
      font-family: 'Poppins', -apple-system, BlinkMacSystemFont, sans-serif;
      background: var(--ivory);
      min-height: 100vh;
      color: var(--text1);
      overflow-x: hidden;
    }}

    /* ── Hero ── */
    .hero {{
      position: relative;
      min-height: 280px;
      {hero_style}
      display: flex; flex-direction: column;
      align-items: center; justify-content: flex-end;
      padding: 0 24px 32px;
      text-align: center;
      overflow: hidden;
    }}
    .hero::after {{
      content: '';
      position: absolute; inset: 0;
      background: linear-gradient(to bottom, rgba(120,53,15,.1) 0%, rgba(69,26,3,.75) 100%);
      pointer-events: none;
    }}
    .hero-content {{ position: relative; z-index: 1; width: 100%; }}

    .mango-float {{
      font-size: 52px; line-height: 1;
      display: block; margin-bottom: 12px;
      filter: drop-shadow(0 4px 12px rgba(0,0,0,.4));
      animation: floatMango 3s ease-in-out infinite;
    }}
    @keyframes floatMango {{
      0%, 100% {{ transform: translateY(0px); }}
      50%       {{ transform: translateY(-6px); }}
    }}

    .ai-badge {{
      display: inline-flex; align-items: center; gap: 5px;
      background: rgba(254,243,199,.15);
      border: 1px solid rgba(254,243,199,.35);
      color: #FCD34D;
      font-size: 10px; font-weight: 600; letter-spacing: .07em; text-transform: uppercase;
      padding: 4px 12px; border-radius: 20px;
      margin-bottom: 10px;
      backdrop-filter: blur(8px);
    }}

    .hero-farm {{
      font-size: clamp(22px, 6vw, 30px);
      font-weight: 800; color: var(--white);
      line-height: 1.15; margin-bottom: 8px;
      text-shadow: 0 2px 8px rgba(0,0,0,.3);
      letter-spacing: -.02em;
    }}
    .hero-sub {{
      font-size: 13px; color: rgba(255,255,255,.75);
      line-height: 1.6; max-width: 280px; margin: 0 auto;
    }}

    /* ── Pills ── */
    .pills {{
      display: flex; flex-wrap: wrap; justify-content: center;
      gap: 8px; padding: 20px 20px 0;
      background: var(--ivory);
    }}
    .pill {{
      display: inline-flex; align-items: center; gap: 6px;
      background: var(--white);
      border: 1px solid var(--divider);
      color: var(--text2);
      font-size: 12px; font-weight: 500;
      padding: 7px 14px; border-radius: 20px;
      box-shadow: 0 1px 4px rgba(0,0,0,.05);
    }}
    .pill-dot {{
      width: 7px; height: 7px; border-radius: 50%;
      background: var(--green);
    }}
    .pill-dot.amber {{ background: var(--amber-primary); }}
    .pill-dot.blue  {{ background: #3B82F6; }}

    /* ── CTA card ── */
    .cta-section {{
      padding: 20px 16px 0;
      background: var(--ivory);
    }}
    .cta-card {{
      background: var(--white);
      border: 1px solid var(--divider);
      border-radius: 24px;
      padding: 24px 20px;
      box-shadow: 0 4px 20px rgba(0,0,0,.06), 0 1px 4px rgba(0,0,0,.04);
    }}

    .btn {{
      display: flex; align-items: center; justify-content: center; gap: 10px;
      width: 100%; padding: 15px 20px;
      border-radius: 14px; font-size: 15px; font-weight: 700;
      font-family: 'Poppins', sans-serif;
      text-decoration: none; border: none; cursor: pointer;
      transition: transform .12s ease, box-shadow .12s ease;
      letter-spacing: -.01em;
    }}
    .btn:active {{ transform: scale(.97); }}
    .btn svg {{ width: 18px; height: 18px; flex-shrink: 0; }}

    .btn-primary {{
      background: linear-gradient(135deg, #D97706 0%, #B45309 100%);
      color: white;
      box-shadow: 0 6px 20px rgba(180,83,9,.35);
      margin-bottom: 10px;
    }}
    .btn-primary:hover {{ box-shadow: 0 8px 28px rgba(180,83,9,.5); }}

    .btn-secondary {{
      background: var(--amber-tint);
      border: 1.5px solid var(--amber-light);
      color: var(--amber-dark);
    }}
    .btn-secondary:hover {{ background: var(--amber-light); }}

    .cta-note {{
      text-align: center;
      font-size: 11px; color: var(--text3);
      margin-top: 14px; line-height: 1.7;
    }}

    /* ── How it works ── */
    .section {{
      padding: 28px 16px;
      background: var(--ivory);
    }}
    .section-title {{
      font-size: 10px; font-weight: 700; letter-spacing: .12em;
      color: var(--text3); text-transform: uppercase;
      text-align: center; margin-bottom: 20px;
    }}
    .steps {{
      display: flex; flex-direction: column; gap: 12px;
      max-width: 400px; margin: 0 auto;
    }}
    .step {{
      display: flex; align-items: flex-start; gap: 14px;
      background: var(--white);
      border: 1px solid var(--divider);
      border-radius: 16px; padding: 16px;
      box-shadow: 0 1px 4px rgba(0,0,0,.04);
    }}
    .step-num {{
      width: 36px; height: 36px; border-radius: 10px; flex-shrink: 0;
      background: var(--amber-light);
      border: 1px solid rgba(180,83,9,.2);
      display: flex; align-items: center; justify-content: center;
      font-size: 14px; font-weight: 800; color: var(--amber-primary);
    }}
    .step-body h3 {{
      font-size: 13.5px; font-weight: 700; color: var(--text1); margin-bottom: 3px;
    }}
    .step-body p {{
      font-size: 12px; color: var(--text2); line-height: 1.55;
    }}

    /* ── Divider ── */
    .divider {{
      height: 1px; background: var(--divider); margin: 0 16px;
    }}

    /* ── Footer ── */
    .footer {{
      padding: 20px 20px 40px;
      text-align: center;
      background: var(--ivory);
    }}
    .footer-logo {{
      font-size: 13px; font-weight: 700;
      color: var(--text3); margin-bottom: 4px;
    }}
    .footer-logo span {{ color: var(--divider); }}
    .footer-sub {{
      font-size: 11px; color: var(--text3); line-height: 1.6;
    }}
  </style>
</head>
<body>

  <!-- Hero -->
  <div class="hero">
    <div class="hero-content">
      <span class="mango-float">🥭</span>
      <div class="ai-badge">✦ AI-Tracked Harvest</div>
      <div class="hero-farm">{farm_name}</div>
      <p class="hero-sub">Fresh Harumanis mango, tracked from branch to your door.</p>
    </div>
  </div>

  <!-- Feature pills -->
  <div class="pills">
    <div class="pill"><div class="pill-dot"></div> Direct from farm</div>
    <div class="pill"><div class="pill-dot amber"></div> AI ripeness check</div>
    <div class="pill"><div class="pill-dot blue"></div> Ripeness alerts</div>
  </div>

  <!-- CTA -->
  <div class="cta-section">
    <div class="cta-card">
      <a class="btn btn-primary" href="{deep_link}">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="5" y="2" width="14" height="20" rx="2" ry="2"/>
          <line x1="12" y1="18" x2="12.01" y2="18"/>
        </svg>
        Open in Beli Harumanis App
      </a>
      <a class="btn btn-secondary" href="{apk_url}">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
          <polyline points="7 10 12 15 17 10"/>
          <line x1="12" y1="15" x2="12" y2="3"/>
        </svg>
        Download Beli Harumanis
      </a>
      <p class="cta-note">
        Already installed? Tap "Open in App" above.<br/>
        First time? Download, install, then tap "Open in App".
      </p>
    </div>
  </div>

  <!-- How it works -->
  <div class="section">
    <div class="section-title">How It Works</div>
    <div class="steps">
      <div class="step">
        <div class="step-num">1</div>
        <div class="step-body">
          <h3>AI scans the mango</h3>
          <p>Farmer photographs fruit on the tree. AI measures size and predicts harvest date.</p>
        </div>
      </div>
      <div class="step">
        <div class="step-num">2</div>
        <div class="step-body">
          <h3>Order direct from farm</h3>
          <p>Browse, check ripeness stage, and place your order — picked fresh for you.</p>
        </div>
      </div>
      <div class="step">
        <div class="step-num">3</div>
        <div class="step-body">
          <h3>Get notified when ready</h3>
          <p>Set a reminder. The app alerts you when your Harumanis is at peak sweetness.</p>
        </div>
      </div>
    </div>
  </div>

  <div class="divider"></div>

  <!-- Footer -->
  <div class="footer">
    <div class="footer-logo">{farm_name} <span>·</span> UniMAP</div>
    <div class="footer-sub">AI-based Harumanis mango harvest tracking<br/>Universiti Malaysia Perlis</div>
  </div>

</body>
</html>"""
