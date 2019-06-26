// ==UserScript==
// @name           JIRA-ImAnEngineerDammit
// @namespace      https://jira.g2planet.com/
// @include        https://jira.g2planet.com/*
// ==/UserScript==

(function () {
  var autoSelectLabel = 'Engineer';
  document.onclick = function () {
    var e = document.querySelectorAll('select#activity');
    if (e.length && e[0].value === '0') {
      var options = e[0].querySelectorAll('option');
      for (var eo of options) {
        if (eo.label === autoSelectLabel) {
          e[0].value = eo.value;
          return;
        }
      }
    }
  };

})();
