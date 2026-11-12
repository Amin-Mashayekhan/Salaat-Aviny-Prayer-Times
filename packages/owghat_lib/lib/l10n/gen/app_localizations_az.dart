// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get aboutAuthorIntro =>
      'Bu tətbiq müstəqil proqramçı tərəfindən hazırlanıb və dəstəklənir. Problem barədə məlumat vermək, təklif irəli sürmək və ya əməkdaşlıq etmək üçün əlaqə saxlayın.';

  @override
  String get aboutAuthorTitle => 'Proqramçı haqqında';

  @override
  String get aboutContactEmail => 'E-poçt';

  @override
  String get aboutContactGithub => 'GitHub';

  @override
  String get aboutContactName => 'Ad';

  @override
  String get aboutContactPhone => 'Mobil';

  @override
  String get aboutContactTelegram => 'Telegram';

  @override
  String get aboutCopiedValue => 'Kopyalandı.';

  @override
  String get aboutCopy => 'Kopyala';

  @override
  String get aboutFontNote =>
      'Vazirmatn şrifti SIL Open Font License 1.1 lisenziyası ilə daxil edilib.';

  @override
  String get aboutLicenceNote =>
      'Bu tətbiq MIT lisenziyası ilə buraxılıb: ondan sərbəst istifadə edə, onu dəyişə və paylaşa bilərsiniz.';

  @override
  String get aboutLicences => 'Açıq mənbə lisenziyaları';

  @override
  String get aboutOpen => 'Aç';

  @override
  String get aboutOpenFailed =>
      'Açmaq mümkün olmadı. Ünvanı kopyalayıb brauzerinizə və ya poçt proqramınıza yapışdırın.';

  @override
  String get aboutPhoneNote =>
      'Zəng və SMS yalnız İran daxilindən. İrandan kənardan yalnız Telegram istifadə edin.';

  @override
  String get aboutSoundNote =>
      'Daxili səslər (standart azan və xatırlatma zəngi) sadə şəkildə yaradılmış nümunələrdir, heç kimin səsyazısı deyil və CC0 altında yayımlanır. Parametrlərdən öz azan səsinizi seçin.';

  @override
  String get aboutTagline =>
      'Windows üçün namaz vaxtları və azan. İnternetsiz işləyir, reklamsız, hesabsız və izləməsiz.';

  @override
  String get aboutTitle => 'Haqqında';

  @override
  String aboutVersion(String version) {
    return 'Versiya $version';
  }

  @override
  String get appName => 'Salaat | Aviny Prayer Times';

  @override
  String get calendarAdjustEarlier => 'Bir gün əvvəl';

  @override
  String get calendarAdjustLater => 'Bir gün sonra';

  @override
  String calendarAdjustValue(String value) {
    return '$value gün';
  }

  @override
  String calendarConvErrDay(String first, String days) {
    return 'Gün $first ilə $days arasında olmalıdır.';
  }

  @override
  String get calendarConvErrIncomplete => 'İli, ayı və günü doldurun.';

  @override
  String get calendarConvErrMonth => 'Ay 1 ilə 12 arasında olmalıdır.';

  @override
  String get calendarConvErrNumber => 'Yalnız rəqəmlərdən istifadə edin.';

  @override
  String get calendarConvErrRange =>
      'Bu tarix təqvimin dəstəklədiyi aralıqdan kənardadır.';

  @override
  String get calendarConverterHint =>
      'Üç təqvimdən istənilənində tarix yazın; digər ikisi onunla birlikdə dəyişir.';

  @override
  String get calendarConverterShow => 'Təqvimdə göstər';

  @override
  String get calendarConverterTitle => 'Tarix çeviricisi';

  @override
  String calendarDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get calendarFieldDay => 'Gün';

  @override
  String get calendarFieldMonth => 'Ay';

  @override
  String get calendarFieldYear => 'İl';

  @override
  String get calendarGridLabel => 'Aylıq təqvim';

  @override
  String get calendarHijriAdjust => 'Qəməri tarixin düzəlişi';

  @override
  String get calendarHijriApproxHint =>
      'Təxminidir: İranın rəsmi qəməri təqvimi ayın görünməsinə əsaslanır və bir gün fərqli ola bilər.';

  @override
  String get calendarHijriUnavailable =>
      'Bu gün üçün cədvəldə qəməri tarix yoxdur';

  @override
  String get calendarKindGregorian => 'Miladi';

  @override
  String get calendarKindHijri => 'Qəməri hicri';

  @override
  String get calendarKindJalali => 'Şəmsi hicri';

  @override
  String calendarMonthGregorian(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Yanvar',
      'm2': 'Fevral',
      'm3': 'Mart',
      'm4': 'Aprel',
      'm5': 'May',
      'm6': 'İyun',
      'm7': 'İyul',
      'm8': 'Avqust',
      'm9': 'Sentyabr',
      'm10': 'Oktyabr',
      'm11': 'Noyabr',
      'm12': 'Dekabr',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthHijri(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Məhərrəm',
      'm2': 'Səfər',
      'm3': 'Rəbiüləvvəl',
      'm4': 'Rəbiülaxır',
      'm5': 'Cəmadiyələvvəl',
      'm6': 'Cəmadiyəlaxır',
      'm7': 'Rəcəb',
      'm8': 'Şaban',
      'm9': 'Ramazan',
      'm10': 'Şəvval',
      'm11': 'Zilqədə',
      'm12': 'Zilhiccə',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthJalali(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Fərvərdin',
      'm2': 'Ordibehişt',
      'm3': 'Xordad',
      'm4': 'Tir',
      'm5': 'Mordad',
      'm6': 'Şəhrivər',
      'm7': 'Mehr',
      'm8': 'Aban',
      'm9': 'Azər',
      'm10': 'Dey',
      'm11': 'Bəhmən',
      'm12': 'İsfənd',
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
      'Qəməri tarix Ümmül-Qura cədvəlindən götürülür. İranın rəsmi təqvimi ayın görünməsinə əsaslanır və bir gün fərqli ola bilər; belə olarsa, burada onu dəyişdirin.';

  @override
  String get calendarNextMonth => 'Növbəti ay';

  @override
  String get calendarOpenOnHome => 'Ana ekranda göstər';

  @override
  String get calendarPanelTimes => 'Bu günün namaz vaxtları';

  @override
  String get calendarPreviousMonth => 'Əvvəlki ay';

  @override
  String get calendarSeparator => ', ';

  @override
  String get calendarToday => 'Bu gün';

  @override
  String calendarWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'Bazar ertəsi',
      'd2': 'Çərşənbə axşamı',
      'd3': 'Çərşənbə',
      'd4': 'Cümə axşamı',
      'd5': 'Cümə',
      'd6': 'Şənbə',
      'd7': 'Bazar',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'B.e.',
      'd2': 'Ç.a.',
      'd3': 'Çər',
      'd4': 'C.a.',
      'd5': 'Cümə',
      'd6': 'Şən',
      'd7': 'Baz',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get contributeIntro =>
      'Bu tətbiqin kodu GitHub-dadır və hər cür kömək xoş qarşılanır. İştirak yolları:';

  @override
  String get contributeOpenGuide => 'Töhfə bələdçisi';

  @override
  String get contributeOpenIssues => 'Xəta və ya ideya bildirin';

  @override
  String get contributeOpenRepo => 'Repozitoriyanı GitHub-da aç';

  @override
  String get contributeTitle => 'Töhfə verin';

  @override
  String get contributeWayCode =>
      'Kod: repozitoriyanı fork edin, dəyişikliyi ayrıca branch-də edin, testləri işə salın və Pull Request göndərin. Build və test addımları CONTRIBUTING.md faylındadır.';

  @override
  String get contributeWayData =>
      'Məlumat: şəhərin adını, koordinatlarını və ya saat qurşağını düzəldin, yaxud yeni şəhər əlavə edin.';

  @override
  String get contributeWayIssues =>
      'Xəta və ya ideya bildirmək: GitHub-da Issue açın və versiyanı, eləcə də bu səhifədəki diaqnostika hesabatını əlavə edin (onda ad və koordinat yoxdur).';

  @override
  String get contributeWayTest =>
      'Test: tətbiqi Windows-un müxtəlif versiyalarında və cihazlarında yoxlayın (azan, tray, oyadıcı siqnallar) və gördüklərinizi bildirin.';

  @override
  String get contributeWayTranslate =>
      'Tərcümə: tətbiqin mətnləri lib/l10n qovluğundadır. Yeni dil və ya mövcud dildə düzəliş göndərin; doğma danışan şəxsin yoxlaması çox qiymətlidir.';

  @override
  String get diagAudioFailed =>
      'Sınaq səsi səsləndirilə bilmədi. Dinamikləri və Windows səs səviyyəsini yoxlayın.';

  @override
  String get diagAudioOk => 'Sınaq səsi səsləndirildi.';

  @override
  String get diagAudioPlay => 'Sınaq səsini səsləndir';

  @override
  String get diagAudioStop => 'Dayandır';

  @override
  String get diagAudioTitle => 'Səs testi';

  @override
  String get diagClockOk => 'Saatla bağlı problem tapılmadı.';

  @override
  String get diagClockTitle => 'Saat';

  @override
  String get diagClockUnchecked =>
      'Problem görünmür, lakin şəbəkə vaxtının yoxlanması söndürülüb, ona görə saat fərqi ölçülmür.';

  @override
  String get diagCopied =>
      'Mübadilə buferinə kopyalandı. Ad və dəqiq koordinat yoxdur.';

  @override
  String get diagCopy => 'Diaqnostikanı kopyala';

  @override
  String get diagCopyFailed => 'Kopyalamaq mümkün olmadı.';

  @override
  String diagEventAzan(String prayer) {
    return 'Azan: $prayer';
  }

  @override
  String diagEventReminder(String prayer) {
    return 'Xatırlatma: $prayer';
  }

  @override
  String diagEventTimes(String utc, String local) {
    return 'UTC $utc | yerli $local';
  }

  @override
  String get diagEventWake => 'Oyadıcı siqnal';

  @override
  String get diagEventsEmpty => 'Heç nə planlaşdırılmayıb.';

  @override
  String get diagEventsTitle => 'Növbəti planlı hadisələr';

  @override
  String get diagLogNone => 'Mövcud deyil.';

  @override
  String get diagLogTitle => 'Jurnal faylları';

  @override
  String get diagTitle => 'Diaqnostika';

  @override
  String diagValue(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'yes': 'bəli',
      'no': 'xeyr',
      'unknown': 'naməlum',
      'enabled': 'icazə verilib',
      'disabled': 'söndürülüb',
      'importantOnly': 'yalnız vacib olanlar',
      'ok': 'işləyir',
      'failed': 'alınmadı',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String diagWakeAc(String value) {
    return 'Oyadıcı taymerlər, şəbəkəyə qoşulu: $value';
  }

  @override
  String diagWakeBattery(String value) {
    return 'Oyadıcı taymerlər, batareyada: $value';
  }

  @override
  String get diagWakeCheck => 'İndi yoxla';

  @override
  String diagWakeInProcess(String value) {
    return 'Tətbiq daxilində taymer: $value';
  }

  @override
  String diagWakeModern(String value) {
    return 'Modern Standby: $value';
  }

  @override
  String get diagWakeNotChecked => 'Hələ yoxlanmayıb.';

  @override
  String diagWakeTask(String value) {
    return 'Planlı tapşırıq: $value';
  }

  @override
  String get diagWakeTitle => 'Oyanma yoxlaması';

  @override
  String get formatAm => 'AM';

  @override
  String formatHours(String hours) {
    return '$hours saat';
  }

  @override
  String formatHoursMinutes(String hours, String minutes) {
    return '$hours saat $minutes dəq';
  }

  @override
  String formatMinutes(String minutes) {
    return '$minutes dəq';
  }

  @override
  String get formatPm => 'PM';

  @override
  String formatRemaining(String duration) {
    return '$duration sonra';
  }

  @override
  String formatRemainingLessThan(String minutes) {
    return '$minutes dəqiqədən az qalıb';
  }

  @override
  String formatSeconds(String seconds) {
    return '$seconds san';
  }

  @override
  String get homeAzanMutedIndefinite =>
      'Azan: yenidən yandırana qədər səssizdir';

  @override
  String homeAzanMutedUntil(String time) {
    return 'Azan: $time vaxtınadək səssizdir';
  }

  @override
  String get homeAzanOff => 'Azan: söndürülüb';

  @override
  String get homeAzanOn => 'Azan: aktivdir';

  @override
  String homeAzanToggleOff(String prayer) {
    return '$prayer azanını söndür';
  }

  @override
  String homeAzanToggleOn(String prayer) {
    return '$prayer azanını yandır';
  }

  @override
  String get homeBackToToday => 'Bu günə qayıt';

  @override
  String homeBannerClockSkew(String amount) {
    return 'Kompüterin saatı təxminən $amount fərqlənir.';
  }

  @override
  String get homeBannerDismiss => 'Bağla';

  @override
  String get homeBannerMutedIndefinite =>
      'Azan yenidən yandırılana qədər səssizdir.';

  @override
  String homeBannerMutedUntil(String time) {
    return 'Azan $time vaxtınadək səssizdir.';
  }

  @override
  String get homeBannerSettingsReset =>
      'Parametrlər faylı oxuna bilmədi və parametrlər standart dəyərlərə qaytarıldı.';

  @override
  String get homeBannerStaleZone =>
      'Windows bu yer üçün saat qurşaqları bazasından fərqli vaxt göstərir. Bu tətbiqdəki vaxtlar düzgündür; Windows saatını yoxlayın.';

  @override
  String homeCompass(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'p0': 'şimal',
      'p1': 'şimal-şərq',
      'p2': 'şərq',
      'p3': 'cənub-şərq',
      'p4': 'cənub',
      'p5': 'cənub-qərb',
      'p6': 'qərb',
      'p7': 'şimal-qərb',
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
    return '$date üçün vaxtlar';
  }

  @override
  String homeEventAt(String event, String time) {
    return '$event $time';
  }

  @override
  String get homeHeroNoNext => 'Geri sayım üçün heç nə yoxdur';

  @override
  String get homeMute => 'Səssiz';

  @override
  String get homeMuteCancel => 'Səssizliyi ləğv et';

  @override
  String homeMuteForDuration(String duration) {
    return '$duration müddətinə';
  }

  @override
  String get homeMuteIndefinite => 'Mən yenidən yandırana qədər';

  @override
  String get homeMuteUntilNext => 'Növbəti azana qədər';

  @override
  String get homeNextDay => 'Növbəti gün';

  @override
  String get homeNextMarker => 'Növbəti';

  @override
  String homeNextWakeAlarm(String value) {
    return 'Növbəti oyanma: $value';
  }

  @override
  String get homeNoTimesAction => 'Hesablama parametrləri';

  @override
  String get homeNoTimesInfo =>
      'Bu yer üçün bu gün bütün vaxtları hesablamaq mümkün deyil. Yüksək enlik qaydasını parametrlərdən dəyişə bilərsiniz.';

  @override
  String get homeNoValue => '—';

  @override
  String homeNowPlaying(String prayer) {
    return 'Səslənir: $prayer';
  }

  @override
  String get homeNowPlayingGeneric => 'Azan səslənir';

  @override
  String get homeOtherDayHint =>
      'Bu tarixin vaxtları; geri sayım yalnız bu günə aiddir.';

  @override
  String get homePreviousDay => 'Əvvəlki gün';

  @override
  String homeQiblaSummary(String degrees, String direction) {
    return 'Qiblə: $degrees° $direction';
  }

  @override
  String homeReminderMinutes(String minutes) {
    return 'Xatırlatma: $minutes dəq əvvəl';
  }

  @override
  String get homeReminderOff => 'Xatırlatmalar: söndürülüb';

  @override
  String homeReminderRange(String min, String max) {
    return 'Xatırlatmalar: $min - $max dəq əvvəl';
  }

  @override
  String get homeStatusTitle => 'Vəziyyət';

  @override
  String get homeStop => 'Dayandır';

  @override
  String get homeSwitchLocation => 'Yeri dəyiş';

  @override
  String get homeTimelineLabel => 'Günün qrafiki';

  @override
  String get homeToday => 'Bu gün';

  @override
  String get homeTodayTimes => 'Bu günün vaxtları';

  @override
  String get homeTomorrowTimes => 'Sabahın vaxtları';

  @override
  String homeUntilEvent(String event) {
    return '$event vaxtınadək';
  }

  @override
  String homeViewingDay(String date) {
    return '$date göstərilir';
  }

  @override
  String get navCalendar => 'Təqvim';

  @override
  String get navHome => 'Ana səhifə';

  @override
  String get navQibla => 'Qiblə';

  @override
  String get navSettings => 'Parametrlər';

  @override
  String get navTimetable => 'Cədvəl';

  @override
  String get navWakeUp => 'Oyanma';

  @override
  String notifAzanBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String get notifAzanFailed => 'Azan səsləndirilə bilmədi.';

  @override
  String notifAzanTitle(String prayer) {
    return '$prayer azanı';
  }

  @override
  String notifMissedBody(String time) {
    return 'Kompüter $time vaxtında yuxu rejimində idi.';
  }

  @override
  String notifMissedTitle(String prayer) {
    return '$prayer azanı səsləndirilmədi';
  }

  @override
  String notifReminderBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String notifReminderTitle(String minutes, String prayer) {
    return '$prayer üçün $minutes dəq qalıb';
  }

  @override
  String get notifSoundFallback =>
      'Azan səs faylı tapılmadı; standart səs səsləndirildi.';

  @override
  String get notifStopAction => 'Dayandır';

  @override
  String get notifTrayHint =>
      'Tətbiq Windows saatının yanında işləməyə davam edir.';

  @override
  String get onboardingAzanBody =>
      'Azana qulaq asın və tətbiqin Windows ilə birlikdə başlayıb-başlamayacağını seçin.';

  @override
  String get onboardingAzanTitle => 'Azan və başlanğıc';

  @override
  String get onboardingBack => 'Geri';

  @override
  String get onboardingCityBody => 'Şəhərinizi axtarın və ya əyalətdən seçin.';

  @override
  String get onboardingCityNone => 'Şəhər tapılmadı.';

  @override
  String get onboardingCitySearchHint => 'Şəhər axtarın';

  @override
  String onboardingCitySelected(String city) {
    return 'Seçilib: $city';
  }

  @override
  String get onboardingCityTitle => 'Şəhəriniz';

  @override
  String get onboardingFinish => 'Başla';

  @override
  String get onboardingLanguageBody =>
      'Dilinizi seçin. Sonra parametrlərdən dəyişə bilərsiniz.';

  @override
  String get onboardingLanguageTitle => 'Dil';

  @override
  String get onboardingModeList => 'İran şəhərləri (oflayn siyahı)';

  @override
  String get onboardingModeOnline =>
      'Dünyanın istənilən şəhəri (onlayn axtarış)';

  @override
  String get onboardingNext => 'Növbəti';

  @override
  String get onboardingOnlineBody =>
      'Şəhəriniz siyahıda yoxdur? Dünyanın istənilən şəhərini axtarın. İnternet yalnız bu axtarış üçün lazımdır; sonra tətbiq internetsiz işləyir.';

  @override
  String get onboardingPreview => 'Nümunə azan səsləndir';

  @override
  String get onboardingProvinceAll => 'Bütün əyalətlər';

  @override
  String get onboardingSkip => 'Keç';

  @override
  String get onboardingStartWithWindows => 'Windows ilə başlasın';

  @override
  String get onboardingStartWithWindowsHint =>
      'Tətbiq səssizcə sistem trayında başlayır.';

  @override
  String onboardingStepProgress(String step, String total) {
    return 'Addım $step / $total';
  }

  @override
  String get onboardingStopPreview => 'Dayandır';

  @override
  String get placeSearchAttribution =>
      'Yerlər © OpenStreetMap töhfəçiləri (Nominatim). Saat qurşağı və hündürlük: Open-Meteo.';

  @override
  String get placeSearchButton => 'Axtar';

  @override
  String get placeSearchFailBusy =>
      'Axtarış xidməti məşğuldur. Bir dəqiqə gözləyin və yenidən cəhd edin.';

  @override
  String get placeSearchFailDetails =>
      'Yer tapıldı, lakin saat qurşağı alına bilmədi. Bağlantıya baxın və yeri yenidən seçin.';

  @override
  String get placeSearchFailGeneric =>
      'Axtarış alınmadı. Bir az sonra yenidən cəhd edin.';

  @override
  String get placeSearchFailOffline =>
      'İnternet bağlantısı yoxdur. Qoşulun və yenidən Axtar düyməsinə basın. Tətbiqin qalan hissəsi internetsiz işləyir.';

  @override
  String get placeSearchFailTimeout =>
      'Axtarış xidməti vaxtında cavab vermədi. Yenidən cəhd edin.';

  @override
  String get placeSearchHint => 'Şəhər, ölkə (məsələn, Mumbai, Hindistan)';

  @override
  String placeSearchNone(String query) {
    return '“$query” üçün yer tapılmadı. Yazılışı yoxlayın və ya ölkəni də əlavə edin, məsələn, Mumbai, Hindistan.';
  }

  @override
  String get placeSearchNotice =>
      'Axtarış üçün internet yalnız indi lazımdır. Yazdığınız mətn OpenStreetMap axtarış xidmətinə (Nominatim) göndərilir; başqa heç nə göndərilmir. Yeri seçdikdən sonra tətbiq lazım olanı saxlayır və yenidən internetsiz işləyir.';

  @override
  String get placeSearchNoticeDetails =>
      'Bir yer seçdikdə onun saat qurşağını və hündürlüyünü almaq üçün həmin yerin koordinatları Open-Meteo xidmətinə göndərilir.';

  @override
  String placeSearchResolving(String place) {
    return '$place üçün saat qurşağı və hündürlük alınır…';
  }

  @override
  String get placeSearchResultsTitle => 'Nəticələr: yerinizi seçin';

  @override
  String get placeSearchTitle => 'Yer axtar';

  @override
  String get placeSearchTooShort =>
      'Ən azı iki hərf yazın, sonra Axtar düyməsinə basın.';

  @override
  String get placeSearchUnknownZone =>
      'Bu yerin saat qurşağı tətbiqin verilənlər bazasında yoxdur. Başqa yer sınayın və ya parametrlərdə Fərdi məkan ilə əlavə edin.';

  @override
  String get placeSearching => 'Axtarılır…';

  @override
  String get prayerAsr => 'Əsr';

  @override
  String get prayerDhuhr => 'Zöhr';

  @override
  String get prayerFajr => 'Sübh';

  @override
  String get prayerImsak => 'İmsak';

  @override
  String get prayerIsha => 'İşa';

  @override
  String get prayerMaghrib => 'Məğrib';

  @override
  String get prayerMidnight => 'Gecə yarısı';

  @override
  String get prayerSunrise => 'Günəş';

  @override
  String get prayerSunset => 'Gün batımı';

  @override
  String qiblaAccuracyValue(String meters) {
    return 'Dəqiqlik: təxminən $meters m';
  }

  @override
  String get qiblaBearingLabel =>
      'Azimut (həqiqi şimaldan saat əqrəbi istiqamətində)';

  @override
  String qiblaBearingValue(String degrees, String direction) {
    return '$degrees° ($direction)';
  }

  @override
  String get qiblaCamKaaba => 'Kəbə';

  @override
  String get qiblaCamNearby => 'Ətrafımda';

  @override
  String get qiblaCamOverview => 'Bütün marşrut';

  @override
  String qiblaCardinal(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'n': 'Şm',
      'e': 'Şr',
      's': 'Cn',
      'w': 'Qr',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String qiblaCompassSemantics(String degrees, String direction) {
    return 'Kompas gülü: qiblə $degrees dərəcədədir ($direction)';
  }

  @override
  String qiblaCompassSemanticsSun(String base, String azimuth) {
    return '$base; günəş $azimuth dərəcədədir';
  }

  @override
  String get qiblaCoordsApply => 'Göstər';

  @override
  String get qiblaCoordsHint => 'məsələn 36.2133, 58.7958';

  @override
  String get qiblaCoordsInvalid =>
      'Koordinatlar yanlışdır. Enlik -90 ilə 90, uzunluq isə -180 ilə 180 arasında olmalıdır.';

  @override
  String get qiblaCoordsLabel => 'Enlik və uzunluq';

  @override
  String get qiblaCoordsOr => 'Və ya koordinatları özünüz daxil edin';

  @override
  String qiblaCustomPlaceShown(String place) {
    return '$place nöqtəsindən ölçülür.';
  }

  @override
  String get qiblaDeviceFixShown => 'Bu cihazın mövqeyi göstərilir.';

  @override
  String get qiblaDistanceLabel => 'Kəbəyə qədər məsafə';

  @override
  String qiblaDistanceValue(String km) {
    return '$km km';
  }

  @override
  String get qiblaFailGeneric =>
      'Mövqeyi oxumaq mümkün olmadı; seçilmiş şəhər göstərilir.';

  @override
  String get qiblaFailPermissionDenied =>
      'Windows bu tətbiqə mövqeyi oxumağa icazə verməyib. Aşağıdakı addımları izləyin və yenidən cəhd edin; ya da seçilmiş şəhərdən istifadə edin.';

  @override
  String get qiblaFailPermissionForever =>
      'Mövqeyə giriş rədd edilib. Yenidən icazə vermək üçün aşağıdakı addımları izləyin.';

  @override
  String get qiblaFailServiceDisabled =>
      'Bu cihazda Location services söndürülüb. Aşağıdakı addımları izləyin; ya da seçilmiş şəhərdən və ya istənilən nöqtədən istifadə edin.';

  @override
  String get qiblaFailTimeout =>
      'Mövqe vaxtında alınmadı. Kompüterlərdə adətən GPS olmur və Windows mövqeyi Wi-Fi vasitəsilə təxmin edir. Yenidən cəhd edin və ya şəhərdən istifadə edin.';

  @override
  String get qiblaFailUnsupported =>
      'Bu cihaz mövqe göstərə bilmir; seçilmiş şəhər göstərilir.';

  @override
  String qiblaForLocation(String place) {
    return '$place üçün qiblə istiqaməti';
  }

  @override
  String get qiblaHelpOther =>
      'Əməliyyat sisteminin parametrlərində mövqe xidmətini yandırın, bu tətbiqə istifadə icazəsi verin və yenidən cəhd edin.';

  @override
  String get qiblaHelpTitleOther => 'Mövqeyi necə yandırmaq olar?';

  @override
  String get qiblaHelpTitleWindows => 'Windows-da mövqeyi necə yandırmaq olar?';

  @override
  String get qiblaHelpWin1 =>
      'Windows Parametrlərinin Location səhifəsini açmaq üçün yuxarıdakı düyməni basın. Açılmasa, ora əl ilə keçin: Start > Settings > Privacy & security > Location (Windows 10: Privacy > Location)';

  @override
  String get qiblaHelpWin2 =>
      'Location services seçimini yandırın. Səhifənin yuxarısında Location for this device is off yazılıbsa, Change düyməsini basın və yandırın.';

  @override
  String get qiblaHelpWin3 =>
      'Bir az aşağıda Let desktop apps access your location seçimini yandırın (Windows 10: Allow desktop apps to access your location). Salaat masaüstü tətbiqidir və yalnız bu açarla icazə alır.';

  @override
  String get qiblaHelpWin4 =>
      'Salaat-a qayıdın və Mövqeyimi tap düyməsini yenidən basın. Yenə alınmasa, tətbiqi bir dəfə bağlayıb yenidən açın.';

  @override
  String get qiblaLocateAgain => 'Yenidən tap';

  @override
  String get qiblaLocateButton => 'Mövqeyimi tap';

  @override
  String get qiblaLocating => 'Mövqeyiniz tapılır…';

  @override
  String get qiblaMapAttribution => '© OpenStreetMap contributors';

  @override
  String get qiblaMapAttributionSatellite =>
      'Imagery © Esri, Maxar, Earthstar Geographics, and the GIS User Community';

  @override
  String get qiblaMapConsentBody =>
      'Qiblə xəttini xəritədə çəkmək üçün xəritə şəkilləri internetdən yüklənir və baxdığınız ərazi həmin serverə göndərilir: küçə xəritəsi OpenStreetMap-dən, Peyk seçsəniz, hava şəkilləri Esri-dən. Razılıq verməyincə heç nə sorğulanmır. Qiblə bucağı və məsafə xəritəsiz də düzgün göstərilir.';

  @override
  String get qiblaMapConsentButton => 'Xəritəni göstər';

  @override
  String get qiblaMapConsentTitle => 'Qiblə xəritəsi';

  @override
  String get qiblaMapKaaba => 'Kəbə';

  @override
  String get qiblaMapLineNote =>
      'Xətt yer kürəsində Kəbənin mərkəzinə ən qısa yoldur. Düz xəritədə əyri görünür, lakin qiblə istiqamətindən başlayır. Kəbənin novu mərkəzdən yalnız bir neçə metr aralıdır və istiqamətdə gözə çarpan fərq yaratmır. Küçə və binalarla müqayisə üçün Ətrafımda düyməsini basın.';

  @override
  String get qiblaMapOfflineBanner =>
      'Xəritə şəkilləri yüklənə bilmir (internet yoxdur?). Qiblə xətti və bucağı yenə də düzgündür.';

  @override
  String qiblaMapSemantics(String place, String bearing, String distance) {
    return 'Qiblə xəritəsi: $place yerindən Kəbəyə, $bearing, $distance';
  }

  @override
  String get qiblaMapTapHint => 'Başqa nöqtə seçmək üçün xəritəyə toxunun.';

  @override
  String get qiblaMapTurnOff => 'Xəritəni söndür';

  @override
  String get qiblaMapYou => 'Sizin mövqeyiniz';

  @override
  String get qiblaNoCompassNote =>
      'Kompüterdə kompas yoxdur, ona görə şəkil həqiqi şimala görədir (şimal yuxarıdadır).';

  @override
  String get qiblaOpenSettingsFailed =>
      'Parametrlər səhifəsi açıla bilmədi; addımları əl ilə izləyin.';

  @override
  String get qiblaOpenSettingsOther => 'Mövqe parametrlərini aç';

  @override
  String get qiblaOpenSettingsWindows => 'Windows mövqe parametrlərini aç';

  @override
  String get qiblaSourceCity => 'Seçilmiş şəhər';

  @override
  String qiblaSourceCityHelp(String city) {
    return 'Namaz vaxtları üçün seçdiyiniz şəhər: $city.';
  }

  @override
  String get qiblaSourceCustom => 'İstənilən nöqtə';

  @override
  String get qiblaSourceCustomHelp =>
      'Yeri adı ilə axtarın (bir dəfə internet lazımdır), xəritəyə toxunun və ya koordinatları daxil edin.';

  @override
  String get qiblaSourceDevice => 'Bu cihaz';

  @override
  String get qiblaSourceDeviceHelp =>
      'Mövqe yalnız düyməni basanda cihazdan oxunur; saxlanmır və heç yerə göndərilmir.';

  @override
  String get qiblaSourceTitle => 'Qiblə buradan ölçülsün';

  @override
  String get qiblaStatLatitude => 'Enlik';

  @override
  String get qiblaStatLongitude => 'Uzunluq';

  @override
  String get qiblaStyleLabel => 'Xəritə növü';

  @override
  String get qiblaStyleSatellite => 'Peyk';

  @override
  String get qiblaStyleStreet => 'Xəritə';

  @override
  String get qiblaSunBelow => 'Günəş üfüqdən aşağıdadır.';

  @override
  String get qiblaSunInHelp =>
      'Hazırda günəş tam qiblə istiqamətindədir; üzünüzü günəşə tərəf tutun.';

  @override
  String get qiblaSunInTitle => 'Günəş qiblə istiqamətində';

  @override
  String get qiblaSunNone => 'Bu gün baş vermir.';

  @override
  String get qiblaSunNowLabel => 'Günəş indi';

  @override
  String qiblaSunNowValue(String azimuth, String altitude) {
    return 'Azimut $azimuth°, hündürlük $altitude°';
  }

  @override
  String get qiblaSunOppHelp =>
      'Hazırda şaquli çubuğun kölgəsi qiblə tərəfə yönəlir.';

  @override
  String get qiblaSunOppTitle => 'Günəş qiblənin əksindədir';

  @override
  String get qiblaSunTimesTitle => 'Bu gün günəş və qiblə';

  @override
  String get qiblaTabCompass => 'Kompas və günəş';

  @override
  String get qiblaTabMap => 'Xəritə';

  @override
  String get qiblaTitle => 'Qiblə';

  @override
  String get settingsAboutPlaceholder =>
      'Versiya, lisenziyalar və diaqnostika səhifəsi bu bölmədə görünür.';

  @override
  String get settingsAppAutostart => 'Windows ilə başlasın';

  @override
  String get settingsAppAutostartHelp =>
      'Windows-a daxil olanda tətbiq səssizcə saatın yanında başlayır.';

  @override
  String get settingsAppCloseToTray => 'Trayə bağla';

  @override
  String get settingsAppCloseToTrayHelp =>
      'Pəncərəni bağlamaq tətbiqi Windows saatının yanında saxlayır ki, azan səslənməyə davam etsin. Söndürülübsə, bağlamaq tətbiqdən çıxır.';

  @override
  String get settingsAppMinimized => 'Kiçildilmiş başlasın';

  @override
  String get settingsAppMinimizedHelp =>
      'Windows tətbiqi başladanda pəncərə bağlı qalır.';

  @override
  String get settingsAsrHanafi => 'Hənəfi (kölgə cismin iki mislidir)';

  @override
  String get settingsAsrStandard => 'Standart (kölgə cismə bərabərdir)';

  @override
  String get settingsAzanChoose => 'Fayl seç…';

  @override
  String get settingsAzanEnabled => 'Azan səslənsin';

  @override
  String get settingsAzanEnabledHelp =>
      'Əsas açardır; söndürülübsə, heç bir azan səslənmir.';

  @override
  String get settingsAzanFade => 'Tədricən artsın';

  @override
  String get settingsAzanFadeHelp =>
      'Azan tədricən tam səs səviyyəsinə yüksəlir.';

  @override
  String get settingsAzanMute => 'Sürətli səssiz';

  @override
  String get settingsAzanMuteHelp => 'Azanı müəyyən müddətə səssiz edin.';

  @override
  String get settingsAzanNotMuted => 'Səssiz deyil';

  @override
  String settingsAzanPrayerSwitch(String prayer) {
    return '$prayer azanı';
  }

  @override
  String get settingsAzanPrayerVolume => 'Bu azanın səs səviyyəsi';

  @override
  String get settingsAzanPreview => 'Dinlə';

  @override
  String get settingsAzanSound => 'Səs';

  @override
  String get settingsAzanSoundDefault => 'Daxili azan';

  @override
  String settingsAzanSoundFile(String name) {
    return 'Fayl: $name';
  }

  @override
  String get settingsAzanUseDefault => 'Daxili səsdən istifadə et';

  @override
  String get settingsAzanVolume => 'Səs səviyyəsi';

  @override
  String get settingsAzanVolumeHelp => 'Bütün azanların ümumi səs səviyyəsi';

  @override
  String get settingsBackupExport => 'Ehtiyat nüsxəni ixrac et';

  @override
  String get settingsBackupExportFailed => 'Ehtiyat nüsxə saxlanıla bilmədi.';

  @override
  String get settingsBackupExportHelp =>
      'Bütün parametrlər, yerlər və oyadıcı siqnallar bir faylda saxlanılır.';

  @override
  String settingsBackupExported(String path) {
    return 'Ehtiyat nüsxə saxlanıldı: $path';
  }

  @override
  String get settingsBackupImport => 'Ehtiyat nüsxəni idxal et';

  @override
  String get settingsBackupImportBody =>
      'Bütün cari parametrlər bu faylın məzmunu ilə əvəz olunacaq.';

  @override
  String get settingsBackupImportConfirm => 'Bərpa et';

  @override
  String get settingsBackupImportHelp =>
      'Parametrləri ehtiyat nüsxə faylından bərpa edir.';

  @override
  String get settingsBackupImportInvalid =>
      'Bu fayl düzgün parametr ehtiyat nüsxəsi deyil; parametrlər dəyişdirilmədi.';

  @override
  String get settingsBackupImportReadFailed =>
      'Fayl oxuna bilmədi; parametrlər dəyişdirilmədi.';

  @override
  String get settingsBackupImportTitle => 'Parametrlər bərpa edilsin?';

  @override
  String get settingsBackupImported => 'Parametrlər bərpa edildi.';

  @override
  String get settingsBackupTitle => 'Ehtiyat nüsxə və bərpa';

  @override
  String get settingsCalcAngleHelp =>
      'Günəşin üfüqdən aşağı bucağı, dərəcə ilə';

  @override
  String get settingsCalcAsr => 'Əsr qaydası';

  @override
  String get settingsCalcFajrAngle => 'Sübh bucağı';

  @override
  String get settingsCalcHighLat => 'Yüksək enliklər';

  @override
  String get settingsCalcHighLatHelp =>
      'Gecənin çox qısa olduğu və alacaqaranlıq bucağına heç çatılmayan yerlər üçün.';

  @override
  String get settingsCalcImsak => 'İmsak';

  @override
  String get settingsCalcImsakHelp => 'Sübhdən neçə dəqiqə əvvəl';

  @override
  String get settingsCalcIshaAngle => 'İşa bucağı';

  @override
  String get settingsCalcIshaMinutes => 'Məğribdən neçə dəqiqə sonra';

  @override
  String get settingsCalcIshaMode => 'İşanın təyini';

  @override
  String get settingsCalcIshaModeAngle => 'Günəş bucağı';

  @override
  String get settingsCalcIshaModeMinutes => 'Məğribdən neçə dəqiqə sonra';

  @override
  String get settingsCalcMaghribAngle => 'Məğrib bucağı';

  @override
  String get settingsCalcMaghribSunset => 'Məğrib gün batımında';

  @override
  String get settingsCalcMaghribSunsetHelp =>
      'Söndürülübsə, Məğrib aşağıdakı bucaqla hesablanır.';

  @override
  String get settingsCalcMethod => 'Metod';

  @override
  String get settingsCalcMethodHelp =>
      'İstənilən bucağı dəyişmək metodu Xüsusi vəziyyətinə keçirir.';

  @override
  String get settingsCalcMidnight => 'Gecə yarısı';

  @override
  String settingsCalcOffsetsHelp(String max) {
    return 'İstənilən vaxtı $max dəqiqəyə qədər irəli və ya geri çəkin.';
  }

  @override
  String get settingsCalcOffsetsReset => 'Hamısını sıfırla';

  @override
  String get settingsCalcOffsetsTitle => 'Hər vaxt üçün dəqiqə düzəlişi';

  @override
  String settingsCalcPreviewHelp(String date) {
    return 'Yuxarıdakı parametrlərlə bu günün vaxtları ($date)';
  }

  @override
  String get settingsCalcPreviewTitle => 'Canlı önizləmə';

  @override
  String get settingsCalcRestore => 'Bu metod üçün standartları bərpa et';

  @override
  String settingsCalcRestoreHelp(String method) {
    return 'Bucaqlar, qaydalar və İmsak $method dəyərlərinə qayıdır; hər vaxtın dəqiqə düzəlişləri dəyişmir.';
  }

  @override
  String get settingsCalcRowsHelp =>
      'Sübh, Günəş, Zöhr, Məğrib və Gecə yarısı həmişə göstərilir.';

  @override
  String get settingsCalcRowsTitle => 'Göstəriləcək sətirlər';

  @override
  String get settingsCancel => 'Ləğv et';

  @override
  String get settingsDecrease => 'Azalt';

  @override
  String get settingsDigitsArabic => 'Ərəb (٠١٢)';

  @override
  String get settingsDigitsLatin => 'Latın (123)';

  @override
  String get settingsDigitsPersian => 'Fars (۱۲۳)';

  @override
  String get settingsDispDigits => 'Rəqəmlər';

  @override
  String get settingsDispHijri => 'Hicri tarixin düzəlişi';

  @override
  String get settingsDispHijriHelp =>
      'İran ayın görünməsinə əsaslanır, ona görə göstərilən hicri tarix rəsmi tarixdən fərqlənə bilər; burada onu bir-iki gün sürüşdürün.';

  @override
  String get settingsDispHour => 'Saat';

  @override
  String get settingsDispLanguage => 'Dil';

  @override
  String get settingsDispLanguageHelp => 'Yenidən başlatmadan tətbiq olunur.';

  @override
  String get settingsDispTheme => 'Mövzu';

  @override
  String get settingsHighLatAngleBased => 'Bucağa əsaslanan';

  @override
  String get settingsHighLatNightMiddle => 'Gecənin ortası';

  @override
  String get settingsHighLatNone => 'Düzəliş yoxdur';

  @override
  String get settingsHighLatOneSeventh => 'Gecənin yeddidə biri';

  @override
  String get settingsHour12 => '12 saatlıq';

  @override
  String get settingsHour24 => '24 saatlıq';

  @override
  String get settingsIncrease => 'Artır';

  @override
  String settingsInvalidNumber(String min, String max) {
    return '$min ilə $max arasında ədəd daxil edin.';
  }

  @override
  String get settingsLocActive => 'Aktiv';

  @override
  String get settingsLocAdd => 'Əlavə et';

  @override
  String get settingsLocAddCustom => 'Xüsusi yer';

  @override
  String get settingsLocAddFromDb => 'Şəhər siyahısından';

  @override
  String get settingsLocAddSearch => 'Onlayn axtar';

  @override
  String get settingsLocAddTitle => 'Yer əlavə et';

  @override
  String settingsLocAdded(String name) {
    return '$name əlavə edildi.';
  }

  @override
  String get settingsLocAllProvinces => 'Bütün əyalətlər';

  @override
  String get settingsLocAlreadySaved => 'Artıq saxlanılıb';

  @override
  String settingsLocAlreadySavedName(String name) {
    return '$name artıq yadda saxlanmış məkanlarınızdadır.';
  }

  @override
  String get settingsLocClose => 'Bağla';

  @override
  String settingsLocCoords(String lat, String lon) {
    return 'Enlik $lat, uzunluq $lon';
  }

  @override
  String get settingsLocCustomBadge => 'Xüsusi';

  @override
  String get settingsLocDegrees => 'Dərəcə';

  @override
  String get settingsLocDelete => 'Sil';

  @override
  String get settingsLocDeleteBody => 'Bu yer siyahınızdan silinəcək.';

  @override
  String get settingsLocDeleteLast => 'Sonuncu yeri silmək olmaz.';

  @override
  String settingsLocDeleteTitle(String name) {
    return '$name silinsin?';
  }

  @override
  String get settingsLocEast => 'Şərq';

  @override
  String get settingsLocEdit => 'Redaktə et';

  @override
  String get settingsLocElevation => 'Hündürlük (metr)';

  @override
  String settingsLocErrElevation(String min, String max) {
    return 'Hündürlük $min ilə $max metr arasında olmalıdır.';
  }

  @override
  String settingsLocErrLatitude(String min, String max) {
    return 'Enlik $min ilə $max arasında ədəd olmalıdır.';
  }

  @override
  String settingsLocErrLongitude(String min, String max) {
    return 'Uzunluq $min ilə $max arasında ədəd olmalıdır.';
  }

  @override
  String get settingsLocErrName => 'Ad daxil edin.';

  @override
  String settingsLocErrOffset(String min, String max) {
    return 'Fərq $min ilə $max arasında olmalıdır.';
  }

  @override
  String get settingsLocErrZone => 'Siyahıdan saat qurşağı seçin.';

  @override
  String get settingsLocFormatDecimal => 'Onluq dərəcə';

  @override
  String get settingsLocFormatDms => 'Dərəcə, dəqiqə, saniyə';

  @override
  String get settingsLocLatitude => 'Enlik';

  @override
  String get settingsLocLongitude => 'Uzunluq';

  @override
  String get settingsLocMinutes => 'Dəqiqə';

  @override
  String get settingsLocName => 'Ad';

  @override
  String get settingsLocNoResults => 'Şəhər tapılmadı.';

  @override
  String get settingsLocNorth => 'Şimal';

  @override
  String get settingsLocProvince => 'Əyalət';

  @override
  String get settingsLocSave => 'Saxla';

  @override
  String get settingsLocSavedHelp => 'Vaxtlar aktiv yer üçün hesablanır.';

  @override
  String get settingsLocSavedTitle => 'Saxlanılmış yerlər';

  @override
  String get settingsLocSearchHint => 'Şəhər axtarın';

  @override
  String get settingsLocSeconds => 'Saniyə';

  @override
  String get settingsLocSetActive => 'Aktiv et';

  @override
  String get settingsLocSouth => 'Cənub';

  @override
  String get settingsLocWest => 'Qərb';

  @override
  String get settingsLocZoneNone => 'Saat qurşağı tapılmadı.';

  @override
  String get settingsLocZoneSearch => 'Saat qurşaqlarını axtarın';

  @override
  String settingsLocZoneSelected(String zone) {
    return 'Seçilmiş saat qurşağı: $zone';
  }

  @override
  String get settingsMethodCustom => 'Xüsusi';

  @override
  String get settingsMethodEgypt => 'Misir Ümumi Geodeziya İdarəsi';

  @override
  String get settingsMethodIsna => 'Şimali Amerika İslam Cəmiyyəti';

  @override
  String get settingsMethodJafari => 'Şiə İsna-əşəri, Leva İnstitutu (Qum)';

  @override
  String get settingsMethodKarachi => 'İslam Elmləri Universiteti, Karaçi';

  @override
  String get settingsMethodMakkah => 'Ümmül-Qura Universiteti, Məkkə';

  @override
  String get settingsMethodMwl => 'Müsəlman Dünyası Liqası';

  @override
  String get settingsMethodTehran => 'Tehran Universiteti, Geofizika İnstitutu';

  @override
  String get settingsMidnightJafari => 'Gün batımı ilə Sübh arasında';

  @override
  String get settingsMidnightStandard =>
      'Gün batımı ilə Günəşin doğuşu arasında';

  @override
  String get settingsOff => 'Söndürülüb';

  @override
  String settingsPercent(String value) {
    return '$value%';
  }

  @override
  String get settingsRemChime => 'Yumşaq zəng';

  @override
  String get settingsRemChimeHelp =>
      'Xatırlatma bildirişi ilə yumşaq zəng səslənir.';

  @override
  String get settingsRemChimeTest => 'Nümunə səsləndir';

  @override
  String settingsRemHelp(String max) {
    return '0 söndürülmüş deməkdir; azandan ən çoxu $max dəqiqə əvvələ qədər.';
  }

  @override
  String get settingsRemIndependent =>
      'Xatırlatmaları söndürmək azana heç vaxt təsir etmir.';

  @override
  String settingsRemSummary(String minutes) {
    return 'Azandan $minutes dəq əvvəl';
  }

  @override
  String settingsRemTitle(String prayer) {
    return '$prayer vaxtından əvvəl xatırlatma';
  }

  @override
  String get settingsResetConfirm => 'Təmizlə';

  @override
  String get settingsResetConfirmBody =>
      'Parametrlər standart dəyərlərə qayıdır və aktiv yer Tehran olur. Bunu geri qaytarmaq olmaz.';

  @override
  String get settingsResetConfirmTitle => 'Bütün parametrlər təmizlənsin?';

  @override
  String get settingsResetDone => 'Parametrlər standart dəyərlərə qaytarıldı.';

  @override
  String get settingsResetHelp =>
      'Bütün parametrlər, saxlanılmış yerlər və oyadıcı siqnallar təmizlənir.';

  @override
  String get settingsResetTitle => 'Standartlara qaytar';

  @override
  String get settingsSaved => 'Saxlanıldı';

  @override
  String get settingsSectionAbout => 'Haqqında və diaqnostika';

  @override
  String get settingsSectionApp => 'Tətbiq';

  @override
  String get settingsSectionAzan => 'Azan';

  @override
  String get settingsSectionCalculation => 'Hesablama';

  @override
  String get settingsSectionDisplay => 'Görünüş';

  @override
  String get settingsSectionLocation => 'Yer';

  @override
  String get settingsSectionReminders => 'Xatırlatmalar';

  @override
  String get settingsSectionTime => 'Vaxt';

  @override
  String get settingsSectionsLabel => 'Parametr bölmələri';

  @override
  String get settingsThemeDark => 'Tünd';

  @override
  String get settingsThemeLight => 'Açıq';

  @override
  String get settingsThemeSystem => 'Windows-a uyğun';

  @override
  String get settingsTimeCheck => 'Saatı şəbəkə vaxtı ilə yoxla';

  @override
  String get settingsTimeCheckHelp =>
      'Tətbiq başlayanda və hər altı saatdan bir; standart olaraq söndürülüb.';

  @override
  String get settingsTimeCheckNow => 'İndi yoxla';

  @override
  String settingsTimeCheckedAt(String time) {
    return 'Yoxlama vaxtı: $time';
  }

  @override
  String get settingsTimeChecking => 'Yoxlanılır…';

  @override
  String get settingsTimeCorrect => 'Vaxtı tətbiq daxilində düzəlt';

  @override
  String get settingsTimeCorrectHelp => 'Windows saatı heç vaxt dəyişdirilmir.';

  @override
  String settingsTimeDiagLocation(String offset) {
    return 'Aktiv yerin fərqi (verilənlər bazası): $offset';
  }

  @override
  String get settingsTimeDiagOk => 'Saatla bağlı problem tapılmadı.';

  @override
  String get settingsTimeDiagTitle => 'Saat diaqnostikası';

  @override
  String settingsTimeDiagWindows(String offset) {
    return 'Windows-un UTC-dən fərqi: $offset';
  }

  @override
  String get settingsTimeError =>
      'Vaxt serverinə qoşulmaq mümkün olmadı. İnternet bağlantısını və server adını yoxlayın.';

  @override
  String get settingsTimeNever => 'Hələ yoxlanmayıb.';

  @override
  String get settingsTimeServer => 'Vaxt serveri';

  @override
  String get settingsTimeServerHelp =>
      'Vaxt serverinin adı, məsələn pool.ntp.org';

  @override
  String get settingsTimeServerInvalid => 'Server adı düzgün deyil.';

  @override
  String settingsTimeSkewAhead(String amount) {
    return 'Kompüterin saatı $amount irəlidədir.';
  }

  @override
  String settingsTimeSkewBehind(String amount) {
    return 'Kompüterin saatı $amount geridədir.';
  }

  @override
  String get settingsTimeSkewZero =>
      'Kompüterin saatı şəbəkə vaxtı ilə üst-üstə düşür.';

  @override
  String get settingsTimeStatusTitle => 'Son yoxlama';

  @override
  String get settingsZoneAuto => 'Avtomatik (tövsiyə olunur)';

  @override
  String settingsZoneAutoHelp(String zone) {
    return 'Tətbiqə daxil edilmiş saat qurşaqları bazasından istifadə edir: $zone';
  }

  @override
  String get settingsZoneFixed => 'Sabit fərq';

  @override
  String get settingsZoneFixedAllYear =>
      'Fərq sabitdir və ilin hər günü eyni qalır.';

  @override
  String get settingsZoneFixedHelp =>
      'UTC-dən bir sabit fərq, ilin hər günü tətbiq olunur.';

  @override
  String settingsZoneFixedValue(String offset) {
    return 'Sabit fərq: $offset';
  }

  @override
  String get settingsZoneHourLess => 'Bir saat az';

  @override
  String get settingsZoneHourMore => 'Bir saat çox';

  @override
  String settingsZoneNext(String date, String time, String offset) {
    return 'Növbəti dəyişiklik: $date, saat $time, fərq $offset';
  }

  @override
  String get settingsZoneNoChange =>
      'Bu saat qurşağı üçün başqa dəyişiklik planlaşdırılmayıb.';

  @override
  String settingsZoneNow(String offset) {
    return 'Bu gün qüvvədə olan fərq: $offset';
  }

  @override
  String get settingsZoneQuarterLess => 'Dörddə bir saat az';

  @override
  String get settingsZoneQuarterMore => 'Dörddə bir saat çox';

  @override
  String get settingsZoneTitle => 'Saat qurşağı';

  @override
  String get supportAvailableIn => 'İstifadə oluna bilər:';

  @override
  String get supportCardCountries =>
      'Yalnız İran: Shetab şəbəkəsindəki İran bank kartları. İrandan kənardan ödəmək olmur; əvəzinə kriptovalyuta variantından istifadə edin.';

  @override
  String get supportCardNumberLabel => 'Kart nömrəsi';

  @override
  String get supportCardTitle => 'İran bank kartı';

  @override
  String get supportCheckNote =>
      'Ödəniş etməzdən əvvəl nömrəni və ya ünvanı layihənin GitHub-dakı rəsmi səhifəsi ilə müqayisə edin. Dəstəyinizə görə təşəkkür edirik.';

  @override
  String get supportCryptoAddressLabel => 'Cüzdan ünvanı';

  @override
  String get supportCryptoCountries =>
      'Bütün ölkələr: kripto cüzdan və ya birjanın mövcud olduğu hər yerdən, bank kartı tələb olunmadan.';

  @override
  String get supportCryptoNetworkLabel => 'Şəbəkə';

  @override
  String get supportCryptoNetworkValue =>
      'BEP20 (BNB Smart Chain, BSC də adlanır)';

  @override
  String get supportCryptoTitle => 'USDT (Tether) kriptovalyutası';

  @override
  String get supportCryptoWarning =>
      'Yalnız BEP20 şəbəkəsi ilə USDT göndərin. Bu ünvana başqa koin göndərmək və ya başqa şəbəkədən istifadə etmək pulun itirilməsinə səbəb olur.';

  @override
  String get supportIntro =>
      'Bu tətbiq pulsuzdur, reklamı yoxdur, hesab tələb etmir və heç bir imkanı ödənişin arxasında saxlamır. Sizin üçün faydalıdırsa və inkişafına kömək etmək istəyirsinizsə, aşağıdakı yollardan birini istifadə edə bilərsiniz. Dəstək tamamilə könüllüdür və istənilən məbləğ qiymətləndirilir.';

  @override
  String get supportTitle => 'Layihəyə dəstək olun';

  @override
  String get timetableCalendarSwitch => 'Təqvim növü';

  @override
  String get timetableColDay => 'Gün';

  @override
  String get timetableColWeekday => 'Həftənin günü';

  @override
  String get timetableMonthUnavailable =>
      'Bu ay qəməri təqvim cədvəlindən kənardadır.';

  @override
  String get timetableNextMonth => 'Növbəti ay';

  @override
  String timetableOpenDay(String date) {
    return '$date tarixini ana ekranda göstər';
  }

  @override
  String get timetablePreviousMonth => 'Əvvəlki ay';

  @override
  String get timetableToday => 'Bu gün';

  @override
  String get trayMenuLocation => 'Yer';

  @override
  String get trayMenuMute => 'Səssiz';

  @override
  String get trayMenuMuted => 'Səssizdir';

  @override
  String get trayMenuQuit => 'Çıx';

  @override
  String get trayMenuSettings => 'Parametrlər';

  @override
  String get trayMenuShow => 'Pəncərəni göstər';

  @override
  String get trayMenuStopAzan => 'Azanı dayandır';

  @override
  String get trayMuteCancel => 'Səssizliyi ləğv et';

  @override
  String trayMuteHours(String n) {
    return '$n saat';
  }

  @override
  String get trayMuteIndefinite => 'Özüm ləğv edənə qədər';

  @override
  String get trayMuteUntilNext => 'Növbəti azana qədər';

  @override
  String trayNextLine(String prayer, String time) {
    return 'Növbəti: $prayer · $time';
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
  String get wakeAdd => 'Siqnal əlavə et';

  @override
  String get wakeAfterHibernate => 'Səsdən sonra: hibernasiya';

  @override
  String get wakeAfterHibernateChoice => 'Hibernasiya';

  @override
  String get wakeAfterNote =>
      'Kompüter yuxu rejiminə və ya hibernasiyaya getməzdən əvvəl 30 saniyəlik geri sayım ləğv etməyə imkan verir.';

  @override
  String get wakeAfterNothing => 'Heç nə etmə';

  @override
  String get wakeAfterSleep => 'Səsdən sonra: yuxu rejimi';

  @override
  String get wakeAfterSleepChoice => 'Yuxu rejimi';

  @override
  String get wakeAfterTitle => 'Səsdən sonra';

  @override
  String get wakeCancel => 'Ləğv et';

  @override
  String get wakeCapabilityChecking => 'Bu kompüter yoxlanılır…';

  @override
  String get wakeCapabilityOkBody =>
      'Yoxlama heç bir maneə tapmadı. Əmin olmaq üçün iki dəqiqəlik testi işə salın.';

  @override
  String get wakeCapabilityOkTitle => 'Bu kompüter özünü oyada bilir';

  @override
  String get wakeCapabilityRefresh => 'Yenidən yoxla';

  @override
  String get wakeCapabilityUnknown => 'Hələ yoxlanmayıb.';

  @override
  String get wakeCapabilityWarnTitle =>
      'Bu kompüter siqnal üçün oyanmaya bilər';

  @override
  String get wakeChoiceFixed => 'Müəyyən vaxtda';

  @override
  String get wakeChoiceRelative => 'Namazdan əvvəl';

  @override
  String get wakeChooseFile => 'Fayl seç…';

  @override
  String get wakeCountdownAfterAlarm => 'Siqnal başa çatdı.';

  @override
  String get wakeCountdownCancel => 'Ləğv et';

  @override
  String wakeCountdownHibernate(String time) {
    return 'Kompüter $time sonra hibernasiyaya gedəcək.';
  }

  @override
  String wakeCountdownSleep(String time) {
    return 'Kompüter $time sonra yuxu rejiminə keçəcək.';
  }

  @override
  String get wakeDelete => 'Sil';

  @override
  String get wakeDeleteBody => 'Siqnal və onun oyanma sorğusu silinəcək.';

  @override
  String get wakeDeleteConfirm => 'Sil';

  @override
  String get wakeDeleteTitle => 'Bu siqnal silinsin?';

  @override
  String get wakeDismiss => 'Bağla';

  @override
  String get wakeEdit => 'Redaktə et';

  @override
  String get wakeEditorTitleAdd => 'Yeni siqnal';

  @override
  String get wakeEditorTitleEdit => 'Siqnalı redaktə et';

  @override
  String get wakeEmpty =>
      'Hələ siqnal yoxdur. Kompüteri seçdiyiniz vaxtda oyatmaq üçün birini əlavə edin.';

  @override
  String get wakeEnabledSwitch => 'Aktiv';

  @override
  String wakeErrorMinutes(String min, String max) {
    return '$min ilə $max arasında tam ədəd daxil edin.';
  }

  @override
  String get wakeFieldHour => 'Saat';

  @override
  String get wakeFieldLabel => 'Ad (könüllü)';

  @override
  String get wakeFieldMinute => 'Dəqiqə';

  @override
  String get wakeFieldMinutesBefore => 'Neçə dəqiqə əvvəl';

  @override
  String get wakeFieldPrayer => 'Namaz';

  @override
  String get wakeHibernateNow => 'İndi hibernasiya et';

  @override
  String get wakeIssueImportantOnly =>
      'Windows yalnız vacib oyadıcı taymerlərə icazə verir, bu isə adətən bu tətbiqi əhatə etmir.';

  @override
  String get wakeIssueInProcessTimer =>
      'Tətbiq daxilindəki ehtiyat taymer yaradıla bilmədi.';

  @override
  String get wakeIssueModernStandby =>
      'Bu kompüter Modern Standby istifadə edir, orada müəyyən vaxtda oyanmaq çox vaxt etibarsızdır.';

  @override
  String get wakeIssueTaskCreationFailed =>
      'Windows hesabınız üçün planlı oyanma tapşırığına icazə vermədi, ona görə siqnal yalnız bu tətbiq işləyərkən çalışır.';

  @override
  String get wakeIssueTimersOffAc =>
      'Kompüter şəbəkəyə qoşulu olarkən Windows oyadıcı taymerləri söndürüb.';

  @override
  String get wakeIssueTimersOffBattery =>
      'Kompüter batareya ilə işləyərkən Windows oyadıcı taymerləri söndürüb.';

  @override
  String get wakeIssueUnknown =>
      'Windows-un oyadıcı taymer parametri oxuna bilmədi.';

  @override
  String get wakeListSeparator => ', ';

  @override
  String wakeNext(String remaining, String time) {
    return 'Növbəti: $remaining ($time)';
  }

  @override
  String get wakeNextNone => 'Növbəti: —';

  @override
  String wakeNextOtherDay(String remaining, String weekday, String time) {
    return 'Növbəti: $remaining ($weekday $time)';
  }

  @override
  String get wakeOff => 'Söndürülüb';

  @override
  String get wakeOpenPowerFailed =>
      'Enerji parametrləri açıla bilmədi. Control Panel > Power Options bölməsini özünüz açın.';

  @override
  String get wakeOpenPowerOptions => 'Windows enerji parametrlərini aç';

  @override
  String wakePercent(String percent) {
    return '$percent%';
  }

  @override
  String get wakePlaySound => 'Səs səsləndir';

  @override
  String get wakePowerHint =>
      'Windows-da: Power Options > Change plan settings > Change advanced power settings > Sleep > Allow wake timers. Bu tətbiq heç vaxt enerji parametrini özü dəyişmir.';

  @override
  String get wakePreview => 'Dinlə';

  @override
  String get wakePreviewStop => 'Dinləməni dayandır';

  @override
  String get wakeProblemHibernateUnavailable =>
      'Bu kompüterdə hibernasiya aktiv deyil.';

  @override
  String get wakeProblemProbeFailed =>
      'Bu kompüterin yoxlanılması tamamlana bilmədi.';

  @override
  String get wakeProblemSoundFailed =>
      'Siqnal səsi səsləndirilə bilmədi. Səs faylını və dinamikləri yoxlayın.';

  @override
  String get wakeProblemSuspendRefused =>
      'Windows kompüterin yuxu rejiminə keçməsinə icazə vermədi.';

  @override
  String get wakeRepeatDaily => 'Hər gün';

  @override
  String get wakeRepeatOnce => 'Bir dəfə';

  @override
  String get wakeRepeatTitle => 'Təkrar';

  @override
  String wakeRepeatWeekdays(String days) {
    return '$days günlərində';
  }

  @override
  String get wakeRepeatWeekdaysChoice => 'Seçilmiş günlər';

  @override
  String get wakeRinging => 'Siqnal çalır';

  @override
  String get wakeSave => 'Saxla';

  @override
  String get wakeSaveFailed =>
      'Bu dəyərlər saxlanıla bilmədi. Vaxtı və günləri yoxlayın.';

  @override
  String get wakeSleepHint =>
      'Kompüter ləğv edə biləcəyiniz beş saniyəlik geri sayımdan sonra yuxu rejiminə keçir.';

  @override
  String get wakeSleepNow => 'İndi yuxu rejiminə keç';

  @override
  String get wakeSoundDefault => 'Standart azan səsi';

  @override
  String wakeSoundFile(String name) {
    return 'Fayl: $name';
  }

  @override
  String get wakeSoundTitle => 'Səs';

  @override
  String get wakeStop => 'Dayandır';

  @override
  String get wakeSyncError =>
      'Oyanma sorğusu Windows-da qeydə alına bilmədi; siqnal yalnız tətbiq işləyərkən çalışa bilər.';

  @override
  String get wakeTest => '2 dəqiqəyə sına';

  @override
  String get wakeTestCancel => 'Testi ləğv et';

  @override
  String wakeTestPending(String time) {
    return 'Test siqnalı $time vaxtında çalacaq. Kompüterin oyanıb-oyanmadığını görmək üçün indi onu yuxu rejiminə qoyun.';
  }

  @override
  String get wakeTitle => 'Oyadıcı siqnallar';

  @override
  String wakeTriggerAtPrayer(String prayer) {
    return '$prayer vaxtında';
  }

  @override
  String wakeTriggerFixed(String time) {
    return '$time vaxtında';
  }

  @override
  String wakeTriggerRelative(String minutes, String prayer) {
    return '$prayer vaxtından $minutes əvvəl';
  }

  @override
  String get wakeTriggerTypeTitle => 'Nə vaxt';

  @override
  String get wakeUseDefault => 'Standartdan istifadə et';

  @override
  String get wakeVolume => 'Səs səviyyəsi';

  @override
  String get wakeWeekdaysError => 'Ən azı bir gün seçin.';
}
