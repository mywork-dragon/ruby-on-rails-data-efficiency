'use strict';

angular.module("appApp")
  .factory("newsfeedService", ["$http", 'authService', function($http, authService) {
    return {
      follow: function(id, type, name) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/newsfeed/follow',
          data: {id: id, type: type}
        }).success(function(data) {
          var action = data.following ? 'Followed' : 'Unfollowed'
          
          var platform = 'ios'
          var class_name = 'app'
          
          if (type == 'AndroidSdk' || type == 'AndroidApp') {
            platform = 'android'
          }
          if (type == 'AndroidSdk' || type == 'IosSdk') {
            class_name = 'sdk'
          }
          
          authService.userInfo().success(function(data) {   
            mixpanel.track(
              action, {
                type: type,
                name: name
              }
            );
            /* -------- Mixpanel Analytics End -------- */
            /* -------- Slacktivity Alerts -------- */
            var slacktivityData = {
              "title": action,
              "fallback": action,
              "color": "#45825A",
              'type': type,
              'name': name,
              'url': "http://mightysignal.com/app/app#/" + class_name + '/' + platform + '/' + id,
              'email': data.email
            };
            if (API_URI_BASE.indexOf('mightysignal.com') < 0) { slacktivityData['channel'] = '#staging-slacktivity' } // if on staging server
            window.Slacktivity.send(slacktivityData);
          });
        });
      }
    }
  }]);
