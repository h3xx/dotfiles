// ==UserScript==
// @name           AC-ImAnEngineerDammit
// @namespace      https://ac.g2planet.com/
// @include        https://ac.g2planet.com/*
// ==/UserScript==
// load jquery
/*
var filename = '//code.jquery.com/jquery-1.10.2.min.js';
var fileref = document.createElement('script');
fileref.setAttribute("type","text/javascript");
fileref.setAttribute("src", filename);
document.getElementsByTagName("head")[0].appendChild(fileref);
// */
//document.onLoad = function () {
//  $('#object_time_add_link').live('click', function () {
//    alert('hello world');
//  });
//}
/* attempt 2 : doesn't work
document.onclick = function () {
  
		console.log("I'm an engineer, dammit.");
  window.$('select[name="time\[body\]"]').val('Engineering');

};
// */
// attempt 3 : still wonky, but works
(function () {
  document.onclick = function () {
    var e = document.querySelectorAll('select[name="time\[body\]"]');
    if (e.length && e[0].value === '') {
      e[0].value = 'Engineering';
    }


  
  };
  // remove overlay that unnecessarily prevents clicks
/*
  var e = document.querySelectorAll('.ui-widget-overlay');
  if (e.length) {
    e[0].style.display = 'none';
  }
*/
})();
