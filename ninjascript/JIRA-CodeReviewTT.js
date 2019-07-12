// ==UserScript==
// @name           JIRA-CodeReviewTT
// @namespace      https://jira.g2planet.com/
// @include        https://jira.g2planet.com/*
// ==/UserScript==

(function () {
  var formSelector = 'form#ictime-create-worklog-form';
  var time = '0.15h';
  var desc = 'Code review';
  var buttonHandler = function () {
    // set time
    var timeInput = document.querySelectorAll(`${formSelector} input#log-work-time-logged`);
    if (timeInput.length && timeInput[0].value === '') {
      timeInput[0].value = time;
    }
    // set to not subtract from estimate
    var leaveInput = document.querySelectorAll(`${formSelector} input#log-work-adjust-estimate-leave`);
    if (leaveInput.length) {
      leaveInput[0].checked = true;
    }
    // set comment
    var commentInput = document.querySelectorAll(`${formSelector} textarea#comment`);
    if (leaveInput.length) {
      commentInput[0].value = desc;
    }
  };
  var button = document.createElement('input');
  button.setAttribute('type', 'button');
  button.value = desc;
  button.onclick = buttonHandler;

  var cf = function () {
    // add button to top of form
    var fsElement = document.querySelectorAll(`${formSelector} fieldset:not(.group)`);
    if (fsElement.length) {
      fsElement[0].insertBefore(button, fsElement[0].firstChild)
    }
  };
  // add to onclick handlers
  if (document.onclick) {
     var ocf = document.onclick;
     var ncf = cf;
     cf = function () {
       ocf();
       ncf();
     };
  }
  document.onclick = cf;
})();
