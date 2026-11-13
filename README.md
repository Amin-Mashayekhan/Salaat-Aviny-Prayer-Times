# Salaat | Aviny Prayer Times

A calm, ad-free prayer-times and azan app for Windows. It works offline, lives in the system tray and
plays the azan on time. It is a from-scratch rewrite, in Flutter, of the old *Aviny Prayer Times*
(اوقات شرعی آوینی) desktop program, made for Shia users in Iran and usable anywhere.

[فارسی](#فارسی) · [Contributing](CONTRIBUTING.md) · [Support the project](#support-the-project)

## Download

**[Download page with installation guide and screenshots](https://amin-mashayekhan.github.io/Salaat-Aviny-Prayer-Times/)**
(فارسی · English · العربية), or take the file straight from the
[latest release](https://github.com/Amin-Mashayekhan/Salaat-Aviny-Prayer-Times/releases/latest):

| System | File |
|---|---|
| Windows 10 / 11 (64-bit) | `Salaat-Setup.exe` (installer, recommended) or `Salaat-windows-x64.zip` (portable) |
| Android 7 and later | `Salaat-android.apk` (from version 1.1.0) |
| Linux (64-bit) | `Salaat-linux-x64.tar.gz` (from 1.1.0) |
| macOS 10.15 and later | `Salaat-macos.zip` (from 1.1.0, not notarised: right-click > Open the first time) |
| Any system, iPhone included | [the web version](https://amin-mashayekhan.github.io/Salaat-Aviny-Prayer-Times/app/) in the browser (the azan sounds while the page is open) |
| iOS app | not available yet (needs an Apple developer account) |

The installer is not code-signed yet, so Windows SmartScreen may warn on the first run: press
**More info**, then **Run anyway**. `SHA256SUMS.txt` lets you check the download.

## Features

- **Times:** Imsak, Fajr, Sunrise, Dhuhr, Asr, Sunset, Maghrib, Isha and Islamic midnight. The Tehran
  (Institute of Geophysics) and Jafari (Leva, Qom) methods plus five international ones, with
  adjustable angles and per-prayer offsets.
- **No daylight-saving surprises:** Iran has had no daylight saving since 2022. The app takes UTC offsets
  from a bundled time-zone database or from a fixed offset you choose, and never changes your choice on
  its own.
- **Azan and reminders:** a sound and volume per prayer, reminders before the azan, quick mute and a
  one-click stop. Notifications from the tray.
- **Dates:** Shamsi (Jalali), Hijri (with a manual adjustment) and Gregorian, a converter and a monthly
  timetable.
- **Qibla:** a compass and the times the sun stands in the qibla direction, and a map (street or
  satellite) that draws the shortest path to the Kaaba from your city, your device position or any point
  you tap.
- **Wake-up alarms:** wake the PC from sleep, play a sound, optionally go back to sleep.
- **Private:** no account, no ads, no tracking. The network is used only for the optional clock check
  and, if you switch it on, for map pictures.
- **Eight languages:** فارسی, English, العربية, Türkçe, اردو, Azərbaycanca, Bahasa Indonesia and Français.
  Persian, Arabic and Urdu are right-to-left, with their own digit styles.

## Status

The Windows app builds, starts and its logic is covered by automated tests. The tray icon, toast
notifications, sound playback and wake-up alarms still need testing on more real machines; the manual
checklists in [docs/](docs) say what to look at. The translations other than Persian and English have not
yet been reviewed by native speakers; corrections are very welcome (see Contributing).

## Build and run

You need Flutter 3.47 (stable) with Windows desktop support and Visual Studio with the
"Desktop development with C++" workload.

```
flutter pub get
cd app
flutter run -d windows            # or: flutter build windows --release
```

Tests and checks are listed in [CONTRIBUTING.md](CONTRIBUTING.md). How the code is organised is
explained in [docs/architecture.md](docs/architecture.md); how the times are computed in
[docs/prayer-times.md](docs/prayer-times.md).

## Repository layout

| Path | Contents |
|---|---|
| `app/` | The thin Windows runner and the plugin-based platform code |
| `packages/prayer_core/` | Pure Dart: prayer-time calculator, qibla, schedule builder |
| `packages/owghat_lib/` | Everything else that can be tested: UI, state, scheduling, translations |
| `seed/` | Source data: cities, provinces, countries, reference test data |
| `tools/` | Generators and the Python reference implementation of the algorithm |
| `docs/` | Architecture, algorithm notes and manual test checklists |

## Support the project

The app is free, has no ads and keeps no feature behind a payment. If it is useful to you and you want
to help it keep growing, you can give in one of these ways. Please copy the number or address from
here or from the About page of the app, and only from there.

| Way | Where it works | Details |
|---|---|---|
| Iranian bank card | **Iran only** (Iranian bank cards on the Shetab network) | Card number: `6219 8618 3801 9973` |
| USDT (Tether) | **All countries**, wherever a crypto wallet or exchange is available | Network: **BEP20 (BNB Smart Chain)**<br>Address: `0x4319c7ad3dd5099d93f8128b68494486b01bede1` |

Send only USDT over the BEP20 network to that address. Another coin, or another network, loses the money.

## Contributing

Bug reports, ideas, code, translations, testing on different machines and city data fixes are all
welcome. Start with [CONTRIBUTING.md](CONTRIBUTING.md). Open an issue on the
[issue tracker](https://github.com/Amin-Mashayekhan/Salaat-Aviny-Prayer-Times/issues).

## Author

Mohammad Amin Mashayekhan (محمد امین مشایخان)

| Way | Contact |
|---|---|
| GitHub | [Amin-Mashayekhan](https://github.com/Amin-Mashayekhan) |
| Telegram | [@Amin_NiceDesign](https://t.me/Amin_NiceDesign) (the way to reach me from anywhere) |
| E-mail | amin.mashayekhan@gmail.com |
| Mobile | `+9892128870991`: calls and text messages **only from Iran**; from outside Iran, please use Telegram |

## Licence

[MIT](LICENSE). The Vazirmatn font keeps its SIL Open Font License, and the generated placeholder sounds
are CC0.

---

## فارسی

**Salaat | Aviny Prayer Times** یک برنامه‌ی آرام و بدون تبلیغ برای دیدن اوقات شرعی و پخش اذان در ویندوز است.
بدون اینترنت کار می‌کند، در سینی سیستم می‌نشیند و اذان را سروقت پخش می‌کند. بازنویسی تازه‌ی برنامه‌ی قدیمی
«اوقات شرعی آوینی» با Flutter است.

- اوقات: امساک، اذان صبح، طلوع، ظهر، عصر، غروب، مغرب، عشا و نیمه‌شب شرعی؛ روش‌های ژئوفیزیک تهران و جعفری
  (لوا، قم) و پنج روش جهانی.
- بدون غافلگیری ساعت تابستانی: برنامه خودش ساعت تابستانی ندارد و انتخاب شما را هیچ‌وقت تغییر نمی‌دهد.
- اذان و یادآوری، تقویم شمسی/هجری/میلادی، مبدل تاریخ و جدول ماهانه.
- قبله: قطب‌نما و نقشه (خیابانی یا ماهواره‌ای) با خط کوتاه‌ترین مسیر تا کعبه از شهر شما، موقعیت دستگاه یا هر نقطه.
- بیدارباش: بیدار کردن رایانه از خواب و پخش صدا.
- هشت زبان: فارسی، انگلیسی، عربی، ترکی استانبولی، اردو، آذربایجانی، اندونزیایی و فرانسوی.

### حمایت مالی

برنامه رایگان است و هیچ قابلیتی پشت پرداخت قفل نیست. اگر خواستید از ادامه‌ی توسعه‌ی آن حمایت کنید:

| روش | قابل استفاده در | مشخصات |
|---|---|---|
| کارت بانکی ایران | **فقط ایران** (کارت‌های بانکی ایرانی عضو شبکه‌ی شتاب) | شماره‌ی کارت: `6219 8618 3801 9973` |
| رمزارز USDT (تتر) | **همه‌ی کشورها** (هر جا که کیف پول یا صرافی رمزارز در دسترس باشد) | شبکه: **BEP20 (BNB Smart Chain)**<br>آدرس: `0x4319c7ad3dd5099d93f8128b68494486b01bede1` |

فقط USDT را از شبکه‌ی BEP20 بفرستید؛ ارسال رمزارز دیگر یا از شبکه‌ی دیگر باعث از دست رفتن مبلغ می‌شود.

### مشارکت

گزارش خطا، پیشنهاد، کد، ترجمه، آزمایش روی دستگاه‌های مختلف و اصلاح اطلاعات شهرها همه خوش‌آمدند.
راهنما در [CONTRIBUTING.md](CONTRIBUTING.md) است.
