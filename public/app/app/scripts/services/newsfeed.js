'use strict';

angular.module("appApp")
  .factory("newsfeedService", ["$http", "slacktivity", function($http, slacktivity) {
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

          mixpanel.track(
            action, {
              type: type,
              name: name
            }
          );
        });
      }
    }
  }]);
