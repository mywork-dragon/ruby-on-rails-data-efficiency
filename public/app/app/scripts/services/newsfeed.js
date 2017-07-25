'use strict';

angular.module("appApp")
  .factory("newsfeedService", ["$http", "slacktivity", function($http, slacktivity) {
    return {
      follow: function(follow, source) {
        return $http({
          method: 'POST',
          url: API_URI_BASE + 'api/newsfeed/follow',
          data: {id: follow.id, type: follow.type}
        }).success(function(data) {
          mixpanel.track(
            source, {
              "Followed Type": follow.type,
              name: follow.name,
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
