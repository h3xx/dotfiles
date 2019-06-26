// ==UserScript==
// @name           AC-keybindings
// @namespace      https://ac.g2planet.com/
// @include        https://ac.g2planet.com/*
// ==/UserScript==
(function () {
	var okp = document.onkeypress;
	document.onkeypress = function (e) {
		switch (e.which) {
		case 'a':
			// add ticket
			var parts = window.location.href.match(/(?:[^\/]*\/){5}/);
			if (parts) {
				window.location.href = parts[0] + "tickets/add";
			}
			break;
		}
		if (okp) return okp();
	};
})();
