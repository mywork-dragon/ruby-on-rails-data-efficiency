'use strict';

angular.module("appApp")
  .service("appDataService", [
    function() {
      var appDataService = this;
      appDataService.displayStatus = {appId: -1, status: ""};
    }
  ])
  .factory("linkedInService", ["$window", function($window) {
    return {
      getLink: function(linkType, company) {
        let linkedinLink = "";

        if (linkType == 'company') {
          linkedinLink = `https://www.linkedin.com/search/results/companies/?keywords=${company}&origin=SWITCH_SEARCH_VERTICAL`;
        } else {
          linkedinLink = `https://www.linkedin.com/search/results/people/?keywords=title%3A%20(${linkType})%20AND%20company%3A%20${company}&origin=GLOBAL_SEARCH_HEADER`;
        }

        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "LinkedIn Link Clicked", {
            "companyName": company,
            "companyPosition": linkType
          }
        );
        /* -------- Mixpanel Analytics End -------- */

        $window.open(linkedinLink);
      },
      trackLinkedinContactClick: function (contact) {
        mixpanel.track(
          "LinkedIn Contact Clicked", {
            "Name": contact.fullName,
            "Title": contact.title,
            "LinkedIn": contact.linkedin
          }
        )
      }
    }
  }]);
