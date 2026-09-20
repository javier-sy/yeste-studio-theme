/* Cookie consent for Google Analytics.
 *
 * Nothing from Google is loaded until the visitor accepts; a rejection is remembered and never
 * asked again until it expires or the cookie register changes version. The contract of the
 * consent cookie and the checks behind each step are in docs/cookie-consent.md.
 *
 * Expects window.ysConsent = { measurementId: 'G-…', version: <_data/cookies.yml version> },
 * set by head.html only when the site has a measurement ID.
 *
 * Shared with yeste-studio-website through scripts/sync-consent.sh: edit here, then run it.
 */
(function () {
  'use strict';

  var config = window.ysConsent;
  if (!config || !config.measurementId) return;

  var COOKIE = 'ys_consent';
  var MAX_AGE = 730 * 24 * 60 * 60; // 24 months, the most the AEPD guide allows
  var SHARED_DOMAIN = 'yeste.studio';
  var GRANTED = 'granted', DENIED = 'denied';

  var id = config.measurementId;
  var version = String(config.version);
  var host = document.location.hostname;
  var sharedHost = host === SHARED_DOMAIN || host.slice(-(SHARED_DOMAIN.length + 1)) === '.' + SHARED_DOMAIN;
  var analyticsLoaded = false;

  // --- consent cookie -----------------------------------------------------------------------

  function readChoice() {
    var match = document.cookie.match(new RegExp('(?:^|; )' + COOKIE + '=([^;]*)'));
    if (!match) return null;
    var parts = match[1].split(':');
    if (parts[0] !== version) return null; // an older register: ask again
    return parts[1] === GRANTED || parts[1] === DENIED ? parts[1] : null;
  }

  function writeChoice(decision) {
    var cookie = COOKIE + '=' + version + ':' + decision + '; Max-Age=' + MAX_AGE + '; path=/; SameSite=Lax';
    if (sharedHost) cookie += '; domain=.' + SHARED_DOMAIN;
    if (document.location.protocol === 'https:') cookie += '; Secure';
    document.cookie = cookie;
  }

  // Deleting a cookie needs the same domain it was set with; Google sets its own on the top
  // domain and we may be previewing on a bare host, so try both.
  function deleteCookie(name) {
    var expired = name + '=; Max-Age=0; path=/';
    document.cookie = expired;
    if (sharedHost) document.cookie = expired + '; domain=.' + SHARED_DOMAIN;
  }

  // --- Google Analytics -----------------------------------------------------------------------

  function gtag() { window.dataLayer.push(arguments); }

  function enableAnalytics() {
    window['ga-disable-' + id] = false;
    if (analyticsLoaded) {
      gtag('consent', 'update', { analytics_storage: GRANTED });
      return;
    }
    analyticsLoaded = true;
    window.dataLayer = window.dataLayer || [];
    window.gtag = gtag;
    // Consent Mode: declare everything denied, then grant only analytics, before any config.
    gtag('consent', 'default', {
      ad_storage: DENIED, ad_user_data: DENIED, ad_personalization: DENIED, analytics_storage: DENIED
    });
    gtag('consent', 'update', { analytics_storage: GRANTED });
    gtag('js', new Date());
    gtag('config', id);
    var script = document.createElement('script');
    script.async = true;
    script.src = 'https://www.googletagmanager.com/gtag/js?id=' + encodeURIComponent(id);
    document.head.appendChild(script);
  }

  function disableAnalytics() {
    window['ga-disable-' + id] = true;
    if (analyticsLoaded) gtag('consent', 'update', { analytics_storage: DENIED });
    deleteCookie('_ga');
    deleteCookie('_ga_' + id.replace(/^G-/, ''));
  }

  // --- banner -------------------------------------------------------------------------------

  var banner = document.getElementById('cookie-consent');

  function showBanner() { if (banner) banner.hidden = false; }
  function hideBanner() { if (banner) banner.hidden = true; }

  function decide(decision) {
    writeChoice(decision);
    hideBanner();
    if (decision === GRANTED) enableAnalytics(); else disableAnalytics();
  }

  if (banner) {
    var buttons = banner.querySelectorAll('[data-consent]');
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].addEventListener('click', function () { decide(this.getAttribute('data-consent')); });
    }
  }

  var openers = document.querySelectorAll('.cookie-consent__open');
  for (var j = 0; j < openers.length; j++) {
    openers[j].addEventListener('click', function (event) { event.preventDefault(); showBanner(); });
  }

  // --- on load ------------------------------------------------------------------------------

  var choice = readChoice();
  if (choice === GRANTED) enableAnalytics();
  else if (choice === null) showBanner();
})();
