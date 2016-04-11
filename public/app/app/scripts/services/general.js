'use strict';

angular.module("appApp")
  .factory("loggitService", [
    function() {
      var logIt;
      return toastr.options = {
        closeButton: !0,
        positionClass: "toast-top-right",
        timeOut: "3000"
      }, logIt = function(message, type) {
        return toastr[type](message);
      }, {
        log: function(message) {
          logIt(message, "info");
        },
        logWarning: function(message) {
          logIt(message, "warning");
        },
        logSuccess: function(message) {
          logIt(message, "success");
        },
        logError: function(message) {
          logIt(message, "error");
        }
      };
    }
  ])
  .factory('pageTitleService', function() {
    var title = 'MightySignal';
    return {
      title: function() { return title; },
      setTitle: function(newTitle) { title = newTitle }
    };
  })
  .factory('AppPlatform', function() {
    return {platform: APP_PLATFORM};
  })
  .factory('slacktivity', ["authService", function(authService) {
    return {
      notifySlack: function(slacktivityData, showMightySignal) {
        showMightySignal = typeof showMightySignal !== 'undefined' ? showMightySignal : false;
        authService.userInfo().success(function(data) {
          if (!showMightySignal && data.email.indexOf('mightysignal') > -1) {
            return;
          }  
          slacktivityData.email = data.email;
          if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
          window.Slacktivity.send(slacktivityData);
        });
      }
    }
  }]);
