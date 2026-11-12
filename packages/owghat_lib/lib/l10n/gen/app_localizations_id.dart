// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get aboutAuthorIntro =>
      'Aplikasi ini dibuat dan dikelola oleh pengembang independen. Hubungi untuk melaporkan masalah, memberi saran, atau bekerja sama.';

  @override
  String get aboutAuthorTitle => 'Tentang pengembang';

  @override
  String get aboutContactEmail => 'Email';

  @override
  String get aboutContactGithub => 'GitHub';

  @override
  String get aboutContactName => 'Nama';

  @override
  String get aboutContactPhone => 'Ponsel';

  @override
  String get aboutContactTelegram => 'Telegram';

  @override
  String get aboutCopiedValue => 'Disalin.';

  @override
  String get aboutCopy => 'Salin';

  @override
  String get aboutFontNote =>
      'Font Vazirmatn disertakan di bawah SIL Open Font License 1.1.';

  @override
  String get aboutLicenceNote =>
      'Aplikasi ini dirilis dengan lisensi MIT: Anda bebas menggunakan, mengubah, dan membagikannya.';

  @override
  String get aboutLicences => 'Lisensi sumber terbuka';

  @override
  String get aboutOpen => 'Buka';

  @override
  String get aboutOpenFailed =>
      'Tidak dapat dibuka. Salin alamatnya dan tempel ke peramban atau program email Anda.';

  @override
  String get aboutPhoneNote =>
      'Telepon dan SMS hanya dari dalam Iran. Dari luar Iran, gunakan Telegram saja.';

  @override
  String get aboutSoundNote =>
      'Suara bawaan (azan bawaan dan denting pengingat) hanyalah placeholder sederhana buatan komputer, bukan rekaman siapa pun, dan dirilis di bawah CC0. Pilih suara azan Anda sendiri di Pengaturan.';

  @override
  String get aboutTagline =>
      'Waktu salat dan azan untuk Windows. Berfungsi tanpa internet, tanpa iklan, tanpa akun, dan tanpa pelacakan.';

  @override
  String get aboutTitle => 'Tentang';

  @override
  String aboutVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get appName => 'Salaat | Aviny Prayer Times';

  @override
  String get calendarAdjustEarlier => 'Satu hari lebih awal';

  @override
  String get calendarAdjustLater => 'Satu hari lebih lambat';

  @override
  String calendarAdjustValue(String value) {
    return '$value hari';
  }

  @override
  String calendarConvErrDay(String first, String days) {
    return 'Hari harus antara $first dan $days.';
  }

  @override
  String get calendarConvErrIncomplete => 'Isi tahun, bulan, dan hari.';

  @override
  String get calendarConvErrMonth => 'Bulan harus antara 1 dan 12.';

  @override
  String get calendarConvErrNumber => 'Gunakan angka saja.';

  @override
  String get calendarConvErrRange =>
      'Tanggal ini di luar rentang yang didukung kalender.';

  @override
  String get calendarConverterHint =>
      'Ketik tanggal di salah satu dari tiga kalender; dua kalender lainnya ikut berubah.';

  @override
  String get calendarConverterShow => 'Tampilkan di kalender';

  @override
  String get calendarConverterTitle => 'Pengonversi tanggal';

  @override
  String calendarDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get calendarFieldDay => 'Hari';

  @override
  String get calendarFieldMonth => 'Bulan';

  @override
  String get calendarFieldYear => 'Tahun';

  @override
  String get calendarGridLabel => 'Kalender bulanan';

  @override
  String get calendarHijriAdjust => 'Penyesuaian tanggal kamariah';

  @override
  String get calendarHijriApproxHint =>
      'Perkiraan: kalender kamariah resmi Iran mengikuti rukyat hilal dan bisa berbeda satu hari.';

  @override
  String get calendarHijriUnavailable =>
      'Tidak ada tanggal kamariah di tabel untuk hari ini';

  @override
  String get calendarKindGregorian => 'Masehi';

  @override
  String get calendarKindHijri => 'Hijriah Kamariah';

  @override
  String get calendarKindJalali => 'Hijriah Syamsiah (Jalali)';

  @override
  String calendarMonthGregorian(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Januari',
      'm2': 'Februari',
      'm3': 'Maret',
      'm4': 'April',
      'm5': 'Mei',
      'm6': 'Juni',
      'm7': 'Juli',
      'm8': 'Agustus',
      'm9': 'September',
      'm10': 'Oktober',
      'm11': 'November',
      'm12': 'Desember',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthHijri(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharam',
      'm2': 'Safar',
      'm3': 'Rabiulawal',
      'm4': 'Rabiulakhir',
      'm5': 'Jumadilawal',
      'm6': 'Jumadilakhir',
      'm7': 'Rajab',
      'm8': 'Syaban',
      'm9': 'Ramadan',
      'm10': 'Syawal',
      'm11': 'Zulkaidah',
      'm12': 'Zulhijah',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthJalali(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Farvardin',
      'm2': 'Ordibehesht',
      'm3': 'Khordad',
      'm4': 'Tir',
      'm5': 'Mordad',
      'm6': 'Shahrivar',
      'm7': 'Mehr',
      'm8': 'Aban',
      'm9': 'Azar',
      'm10': 'Dey',
      'm11': 'Bahman',
      'm12': 'Esfand',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthYear(String month, String year) {
    return '$month $year';
  }

  @override
  String get calendarMoonNote =>
      'Tanggal kamariah berasal dari tabel Ummul Qura. Kalender resmi Iran mengikuti rukyat hilal dan bisa berbeda satu hari; jika begitu, geser di sini.';

  @override
  String get calendarNextMonth => 'Bulan berikutnya';

  @override
  String get calendarOpenOnHome => 'Tampilkan di layar utama';

  @override
  String get calendarPanelTimes => 'Waktu salat hari ini';

  @override
  String get calendarPreviousMonth => 'Bulan sebelumnya';

  @override
  String get calendarSeparator => ', ';

  @override
  String get calendarToday => 'Hari ini';

  @override
  String calendarWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Senin',
      'd2': 'Selasa',
      'd3': 'Rabu',
      'd4': 'Kamis',
      'd5': 'Jumat',
      'd6': 'Sabtu',
      'd7': 'Minggu',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Sen',
      'd2': 'Sel',
      'd3': 'Rab',
      'd4': 'Kam',
      'd5': 'Jum',
      'd6': 'Sab',
      'd7': 'Min',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get contributeIntro =>
      'Kode aplikasi ini ada di GitHub dan segala bentuk bantuan disambut baik. Cara untuk ikut serta:';

  @override
  String get contributeOpenGuide => 'Panduan kontribusi';

  @override
  String get contributeOpenIssues => 'Laporkan bug atau ide';

  @override
  String get contributeOpenRepo => 'Buka repositori di GitHub';

  @override
  String get contributeTitle => 'Berkontribusi';

  @override
  String get contributeWayCode =>
      'Kode: fork repositori, buat perubahan di sebuah branch, jalankan pengujian, lalu kirim Pull Request. Langkah build dan pengujian ada di CONTRIBUTING.md.';

  @override
  String get contributeWayData =>
      'Data: perbaiki nama, koordinat, atau zona waktu sebuah kota, atau tambahkan kota baru.';

  @override
  String get contributeWayIssues =>
      'Laporkan bug atau ide: buka Issue di GitHub dan lampirkan versi serta laporan diagnostik dari halaman ini (tidak berisi nama atau koordinat).';

  @override
  String get contributeWayTest =>
      'Pengujian: coba aplikasi di berbagai versi dan perangkat keras Windows (azan, tray, alarm bangun) dan laporkan hasilnya.';

  @override
  String get contributeWayTranslate =>
      'Terjemahan: teks aplikasi ada di folder lib/l10n. Kirimkan bahasa baru atau perbaikan untuk bahasa yang ada; tinjauan oleh penutur asli sangat berharga.';

  @override
  String get diagAudioFailed =>
      'Suara uji tidak dapat diputar. Periksa pengeras suara dan volume Windows.';

  @override
  String get diagAudioOk => 'Suara uji diputar.';

  @override
  String get diagAudioPlay => 'Putar suara uji';

  @override
  String get diagAudioStop => 'Berhenti';

  @override
  String get diagAudioTitle => 'Uji audio';

  @override
  String get diagClockOk => 'Tidak ada masalah jam.';

  @override
  String get diagClockTitle => 'Jam';

  @override
  String get diagClockUnchecked =>
      'Tidak ada masalah terlihat, tetapi pemeriksaan waktu jaringan mati, sehingga selisih jam tidak diukur.';

  @override
  String get diagCopied =>
      'Disalin ke papan klip. Tidak berisi nama maupun koordinat persis.';

  @override
  String get diagCopy => 'Salin diagnostik';

  @override
  String get diagCopyFailed => 'Tidak dapat disalin.';

  @override
  String diagEventAzan(String prayer) {
    return 'Azan: $prayer';
  }

  @override
  String diagEventReminder(String prayer) {
    return 'Pengingat: $prayer';
  }

  @override
  String diagEventTimes(String utc, String local) {
    return 'UTC $utc | lokal $local';
  }

  @override
  String get diagEventWake => 'Alarm bangun';

  @override
  String get diagEventsEmpty => 'Tidak ada yang dijadwalkan.';

  @override
  String get diagEventsTitle => 'Acara terjadwal berikutnya';

  @override
  String get diagLogNone => 'Tidak tersedia.';

  @override
  String get diagLogTitle => 'Berkas log';

  @override
  String get diagTitle => 'Diagnostik';

  @override
  String diagValue(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'yes': 'ya',
      'no': 'tidak',
      'unknown': 'tidak diketahui',
      'enabled': 'diizinkan',
      'disabled': 'mati',
      'importantOnly': 'hanya yang penting',
      'ok': 'berfungsi',
      'failed': 'gagal',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String diagWakeAc(String value) {
    return 'Timer bangun, saat dicolok: $value';
  }

  @override
  String diagWakeBattery(String value) {
    return 'Timer bangun, saat memakai baterai: $value';
  }

  @override
  String get diagWakeCheck => 'Periksa sekarang';

  @override
  String diagWakeInProcess(String value) {
    return 'Timer di dalam aplikasi: $value';
  }

  @override
  String diagWakeModern(String value) {
    return 'Modern Standby: $value';
  }

  @override
  String get diagWakeNotChecked => 'Belum diperiksa.';

  @override
  String diagWakeTask(String value) {
    return 'Tugas terjadwal: $value';
  }

  @override
  String get diagWakeTitle => 'Pemeriksaan bangun';

  @override
  String get formatAm => 'AM';

  @override
  String formatHours(String hours) {
    return '$hours jam';
  }

  @override
  String formatHoursMinutes(String hours, String minutes) {
    return '$hours jam $minutes mnt';
  }

  @override
  String formatMinutes(String minutes) {
    return '$minutes mnt';
  }

  @override
  String get formatPm => 'PM';

  @override
  String formatRemaining(String duration) {
    return 'dalam $duration';
  }

  @override
  String formatRemainingLessThan(String minutes) {
    return 'dalam kurang dari $minutes mnt';
  }

  @override
  String formatSeconds(String seconds) {
    return '$seconds dtk';
  }

  @override
  String get homeAzanMutedIndefinite =>
      'Azan: dibisukan sampai Anda mengaktifkannya lagi';

  @override
  String homeAzanMutedUntil(String time) {
    return 'Azan: dibisukan sampai $time';
  }

  @override
  String get homeAzanOff => 'Azan: mati';

  @override
  String get homeAzanOn => 'Azan: aktif';

  @override
  String homeAzanToggleOff(String prayer) {
    return 'Matikan azan $prayer';
  }

  @override
  String homeAzanToggleOn(String prayer) {
    return 'Aktifkan azan $prayer';
  }

  @override
  String get homeBackToToday => 'Kembali ke hari ini';

  @override
  String homeBannerClockSkew(String amount) {
    return 'Jam PC meleset sekitar $amount.';
  }

  @override
  String get homeBannerDismiss => 'Tutup';

  @override
  String get homeBannerMutedIndefinite =>
      'Azan dibisukan sampai Anda mengaktifkannya lagi.';

  @override
  String homeBannerMutedUntil(String time) {
    return 'Azan dibisukan sampai $time.';
  }

  @override
  String get homeBannerSettingsReset =>
      'Berkas pengaturan tidak dapat dibaca dan pengaturan dikembalikan ke bawaan.';

  @override
  String get homeBannerStaleZone =>
      'Windows menampilkan waktu yang berbeda untuk tempat ini dibandingkan basis data zona waktu. Waktu di aplikasi ini benar; periksa jam Windows.';

  @override
  String homeCompass(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'p0': 'utara',
      'p1': 'timur laut',
      'p2': 'timur',
      'p3': 'tenggara',
      'p4': 'selatan',
      'p5': 'barat daya',
      'p6': 'barat',
      'p7': 'barat laut',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String homeCountdownSemantics(String event, String duration) {
    return '$event $duration';
  }

  @override
  String homeDayTimes(String date) {
    return 'Waktu untuk $date';
  }

  @override
  String homeEventAt(String event, String time) {
    return '$event $time';
  }

  @override
  String get homeHeroNoNext => 'Tidak ada yang dihitung mundur';

  @override
  String get homeMute => 'Bisukan';

  @override
  String get homeMuteCancel => 'Batalkan bisu';

  @override
  String homeMuteForDuration(String duration) {
    return 'Selama $duration';
  }

  @override
  String get homeMuteIndefinite => 'Sampai saya aktifkan lagi';

  @override
  String get homeMuteUntilNext => 'Sampai azan berikutnya';

  @override
  String get homeNextDay => 'Hari berikutnya';

  @override
  String get homeNextMarker => 'Berikut';

  @override
  String homeNextWakeAlarm(String value) {
    return 'Bangun berikutnya: $value';
  }

  @override
  String get homeNoTimesAction => 'Pengaturan perhitungan';

  @override
  String get homeNoTimesInfo =>
      'Tidak semua waktu dapat dihitung untuk tempat ini pada hari ini. Anda dapat mengubah aturan lintang tinggi di pengaturan.';

  @override
  String get homeNoValue => '—';

  @override
  String homeNowPlaying(String prayer) {
    return 'Memutar: $prayer';
  }

  @override
  String get homeNowPlayingGeneric => 'Memutar azan';

  @override
  String get homeOtherDayHint =>
      'Waktu hari ini; hitung mundur hanya untuk hari ini.';

  @override
  String get homePreviousDay => 'Hari sebelumnya';

  @override
  String homeQiblaSummary(String degrees, String direction) {
    return 'Kiblat: $degrees° $direction';
  }

  @override
  String homeReminderMinutes(String minutes) {
    return 'Pengingat: $minutes mnt sebelumnya';
  }

  @override
  String get homeReminderOff => 'Pengingat: mati';

  @override
  String homeReminderRange(String min, String max) {
    return 'Pengingat: $min sampai $max mnt sebelumnya';
  }

  @override
  String get homeStatusTitle => 'Status';

  @override
  String get homeStop => 'Berhenti';

  @override
  String get homeSwitchLocation => 'Ganti lokasi';

  @override
  String get homeTimelineLabel => 'Lini masa hari';

  @override
  String get homeToday => 'Hari ini';

  @override
  String get homeTodayTimes => 'Waktu hari ini';

  @override
  String get homeTomorrowTimes => 'Waktu besok';

  @override
  String homeUntilEvent(String event) {
    return 'Hingga $event';
  }

  @override
  String homeViewingDay(String date) {
    return 'Melihat $date';
  }

  @override
  String get navCalendar => 'Kalender';

  @override
  String get navHome => 'Beranda';

  @override
  String get navQibla => 'Kiblat';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get navTimetable => 'Jadwal';

  @override
  String get navWakeUp => 'Bangun';

  @override
  String notifAzanBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String get notifAzanFailed => 'Azan tidak dapat diputar.';

  @override
  String notifAzanTitle(String prayer) {
    return 'Azan $prayer';
  }

  @override
  String notifMissedBody(String time) {
    return 'Komputer sedang tidur pada $time.';
  }

  @override
  String notifMissedTitle(String prayer) {
    return 'Azan $prayer tidak diputar';
  }

  @override
  String notifReminderBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String notifReminderTitle(String minutes, String prayer) {
    return '$minutes mnt lagi $prayer';
  }

  @override
  String get notifSoundFallback =>
      'Berkas suara azan tidak ditemukan; suara bawaan diputar.';

  @override
  String get notifStopAction => 'Berhenti';

  @override
  String get notifTrayHint => 'Aplikasi tetap berjalan di samping jam Windows.';

  @override
  String get onboardingAzanBody =>
      'Dengarkan azan dan pilih apakah aplikasi dimulai bersama Windows.';

  @override
  String get onboardingAzanTitle => 'Azan dan mulai otomatis';

  @override
  String get onboardingBack => 'Kembali';

  @override
  String get onboardingCityBody =>
      'Cari kota Anda atau pilih dari sebuah provinsi.';

  @override
  String get onboardingCityNone => 'Kota tidak ditemukan.';

  @override
  String get onboardingCitySearchHint => 'Cari kota';

  @override
  String onboardingCitySelected(String city) {
    return 'Dipilih: $city';
  }

  @override
  String get onboardingCityTitle => 'Kota Anda';

  @override
  String get onboardingFinish => 'Mulai';

  @override
  String get onboardingLanguageBody =>
      'Pilih bahasa Anda. Anda dapat mengubahnya nanti di pengaturan.';

  @override
  String get onboardingLanguageTitle => 'Bahasa';

  @override
  String get onboardingModeList => 'Kota-kota Iran (daftar offline)';

  @override
  String get onboardingModeOnline => 'Kota mana pun di dunia (cari online)';

  @override
  String get onboardingNext => 'Lanjut';

  @override
  String get onboardingOnlineBody =>
      'Kota Anda tidak ada dalam daftar? Cari kota mana pun di dunia. Internet hanya dibutuhkan untuk pencarian ini; setelahnya aplikasi bekerja tanpa internet.';

  @override
  String get onboardingPreview => 'Putar contoh azan';

  @override
  String get onboardingProvinceAll => 'Semua provinsi';

  @override
  String get onboardingSkip => 'Lewati';

  @override
  String get onboardingStartWithWindows => 'Mulai bersama Windows';

  @override
  String get onboardingStartWithWindowsHint =>
      'Aplikasi dimulai secara senyap di system tray.';

  @override
  String onboardingStepProgress(String step, String total) {
    return 'Langkah $step dari $total';
  }

  @override
  String get onboardingStopPreview => 'Berhenti';

  @override
  String get placeSearchAttribution =>
      'Tempat © kontributor OpenStreetMap (Nominatim). Zona waktu dan ketinggian: Open-Meteo.';

  @override
  String get placeSearchButton => 'Cari';

  @override
  String get placeSearchFailBusy =>
      'Layanan pencarian sedang sibuk. Tunggu semenit lalu coba lagi.';

  @override
  String get placeSearchFailDetails =>
      'Tempat ditemukan, tetapi zona waktunya tidak dapat diambil. Periksa koneksi dan pilih lagi.';

  @override
  String get placeSearchFailGeneric =>
      'Pencarian tidak berhasil. Coba lagi sebentar lagi.';

  @override
  String get placeSearchFailOffline =>
      'Tidak ada koneksi internet. Sambungkan lalu tekan Cari lagi. Bagian aplikasi lainnya bekerja tanpa internet.';

  @override
  String get placeSearchFailTimeout =>
      'Layanan pencarian tidak menjawab tepat waktu. Coba lagi.';

  @override
  String get placeSearchHint => 'Kota, negara (misalnya Mumbai, India)';

  @override
  String placeSearchNone(String query) {
    return 'Tidak ada tempat untuk “$query”. Periksa ejaannya atau tambahkan negara, misalnya Mumbai, India.';
  }

  @override
  String get placeSearchNotice =>
      'Pencarian hanya membutuhkan internet kali ini saja. Teks yang Anda ketik dikirim ke layanan pencarian OpenStreetMap (Nominatim); tidak ada hal lain yang dikirim. Setelah Anda memilih tempat, aplikasi menyimpan yang diperlukan dan kembali bekerja tanpa internet.';

  @override
  String get placeSearchNoticeDetails =>
      'Saat Anda memilih tempat, koordinat tempat itu dikirim ke Open-Meteo untuk mengambil zona waktu dan ketinggiannya.';

  @override
  String placeSearchResolving(String place) {
    return 'Mengambil zona waktu dan ketinggian $place…';
  }

  @override
  String get placeSearchResultsTitle => 'Hasil: pilih tempat Anda';

  @override
  String get placeSearchTitle => 'Cari tempat';

  @override
  String get placeSearchTooShort => 'Ketik minimal dua huruf, lalu tekan Cari.';

  @override
  String get placeSearchUnknownZone =>
      'Zona waktu tempat ini tidak ada di basis data aplikasi. Coba tempat lain, atau tambahkan lewat Lokasi kustom di pengaturan.';

  @override
  String get placeSearching => 'Mencari…';

  @override
  String get prayerAsr => 'Asar';

  @override
  String get prayerDhuhr => 'Zuhur';

  @override
  String get prayerFajr => 'Subuh';

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerIsha => 'Isya';

  @override
  String get prayerMaghrib => 'Magrib';

  @override
  String get prayerMidnight => 'Tengah malam syari';

  @override
  String get prayerSunrise => 'Terbit';

  @override
  String get prayerSunset => 'Terbenam';

  @override
  String qiblaAccuracyValue(String meters) {
    return 'Akurasi: sekitar $meters m';
  }

  @override
  String get qiblaBearingLabel => 'Arah (searah jarum jam dari utara sejati)';

  @override
  String qiblaBearingValue(String degrees, String direction) {
    return '$degrees° ($direction)';
  }

  @override
  String get qiblaCamKaaba => 'Kakbah';

  @override
  String get qiblaCamNearby => 'Sekitar saya';

  @override
  String get qiblaCamOverview => 'Seluruh rute';

  @override
  String qiblaCardinal(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'n': 'U',
      'e': 'T',
      's': 'S',
      'w': 'B',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String qiblaCompassSemantics(String degrees, String direction) {
    return 'Mawar kompas: kiblat berada di $degrees derajat ($direction)';
  }

  @override
  String qiblaCompassSemanticsSun(String base, String azimuth) {
    return '$base; matahari berada di $azimuth derajat';
  }

  @override
  String get qiblaCoordsApply => 'Tampilkan';

  @override
  String get qiblaCoordsHint => 'contoh 36.2133, 58.7958';

  @override
  String get qiblaCoordsInvalid =>
      'Koordinat tidak valid. Lintang harus antara -90 dan 90 dan bujur antara -180 dan 180.';

  @override
  String get qiblaCoordsLabel => 'Lintang dan bujur';

  @override
  String get qiblaCoordsOr => 'Atau masukkan koordinat sendiri';

  @override
  String qiblaCustomPlaceShown(String place) {
    return 'Mengukur dari $place.';
  }

  @override
  String get qiblaDeviceFixShown => 'Menampilkan posisi perangkat ini.';

  @override
  String get qiblaDistanceLabel => 'Jarak ke Kakbah';

  @override
  String qiblaDistanceValue(String km) {
    return '$km km';
  }

  @override
  String get qiblaFailGeneric =>
      'Posisi tidak dapat dibaca; kota yang dipilih ditampilkan.';

  @override
  String get qiblaFailPermissionDenied =>
      'Windows belum mengizinkan aplikasi ini membaca posisi. Ikuti langkah di bawah dan coba lagi; atau gunakan kota yang dipilih.';

  @override
  String get qiblaFailPermissionForever =>
      'Akses lokasi ditolak. Untuk mengizinkannya lagi, ikuti langkah di bawah.';

  @override
  String get qiblaFailServiceDisabled =>
      'Layanan lokasi mati di perangkat ini. Ikuti langkah di bawah; atau gunakan kota yang dipilih atau titik mana pun.';

  @override
  String get qiblaFailTimeout =>
      'Tidak ada posisi yang diterima tepat waktu. PC jarang memiliki GPS dan Windows memperkirakan posisi dari Wi-Fi. Coba lagi atau gunakan kota.';

  @override
  String get qiblaFailUnsupported =>
      'Perangkat ini tidak dapat melaporkan posisi; kota yang dipilih ditampilkan.';

  @override
  String qiblaForLocation(String place) {
    return 'Arah kiblat untuk $place';
  }

  @override
  String get qiblaHelpOther =>
      'Aktifkan lokasi di pengaturan sistem operasi, izinkan aplikasi ini menggunakannya, lalu coba lagi.';

  @override
  String get qiblaHelpTitleOther => 'Bagaimana cara mengaktifkan lokasi?';

  @override
  String get qiblaHelpTitleWindows =>
      'Bagaimana cara mengaktifkan lokasi di Windows?';

  @override
  String get qiblaHelpWin1 =>
      'Tekan tombol di atas untuk membuka halaman Location pada Pengaturan Windows. Jika tidak terbuka, buka secara manual: Start > Settings > Privacy & security > Location (Windows 10: Privacy > Location)';

  @override
  String get qiblaHelpWin2 =>
      'Aktifkan Location services. Jika bagian atas halaman menyatakan Location for this device is off, tekan Change lalu aktifkan.';

  @override
  String get qiblaHelpWin3 =>
      'Sedikit ke bawah, aktifkan Let desktop apps access your location (Windows 10: Allow desktop apps to access your location). Salaat adalah aplikasi desktop dan hanya diizinkan oleh sakelar ini.';

  @override
  String get qiblaHelpWin4 =>
      'Kembali ke Salaat dan tekan Temukan posisi saya lagi. Jika masih gagal, tutup aplikasi sekali lalu buka lagi.';

  @override
  String get qiblaLocateAgain => 'Temukan lagi';

  @override
  String get qiblaLocateButton => 'Temukan posisi saya';

  @override
  String get qiblaLocating => 'Mencari posisi Anda…';

  @override
  String get qiblaMapAttribution => '© kontributor OpenStreetMap';

  @override
  String get qiblaMapAttributionSatellite =>
      'Citra © Esri, Maxar, Earthstar Geographics, dan Komunitas Pengguna GIS';

  @override
  String get qiblaMapConsentBody =>
      'Untuk menggambar garis kiblat pada peta, gambar peta diambil dari internet dan area yang Anda lihat dikirim ke server tersebut: peta jalan dari OpenStreetMap, dan, jika Anda memilih Satelit, foto udara dari Esri. Tidak ada yang diminta sebelum Anda setuju. Sudut dan jarak kiblat tetap ditampilkan dengan benar tanpa peta.';

  @override
  String get qiblaMapConsentButton => 'Tampilkan peta';

  @override
  String get qiblaMapConsentTitle => 'Peta kiblat';

  @override
  String get qiblaMapKaaba => 'Kakbah';

  @override
  String get qiblaMapLineNote =>
      'Garis ini adalah jalur terpendek di permukaan bumi menuju pusat Kakbah. Pada peta datar garis tampak melengkung, tetapi dimulai dari arah kiblat. Talang Kakbah hanya beberapa meter dari pusat dan tidak membuat perbedaan arah yang terlihat. Tekan Sekitar saya untuk membandingkan dengan jalan dan bangunan.';

  @override
  String get qiblaMapOfflineBanner =>
      'Gambar peta tidak dapat dimuat (tidak ada internet?). Garis dan sudut kiblat tetap benar.';

  @override
  String qiblaMapSemantics(String place, String bearing, String distance) {
    return 'Peta kiblat: dari $place ke Kakbah, $bearing, $distance';
  }

  @override
  String get qiblaMapTapHint => 'Ketuk peta untuk memilih titik lain.';

  @override
  String get qiblaMapTurnOff => 'Matikan peta';

  @override
  String get qiblaMapYou => 'Posisi Anda';

  @override
  String get qiblaNoCompassNote =>
      'PC tidak memiliki kompas, jadi gambar mengacu pada utara sejati (utara di bagian atas).';

  @override
  String get qiblaOpenSettingsFailed =>
      'Halaman pengaturan tidak dapat dibuka; ikuti langkah secara manual.';

  @override
  String get qiblaOpenSettingsOther => 'Buka pengaturan lokasi';

  @override
  String get qiblaOpenSettingsWindows => 'Buka pengaturan lokasi Windows';

  @override
  String get qiblaSourceCity => 'Kota yang dipilih';

  @override
  String qiblaSourceCityHelp(String city) {
    return 'Kota yang Anda pilih untuk waktu salat: $city.';
  }

  @override
  String get qiblaSourceCustom => 'Titik mana pun';

  @override
  String get qiblaSourceCustomHelp =>
      'Cari tempat dengan nama (butuh internet satu kali), ketuk peta, atau masukkan koordinat.';

  @override
  String get qiblaSourceDevice => 'Perangkat ini';

  @override
  String get qiblaSourceDeviceHelp =>
      'Posisi dibaca dari perangkat hanya saat Anda menekan tombol; tidak disimpan atau dikirim ke mana pun.';

  @override
  String get qiblaSourceTitle => 'Ukur kiblat dari';

  @override
  String get qiblaStatLatitude => 'Lintang';

  @override
  String get qiblaStatLongitude => 'Bujur';

  @override
  String get qiblaStyleLabel => 'Jenis peta';

  @override
  String get qiblaStyleSatellite => 'Satelit';

  @override
  String get qiblaStyleStreet => 'Peta';

  @override
  String get qiblaSunBelow => 'Matahari berada di bawah cakrawala.';

  @override
  String get qiblaSunInHelp =>
      'Saat ini matahari tepat berada di arah kiblat; hadaplah matahari.';

  @override
  String get qiblaSunInTitle => 'Matahari di arah kiblat';

  @override
  String get qiblaSunNone => 'Tidak terjadi hari ini.';

  @override
  String get qiblaSunNowLabel => 'Matahari sekarang';

  @override
  String qiblaSunNowValue(String azimuth, String altitude) {
    return 'Azimut $azimuth°, ketinggian $altitude°';
  }

  @override
  String get qiblaSunOppHelp =>
      'Saat ini bayangan tongkat tegak mengarah ke kiblat.';

  @override
  String get qiblaSunOppTitle => 'Matahari berlawanan dengan kiblat';

  @override
  String get qiblaSunTimesTitle => 'Matahari dan kiblat hari ini';

  @override
  String get qiblaTabCompass => 'Kompas dan matahari';

  @override
  String get qiblaTabMap => 'Peta';

  @override
  String get qiblaTitle => 'Kiblat';

  @override
  String get settingsAboutPlaceholder =>
      'Versi, lisensi, dan halaman diagnostik muncul di bagian ini.';

  @override
  String get settingsAppAutostart => 'Mulai bersama Windows';

  @override
  String get settingsAppAutostartHelp =>
      'Aplikasi dimulai secara senyap di samping jam saat Anda masuk ke Windows.';

  @override
  String get settingsAppCloseToTray => 'Tutup ke tray';

  @override
  String get settingsAppCloseToTrayHelp =>
      'Menutup jendela membuat aplikasi tetap berada di samping jam Windows sehingga azan tetap diputar. Jika mati, menutup berarti keluar dari aplikasi.';

  @override
  String get settingsAppMinimized => 'Mulai terkecil';

  @override
  String get settingsAppMinimizedHelp =>
      'Jendela tetap tertutup saat Windows memulai aplikasi.';

  @override
  String get settingsAsrHanafi => 'Hanafi (bayangan dua kali benda)';

  @override
  String get settingsAsrStandard => 'Standar (bayangan sama dengan benda)';

  @override
  String get settingsAzanChoose => 'Pilih berkas…';

  @override
  String get settingsAzanEnabled => 'Putar azan';

  @override
  String get settingsAzanEnabledHelp =>
      'Sakelar utama; jika mati, tidak ada azan yang diputar.';

  @override
  String get settingsAzanFade => 'Naik perlahan';

  @override
  String get settingsAzanFadeHelp => 'Azan naik perlahan hingga volume penuh.';

  @override
  String get settingsAzanMute => 'Bisu cepat';

  @override
  String get settingsAzanMuteHelp => 'Bisukan azan untuk sementara.';

  @override
  String get settingsAzanNotMuted => 'Tidak dibisukan';

  @override
  String settingsAzanPrayerSwitch(String prayer) {
    return 'Azan $prayer';
  }

  @override
  String get settingsAzanPrayerVolume => 'Volume azan ini';

  @override
  String get settingsAzanPreview => 'Pratinjau';

  @override
  String get settingsAzanSound => 'Suara';

  @override
  String get settingsAzanSoundDefault => 'Azan bawaan';

  @override
  String settingsAzanSoundFile(String name) {
    return 'Berkas: $name';
  }

  @override
  String get settingsAzanUseDefault => 'Gunakan suara bawaan';

  @override
  String get settingsAzanVolume => 'Volume';

  @override
  String get settingsAzanVolumeHelp => 'Volume keseluruhan setiap azan';

  @override
  String get settingsBackupExport => 'Ekspor cadangan';

  @override
  String get settingsBackupExportFailed => 'Cadangan tidak dapat disimpan.';

  @override
  String get settingsBackupExportHelp =>
      'Semua pengaturan, lokasi, dan alarm bangun disimpan dalam satu berkas.';

  @override
  String settingsBackupExported(String path) {
    return 'Cadangan disimpan: $path';
  }

  @override
  String get settingsBackupImport => 'Impor cadangan';

  @override
  String get settingsBackupImportBody =>
      'Semua pengaturan saat ini diganti dengan isi berkas ini.';

  @override
  String get settingsBackupImportConfirm => 'Pulihkan';

  @override
  String get settingsBackupImportHelp =>
      'Memulihkan pengaturan dari berkas cadangan.';

  @override
  String get settingsBackupImportInvalid =>
      'Berkas ini bukan cadangan pengaturan yang valid; pengaturan tidak diubah.';

  @override
  String get settingsBackupImportReadFailed =>
      'Berkas tidak dapat dibaca; pengaturan tidak diubah.';

  @override
  String get settingsBackupImportTitle => 'Pulihkan pengaturan?';

  @override
  String get settingsBackupImported => 'Pengaturan telah dipulihkan.';

  @override
  String get settingsBackupTitle => 'Cadangan dan pemulihan';

  @override
  String get settingsCalcAngleHelp =>
      'Sudut matahari di bawah cakrawala, dalam derajat';

  @override
  String get settingsCalcAsr => 'Aturan Asar';

  @override
  String get settingsCalcFajrAngle => 'Sudut Subuh';

  @override
  String get settingsCalcHighLat => 'Lintang tinggi';

  @override
  String get settingsCalcHighLatHelp =>
      'Untuk tempat yang malamnya sangat pendek dan sudut senja tidak pernah tercapai.';

  @override
  String get settingsCalcImsak => 'Imsak';

  @override
  String get settingsCalcImsakHelp => 'Menit sebelum Subuh';

  @override
  String get settingsCalcIshaAngle => 'Sudut Isya';

  @override
  String get settingsCalcIshaMinutes => 'Menit setelah Magrib';

  @override
  String get settingsCalcIshaMode => 'Definisi Isya';

  @override
  String get settingsCalcIshaModeAngle => 'Sudut matahari';

  @override
  String get settingsCalcIshaModeMinutes => 'Menit setelah Magrib';

  @override
  String get settingsCalcMaghribAngle => 'Sudut Magrib';

  @override
  String get settingsCalcMaghribSunset => 'Magrib saat terbenam';

  @override
  String get settingsCalcMaghribSunsetHelp =>
      'Jika mati, Magrib dihitung dengan sudut di bawah.';

  @override
  String get settingsCalcMethod => 'Metode';

  @override
  String get settingsCalcMethodHelp =>
      'Mengubah sudut apa pun menjadikan metode ini Kustom.';

  @override
  String get settingsCalcMidnight => 'Tengah malam syari';

  @override
  String settingsCalcOffsetsHelp(String max) {
    return 'Majukan atau mundurkan waktu mana pun hingga $max menit.';
  }

  @override
  String get settingsCalcOffsetsReset => 'Atur ulang semua';

  @override
  String get settingsCalcOffsetsTitle => 'Penyesuaian menit per waktu';

  @override
  String settingsCalcPreviewHelp(String date) {
    return 'Waktu hari ini ($date) dengan pengaturan di atas';
  }

  @override
  String get settingsCalcPreviewTitle => 'Pratinjau langsung';

  @override
  String get settingsCalcRestore => 'Pulihkan bawaan untuk metode ini';

  @override
  String settingsCalcRestoreHelp(String method) {
    return 'Sudut, aturan, dan Imsak kembali ke nilai $method; penyesuaian menit tiap waktu tidak diubah.';
  }

  @override
  String get settingsCalcRowsHelp =>
      'Subuh, Terbit, Zuhur, Magrib, dan tengah malam syari selalu ditampilkan.';

  @override
  String get settingsCalcRowsTitle => 'Baris yang ditampilkan';

  @override
  String get settingsCancel => 'Batal';

  @override
  String get settingsDecrease => 'Kurangi';

  @override
  String get settingsDigitsArabic => 'Arab (٠١٢)';

  @override
  String get settingsDigitsLatin => 'Latin (123)';

  @override
  String get settingsDigitsPersian => 'Persia (۱۲۳)';

  @override
  String get settingsDispDigits => 'Angka';

  @override
  String get settingsDispHijri => 'Penyesuaian tanggal Hijriah';

  @override
  String get settingsDispHijriHelp =>
      'Iran mengikuti rukyat hilal, sehingga tanggal Hijriah yang ditampilkan bisa berbeda dari yang resmi; geser satu atau dua hari di sini.';

  @override
  String get settingsDispHour => 'Jam';

  @override
  String get settingsDispLanguage => 'Bahasa';

  @override
  String get settingsDispLanguageHelp => 'Berlaku tanpa memulai ulang.';

  @override
  String get settingsDispTheme => 'Tema';

  @override
  String get settingsHighLatAngleBased => 'Berdasarkan sudut';

  @override
  String get settingsHighLatNightMiddle => 'Pertengahan malam';

  @override
  String get settingsHighLatNone => 'Tanpa penyesuaian';

  @override
  String get settingsHighLatOneSeventh => 'Sepertujuh malam';

  @override
  String get settingsHour12 => '12 jam';

  @override
  String get settingsHour24 => '24 jam';

  @override
  String get settingsIncrease => 'Tambah';

  @override
  String settingsInvalidNumber(String min, String max) {
    return 'Masukkan angka antara $min dan $max.';
  }

  @override
  String get settingsLocActive => 'Aktif';

  @override
  String get settingsLocAdd => 'Tambah';

  @override
  String get settingsLocAddCustom => 'Lokasi kustom';

  @override
  String get settingsLocAddFromDb => 'Dari daftar kota';

  @override
  String get settingsLocAddSearch => 'Cari online';

  @override
  String get settingsLocAddTitle => 'Tambah lokasi';

  @override
  String settingsLocAdded(String name) {
    return '$name telah ditambahkan.';
  }

  @override
  String get settingsLocAllProvinces => 'Semua provinsi';

  @override
  String get settingsLocAlreadySaved => 'Sudah disimpan';

  @override
  String settingsLocAlreadySavedName(String name) {
    return '$name sudah ada di lokasi tersimpan Anda.';
  }

  @override
  String get settingsLocClose => 'Tutup';

  @override
  String settingsLocCoords(String lat, String lon) {
    return 'Lintang $lat, bujur $lon';
  }

  @override
  String get settingsLocCustomBadge => 'Kustom';

  @override
  String get settingsLocDegrees => 'Derajat';

  @override
  String get settingsLocDelete => 'Hapus';

  @override
  String get settingsLocDeleteBody => 'Lokasi ini dihapus dari daftar Anda.';

  @override
  String get settingsLocDeleteLast => 'Lokasi terakhir tidak dapat dihapus.';

  @override
  String settingsLocDeleteTitle(String name) {
    return 'Hapus $name?';
  }

  @override
  String get settingsLocEast => 'Timur';

  @override
  String get settingsLocEdit => 'Ubah';

  @override
  String get settingsLocElevation => 'Ketinggian (meter)';

  @override
  String settingsLocErrElevation(String min, String max) {
    return 'Ketinggian harus antara $min dan $max meter.';
  }

  @override
  String settingsLocErrLatitude(String min, String max) {
    return 'Lintang harus berupa angka antara $min dan $max.';
  }

  @override
  String settingsLocErrLongitude(String min, String max) {
    return 'Bujur harus berupa angka antara $min dan $max.';
  }

  @override
  String get settingsLocErrName => 'Masukkan nama.';

  @override
  String settingsLocErrOffset(String min, String max) {
    return 'Selisih harus antara $min dan $max.';
  }

  @override
  String get settingsLocErrZone => 'Pilih zona waktu dari daftar.';

  @override
  String get settingsLocFormatDecimal => 'Derajat desimal';

  @override
  String get settingsLocFormatDms => 'Derajat, menit, detik';

  @override
  String get settingsLocLatitude => 'Lintang';

  @override
  String get settingsLocLongitude => 'Bujur';

  @override
  String get settingsLocMinutes => 'Menit';

  @override
  String get settingsLocName => 'Nama';

  @override
  String get settingsLocNoResults => 'Kota tidak ditemukan.';

  @override
  String get settingsLocNorth => 'Utara';

  @override
  String get settingsLocProvince => 'Provinsi';

  @override
  String get settingsLocSave => 'Simpan';

  @override
  String get settingsLocSavedHelp => 'Waktu dihitung untuk lokasi yang aktif.';

  @override
  String get settingsLocSavedTitle => 'Lokasi tersimpan';

  @override
  String get settingsLocSearchHint => 'Cari kota';

  @override
  String get settingsLocSeconds => 'Detik';

  @override
  String get settingsLocSetActive => 'Jadikan aktif';

  @override
  String get settingsLocSouth => 'Selatan';

  @override
  String get settingsLocWest => 'Barat';

  @override
  String get settingsLocZoneNone => 'Zona waktu tidak ditemukan.';

  @override
  String get settingsLocZoneSearch => 'Cari zona waktu';

  @override
  String settingsLocZoneSelected(String zone) {
    return 'Zona waktu terpilih: $zone';
  }

  @override
  String get settingsMethodCustom => 'Kustom';

  @override
  String get settingsMethodEgypt => 'Otoritas Survei Umum Mesir';

  @override
  String get settingsMethodIsna => 'Masyarakat Islam Amerika Utara';

  @override
  String get settingsMethodJafari =>
      'Syiah Itsna Asyariah, Institut Leva (Qom)';

  @override
  String get settingsMethodKarachi => 'Universitas Ilmu-Ilmu Islam, Karachi';

  @override
  String get settingsMethodMakkah => 'Universitas Ummul Qura, Makkah';

  @override
  String get settingsMethodMwl => 'Liga Muslim Dunia';

  @override
  String get settingsMethodTehran => 'Universitas Teheran, Institut Geofisika';

  @override
  String get settingsMidnightJafari => 'Antara terbenam dan Subuh';

  @override
  String get settingsMidnightStandard => 'Antara terbenam dan terbit';

  @override
  String get settingsOff => 'Mati';

  @override
  String settingsPercent(String value) {
    return '$value%';
  }

  @override
  String get settingsRemChime => 'Denting lembut';

  @override
  String get settingsRemChimeHelp =>
      'Denting lembut diputar bersama notifikasi pengingat.';

  @override
  String get settingsRemChimeTest => 'Putar contoh';

  @override
  String settingsRemHelp(String max) {
    return '0 berarti mati; hingga $max menit sebelum azan.';
  }

  @override
  String get settingsRemIndependent =>
      'Mematikan pengingat tidak pernah memengaruhi azan.';

  @override
  String settingsRemSummary(String minutes) {
    return '$minutes mnt sebelum azan';
  }

  @override
  String settingsRemTitle(String prayer) {
    return 'Pengingat sebelum $prayer';
  }

  @override
  String get settingsResetConfirm => 'Hapus';

  @override
  String get settingsResetConfirmBody =>
      'Pengaturan kembali ke bawaan dan lokasi aktif menjadi Teheran. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get settingsResetConfirmTitle => 'Hapus semua pengaturan?';

  @override
  String get settingsResetDone => 'Pengaturan telah dikembalikan ke bawaan.';

  @override
  String get settingsResetHelp =>
      'Semua pengaturan, lokasi tersimpan, dan alarm bangun dihapus.';

  @override
  String get settingsResetTitle => 'Kembalikan ke bawaan';

  @override
  String get settingsSaved => 'Tersimpan';

  @override
  String get settingsSectionAbout => 'Tentang dan diagnostik';

  @override
  String get settingsSectionApp => 'Aplikasi';

  @override
  String get settingsSectionAzan => 'Azan';

  @override
  String get settingsSectionCalculation => 'Perhitungan';

  @override
  String get settingsSectionDisplay => 'Tampilan';

  @override
  String get settingsSectionLocation => 'Lokasi';

  @override
  String get settingsSectionReminders => 'Pengingat';

  @override
  String get settingsSectionTime => 'Waktu';

  @override
  String get settingsSectionsLabel => 'Bagian pengaturan';

  @override
  String get settingsThemeDark => 'Gelap';

  @override
  String get settingsThemeLight => 'Terang';

  @override
  String get settingsThemeSystem => 'Ikuti Windows';

  @override
  String get settingsTimeCheck => 'Periksa jam dengan waktu jaringan';

  @override
  String get settingsTimeCheckHelp =>
      'Saat aplikasi dimulai dan setiap enam jam; mati secara bawaan.';

  @override
  String get settingsTimeCheckNow => 'Periksa sekarang';

  @override
  String settingsTimeCheckedAt(String time) {
    return 'Diperiksa pada $time';
  }

  @override
  String get settingsTimeChecking => 'Memeriksa…';

  @override
  String get settingsTimeCorrect => 'Koreksi waktu di dalam aplikasi';

  @override
  String get settingsTimeCorrectHelp => 'Jam Windows tidak pernah diubah.';

  @override
  String settingsTimeDiagLocation(String offset) {
    return 'Selisih lokasi aktif (basis data): $offset';
  }

  @override
  String get settingsTimeDiagOk => 'Tidak ada masalah jam.';

  @override
  String get settingsTimeDiagTitle => 'Diagnostik jam';

  @override
  String settingsTimeDiagWindows(String offset) {
    return 'Selisih Windows dari UTC: $offset';
  }

  @override
  String get settingsTimeError =>
      'Server waktu tidak dapat dijangkau. Periksa koneksi internet dan nama server.';

  @override
  String get settingsTimeNever => 'Belum diperiksa.';

  @override
  String get settingsTimeServer => 'Server waktu';

  @override
  String get settingsTimeServerHelp =>
      'Nama server waktu, misalnya pool.ntp.org';

  @override
  String get settingsTimeServerInvalid => 'Nama server tidak valid.';

  @override
  String settingsTimeSkewAhead(String amount) {
    return 'Jam PC lebih cepat $amount.';
  }

  @override
  String settingsTimeSkewBehind(String amount) {
    return 'Jam PC lebih lambat $amount.';
  }

  @override
  String get settingsTimeSkewZero => 'Jam PC sesuai dengan waktu jaringan.';

  @override
  String get settingsTimeStatusTitle => 'Pemeriksaan terakhir';

  @override
  String get settingsZoneAuto => 'Otomatis (disarankan)';

  @override
  String settingsZoneAutoHelp(String zone) {
    return 'Memakai basis data zona waktu bawaan aplikasi: $zone';
  }

  @override
  String get settingsZoneFixed => 'Selisih tetap';

  @override
  String get settingsZoneFixedAllYear =>
      'Selisih ini tetap dan sama pada setiap hari sepanjang tahun.';

  @override
  String get settingsZoneFixedHelp =>
      'Satu selisih tetap dari UTC yang berlaku pada setiap hari sepanjang tahun.';

  @override
  String settingsZoneFixedValue(String offset) {
    return 'Selisih tetap: $offset';
  }

  @override
  String get settingsZoneHourLess => 'Kurang satu jam';

  @override
  String get settingsZoneHourMore => 'Lebih satu jam';

  @override
  String settingsZoneNext(String date, String time, String offset) {
    return 'Perubahan berikutnya: $date pukul $time, selisih $offset';
  }

  @override
  String get settingsZoneNoChange =>
      'Tidak ada perubahan lain yang direncanakan untuk zona waktu ini.';

  @override
  String settingsZoneNow(String offset) {
    return 'Selisih yang berlaku hari ini: $offset';
  }

  @override
  String get settingsZoneQuarterLess => 'Kurang seperempat jam';

  @override
  String get settingsZoneQuarterMore => 'Lebih seperempat jam';

  @override
  String get settingsZoneTitle => 'Zona waktu';

  @override
  String get supportAvailableIn => 'Dapat digunakan di:';

  @override
  String get supportCardCountries =>
      'Hanya Iran: kartu bank Iran pada jaringan Shetab. Tidak dapat dibayar dari luar Iran; gunakan opsi mata uang kripto.';

  @override
  String get supportCardNumberLabel => 'Nomor kartu';

  @override
  String get supportCardTitle => 'Kartu bank Iran';

  @override
  String get supportCheckNote =>
      'Sebelum membayar, bandingkan nomor atau alamat dengan halaman resmi proyek di GitHub. Terima kasih atas dukungan Anda.';

  @override
  String get supportCryptoAddressLabel => 'Alamat dompet';

  @override
  String get supportCryptoCountries =>
      'Semua negara: dari mana pun yang tersedia dompet atau bursa kripto, tanpa perlu kartu bank.';

  @override
  String get supportCryptoNetworkLabel => 'Jaringan';

  @override
  String get supportCryptoNetworkValue =>
      'BEP20 (BNB Smart Chain, juga disebut BSC)';

  @override
  String get supportCryptoTitle => 'Mata uang kripto USDT (Tether)';

  @override
  String get supportCryptoWarning =>
      'Kirim hanya USDT melalui jaringan BEP20. Mengirim koin lain, atau memakai jaringan lain, ke alamat ini akan menghilangkan uang Anda.';

  @override
  String get supportIntro =>
      'Aplikasi ini gratis, tanpa iklan, tidak memerlukan akun, dan tidak menyembunyikan fitur apa pun di balik pembayaran. Jika bermanfaat bagi Anda dan Anda ingin membantunya terus berkembang, Anda dapat memakai salah satu cara di bawah. Dukungan sepenuhnya bersifat sukarela dan berapa pun jumlahnya sangat dihargai.';

  @override
  String get supportTitle => 'Dukung proyek ini';

  @override
  String get timetableCalendarSwitch => 'Jenis kalender';

  @override
  String get timetableColDay => 'Tanggal';

  @override
  String get timetableColWeekday => 'Hari';

  @override
  String get timetableMonthUnavailable =>
      'Bulan ini di luar tabel kalender kamariah.';

  @override
  String get timetableNextMonth => 'Bulan berikutnya';

  @override
  String timetableOpenDay(String date) {
    return 'Tampilkan $date di layar utama';
  }

  @override
  String get timetablePreviousMonth => 'Bulan sebelumnya';

  @override
  String get timetableToday => 'Hari ini';

  @override
  String get trayMenuLocation => 'Lokasi';

  @override
  String get trayMenuMute => 'Bisukan';

  @override
  String get trayMenuMuted => 'Dibisukan';

  @override
  String get trayMenuQuit => 'Keluar';

  @override
  String get trayMenuSettings => 'Pengaturan';

  @override
  String get trayMenuShow => 'Tampilkan jendela';

  @override
  String get trayMenuStopAzan => 'Hentikan azan';

  @override
  String get trayMuteCancel => 'Batalkan bisu';

  @override
  String trayMuteHours(String n) {
    return '$n jam';
  }

  @override
  String get trayMuteIndefinite => 'Sampai saya matikan';

  @override
  String get trayMuteUntilNext => 'Sampai azan berikutnya';

  @override
  String trayNextLine(String prayer, String time) {
    return 'Berikut: $prayer · $time';
  }

  @override
  String trayTimeRow(String prayer, String time) {
    return '$prayer   $time';
  }

  @override
  String trayTooltip(String prayer, String time, String remaining) {
    return '$prayer $time · $remaining';
  }

  @override
  String get wakeAdd => 'Tambah alarm';

  @override
  String get wakeAfterHibernate => 'Setelah suara: hibernasi';

  @override
  String get wakeAfterHibernateChoice => 'Hibernasi';

  @override
  String get wakeAfterNote =>
      'Sebelum PC tidur atau hibernasi, hitung mundur 30 detik memungkinkan Anda membatalkan.';

  @override
  String get wakeAfterNothing => 'Tidak melakukan apa-apa';

  @override
  String get wakeAfterSleep => 'Setelah suara: tidur';

  @override
  String get wakeAfterSleepChoice => 'Tidur';

  @override
  String get wakeAfterTitle => 'Setelah suara';

  @override
  String get wakeCancel => 'Batal';

  @override
  String get wakeCapabilityChecking => 'Memeriksa PC ini…';

  @override
  String get wakeCapabilityOkBody =>
      'Pemeriksaan tidak menemukan hambatan. Jalankan uji dua menit untuk memastikan.';

  @override
  String get wakeCapabilityOkTitle => 'PC ini dapat bangun sendiri';

  @override
  String get wakeCapabilityRefresh => 'Periksa lagi';

  @override
  String get wakeCapabilityUnknown => 'Belum diperiksa.';

  @override
  String get wakeCapabilityWarnTitle =>
      'PC ini mungkin tidak bangun untuk alarm';

  @override
  String get wakeChoiceFixed => 'Pada waktu tetap';

  @override
  String get wakeChoiceRelative => 'Sebelum salat';

  @override
  String get wakeChooseFile => 'Pilih berkas…';

  @override
  String get wakeCountdownAfterAlarm => 'Alarm telah selesai.';

  @override
  String get wakeCountdownCancel => 'Batal';

  @override
  String wakeCountdownHibernate(String time) {
    return 'PC akan hibernasi dalam $time.';
  }

  @override
  String wakeCountdownSleep(String time) {
    return 'PC akan tidur dalam $time.';
  }

  @override
  String get wakeDelete => 'Hapus';

  @override
  String get wakeDeleteBody => 'Alarm dan permintaan bangunnya akan dihapus.';

  @override
  String get wakeDeleteConfirm => 'Hapus';

  @override
  String get wakeDeleteTitle => 'Hapus alarm ini?';

  @override
  String get wakeDismiss => 'Tutup';

  @override
  String get wakeEdit => 'Ubah';

  @override
  String get wakeEditorTitleAdd => 'Alarm baru';

  @override
  String get wakeEditorTitleEdit => 'Ubah alarm';

  @override
  String get wakeEmpty =>
      'Belum ada alarm. Tambahkan satu untuk membangunkan PC ini pada waktu yang Anda pilih.';

  @override
  String get wakeEnabledSwitch => 'Aktif';

  @override
  String wakeErrorMinutes(String min, String max) {
    return 'Masukkan bilangan bulat dari $min sampai $max.';
  }

  @override
  String get wakeFieldHour => 'Jam';

  @override
  String get wakeFieldLabel => 'Nama (opsional)';

  @override
  String get wakeFieldMinute => 'Menit';

  @override
  String get wakeFieldMinutesBefore => 'Menit sebelumnya';

  @override
  String get wakeFieldPrayer => 'Salat';

  @override
  String get wakeHibernateNow => 'Hibernasi sekarang';

  @override
  String get wakeIssueImportantOnly =>
      'Windows hanya mengizinkan timer bangun yang penting, yang biasanya tidak mencakup aplikasi ini.';

  @override
  String get wakeIssueInProcessTimer =>
      'Timer cadangan di dalam aplikasi tidak dapat dibuat.';

  @override
  String get wakeIssueModernStandby =>
      'PC ini memakai Modern Standby, yang sering tidak andal untuk bangun pada waktu tertentu.';

  @override
  String get wakeIssueTaskCreationFailed =>
      'Windows tidak mengizinkan tugas bangun terjadwal untuk akun Anda, sehingga alarm hanya berfungsi saat aplikasi ini berjalan.';

  @override
  String get wakeIssueTimersOffAc =>
      'Windows mematikan timer bangun saat PC dicolok.';

  @override
  String get wakeIssueTimersOffBattery =>
      'Windows mematikan timer bangun saat PC memakai baterai.';

  @override
  String get wakeIssueUnknown =>
      'Pengaturan timer bangun Windows tidak dapat dibaca.';

  @override
  String get wakeListSeparator => ', ';

  @override
  String wakeNext(String remaining, String time) {
    return 'Berikut: $remaining ($time)';
  }

  @override
  String get wakeNextNone => 'Berikut: —';

  @override
  String wakeNextOtherDay(String remaining, String weekday, String time) {
    return 'Berikut: $remaining ($weekday $time)';
  }

  @override
  String get wakeOff => 'Mati';

  @override
  String get wakeOpenPowerFailed =>
      'Pengaturan daya tidak dapat dibuka. Buka sendiri Control Panel > Power Options.';

  @override
  String get wakeOpenPowerOptions => 'Buka pengaturan daya Windows';

  @override
  String wakePercent(String percent) {
    return '$percent%';
  }

  @override
  String get wakePlaySound => 'Putar suara';

  @override
  String get wakePowerHint =>
      'Di Windows: Power Options > Change plan settings > Change advanced power settings > Sleep > Allow wake timers. Aplikasi ini tidak pernah mengubah pengaturan daya sendiri.';

  @override
  String get wakePreview => 'Pratinjau';

  @override
  String get wakePreviewStop => 'Hentikan pratinjau';

  @override
  String get wakeProblemHibernateUnavailable =>
      'Hibernasi tidak diaktifkan untuk PC ini.';

  @override
  String get wakeProblemProbeFailed =>
      'Pemeriksaan PC ini tidak dapat diselesaikan.';

  @override
  String get wakeProblemSoundFailed =>
      'Suara alarm tidak dapat diputar. Periksa berkas suara dan pengeras suara.';

  @override
  String get wakeProblemSuspendRefused => 'Windows tidak mengizinkan PC tidur.';

  @override
  String get wakeRepeatDaily => 'Setiap hari';

  @override
  String get wakeRepeatOnce => 'Sekali';

  @override
  String get wakeRepeatTitle => 'Ulangi';

  @override
  String wakeRepeatWeekdays(String days) {
    return 'Pada $days';
  }

  @override
  String get wakeRepeatWeekdaysChoice => 'Hari tertentu';

  @override
  String get wakeRinging => 'Alarm sedang berbunyi';

  @override
  String get wakeSave => 'Simpan';

  @override
  String get wakeSaveFailed =>
      'Nilai ini tidak dapat disimpan. Periksa waktu dan harinya.';

  @override
  String get wakeSleepHint =>
      'PC tidur setelah hitung mundur lima detik yang dapat Anda batalkan.';

  @override
  String get wakeSleepNow => 'Tidur sekarang';

  @override
  String get wakeSoundDefault => 'Suara azan bawaan';

  @override
  String wakeSoundFile(String name) {
    return 'Berkas: $name';
  }

  @override
  String get wakeSoundTitle => 'Suara';

  @override
  String get wakeStop => 'Berhenti';

  @override
  String get wakeSyncError =>
      'Permintaan bangun tidak dapat didaftarkan ke Windows; alarm mungkin hanya berfungsi saat aplikasi berjalan.';

  @override
  String get wakeTest => 'Uji dalam 2 menit';

  @override
  String get wakeTestCancel => 'Batalkan uji';

  @override
  String wakeTestPending(String time) {
    return 'Alarm uji akan berbunyi pada $time. Tidurkan PC sekarang untuk melihat apakah PC bangun.';
  }

  @override
  String get wakeTitle => 'Alarm bangun';

  @override
  String wakeTriggerAtPrayer(String prayer) {
    return 'Saat $prayer';
  }

  @override
  String wakeTriggerFixed(String time) {
    return 'Pada $time';
  }

  @override
  String wakeTriggerRelative(String minutes, String prayer) {
    return '$minutes sebelum $prayer';
  }

  @override
  String get wakeTriggerTypeTitle => 'Kapan';

  @override
  String get wakeUseDefault => 'Gunakan bawaan';

  @override
  String get wakeVolume => 'Volume';

  @override
  String get wakeWeekdaysError => 'Pilih setidaknya satu hari.';
}
