import angular from 'angular';
import toastr from 'toastr';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .factory('loggitService', [
    function () {
      toastr.options = {
        closeButton: !0,
        positionClass: 'toast-top-right',
        timeOut: '3000',
      };

      function logIt (message, type) {
        return toastr[type](message);
      }

      return {
        log(message) {
          logIt(message, 'info');
        },
        logWarning(message) {
          logIt(message, 'warning');
        },
        logSuccess(message) {
          logIt(message, 'success');
        },
        logError(message) {
          logIt(message, 'error');
        },
      };
    },
  ])
  .factory('pageTitleService', () => {
    let title = 'MightySignal';
    return {
      title() { return title; },
      setTitle(newTitle) { title = newTitle; },
    };
  })
  .factory('AppPlatform', () => ({ platform: window.APP_PLATFORM }))
  .factory('slacktivity', ['authService', function (authService) {
    return {
      notifySlack(slacktivityData, showMightySignal, channel) {
        showMightySignal = typeof showMightySignal !== 'undefined' ? showMightySignal : false;
        authService.userInfo().success((data) => {
          if (!showMightySignal && data.email.indexOf('mightysignal') > -1) {
            return;
          }
          slacktivityData.email = data.email;
          if (channel) {
            slacktivityData.channel = channel;
          }
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData.channel = '#staging-slacktivity'; } // if on staging server
          window.Slacktivity.send(slacktivityData);
        });
      },
    };
  }]);
