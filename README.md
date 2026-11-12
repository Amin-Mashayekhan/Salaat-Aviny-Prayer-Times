# Salaat | Avini Prayer Times (جایگزین «اوقات شرعی آوینی»)

این پوشه بسته‌ی کامل برنامه‌ریزی برای بازنویسی نرم‌افزار «اوقات شرعی آوینی» (نسخه‌ی ۱.۰.۸.۶، سال ۲۰۱۳) با **Flutter / Dart** است. کد اپ نوشته شده و بخش منطقی آن با آزمون خودکار تأیید شده است، اما **اپ ویندوز کامپایل می‌شود و بالا می‌آید (۲۰۲۶-۱۱-۱۲)، اما تری، نوتیفیکیشن، صدا و بیدارباش هنوز روی سخت‌افزار آزموده نشده‌اند**. وضعیت دقیق در [PROGRESS.md](PROGRESS.md) است.

## از کجا شروع کنم؟

| فایل | محتوا |
|---|---|
| [docs/01-PRODUCT-SPEC.md](docs/01-PRODUCT-SPEC.md) | اپ جدید چه کارهایی می‌کند (ویژگی‌ها با اولویت P0 / P1 / P2) |
| [docs/02-LEGACY-ANALYSIS.md](docs/02-LEGACY-ANALYSIS.md) | تحلیل مهندسی معکوس برنامه‌ی قدیمی و فهرست باگ‌هایش (از جمله ریشه‌ی باگ جابجایی یک‌ساعته) |
| [docs/03-ARCHITECTURE.md](docs/03-ARCHITECTURE.md) | معماری، ساختار پوشه‌ها، پکیج‌ها و قواعد کدنویسی |
| [docs/04-DOMAIN-SPEC.md](docs/04-DOMAIN-SPEC.md) | مدل زمان، الگوریتم محاسبه‌ی اوقات، موتور زمان‌بندی اذان، تقویم و قبله |
| [docs/05-UI-UX-SPEC.md](docs/05-UI-UX-SPEC.md) | طراحی رابط کاربری، صفحه‌ها و متن‌ها |
| [docs/06-IMPLEMENTATION-PLAN.md](docs/06-IMPLEMENTATION-PLAN.md) | برنامه‌ی پیاده‌سازی در ۱۰ فاز با معیار پذیرش هر کار |
| [docs/07-RESEARCH-NOTES.md](docs/07-RESEARCH-NOTES.md) | نتیجه‌ی بررسی اپ‌های مشابه و پکیج‌ها، با منبع |
| [CLAUDE.md](CLAUDE.md) | قوانین کار برای مدل پیاده‌ساز (خودکار خوانده می‌شود) |
| [PROGRESS.md](PROGRESS.md) | وضعیت پیشرفت؛ بعد از هر جلسه‌ی کاری به‌روز می‌شود |

سندهای `docs/` به انگلیسی نوشته شده‌اند چون مخاطب اصلی‌شان مدل پیاده‌ساز است.

## داده‌ها و ابزارها

| مسیر | محتوا |
|---|---|
| `seed/locations/` | بانک شهرها که از برنامه‌ی قدیمی استخراج و پاک‌سازی شده: ۷۴۲ شهر ایران (۵۶۷ تأییدشده)، ۳۱ استان، ۳۱۹ کشور |
| `seed/golden/prayer_times_golden.json` | ۳۰۰ نمونه‌ی مرجع برای آزمون درستی محاسبه‌ی اوقات |
| `tools/reference/prayer_times_reference.py` | پیاده‌سازی مرجع الگوریتم به پایتون (کد Dart باید همین را بازتولید کند) |
| `tools/legacy/decode_legacy_locations.py` | اسکریپت رمزگشایی فایل‌های شهر برنامه‌ی قدیمی |

## روش کار با مدل پیاده‌ساز

1. Flutter 3.47 و Visual Studio با بار کاری «Desktop development with C++» را نصب کنید، سپس `flutter build windows --release` را در پوشه‌ی `app` اجرا کنید و خطاهای احتمالی کامپایل را رفع کنید.
2. در همین پوشه یک جلسه‌ی Claude Code باز کنید و بنویسید: «کار بعدی `PROGRESS.md` را انجام بده».
3. هر جلسه فقط **یک کار** از برنامه. بعد از هر کار، خروجی آزمون‌ها را نگاه کنید.
4. در پایان فازهای M1، M4 و M7 بهتر است یک مدل قوی‌تر کد را بازبینی کند.

## پرسش‌های باز

پنج تصمیم با شماست (نام نهایی اپ، فایل‌های صوتی اذان و …). در ابتدای [برنامه‌ی پیاده‌سازی](docs/06-IMPLEMENTATION-PLAN.md) فهرست شده‌اند و برای هرکدام یک پیش‌فرض گذاشته شده تا کار متوقف نشود.

## Salaat | Avini Prayer Times for users (English)

Salaat | Avini Prayer Times is a calm, ad-free prayer-times and azan app for Windows, made for Shia users in Iran and usable
anywhere. It works offline, lives in the system tray and plays the azan on time.

- **Times:** Imsak, Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha and Islamic midnight, with the Tehran
  (Institute of Geophysics) and Jafari (Leva, Qom) methods and five international ones.
- **No daylight-saving surprises:** Iran has no DST since 2022; the app takes UTC offsets from a bundled
  time-zone database or from a fixed offset you choose, and never changes your choice on its own.
- **Azan and reminders:** per-prayer sounds and volume, reminders before the azan, quick mute, one-click stop.
- **Dates:** Shamsi, Hijri (with a manual adjustment) and Gregorian, a converter and a monthly timetable.
- **Qibla:** bearing, distance and the times the sun stands in the qibla direction.
- **Wake-up alarms:** wake the PC from sleep, play a sound, optionally go back to sleep.
- **Private:** no account, no ads, no tracking. The only network use is the optional clock check.
- **Languages:** Persian (default, right-to-left) and English.

Status: see `PROGRESS.md`. Build and test instructions: `CONTRIBUTING.md`.
