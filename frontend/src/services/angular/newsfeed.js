import angular from 'angular';
import mixpanel from 'mixpanel-browser';

const API_URI_BASE = window.API_URI_BASE;

angular.module('appApp')
  .factory('newsfeedService', ['$http', 'slacktivity', function($http) {
    return {
      follow(follow) {
        return $http({
          method: 'POST',
          url: `${API_URI_BASE}api/newsfeed/follow`,
          data: { id: follow.id, type: follow.type },
        }).success(() => {
          mixpanel.track(follow.action, {
            'Followed Type': follow.type,
            name: follow.name,
            source: follow.source,
          });
        });
      },
    };
  }])
  .factory('rssService', ['$http', function($http) {
    return {
      fetchRssFeed() {
        return $http({
          method: 'GET',
          url: `${API_URI_BASE}api/blog_feed`,
        });
      },
    };
  }]);
