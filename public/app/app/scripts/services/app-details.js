'use strict';

angular.module("appApp")
  .service("appDataService", [
    function() {
      var appDataService = this;
      appDataService.displayStatus = {appId: -1, status: ""};
    }
  ])
  .factory("contactService", ["$window", function($window) {
    return {
      getLink: function(linkType, company, source) {
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
      },
      trackLinkedinContactClick: function (contact, source) {
        mixpanel.track(
          "LinkedIn Contact Clicked", {
            "Name": contact.fullName,
            "Title": contact.title,
            "LinkedIn": contact.linkedin,
            "Source Type": source
          }
        )
      },
      trackCrunchbaseClick: function (company, source) {
        mixpanel.track(
          "Crunchbase Link Clicked", {
            "Company": company,
            "Source Type": source
          }
        )
      }
    }
  }]);
