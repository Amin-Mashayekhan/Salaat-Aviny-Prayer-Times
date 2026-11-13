(function () {
  'use strict';

  var REPO = 'Amin-Mashayekhan/Salaat-Aviny-Prayer-Times';
  var DOWNLOAD = 'https://github.com/' + REPO + '/releases/latest/download/';
  var LANGS = ['fa', 'en', 'ar'];
  var RTL = { fa: true, ar: true, en: false };

  // Screenshots shown for each language: [file, caption key].
  var GALLERY = {
    en: [['home-en', 'cap.home'], ['qibla-street-en', 'cap.qibla'], ['qibla-satellite-en', 'cap.sat'],
         ['timetable-en', 'cap.timetable'], ['settings-en', 'cap.settings'], ['home-en-dark', 'cap.dark']],
    fa: [['home-fa', 'cap.home'], ['qibla-fa', 'cap.qibla'], ['timetable-fa', 'cap.timetable'],
         ['settings-fa', 'cap.settings'], ['qibla-satellite-en', 'cap.sat']],
    ar: [['home-ar', 'cap.home'], ['qibla-ar', 'cap.sat'], ['timetable-ar', 'cap.timetable'],
         ['settings-ar', 'cap.settings'], ['qibla-street-en', 'cap.qibla']]
  };
  var HERO = { en: 'home-en', fa: 'home-fa', ar: 'home-ar' };

  function safeGet(key) {
    try { return window.localStorage.getItem(key); } catch (e) { return null; }
  }
  function safeSet(key, value) {
    try { window.localStorage.setItem(key, value); } catch (e) { /* private mode */ }
  }

  function detectLanguage() {
    var saved = safeGet('salaat-site-lang');
    if (saved && LANGS.indexOf(saved) >= 0) return saved;
    var list = navigator.languages && navigator.languages.length ? navigator.languages : [navigator.language || 'en'];
    for (var i = 0; i < list.length; i++) {
      var code = String(list[i]).toLowerCase().slice(0, 2);
      if (LANGS.indexOf(code) >= 0) return code;
    }
    return 'en';
  }

  function detectOs() {
    var ua = (navigator.userAgentData && navigator.userAgentData.platform) || navigator.platform || '';
    var agent = navigator.userAgent || '';
    var text = (ua + ' ' + agent).toLowerCase();
    if (/android/.test(text)) return 'android';
    if (/iphone|ipad|ipod/.test(text)) return 'ios';
    if (/win/.test(text)) return 'windows';
    if (/mac/.test(text)) return 'mac';
    if (/linux|x11|cros/.test(text)) return 'linux';
    return 'other';
  }

  var lang = detectLanguage();
  var os = detectOs();

  function t(key) {
    var table = window.STRINGS[lang] || window.STRINGS.en;
    return table[key] !== undefined ? table[key] : window.STRINGS.en[key] || key;
  }

  function renderGallery() {
    var box = document.getElementById('gallery');
    box.innerHTML = '';
    GALLERY[lang].forEach(function (entry) {
      var figure = document.createElement('figure');
      figure.className = 'shot';
      var link = document.createElement('a');
      link.href = 'img/' + entry[0] + '.png';
      link.target = '_blank';
      link.rel = 'noopener';
      var img = document.createElement('img');
      img.src = 'img/' + entry[0] + '.png';
      img.loading = 'lazy';
      img.width = 1184;
      img.height = 792;
      img.alt = t(entry[1]);
      link.appendChild(img);
      var caption = document.createElement('figcaption');
      caption.textContent = t(entry[1]);
      figure.appendChild(link);
      figure.appendChild(caption);
      box.appendChild(figure);
    });
  }

  function apply() {
    document.documentElement.lang = lang;
    document.documentElement.dir = RTL[lang] ? 'rtl' : 'ltr';
    var nodes = document.querySelectorAll('[data-i18n],[data-i18n-html]');
    for (var i = 0; i < nodes.length; i++) {
      var key = nodes[i].getAttribute('data-i18n') || nodes[i].getAttribute('data-i18n-html');
      nodes[i].innerHTML = t(key);
    }
    var buttons = document.querySelectorAll('.langs button');
    for (var j = 0; j < buttons.length; j++) {
      buttons[j].setAttribute('aria-pressed', buttons[j].getAttribute('data-lang') === lang ? 'true' : 'false');
    }
    document.getElementById('hero-image').src = 'img/' + HERO[lang] + '.png';
    document.getElementById('hero-image').alt = t('cap.home');
    renderGallery();
    showVersion(window.__latest || null);
  }

  function wireDownloads() {
    var links = document.querySelectorAll('[data-asset]');
    for (var i = 0; i < links.length; i++) {
      links[i].href = DOWNLOAD + links[i].getAttribute('data-asset');
    }
    var main = document.getElementById('main-download');
    var rows = document.querySelectorAll('tbody tr');
    for (var r = 0; r < rows.length; r++) {
      if (rows[r].className.indexOf('os-' + os) >= 0) rows[r].className += ' me';
    }
    if (os === 'windows') {
      main.href = DOWNLOAD + 'Salaat-Setup.exe';
    } else {
      main.href = '#download';
      document.getElementById('os-note').hidden = false;
    }
  }

  function showVersion(release) {
    var line = document.getElementById('version-line');
    if (!release) {
      line.textContent = t('ver.none');
      return;
    }
    line.textContent = t('ver.latest') + ': ' + release.tag_name;
  }

  // Rows whose file is not in the latest release say "not available yet"
  // instead of offering a link that would fail.
  function markMissing(release) {
    var names = (release.assets || []).map(function (a) { return a.name; });
    var rows = document.querySelectorAll('tr[data-needs]');
    for (var i = 0; i < rows.length; i++) {
      var missing = names.indexOf(rows[i].getAttribute('data-needs')) < 0;
      rows[i].classList.toggle('missing', missing);
    }
  }

  function loadVersion() {
    if (!window.fetch) return;
    fetch('https://api.github.com/repos/' + REPO + '/releases/latest', { headers: { Accept: 'application/vnd.github+json' } })
      .then(function (response) { return response.ok ? response.json() : null; })
      .then(function (release) {
        if (release && release.tag_name) {
          window.__latest = release;
          showVersion(release);
          markMissing(release);
        }
      })
      .catch(function () { /* offline or rate limited: keep the default line */ });
  }

  document.querySelector('.langs').addEventListener('click', function (event) {
    var button = event.target.closest('button[data-lang]');
    if (!button) return;
    lang = button.getAttribute('data-lang');
    safeSet('salaat-site-lang', lang);
    apply();
  });

  wireDownloads();
  apply();
  loadVersion();
})();
