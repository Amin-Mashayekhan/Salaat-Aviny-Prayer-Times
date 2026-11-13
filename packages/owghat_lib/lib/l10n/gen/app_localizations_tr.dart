// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get aboutAuthorIntro =>
      'Bu uygulama bağımsız bir geliştirici tarafından yapılmış ve sürdürülmektedir. Bir sorunu bildirmek, öneride bulunmak veya birlikte çalışmak için iletişime geçin.';

  @override
  String get aboutAuthorTitle => 'Geliştirici hakkında';

  @override
  String get aboutContactEmail => 'E-posta';

  @override
  String get aboutContactGithub => 'GitHub';

  @override
  String get aboutContactName => 'Ad';

  @override
  String get aboutContactPhone => 'Cep telefonu';

  @override
  String get aboutContactTelegram => 'Telegram';

  @override
  String get aboutCopiedValue => 'Kopyalandı.';

  @override
  String get aboutCopy => 'Kopyala';

  @override
  String get aboutFontNote =>
      'Vazirmatn yazı tipi SIL Open Font License 1.1 kapsamında uygulamayla birlikte gelir.';

  @override
  String get aboutLicenceNote =>
      'Bu uygulama MIT lisansıyla yayımlanır: özgürce kullanabilir, değiştirebilir ve paylaşabilirsiniz.';

  @override
  String get aboutLicences => 'Açık kaynak lisansları';

  @override
  String get aboutOpen => 'Aç';

  @override
  String get aboutOpenFailed =>
      'Açılamadı. Adresi kopyalayıp tarayıcınıza veya e-posta programınıza yapıştırın.';

  @override
  String get aboutPhoneNote =>
      'Arama ve SMS yalnızca İran içinden. İran dışından lütfen yalnızca Telegram kullanın.';

  @override
  String get aboutSoundNote =>
      'Uygulamayla gelen sesler (varsayılan ezan ve hatırlatma zili) üretilmiş basit yer tutucu seslerdir; kimseye ait kayıt değildir ve CC0 ile yayımlanmıştır. Kendi ezan sesinizi Ayarlar bölümünden seçebilirsiniz.';

  @override
  String get aboutTagline =>
      'Windows için namaz vakitleri ve ezan. Çevrimdışı çalışır; reklam, hesap ve izleme yoktur.';

  @override
  String get aboutTitle => 'Hakkında';

  @override
  String aboutVersion(String version) {
    return 'Sürüm $version';
  }

  @override
  String get appName => 'Salaat | Aviny Prayer Times';

  @override
  String get calendarAdjustEarlier => 'Bir gün önce';

  @override
  String get calendarAdjustLater => 'Bir gün sonra';

  @override
  String calendarAdjustValue(String value) {
    return '$value gün';
  }

  @override
  String calendarConvErrDay(String first, String days) {
    return 'Gün $first ile $days arasında olmalıdır.';
  }

  @override
  String get calendarConvErrIncomplete => 'Yıl, ay ve günü doldurun.';

  @override
  String get calendarConvErrMonth => 'Ay 1 ile 12 arasında olmalıdır.';

  @override
  String get calendarConvErrNumber => 'Yalnızca rakam kullanın.';

  @override
  String get calendarConvErrRange =>
      'Bu tarih, takvimin desteklediği aralığın dışında.';

  @override
  String get calendarConverterHint =>
      'Üç takvimden birine tarih yazın; diğer ikisi buna göre değişir.';

  @override
  String get calendarConverterShow => 'Takvimde göster';

  @override
  String get calendarConverterTitle => 'Tarih dönüştürücü';

  @override
  String calendarDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get calendarFieldDay => 'Gün';

  @override
  String get calendarFieldMonth => 'Ay';

  @override
  String get calendarFieldYear => 'Yıl';

  @override
  String get calendarGridLabel => 'Aylık takvim';

  @override
  String get calendarHijriAdjust => 'Kameri tarih ayarı';

  @override
  String get calendarHijriApproxHint =>
      'Yaklaşıktır: İranın resmî kameri takvimi hilal gözlemine göre belirlenir ve bir gün farklı olabilir.';

  @override
  String get calendarHijriUnavailable => 'Bu gün için tabloda kameri tarih yok';

  @override
  String get calendarKindGregorian => 'Miladi';

  @override
  String get calendarKindHijri => 'Hicri (kameri)';

  @override
  String get calendarKindJalali => 'Şemsi Hicri (Celali)';

  @override
  String calendarMonthGregorian(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Ocak',
      'm2': 'Şubat',
      'm3': 'Mart',
      'm4': 'Nisan',
      'm5': 'Mayıs',
      'm6': 'Haziran',
      'm7': 'Temmuz',
      'm8': 'Ağustos',
      'm9': 'Eylül',
      'm10': 'Ekim',
      'm11': 'Kasım',
      'm12': 'Aralık',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthHijri(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Muharrem',
      'm2': 'Safer',
      'm3': 'Rebiülevvel',
      'm4': 'Rebiülahir',
      'm5': 'Cemaziyelevvel',
      'm6': 'Cemaziyelahir',
      'm7': 'Recep',
      'm8': 'Şaban',
      'm9': 'Ramazan',
      'm10': 'Şevval',
      'm11': 'Zilkade',
      'm12': 'Zilhicce',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthJalali(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Ferverdin',
      'm2': 'Ordibeheşt',
      'm3': 'Hordad',
      'm4': 'Tir',
      'm5': 'Mordad',
      'm6': 'Şehrivar',
      'm7': 'Mihr',
      'm8': 'Aban',
      'm9': 'Azer',
      'm10': 'Dey',
      'm11': 'Behmen',
      'm12': 'İsfend',
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
      'Kameri tarih Ümmülkura tablosundan alınır. İranın resmî takvimi hilal gözlemine göre belirlenir ve bir gün farklı olabilir; öyleyse burada kaydırın.';

  @override
  String get calendarNextMonth => 'Sonraki ay';

  @override
  String get calendarOpenOnHome => 'Ana ekranda göster';

  @override
  String get calendarPanelTimes => 'Bu günün namaz vakitleri';

  @override
  String get calendarPreviousMonth => 'Önceki ay';

  @override
  String get calendarSeparator => ', ';

  @override
  String get calendarToday => 'Bugün';

  @override
  String calendarWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Pazartesi',
      'd2': 'Salı',
      'd3': 'Çarşamba',
      'd4': 'Perşembe',
      'd5': 'Cuma',
      'd6': 'Cumartesi',
      'd7': 'Pazar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Pzt',
      'd2': 'Sal',
      'd3': 'Çar',
      'd4': 'Per',
      'd5': 'Cum',
      'd6': 'Cmt',
      'd7': 'Paz',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get contributeIntro =>
      'Bu uygulamanın kodu GitHub üzerindedir ve her türlü yardım memnuniyetle karşılanır. Katılma yolları:';

  @override
  String get contributeOpenGuide => 'Katkı rehberi';

  @override
  String get contributeOpenIssues => 'Hata veya fikir bildir';

  @override
  String get contributeOpenRepo => 'Depoyu GitHub üzerinde aç';

  @override
  String get contributeTitle => 'Katkıda bulunun';

  @override
  String get contributeWayCode =>
      'Kod: depoyu fork edin, değişikliği bir dalda yapın, testleri çalıştırın ve Pull Request gönderin. Derleme ve test adımları CONTRIBUTING.md içindedir.';

  @override
  String get contributeWayData =>
      'Veri: bir şehrin adını, koordinatlarını veya saat dilimini düzeltin ya da yeni bir şehir ekleyin.';

  @override
  String get contributeWayIssues =>
      'Hata veya fikir bildirme: GitHub üzerinde bir Issue açın ve sürümü ile bu sayfadaki tanılama raporunu ekleyin (rapor ad veya koordinat içermez).';

  @override
  String get contributeWayTest =>
      'Test: uygulamayı farklı Windows sürümlerinde ve donanımlarında deneyin (ezan, tepsi, uyandırma alarmları) ve gördüklerinizi bildirin.';

  @override
  String get contributeWayTranslate =>
      'Çeviri: uygulamanın metinleri lib/l10n klasöründedir. Yeni bir dil veya mevcut bir dil için düzeltme gönderin; ana dili konuşan birinin gözden geçirmesi çok değerlidir.';

  @override
  String get diagAudioFailed =>
      'Deneme sesi çalınamadı. Hoparlörleri ve Windows ses düzeyini kontrol edin.';

  @override
  String get diagAudioOk => 'Deneme sesi çalındı.';

  @override
  String get diagAudioPlay => 'Deneme sesi çal';

  @override
  String get diagAudioStop => 'Durdur';

  @override
  String get diagAudioTitle => 'Ses testi';

  @override
  String get diagClockOk => 'Saat sorunu bulunamadı.';

  @override
  String get diagClockTitle => 'Saat';

  @override
  String get diagClockUnchecked =>
      'Sorun görülmedi, ancak ağ saati denetimi kapalı olduğundan saat sapması ölçülmüyor.';

  @override
  String get diagCopied => 'Panoya kopyalandı. Ad ve kesin koordinat içermez.';

  @override
  String get diagCopy => 'Tanılamayı kopyala';

  @override
  String get diagCopyFailed => 'Kopyalanamadı.';

  @override
  String diagEventAzan(String prayer) {
    return 'Ezan: $prayer';
  }

  @override
  String diagEventReminder(String prayer) {
    return 'Hatırlatma: $prayer';
  }

  @override
  String diagEventTimes(String utc, String local) {
    return 'UTC $utc | yerel $local';
  }

  @override
  String get diagEventWake => 'Uyandırma alarmı';

  @override
  String get diagEventsEmpty => 'Planlanmış bir şey yok.';

  @override
  String get diagEventsTitle => 'Sıradaki planlı olaylar';

  @override
  String get diagLogNone => 'Mevcut değil.';

  @override
  String get diagLogTitle => 'Günlük dosyaları';

  @override
  String get diagTitle => 'Tanılama';

  @override
  String diagValue(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'yes': 'evet',
      'no': 'hayır',
      'unknown': 'bilinmiyor',
      'enabled': 'izinli',
      'disabled': 'kapalı',
      'importantOnly': 'yalnızca önemliler',
      'ok': 'çalışıyor',
      'failed': 'başarısız',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String diagWakeAc(String value) {
    return 'Uyandırma zamanlayıcıları, prize takılıyken: $value';
  }

  @override
  String diagWakeBattery(String value) {
    return 'Uyandırma zamanlayıcıları, pilde: $value';
  }

  @override
  String get diagWakeCheck => 'Şimdi denetle';

  @override
  String diagWakeInProcess(String value) {
    return 'Uygulama içi zamanlayıcı: $value';
  }

  @override
  String diagWakeModern(String value) {
    return 'Modern Standby: $value';
  }

  @override
  String get diagWakeNotChecked => 'Henüz denetlenmedi.';

  @override
  String diagWakeTask(String value) {
    return 'Zamanlanmış görev: $value';
  }

  @override
  String get diagWakeTitle => 'Uyandırma denetimi';

  @override
  String get formatAm => 'ÖÖ';

  @override
  String formatHours(String hours) {
    return '$hours sa';
  }

  @override
  String formatHoursMinutes(String hours, String minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String formatMinutes(String minutes) {
    return '$minutes dk';
  }

  @override
  String get formatPm => 'ÖS';

  @override
  String formatRemaining(String duration) {
    return '$duration sonra';
  }

  @override
  String formatRemainingLessThan(String minutes) {
    return '$minutes dk içinde';
  }

  @override
  String formatSeconds(String seconds) {
    return '$seconds sn';
  }

  @override
  String get homeAzanMutedIndefinite => 'Ezan: siz açana kadar sessiz';

  @override
  String homeAzanMutedUntil(String time) {
    return 'Ezan: $time saatine kadar sessiz';
  }

  @override
  String get homeAzanOff => 'Ezan: kapalı';

  @override
  String get homeAzanOn => 'Ezan: açık';

  @override
  String homeAzanToggleOff(String prayer) {
    return '$prayer ezanını kapat';
  }

  @override
  String homeAzanToggleOn(String prayer) {
    return '$prayer ezanını aç';
  }

  @override
  String get homeBackToToday => 'Bugüne dön';

  @override
  String get homeBannerAllow => 'İzin ver';

  @override
  String homeBannerClockSkew(String amount) {
    return 'Bilgisayarın saati yaklaşık $amount yanlış.';
  }

  @override
  String get homeBannerDismiss => 'Kapat';

  @override
  String get homeBannerExactTiming =>
      'Android ezanı geç, bazen bir saate kadar gecikmeyle iletebilir. İzin ver düğmesine basın ve açılan sayfada Salaat için Alarms & reminders seçeneğini açın; ezan tam dakikasında gelsin.';

  @override
  String get homeBannerMutedIndefinite =>
      'Ezan, siz yeniden açana kadar sessizde.';

  @override
  String homeBannerMutedUntil(String time) {
    return 'Ezan $time saatine kadar sessizde.';
  }

  @override
  String get homeBannerNotificationsOff =>
      'Bildirimler kapalı; bu yüzden uygulama kapalıyken ezan okunamaz. İzin ver düğmesine basın ve Salaat için bildirimleri açın.';

  @override
  String get homeBannerSettingsReset =>
      'Ayar dosyası okunamadı ve ayarlar varsayılanlara sıfırlandı.';

  @override
  String get homeBannerStaleZone =>
      'Windows bu yer için saat dilimi veritabanından farklı bir saat gösteriyor. Uygulamadaki vakitler doğrudur; Windows saatini kontrol edin.';

  @override
  String homeCompass(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'p0': 'kuzey',
      'p1': 'kuzeydoğu',
      'p2': 'doğu',
      'p3': 'güneydoğu',
      'p4': 'güney',
      'p5': 'güneybatı',
      'p6': 'batı',
      'p7': 'kuzeybatı',
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
    return '$date vakitleri';
  }

  @override
  String homeEventAt(String event, String time) {
    return '$event $time';
  }

  @override
  String get homeHeroNoNext => 'Geri sayılacak bir şey yok';

  @override
  String get homeMute => 'Sessize al';

  @override
  String get homeMuteCancel => 'Sessizi iptal et';

  @override
  String homeMuteForDuration(String duration) {
    return '$duration boyunca';
  }

  @override
  String get homeMuteIndefinite => 'Ben açana kadar';

  @override
  String get homeMuteUntilNext => 'Sonraki ezana kadar';

  @override
  String get homeNextDay => 'Sonraki gün';

  @override
  String get homeNextMarker => 'Sıradaki';

  @override
  String homeNextWakeAlarm(String value) {
    return 'Sonraki uyandırma: $value';
  }

  @override
  String get homeNoTimesAction => 'Hesaplama ayarları';

  @override
  String get homeNoTimesInfo =>
      'Bu yer için bu günde her vakit hesaplanamaz. Yüksek enlem kuralını ayarlardan değiştirebilirsiniz.';

  @override
  String get homeNoValue => '—';

  @override
  String homeNowPlaying(String prayer) {
    return 'Çalıyor: $prayer';
  }

  @override
  String get homeNowPlayingGeneric => 'Ezan çalıyor';

  @override
  String get homeOtherDayHint =>
      'Bu günün vakitleri; geri sayım yalnızca bugün içindir.';

  @override
  String get homePreviousDay => 'Önceki gün';

  @override
  String homeQiblaSummary(String degrees, String direction) {
    return 'Kıble: $degrees° $direction';
  }

  @override
  String homeReminderMinutes(String minutes) {
    return 'Hatırlatma: $minutes dk önce';
  }

  @override
  String get homeReminderOff => 'Hatırlatmalar: kapalı';

  @override
  String homeReminderRange(String min, String max) {
    return 'Hatırlatmalar: $min ile $max dk önce';
  }

  @override
  String get homeStatusTitle => 'Durum';

  @override
  String get homeStop => 'Durdur';

  @override
  String get homeSwitchLocation => 'Konumu değiştir';

  @override
  String get homeTimelineLabel => 'Gün zaman çizelgesi';

  @override
  String get homeToday => 'Bugün';

  @override
  String get homeTodayTimes => 'Bugünün vakitleri';

  @override
  String get homeTomorrowTimes => 'Yarının vakitleri';

  @override
  String homeUntilEvent(String event) {
    return '$event vaktine kadar';
  }

  @override
  String homeViewingDay(String date) {
    return '$date görüntüleniyor';
  }

  @override
  String get navCalendar => 'Takvim';

  @override
  String get navHome => 'Ana sayfa';

  @override
  String get navQibla => 'Kıble';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get navTimetable => 'Vakit cetveli';

  @override
  String get navWakeUp => 'Uyandırma';

  @override
  String notifAzanBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String get notifAzanFailed => 'Ezan çalınamadı.';

  @override
  String notifAzanTitle(String prayer) {
    return '$prayer ezanı';
  }

  @override
  String notifMissedBody(String time) {
    return 'Bilgisayar saat $time sırasında uykudaydı.';
  }

  @override
  String notifMissedTitle(String prayer) {
    return '$prayer ezanı çalınmadı';
  }

  @override
  String notifReminderBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String notifReminderTitle(String minutes, String prayer) {
    return '$prayer vaktine $minutes dk kaldı';
  }

  @override
  String get notifSoundFallback =>
      'Ezan ses dosyası bulunamadı; varsayılan ses çalındı.';

  @override
  String get notifStopAction => 'Durdur';

  @override
  String get notifTrayHint =>
      'Uygulama Windows saatinin yanında çalışmaya devam eder.';

  @override
  String get onboardingAzanBody =>
      'Ezanı dinleyin ve uygulamanın Windows ile başlayıp başlamayacağını seçin.';

  @override
  String get onboardingAzanBodyOnly =>
      'Ezanı dinleyin. Her namazın sesini ve ses düzeyini daha sonra ayarlardan değiştirebilirsiniz.';

  @override
  String get onboardingAzanTitle => 'Ezan ve başlangıç';

  @override
  String get onboardingAzanTitleOnly => 'Ezan sesi';

  @override
  String get onboardingBack => 'Geri';

  @override
  String get onboardingCityBody => 'Şehrinizi arayın veya bir ilden seçin.';

  @override
  String get onboardingCityNone => 'Şehir bulunamadı.';

  @override
  String get onboardingCitySearchHint => 'Şehir ara';

  @override
  String onboardingCitySelected(String city) {
    return 'Seçilen: $city';
  }

  @override
  String get onboardingCityTitle => 'Şehriniz';

  @override
  String get onboardingFinish => 'Başla';

  @override
  String get onboardingLanguageBody =>
      'Dilinizi seçin. Daha sonra ayarlardan değiştirebilirsiniz.';

  @override
  String get onboardingLanguageTitle => 'Dil';

  @override
  String get onboardingModeList => 'İran şehirleri (çevrimdışı liste)';

  @override
  String get onboardingModeOnline =>
      'Dünyadaki herhangi bir şehir (çevrimiçi arama)';

  @override
  String get onboardingNext => 'İleri';

  @override
  String get onboardingOnlineBody =>
      'Şehriniz listede yok mu? Dünyadaki herhangi bir şehri arayın. İnternet yalnızca bu arama için gerekir; sonrasında uygulama internetsiz çalışır.';

  @override
  String get onboardingPreview => 'Örnek ezan çal';

  @override
  String get onboardingProvinceAll => 'Tüm iller';

  @override
  String get onboardingSkip => 'Atla';

  @override
  String get onboardingStartWithWindows => 'Windows ile başlat';

  @override
  String get onboardingStartWithWindowsHint =>
      'Uygulama sessizce sistem tepsisinde başlar.';

  @override
  String onboardingStepProgress(String step, String total) {
    return 'Adım $step / $total';
  }

  @override
  String get onboardingStopPreview => 'Durdur';

  @override
  String get placeSearchAttribution =>
      'Yerler © OpenStreetMap katkıda bulunanlar (Nominatim). Saat dilimi ve yükseklik: Open-Meteo.';

  @override
  String get placeSearchButton => 'Ara';

  @override
  String get placeSearchFailBusy =>
      'Arama hizmeti meşgul. Bir dakika bekleyip yeniden deneyin.';

  @override
  String get placeSearchFailDetails =>
      'Yer bulundu ancak saat dilimi alınamadı. Bağlantıyı kontrol edin ve yeri yeniden seçin.';

  @override
  String get placeSearchFailGeneric =>
      'Arama çalışmadı. Biraz sonra yeniden deneyin.';

  @override
  String get placeSearchFailOffline =>
      'İnternet bağlantısı yok. Bağlanın ve yeniden Ara düğmesine basın. Uygulamanın geri kalanı internetsiz çalışır.';

  @override
  String get placeSearchFailTimeout =>
      'Arama hizmeti zamanında yanıt vermedi. Yeniden deneyin.';

  @override
  String get placeSearchHint => 'Şehir, ülke (örneğin Mumbai, Hindistan)';

  @override
  String placeSearchNone(String query) {
    return '“$query” için yer bulunamadı. Yazımı kontrol edin veya ülkeyi de ekleyin, örneğin Mumbai, Hindistan.';
  }

  @override
  String get placeSearchNotice =>
      'Arama yalnızca bu seferlik internet gerektirir. Yazdığınız metin OpenStreetMap arama hizmetine (Nominatim) gönderilir; başka hiçbir şey gönderilmez. Yeri seçtikten sonra uygulama gereken bilgiyi saklar ve yeniden internetsiz çalışır.';

  @override
  String get placeSearchNoticeWithDetails =>
      'Arama yalnızca bu seferlik internet gerektirir. Yazdığınız metin OpenStreetMap arama hizmetine (Nominatim) gönderilir; bir yer seçtiğinizde saat dilimi ve yüksekliği için yalnızca o yerin koordinatları Open-Meteo’ya gider. Başka hiçbir şey gönderilmez ve sonrasında uygulama internetsiz çalışır.';

  @override
  String placeSearchResolving(String place) {
    return '$place için saat dilimi ve yükseklik alınıyor…';
  }

  @override
  String get placeSearchResultsTitle => 'Sonuçlar: yerinizi seçin';

  @override
  String get placeSearchTitle => 'Yer ara';

  @override
  String get placeSearchTooShort =>
      'En az iki harf yazın, sonra Ara düğmesine basın.';

  @override
  String get placeSearchUnknownZone =>
      'Bu yerin saat dilimi uygulama veritabanında yok. Başka bir yer deneyin veya ayarlardaki Özel konum ile ekleyin.';

  @override
  String get placeSearching => 'Aranıyor…';

  @override
  String get prayerAsr => 'İkindi';

  @override
  String get prayerDhuhr => 'Öğle';

  @override
  String get prayerFajr => 'Sabah';

  @override
  String get prayerImsak => 'İmsak';

  @override
  String get prayerIsha => 'Yatsı';

  @override
  String get prayerMaghrib => 'Akşam';

  @override
  String get prayerMidnight => 'Gece yarısı';

  @override
  String get prayerSunrise => 'Güneş';

  @override
  String get prayerSunset => 'Güneş batışı';

  @override
  String qiblaAccuracyValue(String meters) {
    return 'Doğruluk: yaklaşık $meters m';
  }

  @override
  String get qiblaBearingLabel => 'Yön açısı (gerçek kuzeyden saat yönünde)';

  @override
  String qiblaBearingValue(String degrees, String direction) {
    return '$degrees° ($direction)';
  }

  @override
  String get qiblaCamKaaba => 'Kâbe';

  @override
  String get qiblaCamNearby => 'Çevrem';

  @override
  String get qiblaCamOverview => 'Tüm güzergâh';

  @override
  String qiblaCardinal(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'n': 'K',
      'e': 'D',
      's': 'G',
      'w': 'B',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String qiblaCompassSemantics(String degrees, String direction) {
    return 'Pusula gülü: kıble $degrees derecede ($direction)';
  }

  @override
  String qiblaCompassSemanticsSun(String base, String azimuth) {
    return '$base; güneş $azimuth derecede';
  }

  @override
  String get qiblaCoordsApply => 'Göster';

  @override
  String get qiblaCoordsHint => 'örneğin 36.2133, 58.7958';

  @override
  String get qiblaCoordsInvalid =>
      'Geçerli koordinat değil. Enlem -90 ile 90, boylam -180 ile 180 arasında olmalıdır.';

  @override
  String get qiblaCoordsLabel => 'Enlem ve boylam';

  @override
  String get qiblaCoordsOr => 'Ya da koordinatları kendiniz girin';

  @override
  String qiblaCustomPlaceShown(String place) {
    return '$place noktasından ölçülüyor.';
  }

  @override
  String get qiblaDeviceFixShown => 'Bu cihazın konumu gösteriliyor.';

  @override
  String get qiblaDistanceLabel => 'Kâbeye uzaklık';

  @override
  String qiblaDistanceValue(String km) {
    return '$km km';
  }

  @override
  String get qiblaFailGeneric => 'Konum okunamadı; seçili şehir gösteriliyor.';

  @override
  String get qiblaFailPermissionDenied =>
      'Windows bu uygulamanın konumu okumasına izin vermedi. Aşağıdaki adımları izleyip yeniden deneyin; ya da seçili şehri kullanın.';

  @override
  String get qiblaFailPermissionForever =>
      'Konum erişimi reddedildi. Yeniden izin vermek için aşağıdaki adımları izleyin.';

  @override
  String get qiblaFailServiceDisabled =>
      'Bu cihazda konum hizmetleri kapalı. Aşağıdaki adımları izleyin; ya da seçili şehri veya herhangi bir noktayı kullanın.';

  @override
  String get qiblaFailTimeout =>
      'Konum zamanında gelmedi. Bilgisayarlarda nadiren GPS bulunur; Windows konumu Wi-Fi ile tahmin eder. Yeniden deneyin veya şehri kullanın.';

  @override
  String get qiblaFailUnsupported =>
      'Bu cihaz konum bildiremiyor; seçili şehir gösteriliyor.';

  @override
  String qiblaForLocation(String place) {
    return '$place için kıble yönü';
  }

  @override
  String get qiblaHelpOther =>
      'İşletim sistemi ayarlarında konumu açın, bu uygulamanın kullanmasına izin verin ve yeniden deneyin.';

  @override
  String get qiblaHelpTitleOther => 'Konumu nasıl açarım?';

  @override
  String get qiblaHelpTitleWindows => 'Windows için konumu nasıl açarım?';

  @override
  String get qiblaHelpWin1 =>
      'Windows Ayarlarındaki Konum sayfasını açmak için yukarıdaki düğmeye basın. Açılmazsa elle gidin: Start > Settings > Privacy & security > Location (Windows 10: Privacy > Location)';

  @override
  String get qiblaHelpWin2 =>
      'Location services seçeneğini açın. Sayfanın üstünde Location for this device is off yazıyorsa Change düğmesine basıp açın.';

  @override
  String get qiblaHelpWin3 =>
      'Biraz aşağıda Let desktop apps access your location seçeneğini açın (Windows 10: Allow desktop apps to access your location). Salaat bir masaüstü uygulamasıdır ve yalnızca bu anahtarla izin alır.';

  @override
  String get qiblaHelpWin4 =>
      'Salaat uygulamasına dönün ve Konumumu bul düğmesine yeniden basın. Yine olmazsa uygulamayı bir kez kapatıp yeniden açın.';

  @override
  String get qiblaLocateAgain => 'Yeniden bul';

  @override
  String get qiblaLocateButton => 'Konumumu bul';

  @override
  String get qiblaLocating => 'Konumunuz bulunuyor…';

  @override
  String get qiblaMapAttribution => '© OpenStreetMap contributors';

  @override
  String get qiblaMapAttributionSatellite =>
      'Imagery © Esri, Maxar, Earthstar Geographics, and the GIS User Community';

  @override
  String get qiblaMapConsentBody =>
      'Kıble çizgisini harita üzerinde çizmek için harita görselleri internetten alınır ve baktığınız alan o sunucuya gönderilir: sokak haritası OpenStreetMap tarafından, Uydu seçerseniz hava fotoğrafları Esri tarafından sağlanır. Siz kabul edene kadar hiçbir istek yapılmaz. Kıble açısı ve uzaklığı harita olmadan da doğru gösterilir.';

  @override
  String get qiblaMapConsentButton => 'Haritayı göster';

  @override
  String get qiblaMapConsentTitle => 'Kıble haritası';

  @override
  String get qiblaMapKaaba => 'Kâbe';

  @override
  String get qiblaMapLineNote =>
      'Çizgi, küre üzerinde Kâbe merkezine giden en kısa yoldur. Düz haritada eğri görünür, ama kıble yönünde başlar. Kâbe oluğu merkezden yalnızca birkaç metre uzaktadır ve yönde gözle görülür bir fark yaratmaz. Sokaklar ve binalarla karşılaştırmak için Çevrem düğmesine basın.';

  @override
  String get qiblaMapOfflineBanner =>
      'Harita görselleri yüklenemiyor (internet yok mu?). Kıble çizgisi ve açısı yine de doğrudur.';

  @override
  String qiblaMapSemantics(String place, String bearing, String distance) {
    return 'Kıble haritası: $place konumundan Kâbeye, $bearing, $distance';
  }

  @override
  String get qiblaMapTapHint => 'Başka bir nokta seçmek için haritaya dokunun.';

  @override
  String get qiblaMapTurnOff => 'Haritayı kapat';

  @override
  String get qiblaMapYou => 'Konumunuz';

  @override
  String get qiblaNoCompassNote =>
      'Bilgisayarda pusula yoktur; bu yüzden çizim gerçek kuzeye göredir (kuzey üsttedir).';

  @override
  String get qiblaOpenSettingsFailed =>
      'Ayarlar sayfası açılamadı; adımları elle izleyin.';

  @override
  String get qiblaOpenSettingsOther => 'Konum ayarlarını aç';

  @override
  String get qiblaOpenSettingsWindows => 'Windows konum ayarlarını aç';

  @override
  String get qiblaSourceCity => 'Seçili şehir';

  @override
  String qiblaSourceCityHelp(String city) {
    return 'Namaz vakitleri için seçtiğiniz şehir: $city.';
  }

  @override
  String get qiblaSourceCustom => 'Herhangi bir nokta';

  @override
  String get qiblaSourceCustomHelp =>
      'Bir yeri adıyla arayın (bir kez internet gerekir), haritaya dokunun veya koordinatları girin.';

  @override
  String get qiblaSourceDevice => 'Bu cihaz';

  @override
  String get qiblaSourceDeviceHelp =>
      'Konum yalnızca düğmeye bastığınızda cihazdan okunur; saklanmaz ve hiçbir yere gönderilmez.';

  @override
  String get qiblaSourceTitle => 'Kıbleyi şuradan ölç';

  @override
  String get qiblaStatLatitude => 'Enlem';

  @override
  String get qiblaStatLongitude => 'Boylam';

  @override
  String get qiblaStyleLabel => 'Harita türü';

  @override
  String get qiblaStyleSatellite => 'Uydu';

  @override
  String get qiblaStyleStreet => 'Harita';

  @override
  String get qiblaSunBelow => 'Güneş ufkun altında.';

  @override
  String get qiblaSunInHelp => 'Şu anda güneş tam kıble yönünde; güneşe dönün.';

  @override
  String get qiblaSunInTitle => 'Güneş kıble yönünde';

  @override
  String get qiblaSunNone => 'Bugün olmuyor.';

  @override
  String get qiblaSunNowLabel => 'Güneş şimdi';

  @override
  String qiblaSunNowValue(String azimuth, String altitude) {
    return 'Azimut $azimuth°, yükseklik $altitude°';
  }

  @override
  String get qiblaSunOppHelp =>
      'Şu anda dik bir çubuğun gölgesi kıbleyi gösteriyor.';

  @override
  String get qiblaSunOppTitle => 'Güneş kıblenin karşısında';

  @override
  String get qiblaSunTimesTitle => 'Bugün güneş ve kıble';

  @override
  String get qiblaTabCompass => 'Pusula ve güneş';

  @override
  String get qiblaTabMap => 'Harita';

  @override
  String get qiblaTitle => 'Kıble';

  @override
  String get settingsAboutPlaceholder =>
      'Sürüm, lisanslar ve tanılama sayfası bu bölümde görünür.';

  @override
  String get settingsAppAutostart => 'Windows ile başlat';

  @override
  String get settingsAppAutostartHelp =>
      'Windows oturumu açtığınızda uygulama sessizce saatin yanında başlar.';

  @override
  String get settingsAppCloseToTray => 'Tepsiye kapat';

  @override
  String get settingsAppCloseToTrayHelp =>
      'Pencereyi kapatmak uygulamayı Windows saatinin yanında tutar, böylece ezan yine çalar. Kapalıyken pencereyi kapatmak uygulamadan çıkar.';

  @override
  String get settingsAppMinimized => 'Küçültülmüş başlat';

  @override
  String get settingsAppMinimizedHelp =>
      'Windows uygulamayı başlattığında pencere kapalı kalır.';

  @override
  String get settingsAsrHanafi => 'Hanefi (gölge nesnenin iki katı)';

  @override
  String get settingsAsrStandard => 'Standart (gölge nesneye eşit)';

  @override
  String get settingsAzanChoose => 'Dosya seç…';

  @override
  String get settingsAzanEnabled => 'Ezanı çal';

  @override
  String get settingsAzanEnabledHelp =>
      'Ana anahtar; kapalıyken hiçbir ezan çalmaz.';

  @override
  String get settingsAzanFade => 'Yumuşak giriş';

  @override
  String get settingsAzanFadeHelp =>
      'Ezan sesi yavaşça tam ses düzeyine yükselir.';

  @override
  String get settingsAzanMute => 'Hızlı sessize alma';

  @override
  String get settingsAzanMuteHelp => 'Ezanı bir süre susturun.';

  @override
  String get settingsAzanNotMuted => 'Sessizde değil';

  @override
  String get settingsAzanPhoneNote =>
      'Telefonda ezan ve hatırlatmalar sistem bildirimi olarak gelir; böylece uygulama kapalıyken de ulaşırlar. Ezan bildirimi uygulamayla gelen ezan sesini çalar; bu sayfada seçilen ses ve ses düzeyi uygulama içindeki önizleme içindir. Sesin yüksekliğini telefonun bildirim sesiyle ayarlayın.';

  @override
  String settingsAzanPrayerSwitch(String prayer) {
    return '$prayer ezanı';
  }

  @override
  String get settingsAzanPrayerVolume => 'Bu ezanın ses düzeyi';

  @override
  String get settingsAzanPreview => 'Önizleme';

  @override
  String get settingsAzanSound => 'Ses';

  @override
  String get settingsAzanSoundDefault => 'Uygulamayla gelen ezan';

  @override
  String settingsAzanSoundFile(String name) {
    return 'Dosya: $name';
  }

  @override
  String get settingsAzanUseDefault => 'Uygulamayla gelen sesi kullan';

  @override
  String get settingsAzanVolume => 'Ses düzeyi';

  @override
  String get settingsAzanVolumeHelp => 'Tüm ezanların genel ses düzeyi';

  @override
  String get settingsBackupExport => 'Yedeği dışa aktar';

  @override
  String get settingsBackupExportFailed => 'Yedek kaydedilemedi.';

  @override
  String get settingsBackupExportHelp =>
      'Tüm ayarlar, konumlar ve uyandırma alarmları tek bir dosyaya kaydedilir.';

  @override
  String settingsBackupExported(String path) {
    return 'Yedek kaydedildi: $path';
  }

  @override
  String get settingsBackupImport => 'Yedeği içe aktar';

  @override
  String get settingsBackupImportBody =>
      'Mevcut tüm ayarlar bu dosyanın içeriğiyle değiştirilir.';

  @override
  String get settingsBackupImportConfirm => 'Geri yükle';

  @override
  String get settingsBackupImportHelp =>
      'Ayarları bir yedek dosyasından geri yükler.';

  @override
  String get settingsBackupImportInvalid =>
      'Bu dosya geçerli bir ayar yedeği değil; ayarlar değiştirilmedi.';

  @override
  String get settingsBackupImportReadFailed =>
      'Dosya okunamadı; ayarlar değiştirilmedi.';

  @override
  String get settingsBackupImportTitle => 'Ayarlar geri yüklensin mi?';

  @override
  String get settingsBackupImported => 'Ayarlar geri yüklendi.';

  @override
  String get settingsBackupTitle => 'Yedekleme ve geri yükleme';

  @override
  String get settingsCalcAngleHelp =>
      'Güneşin ufkun altındaki açısı, derece cinsinden';

  @override
  String get settingsCalcAsr => 'İkindi kuralı';

  @override
  String get settingsCalcFajrAngle => 'Sabah açısı';

  @override
  String get settingsCalcHighLat => 'Yüksek enlemler';

  @override
  String get settingsCalcHighLatHelp =>
      'Gecenin çok kısa olduğu ve alacakaranlık açısına hiç ulaşılmayan yerler için.';

  @override
  String get settingsCalcImsak => 'İmsak';

  @override
  String get settingsCalcImsakHelp => 'Sabahtan önce dakika';

  @override
  String get settingsCalcIshaAngle => 'Yatsı açısı';

  @override
  String get settingsCalcIshaMinutes => 'Akşamdan sonra dakika';

  @override
  String get settingsCalcIshaMode => 'Yatsı tanımı';

  @override
  String get settingsCalcIshaModeAngle => 'Güneş açısı';

  @override
  String get settingsCalcIshaModeMinutes => 'Akşamdan sonra dakika';

  @override
  String get settingsCalcMaghribAngle => 'Akşam açısı';

  @override
  String get settingsCalcMaghribSunset => 'Akşam, güneş batışında';

  @override
  String get settingsCalcMaghribSunsetHelp =>
      'Kapalıyken akşam vakti aşağıdaki açıyla hesaplanır.';

  @override
  String get settingsCalcMethod => 'Yöntem';

  @override
  String get settingsCalcMethodHelp =>
      'Herhangi bir açıyı değiştirmek yöntemi Özel yapar.';

  @override
  String get settingsCalcMidnight => 'Gece yarısı';

  @override
  String settingsCalcOffsetsHelp(String max) {
    return 'Her vakti en çok $max dakika öne veya geriye alın.';
  }

  @override
  String get settingsCalcOffsetsReset => 'Tümünü sıfırla';

  @override
  String get settingsCalcOffsetsTitle => 'Vakit başına dakika ayarı';

  @override
  String settingsCalcPreviewHelp(String date) {
    return 'Yukarıdaki ayarlarla bugünün vakitleri ($date)';
  }

  @override
  String get settingsCalcPreviewTitle => 'Canlı önizleme';

  @override
  String get settingsCalcRestore => 'Bu yöntemin varsayılanlarını geri yükle';

  @override
  String settingsCalcRestoreHelp(String method) {
    return 'Açılar, kurallar ve İmsak $method değerlerine döner; her vaktin dakika ayarları değişmez.';
  }

  @override
  String get settingsCalcRowsHelp =>
      'Sabah, Güneş, Öğle, Akşam ve Gece yarısı her zaman gösterilir.';

  @override
  String get settingsCalcRowsTitle => 'Gösterilecek satırlar';

  @override
  String get settingsCancel => 'İptal';

  @override
  String get settingsDecrease => 'Azalt';

  @override
  String get settingsDigitsArabic => 'Arapça (٠١٢)';

  @override
  String get settingsDigitsLatin => 'Latin (123)';

  @override
  String get settingsDigitsPersian => 'Farsça (۱۲۳)';

  @override
  String get settingsDispDigits => 'Rakamlar';

  @override
  String get settingsDispHijri => 'Hicri tarih ayarı';

  @override
  String get settingsDispHijriHelp =>
      'İran hilal gözlemine uyar, bu yüzden gösterilen Hicri tarih resmî olandan farklı olabilir; buradan bir veya iki gün kaydırın.';

  @override
  String get settingsDispHour => 'Saat';

  @override
  String get settingsDispLanguage => 'Dil';

  @override
  String get settingsDispLanguageHelp => 'Yeniden başlatmadan uygulanır.';

  @override
  String get settingsDispTheme => 'Tema';

  @override
  String get settingsHighLatAngleBased => 'Açıya dayalı';

  @override
  String get settingsHighLatNightMiddle => 'Gecenin ortası';

  @override
  String get settingsHighLatNone => 'Ayarlama yok';

  @override
  String get settingsHighLatOneSeventh => 'Gecenin yedide biri';

  @override
  String get settingsHour12 => '12 saatlik';

  @override
  String get settingsHour24 => '24 saatlik';

  @override
  String get settingsIncrease => 'Artır';

  @override
  String settingsInvalidNumber(String min, String max) {
    return '$min ile $max arasında bir sayı girin.';
  }

  @override
  String get settingsLocActive => 'Etkin';

  @override
  String get settingsLocAdd => 'Ekle';

  @override
  String get settingsLocAddCustom => 'Özel konum';

  @override
  String get settingsLocAddFromDb => 'Şehir listesinden';

  @override
  String get settingsLocAddSearch => 'Çevrimiçi ara';

  @override
  String get settingsLocAddTitle => 'Konum ekle';

  @override
  String settingsLocAdded(String name) {
    return '$name eklendi.';
  }

  @override
  String get settingsLocAllProvinces => 'Tüm iller';

  @override
  String get settingsLocAlreadySaved => 'Zaten kayıtlı';

  @override
  String settingsLocAlreadySavedName(String name) {
    return '$name kayıtlı konumlarınızda zaten var.';
  }

  @override
  String get settingsLocClose => 'Kapat';

  @override
  String settingsLocCoords(String lat, String lon) {
    return 'Enlem $lat, boylam $lon';
  }

  @override
  String get settingsLocCustomBadge => 'Özel';

  @override
  String get settingsLocDegrees => 'Derece';

  @override
  String get settingsLocDelete => 'Sil';

  @override
  String get settingsLocDeleteBody => 'Bu konum listenizden kaldırılır.';

  @override
  String get settingsLocDeleteLast => 'Son konum silinemez.';

  @override
  String settingsLocDeleteTitle(String name) {
    return '$name silinsin mi?';
  }

  @override
  String get settingsLocEast => 'Doğu';

  @override
  String get settingsLocEdit => 'Düzenle';

  @override
  String get settingsLocElevation => 'Yükseklik (metre)';

  @override
  String settingsLocErrElevation(String min, String max) {
    return 'Yükseklik $min ile $max metre arasında olmalıdır.';
  }

  @override
  String settingsLocErrLatitude(String min, String max) {
    return 'Enlem $min ile $max arasında bir sayı olmalıdır.';
  }

  @override
  String settingsLocErrLongitude(String min, String max) {
    return 'Boylam $min ile $max arasında bir sayı olmalıdır.';
  }

  @override
  String get settingsLocErrName => 'Bir ad girin.';

  @override
  String settingsLocErrOffset(String min, String max) {
    return 'Fark $min ile $max arasında olmalıdır.';
  }

  @override
  String get settingsLocErrZone => 'Listeden bir saat dilimi seçin.';

  @override
  String get settingsLocFormatDecimal => 'Ondalık derece';

  @override
  String get settingsLocFormatDms => 'Derece, dakika, saniye';

  @override
  String get settingsLocLatitude => 'Enlem';

  @override
  String get settingsLocLongitude => 'Boylam';

  @override
  String get settingsLocMinutes => 'Dakika';

  @override
  String get settingsLocName => 'Ad';

  @override
  String get settingsLocNoResults => 'Şehir bulunamadı.';

  @override
  String get settingsLocNorth => 'Kuzey';

  @override
  String get settingsLocProvince => 'İl';

  @override
  String get settingsLocSave => 'Kaydet';

  @override
  String get settingsLocSavedHelp => 'Vakitler etkin konum için hesaplanır.';

  @override
  String get settingsLocSavedTitle => 'Kayıtlı konumlar';

  @override
  String get settingsLocSearchHint => 'Şehir ara';

  @override
  String get settingsLocSeconds => 'Saniye';

  @override
  String get settingsLocSetActive => 'Etkin yap';

  @override
  String get settingsLocSouth => 'Güney';

  @override
  String get settingsLocWest => 'Batı';

  @override
  String get settingsLocZoneNone => 'Saat dilimi bulunamadı.';

  @override
  String get settingsLocZoneSearch => 'Saat dilimi ara';

  @override
  String settingsLocZoneSelected(String zone) {
    return 'Seçilen saat dilimi: $zone';
  }

  @override
  String get settingsMethodCustom => 'Özel';

  @override
  String get settingsMethodEgypt => 'Mısır Genel Etüt Kurumu';

  @override
  String get settingsMethodIsna => 'Kuzey Amerika İslam Cemiyeti';

  @override
  String get settingsMethodJafari => 'Şii İsna Aşeri, Leva Enstitüsü (Kum)';

  @override
  String get settingsMethodKarachi => 'İslami İlimler Üniversitesi, Karaçi';

  @override
  String get settingsMethodMakkah => 'Ümmülkura Üniversitesi, Mekke';

  @override
  String get settingsMethodMwl => 'Müslüman Dünya Birliği';

  @override
  String get settingsMethodTehran => 'Tahran Üniversitesi, Jeofizik Enstitüsü';

  @override
  String get settingsMidnightJafari => 'Güneş batışı ile Sabah arasında';

  @override
  String get settingsMidnightStandard =>
      'Güneş batışı ile Güneş doğuşu arasında';

  @override
  String get settingsOff => 'Kapalı';

  @override
  String settingsPercent(String value) {
    return '%$value';
  }

  @override
  String get settingsRemChime => 'Yumuşak zil';

  @override
  String get settingsRemChimeHelp =>
      'Hatırlatma bildirimiyle birlikte yumuşak bir zil çalar.';

  @override
  String get settingsRemChimeTest => 'Örnek çal';

  @override
  String settingsRemHelp(String max) {
    return '0 kapalı demektir; ezandan en çok $max dakika önce.';
  }

  @override
  String get settingsRemIndependent =>
      'Hatırlatmaları kapatmak ezanı hiçbir zaman etkilemez.';

  @override
  String settingsRemSummary(String minutes) {
    return 'Ezandan $minutes dk önce';
  }

  @override
  String settingsRemTitle(String prayer) {
    return '$prayer öncesi hatırlatma';
  }

  @override
  String get settingsResetConfirm => 'Temizle';

  @override
  String get settingsResetConfirmBody =>
      'Ayarlar varsayılanlara döner ve etkin konum Tahran olur. Bu işlem geri alınamaz.';

  @override
  String get settingsResetConfirmTitle => 'Tüm ayarlar temizlensin mi?';

  @override
  String get settingsResetDone => 'Ayarlar varsayılanlara sıfırlandı.';

  @override
  String get settingsResetHelp =>
      'Tüm ayarlar, kayıtlı konumlar ve uyandırma alarmları temizlenir.';

  @override
  String get settingsResetTitle => 'Varsayılanlara sıfırla';

  @override
  String get settingsSaved => 'Kaydedildi';

  @override
  String get settingsSectionAbout => 'Hakkında ve tanılama';

  @override
  String get settingsSectionApp => 'Uygulama';

  @override
  String get settingsSectionAzan => 'Ezan';

  @override
  String get settingsSectionCalculation => 'Hesaplama';

  @override
  String get settingsSectionDisplay => 'Görünüm';

  @override
  String get settingsSectionLocation => 'Konum';

  @override
  String get settingsSectionReminders => 'Hatırlatmalar';

  @override
  String get settingsSectionTime => 'Saat';

  @override
  String get settingsSectionsLabel => 'Ayar bölümleri';

  @override
  String get settingsThemeDark => 'Koyu';

  @override
  String get settingsThemeLight => 'Açık';

  @override
  String get settingsThemeSystem => 'Windows temasını izle';

  @override
  String get settingsTimeCheck => 'Saati ağ saatiyle karşılaştır';

  @override
  String get settingsTimeCheckHelp =>
      'Uygulama başlarken ve her altı saatte bir; varsayılan olarak kapalı.';

  @override
  String get settingsTimeCheckNow => 'Şimdi denetle';

  @override
  String settingsTimeCheckedAt(String time) {
    return 'Denetim zamanı: $time';
  }

  @override
  String get settingsTimeChecking => 'Denetleniyor…';

  @override
  String get settingsTimeCorrect => 'Saati uygulama içinde düzelt';

  @override
  String get settingsTimeCorrectHelp =>
      'Windows saati hiçbir zaman değiştirilmez.';

  @override
  String settingsTimeDiagLocation(String offset) {
    return 'Etkin konumun farkı (veritabanı): $offset';
  }

  @override
  String get settingsTimeDiagOk => 'Saat sorunu bulunamadı.';

  @override
  String get settingsTimeDiagTitle => 'Saat tanılaması';

  @override
  String settingsTimeDiagWindows(String offset) {
    return 'Windows saatinin UTC farkı: $offset';
  }

  @override
  String get settingsTimeError =>
      'Zaman sunucusuna ulaşılamadı. İnternet bağlantısını ve sunucu adını kontrol edin.';

  @override
  String get settingsTimeNever => 'Henüz denetlenmedi.';

  @override
  String get settingsTimeServer => 'Zaman sunucusu';

  @override
  String get settingsTimeServerHelp =>
      'Zaman sunucusunun adı, örneğin pool.ntp.org';

  @override
  String get settingsTimeServerInvalid => 'Sunucu adı geçerli değil.';

  @override
  String settingsTimeSkewAhead(String amount) {
    return 'Bilgisayarın saati $amount ileri.';
  }

  @override
  String settingsTimeSkewBehind(String amount) {
    return 'Bilgisayarın saati $amount geri.';
  }

  @override
  String get settingsTimeSkewZero => 'Bilgisayarın saati ağ saatiyle uyuşuyor.';

  @override
  String get settingsTimeStatusTitle => 'Son denetim';

  @override
  String get settingsZoneAuto => 'Otomatik (önerilir)';

  @override
  String settingsZoneAutoHelp(String zone) {
    return 'Uygulamaya yerleşik saat dilimi veritabanını kullanır: $zone';
  }

  @override
  String get settingsZoneFixed => 'Sabit fark';

  @override
  String get settingsZoneFixedAllYear =>
      'Fark sabittir ve yılın her gününde aynı kalır.';

  @override
  String get settingsZoneFixedHelp =>
      'UTC ile yılın her günü geçerli olan tek bir sabit fark.';

  @override
  String settingsZoneFixedValue(String offset) {
    return 'Sabit fark: $offset';
  }

  @override
  String get settingsZoneHourLess => 'Bir saat az';

  @override
  String get settingsZoneHourMore => 'Bir saat fazla';

  @override
  String settingsZoneNext(String date, String time, String offset) {
    return 'Sonraki değişiklik: $date saat $time, fark $offset';
  }

  @override
  String get settingsZoneNoChange =>
      'Bu saat dilimi için başka bir değişiklik planlanmamış.';

  @override
  String settingsZoneNow(String offset) {
    return 'Bugün geçerli fark: $offset';
  }

  @override
  String get settingsZoneQuarterLess => 'On beş dakika az';

  @override
  String get settingsZoneQuarterMore => 'On beş dakika fazla';

  @override
  String get settingsZoneTitle => 'Saat dilimi';

  @override
  String get supportAvailableIn => 'Kullanılabildiği yerler:';

  @override
  String get supportCardCountries =>
      'Yalnızca İran: Shetab ağındaki İran banka kartları. İran dışından ödenemez; bunun yerine kripto para seçeneğini kullanın.';

  @override
  String get supportCardNumberLabel => 'Kart numarası';

  @override
  String get supportCardTitle => 'İran banka kartı';

  @override
  String get supportCheckNote =>
      'Ödeme yapmadan önce numarayı veya adresi projenin GitHub üzerindeki resmî sayfasıyla karşılaştırın. Desteğiniz için teşekkürler.';

  @override
  String get supportCryptoAddressLabel => 'Cüzdan adresi';

  @override
  String get supportCryptoCountries =>
      'Tüm ülkeler: kripto cüzdanı veya borsanın bulunduğu her yerden, banka kartı gerekmeden.';

  @override
  String get supportCryptoNetworkLabel => 'Ağ';

  @override
  String get supportCryptoNetworkValue =>
      'BEP20 (BNB Smart Chain, BSC olarak da bilinir)';

  @override
  String get supportCryptoTitle => 'USDT (Tether) kripto parası';

  @override
  String get supportCryptoWarning =>
      'Yalnızca BEP20 ağı üzerinden USDT gönderin. Bu adrese başka bir coin göndermek veya başka bir ağ kullanmak parayı kaybettirir.';

  @override
  String get supportIntro =>
      'Bu uygulama ücretsizdir, reklam içermez, hesap gerektirmez ve hiçbir özelliği ödemenin arkasına koymaz. Size yararlıysa ve büyümesine yardım etmek isterseniz aşağıdaki yollardan birini kullanabilirsiniz. Destek tamamen isteğe bağlıdır ve her miktar değerlidir.';

  @override
  String get supportTitle => 'Projeye destek olun';

  @override
  String get timetableCalendarSwitch => 'Takvim türü';

  @override
  String get timetableColDay => 'Gün';

  @override
  String get timetableColWeekday => 'Haftanın günü';

  @override
  String get timetableMonthUnavailable =>
      'Bu ay kameri takvim tablosunun dışında.';

  @override
  String get timetableNextMonth => 'Sonraki ay';

  @override
  String timetableOpenDay(String date) {
    return '$date tarihini ana ekranda göster';
  }

  @override
  String get timetablePreviousMonth => 'Önceki ay';

  @override
  String get timetableToday => 'Bugün';

  @override
  String get trayMenuLocation => 'Konum';

  @override
  String get trayMenuMute => 'Sessize al';

  @override
  String get trayMenuMuted => 'Sessizde';

  @override
  String get trayMenuQuit => 'Çık';

  @override
  String get trayMenuSettings => 'Ayarlar';

  @override
  String get trayMenuShow => 'Pencereyi göster';

  @override
  String get trayMenuStopAzan => 'Ezanı durdur';

  @override
  String get trayMuteCancel => 'Sessizi iptal et';

  @override
  String trayMuteHours(String n) {
    return '$n sa';
  }

  @override
  String get trayMuteIndefinite => 'Ben kapatana kadar';

  @override
  String get trayMuteUntilNext => 'Sonraki ezana kadar';

  @override
  String trayNextLine(String prayer, String time) {
    return 'Sıradaki: $prayer · $time';
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
  String get wakeAdd => 'Alarm ekle';

  @override
  String get wakeAfterHibernate => 'Sesten sonra: hazırda beklet';

  @override
  String get wakeAfterHibernateChoice => 'Hazırda beklet';

  @override
  String get wakeAfterNote =>
      'Bilgisayar uykuya veya hazırda bekletmeye geçmeden önce 30 saniyelik bir geri sayım iptal etmenizi sağlar.';

  @override
  String get wakeAfterNothing => 'Hiçbir şey yapma';

  @override
  String get wakeAfterSleep => 'Sesten sonra: uyku';

  @override
  String get wakeAfterSleepChoice => 'Uyku';

  @override
  String get wakeAfterTitle => 'Sesten sonra';

  @override
  String get wakeCancel => 'İptal';

  @override
  String get wakeCapabilityChecking => 'Bu bilgisayar denetleniyor…';

  @override
  String get wakeCapabilityOkBody =>
      'Denetimde bir engel bulunmadı. Emin olmak için iki dakikalık testi çalıştırın.';

  @override
  String get wakeCapabilityOkTitle => 'Bu bilgisayar kendini uyandırabilir';

  @override
  String get wakeCapabilityRefresh => 'Yeniden denetle';

  @override
  String get wakeCapabilityUnknown => 'Henüz denetlenmedi.';

  @override
  String get wakeCapabilityWarnTitle =>
      'Bu bilgisayar alarm için uyanmayabilir';

  @override
  String get wakeChoiceFixed => 'Sabit bir saatte';

  @override
  String get wakeChoiceRelative => 'Bir namazdan önce';

  @override
  String get wakeChooseFile => 'Dosya seç…';

  @override
  String get wakeCountdownAfterAlarm => 'Alarm sona erdi.';

  @override
  String get wakeCountdownCancel => 'İptal';

  @override
  String wakeCountdownHibernate(String time) {
    return 'Bilgisayar $time sonra hazırda beklemeye geçecek.';
  }

  @override
  String wakeCountdownSleep(String time) {
    return 'Bilgisayar $time sonra uykuya geçecek.';
  }

  @override
  String get wakeDelete => 'Sil';

  @override
  String get wakeDeleteBody => 'Alarm ve uyandırma isteği kaldırılacak.';

  @override
  String get wakeDeleteConfirm => 'Sil';

  @override
  String get wakeDeleteTitle => 'Bu alarm silinsin mi?';

  @override
  String get wakeDismiss => 'Kapat';

  @override
  String get wakeEdit => 'Düzenle';

  @override
  String get wakeEditorTitleAdd => 'Yeni alarm';

  @override
  String get wakeEditorTitleEdit => 'Alarmı düzenle';

  @override
  String get wakeEmpty =>
      'Henüz alarm yok. Bu bilgisayarı seçtiğiniz saatte uyandırmak için bir alarm ekleyin.';

  @override
  String get wakeEnabledSwitch => 'Açık';

  @override
  String wakeErrorMinutes(String min, String max) {
    return '$min ile $max arasında bir tam sayı girin.';
  }

  @override
  String get wakeFieldHour => 'Saat';

  @override
  String get wakeFieldLabel => 'Ad (isteğe bağlı)';

  @override
  String get wakeFieldMinute => 'Dakika';

  @override
  String get wakeFieldMinutesBefore => 'Kaç dakika önce';

  @override
  String get wakeFieldPrayer => 'Namaz';

  @override
  String get wakeHibernateNow => 'Şimdi hazırda beklet';

  @override
  String get wakeIssueImportantOnly =>
      'Windows yalnızca önemli uyandırma zamanlayıcılarına izin veriyor; bu genellikle bu uygulamayı kapsamaz.';

  @override
  String get wakeIssueInProcessTimer =>
      'Uygulama içindeki yedek zamanlayıcı oluşturulamadı.';

  @override
  String get wakeIssueModernStandby =>
      'Bu bilgisayar Modern Standby kullanıyor; belirli bir saatte uyanma çoğu zaman güvenilir değildir.';

  @override
  String get wakeIssueTaskCreationFailed =>
      'Windows hesabınız için zamanlanmış uyandırma görevine izin vermedi, bu yüzden alarm yalnızca bu uygulama çalışırken işe yarar.';

  @override
  String get wakeIssueTimersOffAc =>
      'Windows, bilgisayar prize takılıyken uyandırma zamanlayıcılarını kapatmış.';

  @override
  String get wakeIssueTimersOffBattery =>
      'Windows, bilgisayar pille çalışırken uyandırma zamanlayıcılarını kapatmış.';

  @override
  String get wakeIssueUnknown =>
      'Windows uyandırma zamanlayıcısı ayarı okunamadı.';

  @override
  String get wakeListSeparator => ', ';

  @override
  String wakeNext(String remaining, String time) {
    return 'Sıradaki: $remaining ($time)';
  }

  @override
  String get wakeNextNone => 'Sıradaki: —';

  @override
  String wakeNextOtherDay(String remaining, String weekday, String time) {
    return 'Sıradaki: $remaining ($weekday $time)';
  }

  @override
  String get wakeOff => 'Kapalı';

  @override
  String get wakeOpenPowerFailed =>
      'Güç ayarları açılamadı. Denetim Masası > Güç Seçenekleri bölümünü kendiniz açın.';

  @override
  String get wakeOpenPowerOptions => 'Windows güç ayarlarını aç';

  @override
  String wakePercent(String percent) {
    return '%$percent';
  }

  @override
  String get wakePlaySound => 'Ses çal';

  @override
  String get wakePowerHint =>
      'Windows içinde: Güç Seçenekleri > Plan ayarlarını değiştir > Gelişmiş güç ayarlarını değiştir > Uyku > Uyandırma zamanlayıcılarına izin ver. Bu uygulama bir güç ayarını kendi kendine asla değiştirmez.';

  @override
  String get wakePreview => 'Önizleme';

  @override
  String get wakePreviewStop => 'Önizlemeyi durdur';

  @override
  String get wakeProblemHibernateUnavailable =>
      'Bu bilgisayarda hazırda bekletme açık değil.';

  @override
  String get wakeProblemProbeFailed =>
      'Bu bilgisayarın denetimi tamamlanamadı.';

  @override
  String get wakeProblemSoundFailed =>
      'Alarm sesi çalınamadı. Ses dosyasını ve hoparlörleri kontrol edin.';

  @override
  String get wakeProblemSuspendRefused =>
      'Windows bilgisayarın uykuya geçmesine izin vermedi.';

  @override
  String get wakeRepeatDaily => 'Her gün';

  @override
  String get wakeRepeatOnce => 'Bir kez';

  @override
  String get wakeRepeatTitle => 'Tekrar';

  @override
  String wakeRepeatWeekdays(String days) {
    return '$days günleri';
  }

  @override
  String get wakeRepeatWeekdaysChoice => 'Seçilen günler';

  @override
  String get wakeRinging => 'Bir alarm çalıyor';

  @override
  String get wakeSave => 'Kaydet';

  @override
  String get wakeSaveFailed =>
      'Bu değerler kaydedilemedi. Saati ve günleri kontrol edin.';

  @override
  String get wakeSleepHint =>
      'Bilgisayar, iptal edebileceğiniz beş saniyelik bir geri sayımdan sonra uykuya geçer.';

  @override
  String get wakeSleepNow => 'Şimdi uyut';

  @override
  String get wakeSoundDefault => 'Varsayılan ezan sesi';

  @override
  String wakeSoundFile(String name) {
    return 'Dosya: $name';
  }

  @override
  String get wakeSoundTitle => 'Ses';

  @override
  String get wakeStop => 'Durdur';

  @override
  String get wakeSyncError =>
      'Uyandırma isteği Windows tarafına kaydedilemedi; alarm yalnızca uygulama çalışırken işe yarayabilir.';

  @override
  String get wakeTest => '2 dakika içinde dene';

  @override
  String get wakeTestCancel => 'Testi iptal et';

  @override
  String wakeTestPending(String time) {
    return 'Saat $time için bir deneme alarmı çalacak. Uyanıp uyanmadığını görmek için bilgisayarı şimdi uykuya alın.';
  }

  @override
  String get wakeTitle => 'Uyandırma alarmları';

  @override
  String wakeTriggerAtPrayer(String prayer) {
    return '$prayer vaktinde';
  }

  @override
  String wakeTriggerFixed(String time) {
    return 'Saat $time';
  }

  @override
  String wakeTriggerRelative(String minutes, String prayer) {
    return '$prayer vaktinden $minutes önce';
  }

  @override
  String get wakeTriggerTypeTitle => 'Ne zaman';

  @override
  String get wakeUseDefault => 'Varsayılanı kullan';

  @override
  String get wakeVolume => 'Ses düzeyi';

  @override
  String get wakeWeekdaysError => 'En az bir gün seçin.';
}
