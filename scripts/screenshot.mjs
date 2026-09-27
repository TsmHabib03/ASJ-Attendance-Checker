/**
 * AttendEase README screenshot harness (puppeteer + headless Chrome)
 *
 * Usage:  node scripts/screenshot.mjs <batch>
 *         batches: pilot | admin | teacher | staff | exports | all
 *
 * Requires the app to be served locally (BASE env var, default http://127.0.0.1:8199)
 * and credentials in %TEMP%/proj_creds.json (keys: id, user, pass, role).
 *
 * Captures JPEG screenshots (1600x1000 viewport, full page, quality 90) into
 * readMeAssets/ and writes a temp ._report.json per batch (deleted after review).
 */
import { execFileSync } from 'node:child_process';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

const require = createRequire(import.meta.url);
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const ROOT = path.resolve(__dirname, '..');
const OUT = path.join(ROOT, 'readMeAssets');
const BASE = process.env.BASE || 'http://127.0.0.1:8199';
const TMP = os.tmpdir();

function loadPuppeteer() {
  try { return require('puppeteer'); } catch { /* fall back to global npm root */ }
  const candidates = [
    process.env.APPDATA && path.join(process.env.APPDATA, 'npm', 'node_modules', 'puppeteer'),
    path.join(os.homedir(), '.npm-global', 'lib', 'node_modules', 'puppeteer'),
  ].filter(Boolean);
  for (const c of candidates) { if (fs.existsSync(c)) return require(c); }
  const root = execFileSync('npm.cmd', ['root', '-g'], { encoding: 'utf8', shell: true }).trim();
  return require(path.join(root, 'puppeteer'));
}

function loadCreds() {
  const raw = fs.readFileSync(path.join(TMP, 'proj_creds.json'), 'utf8').replace(/^\uFEFF/, '');
  const list = JSON.parse(raw);
  const map = {};
  for (const c of list) map[c.role] = c;
  return map;
}

const ROUTES = {
  pilot: [
    { id: '01', slug: 'landing', route: '/', screen: 'Public landing page', role: 'public' },
    { id: '02', slug: 'scan_qr', route: '/scan_attendance.php', screen: 'QR attendance scanner (kiosk)', role: 'public' },
    { id: '03', slug: 'login', route: '/admin/login.php', screen: 'Admin sign-in', role: 'public' },
    { id: '04', slug: 'forgot_password', route: '/admin/forgot_password.php', screen: 'Forgot password', role: 'public' },
    { id: '05', slug: 'reset_password', route: '/admin/reset_password.php', screen: 'Password reset (token form)', role: 'public' },
  ],
  admin: [
    { id: '06', slug: 'admin_dashboard', route: '/admin/dashboard.php', screen: 'Admin dashboard', role: 'admin' },
    { id: '07', slug: 'manage_students', route: '/admin/manage_students.php', screen: 'Manage students', role: 'admin' },
    { id: '08', slug: 'manage_teachers', route: '/admin/manage_teachers.php', screen: 'Manage teachers', role: 'admin' },
    { id: '09', slug: 'students_directory', route: '/admin/students_directory.php', screen: 'Students directory', role: 'admin' },
    { id: '10', slug: 'manage_sections', route: '/admin/manage_sections.php', screen: 'Manage sections', role: 'admin' },
    { id: '11', slug: 'manage_schedules', route: '/admin/manage_schedules.php', screen: 'Attendance schedules', role: 'admin' },
    { id: '12', slug: 'manage_badges', route: '/admin/manage_badges.php', screen: 'Manage badges', role: 'admin' },
    { id: '13', slug: 'manual_attendance', route: '/admin/manual_attendance.php', screen: 'Manual attendance', role: 'admin' },
    { id: '14', slug: 'attendance_reports', route: '/admin/attendance_reports_sections.php', screen: 'Attendance reports by section', role: 'admin',
      prep: async (page) => {
        await page.$eval('#start_date', (el) => { el.value = '2026-01-01'; el.dispatchEvent(new Event('input', { bubbles: true })); el.dispatchEvent(new Event('change', { bubbles: true })); });
        await page.$eval('#end_date', (el) => { el.value = '2026-12-31'; el.dispatchEvent(new Event('input', { bubbles: true })); el.dispatchEvent(new Event('change', { bubbles: true })); });
        await page.click('#reportFilters button[type="submit"]');
        await sleep(3000);
      } },
    { id: '15', slug: 'behavior_monitoring', route: '/admin/behavior_monitoring.php', screen: 'Behavior monitoring', role: 'admin' },
    { id: '16', slug: 'sms_logs', route: '/admin/sms_logs.php', screen: 'SMS logs', role: 'admin' },
    { id: '17', slug: 'students_table', route: '/admin/view_students.php', screen: 'Students table view', role: 'admin' },
  ],
  teacher: [
    { id: '18', slug: 'teacher_dashboard', route: '/admin/dashboard.php', screen: 'Teacher dashboard', role: 'teacher' },
    { id: '19', slug: 'teacher_students_directory', route: '/admin/students_directory.php', screen: 'Teacher students directory', role: 'teacher' },
    { id: '20', slug: 'teacher_behavior_monitoring', route: '/admin/behavior_monitoring.php', screen: 'Teacher behavior monitoring', role: 'teacher' },
  ],
  staff: [
    { id: '21', slug: 'staff_dashboard', route: '/admin/dashboard.php', screen: 'Staff dashboard', role: 'staff' },
    { id: '22', slug: 'staff_students_directory', route: '/admin/students_directory.php', screen: 'Staff students directory', role: 'staff' },
  ],
  exports: [
    {
      id: '23', slug: 'export_attendance_pdf', role: 'admin', screen: 'PDF attendance export (page 1)',
      url: `${BASE}/api/export_attendance_sections_pdf.php?start_date=2026-01-01&end_date=2026-12-31`,
      kind: 'pdf', route: '/api/export_attendance_sections_pdf.php (PDF download)',
    },
    {
      id: '24', slug: 'export_attendance_csv', role: 'admin', screen: 'CSV attendance export (preview)',
      url: `${BASE}/api/export_attendance_sections_csv.php?start_date=2026-01-01&end_date=2026-12-31`,
      kind: 'csv', route: '/api/export_attendance_sections_csv.php (CSV download)',
    },
  ],
};

