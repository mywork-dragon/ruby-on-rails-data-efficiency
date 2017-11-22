import angular from 'angular';
import mixpanel from 'mixpanel-browser';

(function() {
  'use strict';

  angular
    .module('appApp')
    .service('appMixpanelService', appMixpanelService);

  appMixpanelService.$inject = ['$state', '$stateParams', 'contactService'];

  function appMixpanelService($state, $stateParams, contactService) {
    var service = {
      trackAppPageView,
      trackCompanyContactsRequest,
      trackCopiedEmail,
      trackCreativeClick,
      trackCreativeFilterAdded,
      trackCreativePageThrough,
      trackCrunchbaseClick,
      trackEmailRequest,
      trackLinkedinContactClick,
      trackSalesforceModalOpen,
      trackTabClick
    }

    return service;

    function trackAppPageView (app) {
      let eventName;

      if ($stateParams.utm_source == 'ewok') {
        eventName = "Ewok App Page Viewed"
      } else if ($stateParams.utm_source == 'salesforce') {
        eventName = "Salesforce App Page Viewed"
      } else if ($state.is('app.ad-intelligence')){
        eventName = "App Ad Intelligence Tab Viewed"
      } else {
        eventName = "App Page Viewed"
      }

      mixpanel.track(
        eventName, {
          "appId": app.id,
          "appName": app.name,
          "companyName": app.publisher.name,
          "appPlatform": app.platform
        }
      )
    }

    function trackCompanyContactsRequest (filter, app) {
      mixpanel.track(
        "Company Contacts Requested", {
          'companyName': app.publisher.name,
          'requestResultsCount': app.publisher.contactsCount,
          'titleFilter': filter || '',
          'Source Type': 'app'
        }
      );
    }

    function trackCopiedEmail (contact, app) {
      mixpanel.track(
        "Email Copied", {
          "Email": contact.email,
          "Company": app.publisher.name,
          "Name": contact.fullName,
          "Title": contact.title,
          "Source Type": 'publisher'
        }
      )
    }

    function trackCreativeClick (creative) {
      mixpanel.track(
        "Creative Clicked", {
          "type": creative.type,
          "network": creative.ad_network,
          "app_identifier": creative.app_identifier,
          "platform": creative.platform,
          "appId": $stateParams.id
        }
      )
    }

    function trackCreativeFilterAdded (filter) {
      mixpanel.track(
        "Creatives Filtered", {
          "field": filter.field,
          "value": filter.id,
          "platform": $stateParams.platform,
          "appId": $stateParams.id
        }
      )
    }

    function trackCreativePageThrough (page) {
      mixpanel.track(
        "Creatives Paged Through", {
          "pageNum": page,
          "appId": $stateParams.id,
          "platform": $stateParams.platform
        }
      )
    }

    function trackCrunchbaseClick (app) {
      contactService.trackCrunchbaseClick(app.publisher.name, 'app')
    }

    function trackEmailRequest (email, id) {
      mixpanel.track(
        "Contact Email Requested", {
          'email': email,
          'clearbitId': id
        }
      );
    }

    function trackLinkedinContactClick (contact) {
      contactService.trackLinkedinContactClick(contact, 'app')
    }

    function trackSalesforceModalOpen (app) {
      mixpanel.track(
        "Opened Salesforce Export Modal", {
          "appId": app.id,
          "appName": app.name,
          "companyName": app.publisher.name,
          "appPlatform": app.platform
        }
      )
    }

    function trackTabClick (tab, app) {
      mixpanel.track(
        "Tab Clicked", {
          "tab": tab.route.slice(4),
          "page type": 'app',
          "name": app.name,
          "id": app.id,
          "platform": app.platform,
          "appId": $stateParams.id
        }
      )
    }
  }
})();
