# `readMeAssets/` — screenshot manifest

Every image shipped in `README.md`, captured from this repository by
[`scripts/screenshot.mjs`](../scripts/screenshot.mjs) (Node + Puppeteer, headless Chrome).
Captured 2026-09-27 against a local PHP build server on `127.0.0.1:8199`.

## Inventory

| # | File | Screen | Route | Role |
|---|------|--------|-------|------|
| 01 | `01_landing.jpg` | Public landing page | `/` | public |
| 02 | `02_scan_qr.jpg` | QR attendance scanner (kiosk) | `/scan_attendance.php` | public |
| 03 | `03_login.jpg` | Admin sign-in | `/admin/login.php` | public |
| 04 | `04_forgot_password.jpg` | Forgot password | `/admin/forgot_password.php` | public |
| 05 | `05_reset_password.jpg` | Password reset (create new password) | `/admin/reset_password.php?token=…` | public |
| 06 | `06_admin_dashboard.jpg` | Admin dashboard | `/admin/dashboard.php` | admin |
| 07 | `07_manage_students.jpg` | Manage students | `/admin/manage_students.php` | admin |
| 08 | `08_manage_teachers.jpg` | Manage teachers | `/admin/manage_teachers.php` | admin |
| 09 | `09_students_directory.jpg` | Students directory | `/admin/students_directory.php` | admin |
| 10 | `10_manage_sections.jpg` | Manage sections | `/admin/manage_sections.php` | admin |
| 11 | `11_manage_schedules.jpg` | Attendance schedules | `/admin/manage_schedules.php` | admin |
| 12 | `12_manage_badges.jpg` | Manage badges | `/admin/manage_badges.php` | admin |
| 13 | `13_manual_attendance.jpg` | Manual attendance entry | `/admin/manual_attendance.php` | admin |
| 14 | `14_attendance_reports.jpg` | Attendance reports (filters + generated report) | `/admin/attendance_reports_sections.php` | admin |
| 15 | `15_behavior_monitoring.jpg` | Behavior monitoring | `/admin/behavior_monitoring.php` | admin |
| 16 | `16_sms_logs.jpg` | SMS logs | `/admin/sms_logs.php` | admin |
| 17 | `17_students_table.jpg` | Students table view | `/admin/view_students.php` | admin |
| 18 | `18_teacher_dashboard.jpg` | Teacher dashboard | `/admin/dashboard.php` | teacher |
| 19 | `19_teacher_students_directory.jpg` | Teacher students directory | `/admin/students_directory.php` | teacher |
| 20 | `20_teacher_behavior_monitoring.jpg` | Teacher behavior monitoring | `/admin/behavior_monitoring.php` | teacher |
| 21 | `21_staff_dashboard.jpg` | Staff dashboard | `/admin/dashboard.php` | staff |
| 22 | `22_staff_students_directory.jpg` | Staff students directory | `/admin/students_directory.php` | staff |
| 23 | `23_export_attendance_pdf.jpg` | PDF attendance export (page 1) | `/api/export_attendance_sections_pdf.php` | admin |
| 24 | `24_export_attendance_csv.jpg` | CSV attendance export (preview) | `/api/export_attendance_sections_csv.php` | admin |

## How they were captured

- **Harness:** `node scripts/screenshot.mjs <batch>` — batches: `pilot`, `admin`, `teacher`, `staff`, `exports`.
- **Framing:** 1600×1000 viewport, `fullPage: true`, JPEG quality 90, `networkidle0` + settle,
  scroll-through before the shot, AOS/animation CSS neutralized.
- **Auth:** real login sessions per role (admin, teacher, staff); credentials live only in a
  local temp file outside the repo and are never committed.
- **Exports (23/24):** downloaded through the authenticated session, then rendered to JPEG
  (PyMuPDF for the PDF, Pillow for the CSV); the PDF render is cropped to content.
- **Scanner (02):** headless Chrome's fake camera feed with a harness-side
  `getUserMedia` constraint shim — the page demands `min frameRate 30` / `focusMode`,
  which a fake device cannot satisfy. App code is untouched.
- **Reset form (05):** shot with a real one-hour reset token generated for the admin user,
  cleared from the database immediately after the capture.
- **Report (14):** the harness sets 2026-01-01 → 2026-12-31 and clicks *Generate Report*
  so the summary cards and records table are populated.

## Verification

- 24 files, all `.jpg`, zero other files.
- Blank check (grayscale, 240×240 downscale, non-white pixel share): **0 near-blank images**
  (lowest ink ratio: `21_staff_dashboard.jpg` ≈ 4.8% — an empty "today" dashboard, see below).
- Every `README.md` image reference resolves to a file in this folder (checked both ways).

## Known issues & deliberate exclusions

| Item | Observed | Notes |
|------|----------|-------|
| `/admin/attendance_reports.php` | **404** | Still linked from `admin/manage_students.php:1072`; the real page is `attendance_reports_sections.php` (shot 14). |
| `/admin/my_attendance.php` | **404** | Referenced by the side navigation menu, but the file does not exist. |
| `competencies.html` | 200, **0 bytes** | Empty file at the repo root — not captured. |
| `/view_students.php` | 200, **0 bytes** when unauthenticated; renders for a logged-in admin | Captured as `17_students_table.jpg`. |
| `admin/config.php` | 200, **0 output** | Bootstrap/library file, not a screen — not captured. |
| `includes/navigation.php` | — | Never `include`d anywhere; not captured. |
| `debug_*.php`, `test_*.php`, `apply_*_migration.php` | — | Development utilities; deliberately excluded from the tour. |
| `/api/*` (other endpoints) | JSON | Not screens; only the two export endpoints are visualized (23, 24). |
| **Schema drift (bug)** | Code vs. dumps | `admin/reset_password.php`, `api/request_password_reset.php` and `api/update_password.php` query `reset_token_expires_at`, while every SQL dump and `database/migration_v3.sql` define `reset_token_expires`. Password reset fails on a fresh install until the column is added (added locally so shot `05` could render). |
| Dashboard "today" counters = 0 | Data | Seeded attendance rows are dated Feb 2026; screenshots were taken 2026-09-27, so the per-day widgets are empty while totals are populated. |

## Recommended README shortlist (12)

`01_landing` · `02_scan_qr` · `03_login` · `06_admin_dashboard` · `07_manage_students` ·
`09_students_directory` · `14_attendance_reports` · `15_behavior_monitoring` ·
`18_teacher_dashboard` · `21_staff_dashboard` · `23_export_attendance_pdf` ·
`24_export_attendance_csv`
