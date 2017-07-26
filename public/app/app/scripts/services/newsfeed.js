'use strict';

angular.module("appApp")
  .factory("newsfeedService", ["$http", "slacktivity", function($http, slacktivity) {
    return {
      follow: function(follow) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/newsfeed/follow',
          data: {id: follow.id, type: follow.type}
        }).success(function(data) {
          mixpanel.track(
            follow.action, {
              "Followed Type": follow.type,
              name: follow.name,
              source: follow.source
            }
          );
        });
      }
    }
  }])
  .factory("rssService", ["$http", function($http) {
    return {
      fetchRssFeed: function() {
        return $http({
          method: 'GET',
          url: API_URI_BASE + 'api/blog_feed',
        });
      }
    }
  }]);
