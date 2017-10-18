(function() {
  'use strict';

  angular
    .module('appApp')
    .factory('contactService', contactService);

  contactService.$inject = ['$window', '$http'];

  /* @ngInject */
  function contactService($window, $http) {
    var service = {
      exportContactsToCsv,
      getCompanyContacts,
      getContactEmail,
      goToLinkedIn,
      trackCrunchbaseClick
    };

    return service;

    function goToLinkedIn(linkType, company, source) {
      let linkedinLink = "";

      if (linkType == 'company') {
        linkedinLink = `https://www.linkedin.com/search/results/companies/?keywords=${company}&origin=SWITCH_SEARCH_VERTICAL`;
      } else if (linkType == 'linkedin') {
        linkedinLink = `https://www.linkedin.com/${company}`
      }
      else {
        linkedinLink = `https://www.linkedin.com/search/results/people/?keywords=title%3A%20(${linkType})%20AND%20company%3A%20${company}&origin=GLOBAL_SEARCH_HEADER`;
      }

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "LinkedIn Link Clicked", {
          "companyName": company,
          "companyPosition": linkType,
          "Source Type": source
        }
      );
      /* -------- Mixpanel Analytics End -------- */

      $window.open(linkedinLink);
    }

    function getCompanyContacts (platform, publisherId, filter, page) {
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/company/contacts',
        data: {
          platform: platform,
          publisherId: publisherId,
          filter: filter,
          page: page,
          perPage: 10
        }
      })
      .then(function(response) {
        return response.data;
      })
      .catch(function(error) {
        return error;
      })
    }

    function getContactEmail (clearbitId) {
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/company/contact',
        data: { contactId: clearbitId }
      })
      .then(function(data) {
        return response.data;
      })
    }

    function exportContactsToCsv (platform, publisherId, filter, companyName) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "Exported Contacts CSV", {
          'filter': filter,
          'companyName': companyName,
          'publisherId': publisherId,
          'platform': platform
        }
      );
      /* -------- Mixpanel Analytics End -------- */
      return $http({
        method: 'POST',
        url: API_URI_BASE + 'api/contacts/export_to_csv',
        data: {
          platform: platform,
          publisherId: publisherId,
          filter: filter,
          companyName: companyName
        }
      })
      .then(function(response) {
        return response.data;
      })
    }

    function trackCrunchbaseClick (company, source) {
      mixpanel.track(
        "Crunchbase Link Clicked", {
          "Company": company,
          "Source Type": source
        }
      )
    }
  }
})();
