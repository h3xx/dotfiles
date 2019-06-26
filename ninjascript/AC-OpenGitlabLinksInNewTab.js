// ==UserScript==
// @name           AC-OpenGitlabLinksInNewTab
// @namespace      https://ac.g2planet.com/
// @include        https://ac.g2planet.com/*
// ==/UserScript==
(function () {

  var dostuff = function () {
    var e = document.querySelectorAll('a[href^="https://git.g2planet.com/"]');
    for (var i in e) {
        var elem = e[i];
        e.target = '_blank';
    }
  };
  document.addEventListener('click', dostuff, false);
})();
