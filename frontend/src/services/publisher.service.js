import angular from 'angular';
import _ from 'lodash';

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .factory('publisherService', publisherService);

publisherService.$inject = ['$http'];

function publisherService ($http) {
  return {
    getAdIntelData,
    getPublisher,
    getPublisherApps,
    getPublisherCreatives,
    getPublisherSdks,
    getSdkCount,
    getSdkCategories,
    tagAsMajorPublisher,
    untagAsMajorPublisher,
  };

  function getAdIntelData (platform, id) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/ad_intelligence/v2/publisher_summary.json`,
      params: { publisher_id: id, platform },
    });
  }

  function getPublisher (platform, id) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/get_${platform}_developer`,
      params: { id },
    })
    .then(response => response.data)
  }

  function getPublisherApps (platform, id, category, order, pageNum) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/get_developer_apps`,
      params: {
        sortBy: category, orderBy: order, pageNum, platform, id,
      },
    })
      .then(response => response.data);
  }

  function getPublisherCreatives (platform, id, pageNum, pageSize, networks, formats) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/ad_intelligence/v2/publisher_creatives.json`,
      params: {
        platform,
        publisher_id: id,
        pageNum,
        pageSize,
        sourceIds: JSON.stringify(networks),
        formats: JSON.stringify(formats),
      },
    })
      .then(response => response.data);
  }

  function getPublisherSdks (platform, id) {
    return $http({
      method: 'GET',
      url: `${API_URI_BASE}api/${platform}_sdks_exist`,
      params: { publisherId: id },
    })
      .then(response => response.data);
  }

  function getSdkCount (sdks) {
    let count = 0;
    for (const group in sdks) {
      if (Object.prototype.hasOwnProperty.call(sdks, group)) {
        count += sdks[group].length;
      }
    }
    return count;
  }

  function getSdkCategories (sdks) {
    const categories = {};
    const categoryNames = Object.keys(sdks).sort();
    const others = _.remove(categoryNames, x => x === 'Others');
    if (others.length) { categoryNames.push('Others'); }
    categoryNames.forEach(name => categories[name] = true);
    return categories;
  }

  function tagAsMajorPublisher (id, platform) {
    return $http({
      method: 'POST',
      url: `${API_URI_BASE}api/admin/major_publishers/tag`,
      params: { id, platform },
    })
      .then(response => response.data);
  }

  function untagAsMajorPublisher (id, platform) {
    return $http({
      method: 'PUT',
      url: `${API_URI_BASE}api/admin/major_publishers/untag`,
      params: { id, platform },
    })
      .then(response => response.data);
  }
}
