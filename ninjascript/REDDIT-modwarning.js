// ==UserScript==
// @name			REDDIT-modwarning
// @namespace		reddit
// @include			http://www.reddit.com/r/*/comments/*
// @include			https://www.reddit.com/r/*/comments/*
// @require			https://code.jquery.com/jquery-2.2.4.min.js
// @version			0.02
// ==/UserScript==
(function () {

	var button_defs = [
		{
			buttonText: 'Rule 4',
			message: function (vars) {
				return "/u/" + vars.OP + ": Hello. Your post has been removed for breaking " +
					"Rule 4. You have previously broken our rules here:\n\n\n\n" +
					"In line with our 'three strikes' policy, if you break any of our rules again you will be permanently banned from our subreddit.";
			}
		},
		{
			buttonText: 'Rule 6',
			message: function (vars) {
				return "/u/" + vars.OP + ": Hello. Your post has been removed for breaking " +
					"[Rule 6](http://www.reddit.com/r/mildlyinteresting/comments/21p15y/rule_6_for_dummies/). You have previously broken our rules here:\n\n\n\n" +
					"In line with our 'three strikes' policy, if you break any of our rules again you will be permanently banned from our subreddit.";
			}
		},
		{
			buttonText: 'Resub',
			message: function (vars) {
				return "OP, your title breaks Rule 6. Since it was caught early, "+
					"you can resubmit with a better title. See [Rule 6 for dummies]"+
					"(http://www.reddit.com/r/mildlyinteresting/comments/21p15y/rule_6_for_dummies/) "+
					"for explanation.\n\n"+
					"Titles must not contain backstory, fluff or other unnecessary information. "+
					"A better title, e.g.:\n\n"+
					"> \n\n"+
					"If you're not sure if your title will break rule 6, feel free to [message the "+
					"mods](http://www.reddit.com/message/compose?to=%2Fr%2Fmildlyinteresting) "+
					"and we'll help answer your questions.";
			}
		}
	];

	function loadjquery(tgtWindow, callback) {
		var script = tgtWindow.document.createElement('script');
		script.src = '//jquery.com/src/jquery-latest.js';
		script.type = 'text/javascript';
		script.addEventListener("load", function() {
			tgtWindow.jQuery.noConflict();
			callback(tgtWindow.jQuery);
		}, false);
		tgtWindow.document.getElementsByTagName('head')[0].appendChild(script);
	}

	function addModButton(buttonText, message) {
		var $modbutton = $('<div>').text(buttonText);
		$modbutton.css({
			'float': 'left',
			'border': '1px solid black',
			'background-color': 'white',
			'margin': '5px 5px 10px 0',
			'padding': '4px',
			'cursor': 'pointer'
		});
		$modbutton.on('click', function () {
			if (typeof message === 'function') {
				var vars = {
					'OP': $('.entry .tagline .author').first().text()
				};
				message = message(vars);
			}
			$('textarea[name=text]').first().val(message);
		});
		$('.usertext-edit').append($modbutton);
	}

	$(function () {
		$(button_defs).each(function () {
			addModButton(this.buttonText, this.message);
		});
	});

})();
