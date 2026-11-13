// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get aboutAuthorIntro =>
      'Cette application est créée et maintenue par un développeur indépendant. Contactez-le pour signaler un problème, faire une suggestion ou collaborer.';

  @override
  String get aboutAuthorTitle => 'À propos du développeur';

  @override
  String get aboutContactEmail => 'E-mail';

  @override
  String get aboutContactGithub => 'GitHub';

  @override
  String get aboutContactName => 'Nom';

  @override
  String get aboutContactPhone => 'Mobile';

  @override
  String get aboutContactTelegram => 'Telegram';

  @override
  String get aboutCopiedValue => 'Copié.';

  @override
  String get aboutCopy => 'Copier';

  @override
  String get aboutFontNote =>
      'La police Vazirmatn est incluse sous la licence SIL Open Font License 1.1.';

  @override
  String get aboutLicenceNote =>
      'Cette application est publiée sous licence MIT : vous pouvez l’utiliser, la modifier et la partager librement.';

  @override
  String get aboutLicences => 'Licences open source';

  @override
  String get aboutOpen => 'Ouvrir';

  @override
  String get aboutOpenFailed =>
      'Ouverture impossible. Copiez l’adresse et collez-la dans votre navigateur ou votre logiciel de messagerie.';

  @override
  String get aboutPhoneNote =>
      'Appels et SMS uniquement depuis l’Iran. Depuis l’étranger, utilisez uniquement Telegram.';

  @override
  String get aboutSoundNote =>
      'Les sons inclus (l’adhan par défaut et le carillon de rappel) sont de simples sons générés, et non des enregistrements de quelqu’un, publiés sous CC0. Choisissez votre propre adhan dans les paramètres.';

  @override
  String get aboutTagline =>
      'Horaires de prière et adhan pour Windows. Fonctionne hors ligne, sans publicité, sans compte et sans suivi.';

  @override
  String get aboutTitle => 'À propos';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get appName => 'Salaat | Aviny Prayer Times';

  @override
  String get calendarAdjustEarlier => 'Un jour plus tôt';

  @override
  String get calendarAdjustLater => 'Un jour plus tard';

  @override
  String calendarAdjustValue(String value) {
    return '$value jours';
  }

  @override
  String calendarConvErrDay(String first, String days) {
    return 'Le jour doit être compris entre $first et $days.';
  }

  @override
  String get calendarConvErrIncomplete =>
      'Renseignez l’année, le mois et le jour.';

  @override
  String get calendarConvErrMonth => 'Le mois doit être compris entre 1 et 12.';

  @override
  String get calendarConvErrNumber => 'Utilisez uniquement des chiffres.';

  @override
  String get calendarConvErrRange =>
      'Cette date est hors de la plage prise en charge par le calendrier.';

  @override
  String get calendarConverterHint =>
      'Saisissez une date dans l’un des trois calendriers ; les deux autres se mettent à jour.';

  @override
  String get calendarConverterShow => 'Afficher dans le calendrier';

  @override
  String get calendarConverterTitle => 'Convertisseur de dates';

  @override
  String calendarDayMonthYear(String day, String month, String year) {
    return '$day $month $year';
  }

  @override
  String get calendarFieldDay => 'Jour';

  @override
  String get calendarFieldMonth => 'Mois';

  @override
  String get calendarFieldYear => 'Année';

  @override
  String get calendarGridLabel => 'Calendrier du mois';

  @override
  String get calendarHijriAdjust => 'Ajustement de la date lunaire';

  @override
  String get calendarHijriApproxHint =>
      'Approximatif : le calendrier lunaire officiel de l’Iran suit l’observation de la lune et peut différer d’un jour.';

  @override
  String get calendarHijriUnavailable =>
      'Pas de date lunaire dans la table pour ce jour';

  @override
  String get calendarKindGregorian => 'Grégorien';

  @override
  String get calendarKindHijri => 'Hégirien lunaire';

  @override
  String get calendarKindJalali => 'Hégirien solaire';

  @override
  String calendarMonthGregorian(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'janvier',
      'm2': 'février',
      'm3': 'mars',
      'm4': 'avril',
      'm5': 'mai',
      'm6': 'juin',
      'm7': 'juillet',
      'm8': 'août',
      'm9': 'septembre',
      'm10': 'octobre',
      'm11': 'novembre',
      'm12': 'décembre',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarMonthHijri(String month) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'Mouharram',
      'm2': 'Safar',
      'm3': 'Rabi al-awwal',
      'm4': 'Rabi ath-thani',
      'm5': 'Joumada al-oula',
      'm6': 'Joumada ath-thania',
      'm7': 'Rajab',
      'm8': 'Chaabane',
      'm9': 'Ramadan',
      'm10': 'Chawwal',
      'm11': 'Dhou al-qi’da',
      'm12': 'Dhou al-hijja',
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
      'La date lunaire provient de la table Umm al-Qura. Le calendrier officiel de l’Iran suit l’observation de la lune et peut différer d’un jour ; dans ce cas, décalez-la ici.';

  @override
  String get calendarNextMonth => 'Mois suivant';

  @override
  String get calendarOpenOnHome => 'Afficher sur l’écran d’accueil';

  @override
  String get calendarPanelTimes => 'Horaires de prière de ce jour';

  @override
  String get calendarPreviousMonth => 'Mois précédent';

  @override
  String get calendarSeparator => ', ';

  @override
  String get calendarToday => 'Aujourd’hui';

  @override
  String calendarWeekday(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'lundi',
      'd2': 'mardi',
      'd3': 'mercredi',
      'd4': 'jeudi',
      'd5': 'vendredi',
      'd6': 'samedi',
      'd7': 'dimanche',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String calendarWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'd1': 'lun.',
      'd2': 'mar.',
      'd3': 'mer.',
      'd4': 'jeu.',
      'd5': 'ven.',
      'd6': 'sam.',
      'd7': 'dim.',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String get contributeIntro =>
      'Le code de cette application est sur GitHub et toute aide est la bienvenue. Voici comment participer :';

  @override
  String get contributeOpenGuide => 'Guide de contribution';

  @override
  String get contributeOpenIssues => 'Signaler un bogue ou une idée';

  @override
  String get contributeOpenRepo => 'Ouvrir le dépôt sur GitHub';

  @override
  String get contributeTitle => 'Contribuer';

  @override
  String get contributeWayCode =>
      'Code : faites un Fork du dépôt, modifiez le code sur une branche, lancez les tests et envoyez une Pull Request. Les étapes de compilation et de test sont dans CONTRIBUTING.md.';

  @override
  String get contributeWayData =>
      'Données : corrigez le nom, les coordonnées ou le fuseau horaire d’une ville, ou ajoutez une nouvelle ville.';

  @override
  String get contributeWayIssues =>
      'Signaler un bogue ou une idée : ouvrez une Issue sur GitHub en joignant la version et le rapport de diagnostic de cette page (il ne contient ni noms ni coordonnées).';

  @override
  String get contributeWayTest =>
      'Tests : essayez l’application sur différentes versions et configurations de Windows (adhan, zone de notification, alarmes de réveil) et signalez ce que vous constatez.';

  @override
  String get contributeWayTranslate =>
      'Traduction : les textes de l’application se trouvent dans le dossier lib/l10n. Envoyez une nouvelle langue ou une correction ; la relecture par un locuteur natif est très précieuse.';

  @override
  String get diagAudioFailed =>
      'Le son de test n’a pas pu être lu. Vérifiez les haut-parleurs et le volume de Windows.';

  @override
  String get diagAudioOk => 'Le son de test a été lu.';

  @override
  String get diagAudioPlay => 'Lire un son de test';

  @override
  String get diagAudioStop => 'Arrêter';

  @override
  String get diagAudioTitle => 'Test audio';

  @override
  String get diagClockOk => 'Aucun problème d’horloge détecté.';

  @override
  String get diagClockTitle => 'Horloge';

  @override
  String get diagClockUnchecked =>
      'Aucun problème détecté, mais la vérification de l’heure réseau est désactivée : le décalage de l’horloge n’est pas mesuré.';

  @override
  String get diagCopied =>
      'Copié dans le presse-papiers. Il ne contient ni noms ni coordonnées exactes.';

  @override
  String get diagCopy => 'Copier le diagnostic';

  @override
  String get diagCopyFailed => 'Copie impossible.';

  @override
  String diagEventAzan(String prayer) {
    return 'Adhan : $prayer';
  }

  @override
  String diagEventReminder(String prayer) {
    return 'Rappel : $prayer';
  }

  @override
  String diagEventTimes(String utc, String local) {
    return 'UTC $utc | local $local';
  }

  @override
  String get diagEventWake => 'Alarme de réveil';

  @override
  String get diagEventsEmpty => 'Rien n’est programmé.';

  @override
  String get diagEventsTitle => 'Prochains événements programmés';

  @override
  String get diagLogNone => 'Non disponible.';

  @override
  String get diagLogTitle => 'Fichiers journaux';

  @override
  String get diagTitle => 'Diagnostic';

  @override
  String diagValue(String value) {
    String _temp0 = intl.Intl.selectLogic(value, {
      'yes': 'oui',
      'no': 'non',
      'unknown': 'inconnu',
      'enabled': 'autorisé',
      'disabled': 'désactivé',
      'importantOnly': 'importants uniquement',
      'ok': 'fonctionne',
      'failed': 'échec',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String diagWakeAc(String value) {
    return 'Minuteurs de réveil, sur secteur : $value';
  }

  @override
  String diagWakeBattery(String value) {
    return 'Minuteurs de réveil, sur batterie : $value';
  }

  @override
  String get diagWakeCheck => 'Vérifier maintenant';

  @override
  String diagWakeInProcess(String value) {
    return 'Minuteur dans l’application : $value';
  }

  @override
  String diagWakeModern(String value) {
    return 'Veille moderne : $value';
  }

  @override
  String get diagWakeNotChecked => 'Pas encore vérifié.';

  @override
  String diagWakeTask(String value) {
    return 'Tâche planifiée : $value';
  }

  @override
  String get diagWakeTitle => 'Vérification du réveil';

  @override
  String get formatAm => 'AM';

  @override
  String formatHours(String hours) {
    return '$hours h';
  }

  @override
  String formatHoursMinutes(String hours, String minutes) {
    return '$hours h $minutes min';
  }

  @override
  String formatMinutes(String minutes) {
    return '$minutes min';
  }

  @override
  String get formatPm => 'PM';

  @override
  String formatRemaining(String duration) {
    return 'dans $duration';
  }

  @override
  String formatRemainingLessThan(String minutes) {
    return 'dans moins de $minutes min';
  }

  @override
  String formatSeconds(String seconds) {
    return '$seconds s';
  }

  @override
  String get homeAzanMutedIndefinite =>
      'Adhan : en sourdine jusqu’à réactivation';

  @override
  String homeAzanMutedUntil(String time) {
    return 'Adhan : en sourdine jusqu’à $time';
  }

  @override
  String get homeAzanOff => 'Adhan : désactivé';

  @override
  String get homeAzanOn => 'Adhan : activé';

  @override
  String homeAzanToggleOff(String prayer) {
    return 'Désactiver l’adhan pour $prayer';
  }

  @override
  String homeAzanToggleOn(String prayer) {
    return 'Activer l’adhan pour $prayer';
  }

  @override
  String get homeBackToToday => 'Retour à aujourd’hui';

  @override
  String get homeBannerAllow => 'Autoriser';

  @override
  String homeBannerClockSkew(String amount) {
    return 'L’horloge du PC est décalée d’environ $amount.';
  }

  @override
  String get homeBannerDismiss => 'Fermer';

  @override
  String get homeBannerExactTiming =>
      'Android peut délivrer l’adhan avec quelques minutes de retard. Appuyez sur Autoriser et activez Alarms & reminders pour Salaat sur la page qui s’ouvre, afin que l’adhan arrive à la minute exacte.';

  @override
  String get homeBannerMutedIndefinite =>
      'L’adhan est en sourdine jusqu’à ce que vous le réactiviez.';

  @override
  String homeBannerMutedUntil(String time) {
    return 'L’adhan est en sourdine jusqu’à $time.';
  }

  @override
  String get homeBannerNotificationsOff =>
      'Les notifications sont désactivées : l’adhan ne peut pas sonner quand l’application est fermée. Appuyez sur Autoriser et activez les notifications de Salaat.';

  @override
  String get homeBannerSettingsReset =>
      'Le fichier de paramètres n’a pas pu être lu et les paramètres ont été réinitialisés aux valeurs par défaut.';

  @override
  String get homeBannerStaleZone =>
      'Windows affiche une heure différente de la base de fuseaux horaires pour ce lieu. Les horaires de cette application sont corrects ; vérifiez l’horloge de Windows.';

  @override
  String homeCompass(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'p0': 'nord',
      'p1': 'nord-est',
      'p2': 'est',
      'p3': 'sud-est',
      'p4': 'sud',
      'p5': 'sud-ouest',
      'p6': 'ouest',
      'p7': 'nord-ouest',
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
    return 'Horaires : $date';
  }

  @override
  String homeEventAt(String event, String time) {
    return '$event $time';
  }

  @override
  String get homeHeroNoNext => 'Aucun compte à rebours';

  @override
  String get homeMute => 'Sourdine';

  @override
  String get homeMuteCancel => 'Annuler la sourdine';

  @override
  String homeMuteForDuration(String duration) {
    return 'Pendant $duration';
  }

  @override
  String get homeMuteIndefinite => 'Jusqu’à réactivation';

  @override
  String get homeMuteUntilNext => 'Jusqu’au prochain adhan';

  @override
  String get homeNextDay => 'Jour suivant';

  @override
  String get homeNextMarker => 'Suivant';

  @override
  String homeNextWakeAlarm(String value) {
    return 'Prochain réveil : $value';
  }

  @override
  String get homeNoTimesAction => 'Paramètres de calcul';

  @override
  String get homeNoTimesInfo =>
      'Tous les horaires ne peuvent pas être calculés pour ce lieu ce jour-là. Vous pouvez modifier la règle des hautes latitudes dans les paramètres.';

  @override
  String get homeNoValue => '—';

  @override
  String homeNowPlaying(String prayer) {
    return 'Lecture : $prayer';
  }

  @override
  String get homeNowPlayingGeneric => 'Lecture de l’adhan';

  @override
  String get homeOtherDayHint =>
      'Horaires de ce jour ; le compte à rebours ne concerne qu’aujourd’hui.';

  @override
  String get homePreviousDay => 'Jour précédent';

  @override
  String homeQiblaSummary(String degrees, String direction) {
    return 'Qibla : $degrees° $direction';
  }

  @override
  String homeReminderMinutes(String minutes) {
    return 'Rappel : $minutes min avant';
  }

  @override
  String get homeReminderOff => 'Rappels : désactivés';

  @override
  String homeReminderRange(String min, String max) {
    return 'Rappels : $min à $max min avant';
  }

  @override
  String get homeStatusTitle => 'État';

  @override
  String get homeStop => 'Arrêter';

  @override
  String get homeSwitchLocation => 'Changer de lieu';

  @override
  String get homeTimelineLabel => 'Chronologie du jour';

  @override
  String get homeToday => 'Aujourd’hui';

  @override
  String get homeTodayTimes => 'Horaires d’aujourd’hui';

  @override
  String get homeTomorrowTimes => 'Horaires de demain';

  @override
  String homeUntilEvent(String event) {
    return 'Jusqu’à $event';
  }

  @override
  String homeViewingDay(String date) {
    return 'Affichage : $date';
  }

  @override
  String get navCalendar => 'Calendrier';

  @override
  String get navHome => 'Accueil';

  @override
  String get navQibla => 'Qibla';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get navTimetable => 'Horaires';

  @override
  String get navWakeUp => 'Réveil';

  @override
  String notifAzanBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String get notifAzanFailed => 'L’adhan n’a pas pu être lu.';

  @override
  String notifAzanTitle(String prayer) {
    return 'Adhan $prayer';
  }

  @override
  String notifMissedBody(String time) {
    return 'L’ordinateur était en veille à $time.';
  }

  @override
  String notifMissedTitle(String prayer) {
    return 'Adhan $prayer non joué';
  }

  @override
  String notifReminderBody(String place, String time) {
    return '$place · $time';
  }

  @override
  String notifReminderTitle(String minutes, String prayer) {
    return '$minutes min avant $prayer';
  }

  @override
  String get notifSoundFallback =>
      'Le fichier audio de l’adhan est introuvable ; le son par défaut a été lu.';

  @override
  String get notifStopAction => 'Arrêter';

  @override
  String get notifTrayHint =>
      'L’application reste active à côté de l’horloge Windows.';

  @override
  String get onboardingAzanBody =>
      'Écoutez l’adhan et choisissez si l’application démarre avec Windows.';

  @override
  String get onboardingAzanTitle => 'Adhan et démarrage';

  @override
  String get onboardingBack => 'Retour';

  @override
  String get onboardingCityBody =>
      'Recherchez votre ville ou choisissez-la dans une province.';

  @override
  String get onboardingCityNone => 'Aucune ville trouvée.';

  @override
  String get onboardingCitySearchHint => 'Rechercher une ville';

  @override
  String onboardingCitySelected(String city) {
    return 'Sélection : $city';
  }

  @override
  String get onboardingCityTitle => 'Votre ville';

  @override
  String get onboardingFinish => 'Commencer';

  @override
  String get onboardingLanguageBody =>
      'Choisissez votre langue. Vous pourrez la modifier plus tard dans les paramètres.';

  @override
  String get onboardingLanguageTitle => 'Langue';

  @override
  String get onboardingModeList => 'Villes d’Iran (liste hors ligne)';

  @override
  String get onboardingModeOnline =>
      'N’importe quelle ville du monde (recherche en ligne)';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingOnlineBody =>
      'Votre ville n’est pas dans la liste ? Cherchez n’importe quelle ville du monde. Internet n’est nécessaire que pour cette recherche ; ensuite l’application fonctionne sans internet.';

  @override
  String get onboardingPreview => 'Écouter un adhan d’exemple';

  @override
  String get onboardingProvinceAll => 'Toutes les provinces';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingStartWithWindows => 'Démarrer avec Windows';

  @override
  String get onboardingStartWithWindowsHint =>
      'L’application démarre discrètement dans la zone de notification.';

  @override
  String onboardingStepProgress(String step, String total) {
    return 'Étape $step sur $total';
  }

  @override
  String get onboardingStopPreview => 'Arrêter';

  @override
  String get placeSearchAttribution =>
      'Lieux © contributeurs d’OpenStreetMap (Nominatim). Fuseau horaire et altitude : Open-Meteo.';

  @override
  String get placeSearchButton => 'Rechercher';

  @override
  String get placeSearchFailBusy =>
      'Le service de recherche est occupé. Attendez une minute et réessayez.';

  @override
  String get placeSearchFailDetails =>
      'Le lieu a été trouvé, mais son fuseau horaire n’a pas pu être obtenu. Vérifiez la connexion et choisissez-le de nouveau.';

  @override
  String get placeSearchFailGeneric =>
      'La recherche a échoué. Réessayez dans un instant.';

  @override
  String get placeSearchFailOffline =>
      'Pas de connexion internet. Connectez-vous puis appuyez de nouveau sur Rechercher. Le reste de l’application fonctionne sans internet.';

  @override
  String get placeSearchFailTimeout =>
      'Le service de recherche n’a pas répondu à temps. Réessayez.';

  @override
  String get placeSearchHint => 'Ville, pays (par exemple Bombay, Inde)';

  @override
  String placeSearchNone(String query) {
    return 'Aucun lieu trouvé pour « $query ». Vérifiez l’orthographe ou ajoutez le pays, par exemple Bombay, Inde.';
  }

  @override
  String get placeSearchNotice =>
      'La recherche a besoin d’internet, cette fois seulement. Le texte que vous saisissez est envoyé au service de recherche d’OpenStreetMap (Nominatim) ; rien d’autre n’est envoyé. Une fois le lieu choisi, l’application garde ce qu’il lui faut et refonctionne sans internet.';

  @override
  String get placeSearchNoticeDetails =>
      'Quand vous choisissez un lieu, ses coordonnées sont envoyées à Open-Meteo pour obtenir son fuseau horaire et son altitude.';

  @override
  String placeSearchResolving(String place) {
    return 'Récupération du fuseau horaire et de l’altitude de $place…';
  }

  @override
  String get placeSearchResultsTitle => 'Résultats : choisissez votre lieu';

  @override
  String get placeSearchTitle => 'Rechercher un lieu';

  @override
  String get placeSearchTooShort =>
      'Saisissez au moins deux lettres, puis appuyez sur Rechercher.';

  @override
  String get placeSearchUnknownZone =>
      'Le fuseau horaire de ce lieu n’est pas dans la base de données de l’application. Essayez un autre lieu, ou ajoutez-le avec Lieu personnalisé dans les réglages.';

  @override
  String get placeSearching => 'Recherche en cours…';

  @override
  String get prayerAsr => 'Asr';

  @override
  String get prayerDhuhr => 'Dhouhr';

  @override
  String get prayerFajr => 'Fajr';

  @override
  String get prayerImsak => 'Imsak';

  @override
  String get prayerIsha => 'Icha';

  @override
  String get prayerMaghrib => 'Maghrib';

  @override
  String get prayerMidnight => 'Minuit';

  @override
  String get prayerSunrise => 'Lever du soleil';

  @override
  String get prayerSunset => 'Coucher du soleil';

  @override
  String qiblaAccuracyValue(String meters) {
    return 'Précision : environ $meters m';
  }

  @override
  String get qiblaBearingLabel =>
      'Azimut (dans le sens horaire depuis le nord géographique)';

  @override
  String qiblaBearingValue(String degrees, String direction) {
    return '$degrees° ($direction)';
  }

  @override
  String get qiblaCamKaaba => 'Kaaba';

  @override
  String get qiblaCamNearby => 'Autour de moi';

  @override
  String get qiblaCamOverview => 'Trajet complet';

  @override
  String qiblaCardinal(String point) {
    String _temp0 = intl.Intl.selectLogic(point, {
      'n': 'N',
      'e': 'E',
      's': 'S',
      'w': 'O',
      'other': '',
    });
    return '$_temp0';
  }

  @override
  String qiblaCompassSemantics(String degrees, String direction) {
    return 'Rose des vents : la qibla est à $degrees degrés ($direction)';
  }

  @override
  String qiblaCompassSemanticsSun(String base, String azimuth) {
    return '$base ; le soleil est à $azimuth degrés';
  }

  @override
  String get qiblaCoordsApply => 'Afficher';

  @override
  String get qiblaCoordsHint => 'par exemple 36.2133, 58.7958';

  @override
  String get qiblaCoordsInvalid =>
      'Coordonnées non valides. La latitude doit être comprise entre -90 et 90 et la longitude entre -180 et 180.';

  @override
  String get qiblaCoordsLabel => 'Latitude et longitude';

  @override
  String get qiblaCoordsOr => 'Ou saisissez vous-même les coordonnées';

  @override
  String qiblaCustomPlaceShown(String place) {
    return 'Mesure depuis $place.';
  }

  @override
  String get qiblaDeviceFixShown => 'Affichage de la position de cet appareil.';

  @override
  String get qiblaDistanceLabel => 'Distance jusqu’à la Kaaba';

  @override
  String qiblaDistanceValue(String km) {
    return '$km km';
  }

  @override
  String get qiblaFailGeneric =>
      'La position n’a pas pu être lue ; la ville sélectionnée est affichée.';

  @override
  String get qiblaFailPermissionDenied =>
      'Windows n’a pas autorisé cette application à lire la position. Suivez les étapes ci-dessous et réessayez ; ou utilisez la ville sélectionnée.';

  @override
  String get qiblaFailPermissionForever =>
      'L’accès à la localisation a été refusé. Pour l’autoriser à nouveau, suivez les étapes ci-dessous.';

  @override
  String get qiblaFailServiceDisabled =>
      'Les services de localisation sont désactivés sur cet appareil. Suivez les étapes ci-dessous ; ou utilisez la ville sélectionnée ou un point quelconque.';

  @override
  String get qiblaFailTimeout =>
      'Aucune position reçue à temps. Les PC ont rarement un GPS et Windows estime la position à partir du Wi-Fi. Réessayez ou utilisez la ville.';

  @override
  String get qiblaFailUnsupported =>
      'Cet appareil ne peut pas indiquer sa position ; la ville sélectionnée est affichée.';

  @override
  String qiblaForLocation(String place) {
    return 'Direction de la qibla pour $place';
  }

  @override
  String get qiblaHelpOther =>
      'Activez la localisation dans les paramètres du système, autorisez cette application à l’utiliser, puis réessayez.';

  @override
  String get qiblaHelpTitleOther => 'Comment activer la localisation ?';

  @override
  String get qiblaHelpTitleWindows =>
      'Comment activer la localisation dans Windows ?';

  @override
  String get qiblaHelpWin1 =>
      'Appuyez sur le bouton ci-dessus pour ouvrir la page Localisation des paramètres Windows. Si elle ne s’ouvre pas, allez-y manuellement : Start > Settings > Privacy & security > Location (Windows 10 : Privacy > Location)';

  @override
  String get qiblaHelpWin2 =>
      'Activez « Location services ». Si le haut de la page indique que la localisation est désactivée pour cet appareil, appuyez sur « Change » et activez-la.';

  @override
  String get qiblaHelpWin3 =>
      'Un peu plus bas, activez « Let desktop apps access your location » (Windows 10 : « Allow desktop apps to access your location »). Salaat est une application de bureau et n’est autorisée que par ce commutateur.';

  @override
  String get qiblaHelpWin4 =>
      'Revenez dans Salaat et appuyez de nouveau sur « Trouver ma position ». Si cela échoue encore, fermez l’application une fois puis rouvrez-la.';

  @override
  String get qiblaLocateAgain => 'Rechercher à nouveau';

  @override
  String get qiblaLocateButton => 'Trouver ma position';

  @override
  String get qiblaLocating => 'Recherche de votre position…';

  @override
  String get qiblaMapAttribution => '© contributeurs OpenStreetMap';

  @override
  String get qiblaMapAttributionSatellite =>
      'Imagerie © Esri, Maxar, Earthstar Geographics et la communauté des utilisateurs SIG';

  @override
  String get qiblaMapConsentBody =>
      'Pour tracer la ligne de la qibla sur une carte, des images de carte sont téléchargées depuis Internet et la zone que vous regardez est envoyée à ce serveur : le plan des rues depuis OpenStreetMap et, si vous choisissez Satellite, des photographies aériennes depuis Esri. Rien n’est demandé tant que vous n’avez pas accepté. L’angle et la distance de la qibla s’affichent correctement même sans la carte.';

  @override
  String get qiblaMapConsentButton => 'Afficher la carte';

  @override
  String get qiblaMapConsentTitle => 'Carte de la qibla';

  @override
  String get qiblaMapKaaba => 'Kaaba';

  @override
  String get qiblaMapLineNote =>
      'La ligne est le plus court chemin sur le globe jusqu’au centre de la Kaaba. Elle paraît courbe sur une carte plane, mais elle part dans la direction de la qibla. La gouttière de la Kaaba n’est qu’à quelques mètres du centre et ne change rien de visible à la direction. Appuyez sur « Autour de moi » pour comparer avec les rues et les bâtiments.';

  @override
  String get qiblaMapOfflineBanner =>
      'Les images de la carte ne peuvent pas être chargées (pas d’Internet ?). La ligne et l’angle de la qibla restent corrects.';

  @override
  String qiblaMapSemantics(String place, String bearing, String distance) {
    return 'Carte de la qibla : de $place à la Kaaba, $bearing, $distance';
  }

  @override
  String get qiblaMapTapHint => 'Touchez la carte pour choisir un autre point.';

  @override
  String get qiblaMapTurnOff => 'Désactiver la carte';

  @override
  String get qiblaMapYou => 'Votre position';

  @override
  String get qiblaNoCompassNote =>
      'Un PC n’a pas de boussole : le dessin est donc relatif au nord géographique (le nord est en haut).';

  @override
  String get qiblaOpenSettingsFailed =>
      'La page des paramètres n’a pas pu être ouverte ; suivez les étapes manuellement.';

  @override
  String get qiblaOpenSettingsOther => 'Ouvrir les paramètres de localisation';

  @override
  String get qiblaOpenSettingsWindows =>
      'Ouvrir les paramètres de localisation de Windows';

  @override
  String get qiblaSourceCity => 'Ville sélectionnée';

  @override
  String qiblaSourceCityHelp(String city) {
    return 'La ville choisie pour les horaires de prière : $city.';
  }

  @override
  String get qiblaSourceCustom => 'Point quelconque';

  @override
  String get qiblaSourceCustomHelp =>
      'Cherchez un lieu par son nom (internet nécessaire une seule fois), touchez la carte ou saisissez des coordonnées.';

  @override
  String get qiblaSourceDevice => 'Cet appareil';

  @override
  String get qiblaSourceDeviceHelp =>
      'La position n’est lue sur l’appareil que lorsque vous appuyez sur le bouton ; elle n’est ni enregistrée ni envoyée.';

  @override
  String get qiblaSourceTitle => 'Mesurer la qibla depuis';

  @override
  String get qiblaStatLatitude => 'Latitude';

  @override
  String get qiblaStatLongitude => 'Longitude';

  @override
  String get qiblaStyleLabel => 'Type de carte';

  @override
  String get qiblaStyleSatellite => 'Satellite';

  @override
  String get qiblaStyleStreet => 'Plan';

  @override
  String get qiblaSunBelow => 'Le soleil est sous l’horizon.';

  @override
  String get qiblaSunInHelp =>
      'À cet instant, le soleil est exactement dans la direction de la qibla ; faites face au soleil.';

  @override
  String get qiblaSunInTitle => 'Soleil dans la direction de la qibla';

  @override
  String get qiblaSunNone => 'Ne se produit pas aujourd’hui.';

  @override
  String get qiblaSunNowLabel => 'Soleil maintenant';

  @override
  String qiblaSunNowValue(String azimuth, String altitude) {
    return 'Azimut $azimuth°, hauteur $altitude°';
  }

  @override
  String get qiblaSunOppHelp =>
      'À cet instant, l’ombre d’une tige verticale pointe vers la qibla.';

  @override
  String get qiblaSunOppTitle => 'Soleil à l’opposé de la qibla';

  @override
  String get qiblaSunTimesTitle => 'Le soleil et la qibla aujourd’hui';

  @override
  String get qiblaTabCompass => 'Boussole et soleil';

  @override
  String get qiblaTabMap => 'Carte';

  @override
  String get qiblaTitle => 'Qibla';

  @override
  String get settingsAboutPlaceholder =>
      'La version, les licences et la page de diagnostic apparaissent dans cette section.';

  @override
  String get settingsAppAutostart => 'Démarrer avec Windows';

  @override
  String get settingsAppAutostartHelp =>
      'L’application démarre discrètement à côté de l’horloge à l’ouverture de session Windows.';

  @override
  String get settingsAppCloseToTray => 'Réduire dans la zone de notification';

  @override
  String get settingsAppCloseToTrayHelp =>
      'Fermer la fenêtre garde l’application à côté de l’horloge Windows pour que l’adhan soit toujours joué. Si désactivé, la fermeture quitte l’application.';

  @override
  String get settingsAppMinimized => 'Démarrer en mode réduit';

  @override
  String get settingsAppMinimizedHelp =>
      'La fenêtre reste fermée quand Windows lance l’application.';

  @override
  String get settingsAsrHanafi => 'Hanafite (ombre égale à deux fois l’objet)';

  @override
  String get settingsAsrStandard => 'Standard (ombre égale à l’objet)';

  @override
  String get settingsAzanChoose => 'Choisir un fichier…';

  @override
  String get settingsAzanEnabled => 'Jouer l’adhan';

  @override
  String get settingsAzanEnabledHelp =>
      'L’interrupteur général ; s’il est désactivé, aucun adhan n’est joué.';

  @override
  String get settingsAzanFade => 'Fondu d’entrée';

  @override
  String get settingsAzanFadeHelp =>
      'L’adhan monte doucement jusqu’au volume maximal.';

  @override
  String get settingsAzanMute => 'Sourdine rapide';

  @override
  String get settingsAzanMuteHelp => 'Couper l’adhan pour un moment.';

  @override
  String get settingsAzanNotMuted => 'Pas en sourdine';

  @override
  String get settingsAzanPhoneNote =>
      'Sur un téléphone, l’adhan et les rappels arrivent sous forme de notifications du système, même quand l’application est fermée. La notification d’adhan joue le son d’adhan fourni avec l’application ; le son et le volume choisis sur cette page servent aux aperçus dans l’application. Réglez la puissance avec le volume des notifications du téléphone.';

  @override
  String settingsAzanPrayerSwitch(String prayer) {
    return 'Adhan $prayer';
  }

  @override
  String get settingsAzanPrayerVolume => 'Volume de cet adhan';

  @override
  String get settingsAzanPreview => 'Écouter';

  @override
  String get settingsAzanSound => 'Son';

  @override
  String get settingsAzanSoundDefault => 'Adhan inclus';

  @override
  String settingsAzanSoundFile(String name) {
    return 'Fichier : $name';
  }

  @override
  String get settingsAzanUseDefault => 'Utiliser le son inclus';

  @override
  String get settingsAzanVolume => 'Volume';

  @override
  String get settingsAzanVolumeHelp => 'Le volume général de tous les adhans';

  @override
  String get settingsBackupExport => 'Exporter la sauvegarde';

  @override
  String get settingsBackupExportFailed =>
      'La sauvegarde n’a pas pu être enregistrée.';

  @override
  String get settingsBackupExportHelp =>
      'Tous les paramètres, lieux et alarmes de réveil sont enregistrés dans un seul fichier.';

  @override
  String settingsBackupExported(String path) {
    return 'Sauvegarde enregistrée : $path';
  }

  @override
  String get settingsBackupImport => 'Importer une sauvegarde';

  @override
  String get settingsBackupImportBody =>
      'Tous les paramètres actuels sont remplacés par le contenu de ce fichier.';

  @override
  String get settingsBackupImportConfirm => 'Restaurer';

  @override
  String get settingsBackupImportHelp =>
      'Restaure les paramètres à partir d’un fichier de sauvegarde.';

  @override
  String get settingsBackupImportInvalid =>
      'Ce fichier n’est pas une sauvegarde de paramètres valide ; les paramètres n’ont pas été modifiés.';

  @override
  String get settingsBackupImportReadFailed =>
      'Le fichier n’a pas pu être lu ; les paramètres n’ont pas été modifiés.';

  @override
  String get settingsBackupImportTitle => 'Restaurer les paramètres ?';

  @override
  String get settingsBackupImported => 'Les paramètres ont été restaurés.';

  @override
  String get settingsBackupTitle => 'Sauvegarde et restauration';

  @override
  String get settingsCalcAngleHelp =>
      'Angle du soleil sous l’horizon, en degrés';

  @override
  String get settingsCalcAsr => 'Règle de l’Asr';

  @override
  String get settingsCalcFajrAngle => 'Angle du Fajr';

  @override
  String get settingsCalcHighLat => 'Hautes latitudes';

  @override
  String get settingsCalcHighLatHelp =>
      'Pour les lieux où la nuit est très courte et où l’angle du crépuscule n’est jamais atteint.';

  @override
  String get settingsCalcImsak => 'Imsak';

  @override
  String get settingsCalcImsakHelp => 'Minutes avant le Fajr';

  @override
  String get settingsCalcIshaAngle => 'Angle de l’Icha';

  @override
  String get settingsCalcIshaMinutes => 'Minutes après le Maghrib';

  @override
  String get settingsCalcIshaMode => 'Définition de l’Icha';

  @override
  String get settingsCalcIshaModeAngle => 'Angle du soleil';

  @override
  String get settingsCalcIshaModeMinutes => 'Minutes après le Maghrib';

  @override
  String get settingsCalcMaghribAngle => 'Angle du Maghrib';

  @override
  String get settingsCalcMaghribSunset => 'Maghrib au coucher du soleil';

  @override
  String get settingsCalcMaghribSunsetHelp =>
      'Si désactivé, le Maghrib est calculé avec l’angle ci-dessous.';

  @override
  String get settingsCalcMethod => 'Méthode';

  @override
  String get settingsCalcMethodHelp =>
      'Modifier un angle passe la méthode sur Personnalisée.';

  @override
  String get settingsCalcMidnight => 'Minuit';

  @override
  String settingsCalcOffsetsHelp(String max) {
    return 'Avancez ou reculez chaque horaire de $max minutes au plus.';
  }

  @override
  String get settingsCalcOffsetsReset => 'Tout réinitialiser';

  @override
  String get settingsCalcOffsetsTitle => 'Ajustement en minutes par horaire';

  @override
  String settingsCalcPreviewHelp(String date) {
    return 'Horaires d’aujourd’hui ($date) avec les paramètres ci-dessus';
  }

  @override
  String get settingsCalcPreviewTitle => 'Aperçu en direct';

  @override
  String get settingsCalcRestore =>
      'Rétablir les valeurs par défaut de cette méthode';

  @override
  String settingsCalcRestoreHelp(String method) {
    return 'Les angles, règles et l’Imsak reviennent aux valeurs de $method ; les ajustements en minutes de chaque horaire ne changent pas.';
  }

  @override
  String get settingsCalcRowsHelp =>
      'Le Fajr, le lever du soleil, le Dhouhr, le Maghrib et minuit sont toujours affichés.';

  @override
  String get settingsCalcRowsTitle => 'Lignes à afficher';

  @override
  String get settingsCancel => 'Annuler';

  @override
  String get settingsDecrease => 'Diminuer';

  @override
  String get settingsDigitsArabic => 'Arabes (٠١٢)';

  @override
  String get settingsDigitsLatin => 'Latins (123)';

  @override
  String get settingsDigitsPersian => 'Persans (۱۲۳)';

  @override
  String get settingsDispDigits => 'Chiffres';

  @override
  String get settingsDispHijri => 'Ajustement de la date hégirienne';

  @override
  String get settingsDispHijriHelp =>
      'L’Iran suit l’observation de la lune : la date hégirienne affichée peut donc différer de la date officielle ; décalez-la ici d’un ou deux jours.';

  @override
  String get settingsDispHour => 'Horloge';

  @override
  String get settingsDispLanguage => 'Langue';

  @override
  String get settingsDispLanguageHelp => 'S’applique sans redémarrage.';

  @override
  String get settingsDispTheme => 'Thème';

  @override
  String get settingsHighLatAngleBased => 'Selon l’angle';

  @override
  String get settingsHighLatNightMiddle => 'Milieu de la nuit';

  @override
  String get settingsHighLatNone => 'Aucun ajustement';

  @override
  String get settingsHighLatOneSeventh => 'Un septième de la nuit';

  @override
  String get settingsHour12 => '12 heures';

  @override
  String get settingsHour24 => '24 heures';

  @override
  String get settingsIncrease => 'Augmenter';

  @override
  String settingsInvalidNumber(String min, String max) {
    return 'Saisissez un nombre compris entre $min et $max.';
  }

  @override
  String get settingsLocActive => 'Actif';

  @override
  String get settingsLocAdd => 'Ajouter';

  @override
  String get settingsLocAddCustom => 'Lieu personnalisé';

  @override
  String get settingsLocAddFromDb => 'Depuis la liste des villes';

  @override
  String get settingsLocAddSearch => 'Rechercher en ligne';

  @override
  String get settingsLocAddTitle => 'Ajouter un lieu';

  @override
  String settingsLocAdded(String name) {
    return '$name a été ajouté.';
  }

  @override
  String get settingsLocAllProvinces => 'Toutes les provinces';

  @override
  String get settingsLocAlreadySaved => 'Déjà enregistré';

  @override
  String settingsLocAlreadySavedName(String name) {
    return '$name figure déjà dans vos lieux enregistrés.';
  }

  @override
  String get settingsLocClose => 'Fermer';

  @override
  String settingsLocCoords(String lat, String lon) {
    return 'Lat $lat, long $lon';
  }

  @override
  String get settingsLocCustomBadge => 'Personnalisé';

  @override
  String get settingsLocDegrees => 'Degrés';

  @override
  String get settingsLocDelete => 'Supprimer';

  @override
  String get settingsLocDeleteBody => 'Ce lieu est retiré de votre liste.';

  @override
  String get settingsLocDeleteLast =>
      'Le dernier lieu ne peut pas être supprimé.';

  @override
  String settingsLocDeleteTitle(String name) {
    return 'Supprimer $name ?';
  }

  @override
  String get settingsLocEast => 'Est';

  @override
  String get settingsLocEdit => 'Modifier';

  @override
  String get settingsLocElevation => 'Altitude (mètres)';

  @override
  String settingsLocErrElevation(String min, String max) {
    return 'L’altitude doit être comprise entre $min et $max mètres.';
  }

  @override
  String settingsLocErrLatitude(String min, String max) {
    return 'La latitude doit être un nombre compris entre $min et $max.';
  }

  @override
  String settingsLocErrLongitude(String min, String max) {
    return 'La longitude doit être un nombre compris entre $min et $max.';
  }

  @override
  String get settingsLocErrName => 'Saisissez un nom.';

  @override
  String settingsLocErrOffset(String min, String max) {
    return 'Le décalage doit être compris entre $min et $max.';
  }

  @override
  String get settingsLocErrZone =>
      'Choisissez un fuseau horaire dans la liste.';

  @override
  String get settingsLocFormatDecimal => 'Degrés décimaux';

  @override
  String get settingsLocFormatDms => 'Degrés, minutes, secondes';

  @override
  String get settingsLocLatitude => 'Latitude';

  @override
  String get settingsLocLongitude => 'Longitude';

  @override
  String get settingsLocMinutes => 'Minutes';

  @override
  String get settingsLocName => 'Nom';

  @override
  String get settingsLocNoResults => 'Aucune ville trouvée.';

  @override
  String get settingsLocNorth => 'Nord';

  @override
  String get settingsLocProvince => 'Province';

  @override
  String get settingsLocSave => 'Enregistrer';

  @override
  String get settingsLocSavedHelp =>
      'Les horaires sont calculés pour le lieu actif.';

  @override
  String get settingsLocSavedTitle => 'Lieux enregistrés';

  @override
  String get settingsLocSearchHint => 'Rechercher une ville';

  @override
  String get settingsLocSeconds => 'Secondes';

  @override
  String get settingsLocSetActive => 'Activer';

  @override
  String get settingsLocSouth => 'Sud';

  @override
  String get settingsLocWest => 'Ouest';

  @override
  String get settingsLocZoneNone => 'Aucun fuseau horaire trouvé.';

  @override
  String get settingsLocZoneSearch => 'Rechercher un fuseau horaire';

  @override
  String settingsLocZoneSelected(String zone) {
    return 'Fuseau horaire sélectionné : $zone';
  }

  @override
  String get settingsMethodCustom => 'Personnalisée';

  @override
  String get settingsMethodEgypt => 'Autorité générale égyptienne d’arpentage';

  @override
  String get settingsMethodIsna => 'Société islamique d’Amérique du Nord';

  @override
  String get settingsMethodJafari => 'Chiite duodécimain, Institut Leva (Qom)';

  @override
  String get settingsMethodKarachi =>
      'Université des sciences islamiques de Karachi';

  @override
  String get settingsMethodMakkah => 'Université Umm al-Qura, La Mecque';

  @override
  String get settingsMethodMwl => 'Ligue islamique mondiale';

  @override
  String get settingsMethodTehran =>
      'Université de Téhéran, Institut de géophysique';

  @override
  String get settingsMidnightJafari => 'Entre le coucher du soleil et le Fajr';

  @override
  String get settingsMidnightStandard =>
      'Entre le coucher et le lever du soleil';

  @override
  String get settingsOff => 'Désactivé';

  @override
  String settingsPercent(String value) {
    return '$value %';
  }

  @override
  String get settingsRemChime => 'Carillon doux';

  @override
  String get settingsRemChimeHelp =>
      'Un carillon doux accompagne la notification de rappel.';

  @override
  String get settingsRemChimeTest => 'Écouter un exemple';

  @override
  String settingsRemHelp(String max) {
    return '0 signifie désactivé ; jusqu’à $max minutes avant l’adhan.';
  }

  @override
  String get settingsRemIndependent =>
      'Désactiver les rappels n’affecte jamais l’adhan.';

  @override
  String settingsRemSummary(String minutes) {
    return '$minutes min avant l’adhan';
  }

  @override
  String settingsRemTitle(String prayer) {
    return 'Rappel avant $prayer';
  }

  @override
  String get settingsResetConfirm => 'Effacer';

  @override
  String get settingsResetConfirmBody =>
      'Les paramètres reviennent aux valeurs par défaut et le lieu actif devient Téhéran. Cette action est irréversible.';

  @override
  String get settingsResetConfirmTitle => 'Effacer tous les paramètres ?';

  @override
  String get settingsResetDone =>
      'Les paramètres ont été réinitialisés aux valeurs par défaut.';

  @override
  String get settingsResetHelp =>
      'Tous les paramètres, lieux enregistrés et alarmes de réveil sont effacés.';

  @override
  String get settingsResetTitle => 'Rétablir les valeurs par défaut';

  @override
  String get settingsSaved => 'Enregistré';

  @override
  String get settingsSectionAbout => 'À propos et diagnostic';

  @override
  String get settingsSectionApp => 'Application';

  @override
  String get settingsSectionAzan => 'Adhan';

  @override
  String get settingsSectionCalculation => 'Calcul';

  @override
  String get settingsSectionDisplay => 'Affichage';

  @override
  String get settingsSectionLocation => 'Lieu';

  @override
  String get settingsSectionReminders => 'Rappels';

  @override
  String get settingsSectionTime => 'Heure';

  @override
  String get settingsSectionsLabel => 'Sections des paramètres';

  @override
  String get settingsThemeDark => 'Sombre';

  @override
  String get settingsThemeLight => 'Clair';

  @override
  String get settingsThemeSystem => 'Suivre Windows';

  @override
  String get settingsTimeCheck => 'Vérifier l’horloge avec l’heure réseau';

  @override
  String get settingsTimeCheckHelp =>
      'Au démarrage de l’application et toutes les six heures ; désactivé par défaut.';

  @override
  String get settingsTimeCheckNow => 'Vérifier maintenant';

  @override
  String settingsTimeCheckedAt(String time) {
    return 'Vérifié à $time';
  }

  @override
  String get settingsTimeChecking => 'Vérification…';

  @override
  String get settingsTimeCorrect => 'Corriger l’heure dans l’application';

  @override
  String get settingsTimeCorrectHelp =>
      'L’horloge de Windows n’est jamais modifiée.';

  @override
  String settingsTimeDiagLocation(String offset) {
    return 'Décalage du lieu actif (base de données) : $offset';
  }

  @override
  String get settingsTimeDiagOk => 'Aucun problème d’horloge détecté.';

  @override
  String get settingsTimeDiagTitle => 'Diagnostic de l’horloge';

  @override
  String settingsTimeDiagWindows(String offset) {
    return 'Décalage de Windows par rapport à UTC : $offset';
  }

  @override
  String get settingsTimeError =>
      'Impossible de joindre le serveur de temps. Vérifiez la connexion Internet et le nom du serveur.';

  @override
  String get settingsTimeNever => 'Pas encore vérifié.';

  @override
  String get settingsTimeServer => 'Serveur de temps';

  @override
  String get settingsTimeServerHelp =>
      'Nom du serveur de temps, par exemple pool.ntp.org';

  @override
  String get settingsTimeServerInvalid => 'Le nom du serveur n’est pas valide.';

  @override
  String settingsTimeSkewAhead(String amount) {
    return 'L’horloge du PC avance de $amount.';
  }

  @override
  String settingsTimeSkewBehind(String amount) {
    return 'L’horloge du PC retarde de $amount.';
  }

  @override
  String get settingsTimeSkewZero =>
      'L’horloge du PC correspond à l’heure réseau.';

  @override
  String get settingsTimeStatusTitle => 'Dernière vérification';

  @override
  String get settingsZoneAuto => 'Automatique (recommandé)';

  @override
  String settingsZoneAutoHelp(String zone) {
    return 'Utilise la base de fuseaux horaires intégrée à l’application : $zone';
  }

  @override
  String get settingsZoneFixed => 'Décalage fixe';

  @override
  String get settingsZoneFixedAllYear =>
      'Le décalage est fixe et reste identique tous les jours de l’année.';

  @override
  String get settingsZoneFixedHelp =>
      'Une différence fixe avec UTC, valable tous les jours de l’année.';

  @override
  String settingsZoneFixedValue(String offset) {
    return 'Décalage fixe : $offset';
  }

  @override
  String get settingsZoneHourLess => 'Une heure de moins';

  @override
  String get settingsZoneHourMore => 'Une heure de plus';

  @override
  String settingsZoneNext(String date, String time, String offset) {
    return 'Prochain changement : $date à $time, décalage $offset';
  }

  @override
  String get settingsZoneNoChange =>
      'Aucun autre changement n’est prévu pour ce fuseau horaire.';

  @override
  String settingsZoneNow(String offset) {
    return 'Décalage en vigueur aujourd’hui : $offset';
  }

  @override
  String get settingsZoneQuarterLess => 'Un quart d’heure de moins';

  @override
  String get settingsZoneQuarterMore => 'Un quart d’heure de plus';

  @override
  String get settingsZoneTitle => 'Fuseau horaire';

  @override
  String get supportAvailableIn => 'Utilisable dans :';

  @override
  String get supportCardCountries =>
      'Iran uniquement : cartes bancaires iraniennes du réseau Shetab. Le paiement est impossible depuis l’extérieur de l’Iran ; utilisez plutôt l’option cryptomonnaie.';

  @override
  String get supportCardNumberLabel => 'Numéro de carte';

  @override
  String get supportCardTitle => 'Carte bancaire iranienne';

  @override
  String get supportCheckNote =>
      'Avant de payer, comparez le numéro ou l’adresse avec la page officielle du projet sur GitHub. Merci pour votre soutien.';

  @override
  String get supportCryptoAddressLabel => 'Adresse du portefeuille';

  @override
  String get supportCryptoCountries =>
      'Tous les pays : de partout où un portefeuille ou une plateforme crypto est disponible, sans carte bancaire.';

  @override
  String get supportCryptoNetworkLabel => 'Réseau';

  @override
  String get supportCryptoNetworkValue =>
      'BEP20 (BNB Smart Chain, aussi appelé BSC)';

  @override
  String get supportCryptoTitle => 'Cryptomonnaie USDT (Tether)';

  @override
  String get supportCryptoWarning =>
      'Envoyez uniquement des USDT sur le réseau BEP20. Envoyer une autre monnaie, ou utiliser un autre réseau, vers cette adresse fait perdre l’argent.';

  @override
  String get supportIntro =>
      'Cette application est gratuite, sans publicité, ne demande aucun compte et ne réserve aucune fonction à un paiement. Si elle vous est utile et que vous souhaitez l’aider à continuer de grandir, vous pouvez utiliser l’un des moyens ci-dessous. Le soutien est entièrement facultatif et tout montant est apprécié.';

  @override
  String get supportTitle => 'Soutenir le projet';

  @override
  String get timetableCalendarSwitch => 'Type de calendrier';

  @override
  String get timetableColDay => 'Jour';

  @override
  String get timetableColWeekday => 'Jour de la semaine';

  @override
  String get timetableMonthUnavailable =>
      'Ce mois est hors de la table du calendrier lunaire.';

  @override
  String get timetableNextMonth => 'Mois suivant';

  @override
  String timetableOpenDay(String date) {
    return 'Afficher le $date sur l’écran d’accueil';
  }

  @override
  String get timetablePreviousMonth => 'Mois précédent';

  @override
  String get timetableToday => 'Aujourd’hui';

  @override
  String get trayMenuLocation => 'Lieu';

  @override
  String get trayMenuMute => 'Sourdine';

  @override
  String get trayMenuMuted => 'En sourdine';

  @override
  String get trayMenuQuit => 'Quitter';

  @override
  String get trayMenuSettings => 'Paramètres';

  @override
  String get trayMenuShow => 'Afficher la fenêtre';

  @override
  String get trayMenuStopAzan => 'Arrêter l’adhan';

  @override
  String get trayMuteCancel => 'Annuler la sourdine';

  @override
  String trayMuteHours(String n) {
    return '$n h';
  }

  @override
  String get trayMuteIndefinite => 'Jusqu’à désactivation';

  @override
  String get trayMuteUntilNext => 'Jusqu’au prochain adhan';

  @override
  String trayNextLine(String prayer, String time) {
    return 'Prochain : $prayer · $time';
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
  String get wakeAdd => 'Ajouter une alarme';

  @override
  String get wakeAfterHibernate => 'Après le son : hibernation';

  @override
  String get wakeAfterHibernateChoice => 'Hibernation';

  @override
  String get wakeAfterNote =>
      'Avant la mise en veille ou en hibernation du PC, un compte à rebours de 30 secondes permet d’annuler.';

  @override
  String get wakeAfterNothing => 'Ne rien faire';

  @override
  String get wakeAfterSleep => 'Après le son : veille';

  @override
  String get wakeAfterSleepChoice => 'Veille';

  @override
  String get wakeAfterTitle => 'Après le son';

  @override
  String get wakeCancel => 'Annuler';

  @override
  String get wakeCapabilityChecking => 'Vérification de ce PC…';

  @override
  String get wakeCapabilityOkBody =>
      'La vérification n’a trouvé aucun obstacle. Lancez le test de deux minutes pour en être sûr.';

  @override
  String get wakeCapabilityOkTitle => 'Ce PC peut se réveiller seul';

  @override
  String get wakeCapabilityRefresh => 'Vérifier à nouveau';

  @override
  String get wakeCapabilityUnknown => 'Pas encore vérifié.';

  @override
  String get wakeCapabilityWarnTitle =>
      'Ce PC risque de ne pas se réveiller pour une alarme';

  @override
  String get wakeChoiceFixed => 'À une heure fixe';

  @override
  String get wakeChoiceRelative => 'Avant une prière';

  @override
  String get wakeChooseFile => 'Choisir un fichier…';

  @override
  String get wakeCountdownAfterAlarm => 'L’alarme est terminée.';

  @override
  String get wakeCountdownCancel => 'Annuler';

  @override
  String wakeCountdownHibernate(String time) {
    return 'Le PC passera en hibernation dans $time.';
  }

  @override
  String wakeCountdownSleep(String time) {
    return 'Le PC passera en veille dans $time.';
  }

  @override
  String get wakeDelete => 'Supprimer';

  @override
  String get wakeDeleteBody =>
      'L’alarme et sa demande de réveil seront supprimées.';

  @override
  String get wakeDeleteConfirm => 'Supprimer';

  @override
  String get wakeDeleteTitle => 'Supprimer cette alarme ?';

  @override
  String get wakeDismiss => 'Ignorer';

  @override
  String get wakeEdit => 'Modifier';

  @override
  String get wakeEditorTitleAdd => 'Nouvelle alarme';

  @override
  String get wakeEditorTitleEdit => 'Modifier l’alarme';

  @override
  String get wakeEmpty =>
      'Aucune alarme pour le moment. Ajoutez-en une pour réveiller ce PC à l’heure de votre choix.';

  @override
  String get wakeEnabledSwitch => 'Activée';

  @override
  String wakeErrorMinutes(String min, String max) {
    return 'Saisissez un nombre entier de $min à $max.';
  }

  @override
  String get wakeFieldHour => 'Heure';

  @override
  String get wakeFieldLabel => 'Nom (facultatif)';

  @override
  String get wakeFieldMinute => 'Minute';

  @override
  String get wakeFieldMinutesBefore => 'Minutes avant';

  @override
  String get wakeFieldPrayer => 'Prière';

  @override
  String get wakeHibernateNow => 'Hiberner maintenant';

  @override
  String get wakeIssueImportantOnly =>
      'Windows n’autorise que les minuteurs de réveil importants, ce qui n’inclut généralement pas cette application.';

  @override
  String get wakeIssueInProcessTimer =>
      'Le minuteur de secours dans l’application n’a pas pu être créé.';

  @override
  String get wakeIssueModernStandby =>
      'Ce PC utilise la veille moderne, où le réveil à une heure donnée est souvent peu fiable.';

  @override
  String get wakeIssueTaskCreationFailed =>
      'Windows n’a pas autorisé de tâche planifiée de réveil pour votre compte : une alarme ne fonctionne donc que lorsque l’application est active.';

  @override
  String get wakeIssueTimersOffAc =>
      'Windows a désactivé les minuteurs de réveil lorsque le PC est branché sur secteur.';

  @override
  String get wakeIssueTimersOffBattery =>
      'Windows a désactivé les minuteurs de réveil lorsque le PC fonctionne sur batterie.';

  @override
  String get wakeIssueUnknown =>
      'Le paramètre des minuteurs de réveil de Windows n’a pas pu être lu.';

  @override
  String get wakeListSeparator => ', ';

  @override
  String wakeNext(String remaining, String time) {
    return 'Prochaine : $remaining ($time)';
  }

  @override
  String get wakeNextNone => 'Prochaine : —';

  @override
  String wakeNextOtherDay(String remaining, String weekday, String time) {
    return 'Prochaine : $remaining ($weekday $time)';
  }

  @override
  String get wakeOff => 'Désactivée';

  @override
  String get wakeOpenPowerFailed =>
      'Les paramètres d’alimentation n’ont pas pu être ouverts. Ouvrez vous-même Panneau de configuration > Options d’alimentation.';

  @override
  String get wakeOpenPowerOptions =>
      'Ouvrir les paramètres d’alimentation de Windows';

  @override
  String wakePercent(String percent) {
    return '$percent %';
  }

  @override
  String get wakePlaySound => 'Jouer un son';

  @override
  String get wakePowerHint =>
      'Dans Windows : Options d’alimentation > Modifier les paramètres du mode > Modifier les paramètres d’alimentation avancés > Veille > Autoriser les minuteurs de réveil. Cette application ne modifie jamais seule un paramètre d’alimentation.';

  @override
  String get wakePreview => 'Écouter';

  @override
  String get wakePreviewStop => 'Arrêter l’écoute';

  @override
  String get wakeProblemHibernateUnavailable =>
      'L’hibernation n’est pas activée sur ce PC.';

  @override
  String get wakeProblemProbeFailed =>
      'La vérification de ce PC n’a pas pu aboutir.';

  @override
  String get wakeProblemSoundFailed =>
      'Le son de l’alarme n’a pas pu être lu. Vérifiez le fichier audio et les haut-parleurs.';

  @override
  String get wakeProblemSuspendRefused =>
      'Windows n’a pas autorisé la mise en veille du PC.';

  @override
  String get wakeRepeatDaily => 'Tous les jours';

  @override
  String get wakeRepeatOnce => 'Une fois';

  @override
  String get wakeRepeatTitle => 'Répétition';

  @override
  String wakeRepeatWeekdays(String days) {
    return 'Le $days';
  }

  @override
  String get wakeRepeatWeekdaysChoice => 'Jours choisis';

  @override
  String get wakeRinging => 'Une alarme sonne';

  @override
  String get wakeSave => 'Enregistrer';

  @override
  String get wakeSaveFailed =>
      'Ces valeurs n’ont pas pu être enregistrées. Vérifiez l’heure et les jours.';

  @override
  String get wakeSleepHint =>
      'Le PC se met en veille après un compte à rebours de cinq secondes que vous pouvez annuler.';

  @override
  String get wakeSleepNow => 'Mettre en veille maintenant';

  @override
  String get wakeSoundDefault => 'Adhan par défaut';

  @override
  String wakeSoundFile(String name) {
    return 'Fichier : $name';
  }

  @override
  String get wakeSoundTitle => 'Son';

  @override
  String get wakeStop => 'Arrêter';

  @override
  String get wakeSyncError =>
      'La demande de réveil n’a pas pu être enregistrée auprès de Windows ; une alarme risque de ne fonctionner que lorsque l’application est active.';

  @override
  String get wakeTest => 'Tester dans 2 minutes';

  @override
  String get wakeTestCancel => 'Annuler le test';

  @override
  String wakeTestPending(String time) {
    return 'Une alarme de test sonnera à $time. Mettez le PC en veille maintenant pour voir s’il se réveille.';
  }

  @override
  String get wakeTitle => 'Alarmes de réveil';

  @override
  String wakeTriggerAtPrayer(String prayer) {
    return 'À $prayer';
  }

  @override
  String wakeTriggerFixed(String time) {
    return 'À $time';
  }

  @override
  String wakeTriggerRelative(String minutes, String prayer) {
    return '$minutes avant $prayer';
  }

  @override
  String get wakeTriggerTypeTitle => 'Quand';

  @override
  String get wakeUseDefault => 'Utiliser la valeur par défaut';

  @override
  String get wakeVolume => 'Volume';

  @override
  String get wakeWeekdaysError => 'Choisissez au moins un jour.';
}
