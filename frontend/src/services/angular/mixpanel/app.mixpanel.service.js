import angular from 'angular';
import mixpanel from 'mixpanel-browser';

angular
  .module('appApp')
  .service('appMixpanelService', appMixpanelService);

appMixpanelService.$inject = ['$state', '$stateParams', 'contactService'];

function appMixpanelService($state, $stateParams, contactService) {
  const service = {
    trackAppPageView,
    trackCompanyContactsRequest,
    trackCopiedEmail,
    trackCrunchbaseClick,
    trackEmailRequest,
    trackLinkedinContactClick,
    trackSalesforceModalOpen,
    trackTabClick,
  };

  return service;

  function trackAppPageView(app) {
    let eventName;

    if ($stateParams.utm_source === 'ewok') {
      eventName = 'Ewok App Page Viewed';
    } else if ($stateParams.utm_source === 'salesforce') {
      eventName = 'Salesforce App Page Viewed';
    } else if ($state.is('app.ad-intelligence')) {
      eventName = 'App Ad Intelligence Tab Viewed';
    } else {
      eventName = 'App Page Viewed';
    }

    mixpanel.track(eventName, {
      appId: app.id,
      appName: app.name,
      companyName: app.publisher.name,
      appPlatform: app.platform,
    });
  }

  function trackCompanyContactsRequest(filter, app) {
    mixpanel.track('Company Contacts Requested', {
      companyName: app.publisher.name,
      requestResultsCount: app.publisher.contactsCount,
      titleFilter: filter || '',
      'Source Type': 'app',
    });
  }

  function trackCopiedEmail(contact, app) {
    mixpanel.track('Email Copied', {
      Email: contact.email,
      Company: app.publisher.name,
      Name: contact.fullName,
      Title: contact.title,
      'Source Type': 'publisher',
    });
  }

  function trackCrunchbaseClick(app) {
    contactService.trackCrunchbaseClick(app.publisher.name, 'app');
  }

  function trackEmailRequest(email, id) {
    mixpanel.track('Contact Email Requested', {
      email,
      clearbitId: id,
    });
  }

  function trackLinkedinContactClick(contact) {
    contactService.trackLinkedinContactClick(contact, 'app');
  }

  function trackSalesforceModalOpen(app) {
    mixpanel.track('Opened Salesforce Export Modal', {
      appId: app.id,
      appName: app.name,
      companyName: app.publisher.name,
      appPlatform: app.platform,
    });
  }

  function trackTabClick(tab, app) {
    mixpanel.track('Tab Clicked', {
      tab: tab.route.slice(4),
      'page type': 'app',
      name: app.name,
      id: app.id,
      platform: app.platform,
      appId: $stateParams.id,
    });
  }
}
