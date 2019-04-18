import angular from 'angular';
import mixpanel from 'mixpanel-browser';

const API_URI_BASE = window.API_URI_BASE;

angular
  .module('appApp')
  .factory('contactService', contactService);

contactService.$inject = ['$window', '$http'];

/* @ngInject */
function contactService($window, $http) {
  const service = {
    exportContactsToCsv,
    getCompanyContacts,
    getContactEmail,
    goToLinkedIn,
    trackCrunchbaseClick,
    trackLinkedinContactClick,
    exportContactsToCsvByPublishers,
    exportContactsToCsvByPublishersStatus,
  };

  return service;

  function goToLinkedIn(linkType, company, source) {
    let linkedinLink = '';

    if (linkType === 'company') {
      linkedinLink = `https://www.linkedin.com/search/results/companies/?keywords=${company}&origin=SWITCH_SEARCH_VERTICAL`;
    } else {
      linkedinLink = `https://www.linkedin.com/search/results/people/?keywords=title%3A%20(${linkType})%20AND%20company%3A%20${company}&origin=GLOBAL_SEARCH_HEADER`;
    }

    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track('LinkedIn Link Clicked', {
      companyName: company,
      companyPosition: linkType,
      'Source Type': source,
    });
    /* -------- Mixpanel Analytics End -------- */

    $window.open(linkedinLink);
  }

  function getCompanyContacts(platform, publisherId, filter, page) {
    return $http({
      method: 'POST',
      url: `${API_URI_BASE}api/company/contacts`,
      data: {
        platform,
        publisherId,
        filter,
        page,
        perPage: 10,
      },
    })
      .then(response => response.data);
  }

  function getContactEmail(clearbitId) {
    return $http({
      method: 'POST',
      url: `${API_URI_BASE}api/company/contact`,
      data: { contactId: clearbitId },
    })
      .then(response => response.data);
  }

  function exportContactsToCsv(platform, publisherId, filter, companyName) {
    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track('Exported Contacts CSV', {
      filter,
      companyName,
      publisherId,
      platform,
    });
    /* -------- Mixpanel Analytics End -------- */
    return $http({
      method: 'POST',
      url: `${API_URI_BASE}api/contacts/export_to_csv`,
      data: {
        platform,
        publisherId,
        filter,
        companyName,
      },
    })
      .then(response => response.data);
  }

  function trackCrunchbaseClick(company, source) {
    mixpanel.track('Crunchbase Link Clicked', {
      Company: company,
      'Source Type': source,
    });
  }

  function trackLinkedinContactClick(contact, source) {
    mixpanel.track('LinkedIn Contact Clicked', {
      email: contact.email,
      name: contact.fullName,
      linkedIn: contact.linkedIn,
      'Source Type': source,
    });
  }
}
