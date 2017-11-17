import angular from 'angular';
import _ from 'lodash';

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .factory('publisherService', publisherService)

publisherService.$inject = ['$http']

function publisherService ($http) {
  return {
    getPublisher,
    getPublisherApps,
    getPublisherSdks,
    getSdkCount,
    getSdkCategories,
    tagAsMajorPublisher,
    untagAsMajorPublisher
  };

  function getPublisher (platform, id) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/get_' + platform + '_developer',
      params: { id }
    })
    .then(getPublisherComplete)

    function getPublisherComplete(response) {
      return response.data;
    }
  }

  function getPublisherApps (platform, id, category, order, pageNum) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/get_developer_apps',
      params: { sortBy: category, orderBy: order, pageNum, platform, id }
    })
    .then(getPublisherAppsComplete)

    function getPublisherAppsComplete(response) {
      return response.data;
    }
  }

  function getPublisherSdks (platform, id) {
    return $http({
      method: 'GET',
      url: API_URI_BASE + 'api/' + platform + '_sdks_exist',
      params: { publisherId: id }
    })
    .then(getPublisherSdksComplete)

    function getPublisherSdksComplete(response) {
      return response.data;
    }
  }

  function getSdkCount (sdks) {
    let count = 0
    for (var group in sdks) {
      count += sdks[group].length
    }
    return count
  }

  function getSdkCategories (sdks) {
    const categories = {}
    const categoryNames = Object.keys(sdks).sort()
    const others = _.remove(categoryNames, x => x == "Others")
    if (others.length) { categoryNames.push("Others") }
    categoryNames.forEach(name => categories[name] = true)
    return categories
  }

  function tagAsMajorPublisher (id, platform) {
    return $http({
      method: 'POST',
      url: `${API_URI_BASE}api/admin/major_publishers/tag`,
      params: { id, platform }
    })
    .then(function(response) {
      return response.data;
    })
  }

  function untagAsMajorPublisher (id, platform) {
    return $http({
      method: 'PUT',
      url: `${API_URI_BASE}api/admin/major_publishers/untag`,
      params: { id, platform }
    })
    .then(function(response) {
      return response.data;
    })
  }

}