const PY_HELPER = path.join(TMP, 'attendease_render_export.py');
const RENDER_PY = `
import sys
import fitz
from PIL import Image, ImageDraw, ImageFont

src, out, kind = sys.argv[1], sys.argv[2], sys.argv[3]
if kind == "pdf":
    doc = fitz.open(src)
    pix = doc[0].get_pixmap(matrix=fitz.Matrix(2.2, 2.2))
    img = Image.frombytes("RGB", (pix.width, pix.height), pix.samples)
    gray = img.convert("L")
    bbox = gray.point(lambda p: 255 if p < 245 else 0).getbbox()
    if bbox:
        pad = 24
        img = img.crop((max(0, bbox[0]-pad), max(0, bbox[1]-pad),
                        min(img.width, bbox[2]+pad), min(img.height, bbox[3]+pad)))
    img.save(out, "JPEG", quality=90)
else:
    with open(src, "r", encoding="utf-8-sig", errors="replace") as f:
        lines = f.read().splitlines()[:70]
    try:
        font = ImageFont.truetype("C:/Windows/Fonts/consola.ttf", 17)
    except Exception:
        font = ImageFont.load_default()
    pad = 24
    lines = [ln[:170] for ln in lines]
    meas = ImageDraw.Draw(Image.new("RGB", (8, 8)))
    widths = [meas.textlength(ln, font=font) for ln in lines] or [100.0]
    asc, desc = font.getmetrics()
    line_h = asc + desc + 6
    img = Image.new("RGB", (max(int(max(widths)) + pad * 2, 480), len(lines) * line_h + pad * 2), "white")
    d = ImageDraw.Draw(img)
    y = pad
    for ln in lines:
        d.text((pad, y), ln, fill=(20, 20, 20), font=font)
        y += line_h
    img.save(out, "JPEG", quality=90)
print("OK")
`;
fs.writeFileSync(PY_HELPER, RENDER_PY);

