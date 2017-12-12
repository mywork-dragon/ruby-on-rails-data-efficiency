import angular from 'angular'
import _ from 'lodash'

angular
  .module('appApp')
  .service('appUtils', appUtils);

appUtils.$inject = [];

function appUtils() {
  return {
    filterUnavailableCountries,
    formatRatings
  }

  function filterUnavailableCountries(list, countries) {
    const countryCodes = countries.map(country => country.country_code)
    return list.filter(item => countryCodes.includes(item.country_code))
  }

  function formatRatings (ratings) {
    if (ratings.length) {
      const maxRating = _.max(ratings, rating => rating.ratings_count)
      maxRating.count = maxRating.ratings_count
      return maxRating
    }
  }
}
