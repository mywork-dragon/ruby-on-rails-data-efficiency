import angular from 'angular'
import _ from 'lodash'

angular
  .module('appApp')
  .factory('publisherUtils', publisherUtils);

publisherUtils.$inject = [];

function publisherUtils() {
  var service = {
    formatAdData
  };

  return service;

  function formatAdData (data) {
    const result = {
      number_of_creatives: 0,
      creative_formats: [],
      ad_networks: []
    }
    Object.values(data).forEach(app => {
      result.number_of_creatives += app.number_of_creatives
      result.creative_formats = _.union(result.creative_formats, app.creative_formats)
      result.first_seen_ads_date = getMinDate(result.first_seen_ads_date, app.first_seen_ads_date)
      result.last_seen_ads_date = getMaxDate(result.last_seen_ads_date, app.last_seen_ads_date)
      app.ad_networks.forEach(network => {
        const existingNetwork = result.ad_networks.find(x => x.id === network.id)
        if (existingNetwork) {
          existingNetwork.first_seen_ads_date = getMinDate(existingNetwork.first_seen_ads_date, network.first_seen_ads_date)
          existingNetwork.last_seen_ads_date = getMaxDate(existingNetwork.last_seen_ads_date, network.last_seen_ads_date)
          existingNetwork.number_of_creatives += network.number_of_creatives
          existingNetwork.creative_formats = _.union(existingNetwork.creative_formats, network.creative_formats)
        } else {
          result.ad_networks.push(network)
        }
      })
    })

    return result
  }

  function getMaxDate (date1, date2) {
    date1 = new Date(date1)
    date2 = new Date(date2)
    return date1 >= date2 ? date1 : date2
  }

  function getMinDate (date1, date2) {
    date1 = new Date(date1)
    date2 = new Date(date2)
    return date1 <= date2 ? date1 : date2
  }
}
