import angular from 'angular'
import mixpanel from 'mixpanel-browser';

angular
  .module('appApp')
  .service('publisherMixpanelService', publisherMixpanelService);

publisherMixpanelService.$inject = ['contactService', '$state', '$stateParams'];

function publisherMixpanelService(contactService, $state, $stateParams) {
  var service = {
    trackAppClick,
    trackCompanyContactsRequest,
    trackCopiedEmail,
    trackCrunchbaseClick,
    trackPublisherPageView,
    trackTabClick
  }

  return service;

  function trackAppClick (app, publisherName, tab) {
    mixpanel.track(
      "App on Company Page Clicked", {
        "companyName": publisherName,
        "appName": app.name,
        "appId": app.id,
        "appPlatform": app.type,
        "tab": tab
      }
    );
  }

  function trackCompanyContactsRequest (filter, publisher) {
    mixpanel.track(
      "Company Contacts Requested", {
        'companyName': publisher.name,
        'requestResultsCount': publisher.contactsCount,
        'titleFilter': filter || '',
        'Source Type': 'publisher'
      }
    );
  }

  function trackCopiedEmail (contact, publisherName) {
    mixpanel.track("Email Copied", {
      "Email": contact.email,
      "Company": publisherName,
      "Name": contact.fullName,
      "Title": contact.title,
      "Source Type": 'publisher'
    })
  }

  function trackCrunchbaseClick (publisherName) {
    contactService.trackCrunchbaseClick(publisherName, 'publisher')
  }

  // function trackLinkedinContactClick (contact) {
  //   contactService.trackLinkedinContactClick(contact, 'publisher')
  // }

  function trackPublisherPageView (publisher) {
    let eventName = 'Publisher Page Viewed'
    if ($stateParams.utm_source === 'salesforce') {
      eventName = 'Salesforce Publisher Page Viewed'
    } else if ($state.is('publisher.ad-intelligence')) {
      eventName = 'Publisher Ad Intelligence Tab Viewed'
    }

    mixpanel.track(eventName, {
      "publisherId": publisher.id,
      "appPlatform": publisher.platform,
      "publisherName": publisher.name
    })
  }

  function trackTabClick (tab, publisher) {
    mixpanel.track(
      "Tab Clicked", {
        "tab": tab.route.slice(10),
        "page type": 'publisher',
        "name": publisher.name,
        "id": $stateParams.id,
        "platform": publisher.platform,
        "publisherId": $stateParams.id
      }
    )
  }
}