// One-shot helper: creates a valid password-reset token for the admin account
// (so 05 can show the real token form instead of the "expired link" state),
// or clears it afterwards. Never prints or stores the hashed form.
const PHP_HELPER = path.join(TMP, 'attendease_reset_token.php');
const PHP_SRC = [
  '<?php',
  `require '${path.join(ROOT, 'config', 'db_config.php').replace(/\\/g, '/')}';`,
  '$mode = $argv[1] ?? "get";',
  'if ($mode === "clear") {',
  '    $pdo->prepare("UPDATE admin_users SET reset_token = NULL, reset_token_expires_at = NULL WHERE id = 1")->execute();',
  '    echo "OK"; exit;',
  '}',
  '$plain = bin2hex(random_bytes(32));',
  '$stmt = $pdo->prepare("UPDATE admin_users SET reset_token = :t, reset_token_expires_at = DATE_ADD(NOW(), INTERVAL 1 HOUR) WHERE id = 1");',
  '$stmt->execute([":t" => hash("sha256", $plain)]);',
  'echo $plain;',
].join('\n');
fs.writeFileSync(PHP_HELPER, PHP_SRC);

// Headless Chrome's fake camera rejects the scanner page's strict constraints
// (min frameRate / focusMode / zoom) -> OverconstrainedError -> red error card.
// Relax them harness-side so the real scanner UI renders with a live feed.
function cameraShim() {
  const md = navigator.mediaDevices;
  if (!md || !md.getUserMedia) return;
  const orig = md.getUserMedia.bind(md);
  md.getUserMedia = (c) => {
    let n;
    try { n = JSON.parse(JSON.stringify(c)); } catch { return orig(c); }
    if (n.video && typeof n.video === 'object') n.video = true;
    return orig(n).catch(() => orig({ audio: !!n.audio, video: true }));
  };
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

async function healthCheck() {
  const res = await fetch(`${BASE}/admin/login.php`);
  if (res.status !== 200) throw new Error(`health check failed: ${BASE} -> ${res.status}`);
}

async function autoScroll(page) {
  await page.evaluate(async () => {
    await new Promise((resolve) => {
      let total = 0;
      const step = 500;
      const timer = setInterval(() => {
        window.scrollBy(0, step);
        total += step;
        if (total >= document.body.scrollHeight + 1000) {
          clearInterval(timer);
          window.scrollTo(0, 0);
          resolve();
        }
      }, 60);
    });
  });
}

async function prep(page) {
  await page.addStyleTag({
    content: '[data-aos]{opacity:1!important;transform:none!important;transition:none!important;animation:none!important}*{animation-duration:0s!important;transition-duration:0s!important}',
  });
  await autoScroll(page);
  await sleep(400);
}

async function shoot(page, route, file) {
  let status = 'ok';
  try {
    await page.goto(BASE + route.route, { waitUntil: 'networkidle0', timeout: 45000 });
  } catch (e) {
    if (/Timeout/i.test(e.message)) status = 'timeout-settled';
    else throw e;
  }
  await prep(page);
  if (route.prep) { await route.prep(page); await prep(page); }
  await page.screenshot({ path: file, type: 'jpeg', quality: 90, fullPage: true });
  return { status, finalPath: new URL(page.url()).pathname };
}

async function login(context, creds, browser) {
  const page = await context.newPage();
  await page.evaluateOnNewDocument(cameraShim);
  await page.setViewport({ width: 1600, height: 1000 });
  await page.goto(`${BASE}/admin/login.php`, { waitUntil: 'networkidle0', timeout: 45000 });
  await page.type('#username', creds.user);
  await page.type('#password', creds.pass);
  await Promise.all([
    page.waitForFunction(() => !location.pathname.includes('login'), { timeout: 20000 }).catch(() => {}),
    page.click('#btnSignin'),
  ]);
  await sleep(600);
  const url = page.url();
  if (url.includes('/login')) {
    const err = await page.$eval('#errorAlert', (el) => el.innerText).catch(() => '');
    throw new Error(`login failed for role=${creds.role}: ${err.slice(0, 120)}`);
  }
  return page; // keep page as the session holder for cookie export
}

async function downloadExport(cookies, url, ext) {
  const cookieHeader = cookies.map((c) => `${c.name}=${c.value}`).join('; ');
  const res = await fetch(url, { headers: { Cookie: cookieHeader } });
  if (!res.ok) throw new Error(`export download failed: ${res.status}`);
  const buf = Buffer.from(await res.arrayBuffer());
  const tmp = path.join(TMP, `attendease_export_${Date.now()}.${ext}`);
  fs.writeFileSync(tmp, buf);
  return { tmp, status: res.status, bytes: buf.length };
}

async function runBatch(batch, creds) {
  let routes = ROUTES[batch];
  if (!routes) throw new Error(`unknown batch: ${batch}`);
  fs.mkdirSync(OUT, { recursive: true });
  await healthCheck();

  // pilot: 05 must show the real token form, not the "link expired" state
  let resetToken = null;
  if (batch === 'pilot') {
    resetToken = execFileSync('php', [PHP_HELPER, 'get'], { encoding: 'utf8' }).trim();
    if (!/^[0-9a-f]{64}$/.test(resetToken)) throw new Error('reset token generation failed');
    routes = routes.map((r) => (r.id === '05' ? { ...r, route: `/admin/reset_password.php?token=${resetToken}` } : r));
  }

  const puppeteer = loadPuppeteer();
  const browser = await puppeteer.launch({
    headless: true,
    args: [
      '--no-sandbox',
      '--disable-dev-shm-usage',
      '--use-fake-ui-for-media-stream',
      '--use-fake-device-for-media-stream',
      '--autoplay-policy=no-user-gesture-required',
    ],
  });

  const report = [];
  let aborted = null;
  try {
    if (batch === 'exports') {
      // exports download via fetch() using the authenticated session's cookies
      const ctx = await browser.createBrowserContext();
      const sp = await login(ctx, creds.admin, browser);
      const cookies = await ctx.cookies();
      for (const r of routes) {
        const file = path.join(OUT, `${r.id}_${r.slug}.jpg`);
        let status = 'ok';
        let bytes = 0;
        try {
          const { tmp, status: httpStatus } = await downloadExport(cookies, r.url, r.kind);
          execFileSync('python', [PY_HELPER, tmp, file, r.kind], { stdio: 'pipe' });
          fs.unlinkSync(tmp);
          status = `http_${httpStatus}`;
          bytes = fs.statSync(file).size;
        } catch (e) {
          status = `error: ${e.message.slice(0, 80)}`;
        }
        report.push({ id: r.id, url: r.url.replace(BASE, ''), role: r.role, status, file: path.basename(file), bytes });
      }
      await sp.close();
      await ctx.close();
    } else {
      const needsLogin = routes.some((r) => r.role !== 'public');
      const context = await browser.createBrowserContext();
      let sessionPage;
      if (needsLogin) {
        sessionPage = await login(context, creds[routes[0].role], browser);
      } else {
        sessionPage = await context.newPage();
        await sessionPage.evaluateOnNewDocument(cameraShim);
        await sessionPage.setViewport({ width: 1600, height: 1000 });
      }
      const seen = new Set();
      for (const r of routes) {
        const file = path.join(OUT, `${r.id}_${r.slug}.jpg`);
        const { status, finalPath } = await shoot(sessionPage, r, file);
        seen.add(finalPath);
        report.push({
          id: r.id, url: r.route, role: r.role, status,
          file: path.basename(file), bytes: fs.existsSync(file) ? fs.statSync(file).size : 0,
        });
      }
      if (seen.size === 1 && routes.length > 3) {
        aborted = `ABORT: every route in batch '${batch}' ended on ${[...seen][0]} — redirect loop suspected; refusing to keep ${routes.length} identical shots`;
      }
      await sessionPage.close();
      await context.close();
    }
  } finally {
    await browser.close();
    if (resetToken) {
      try { execFileSync('php', [PHP_HELPER, 'clear'], { stdio: 'pipe' }); } catch { /* best-effort cleanup */ }
    }
  }

  const reportPath = path.join(ROOT, '._report.json');
  fs.writeFileSync(reportPath, JSON.stringify({ batch, aborted, report }, null, 2));
  console.log(JSON.stringify({ batch, aborted, report }, null, 2));
  if (aborted) process.exitCode = 2;
}

const batchArg = process.argv[2] || 'pilot';
const creds = loadCreds();
const batches = batchArg === 'all' ? ['pilot', 'admin', 'teacher', 'staff', 'exports'] : [batchArg];
for (const b of batches) {
  await runBatch(b, creds);
}
