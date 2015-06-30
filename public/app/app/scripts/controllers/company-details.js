'use strict';

angular.module('appApp').controller("CompanyDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "$rootScope",
  function($scope, $http, $routeParams, $window, pageTitleService, $rootScope) {
    $scope.load = function() {

      $scope.queryInProgress = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_company',
        params: {id: $routeParams.id}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        $scope.companyData = data;
        var companyApps = data.iosApps.concat(data.androidApps);
        $scope.apps = companyApps;
        $scope.numApps = companyApps.length;
        $rootScope.numApps = companyApps.length;
        $scope.queryInProgress = false;
        /* Sets html title attribute */
      }).error(function() {
        $scope.queryInProgress = false;
      });
    };

    /* LinkedIn Link Button Logic */
    $scope.onLinkedinButtonClick = function(linkedinLinkType) {
      var linkedinLink = "";

      if (linkedinLinkType == 'company') {
        linkedinLink = "https://www.linkedin.com/vsearch/c?keywords=" + encodeURI($scope.companyData.name);
      } else {
        linkedinLink = "https://www.linkedin.com/vsearch/p?keywords=" + linkedinLinkType + "&company=" + encodeURI($scope.companyData.name);
      }

      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "LinkedIn Link Clicked", {
          "companyName": $scope.companyData.name,
          "companyPosition": linkedinLinkType
        }
      );
      /* -------- Mixpanel Analytics End -------- */

      $window.open(linkedinLink, '_blank');
    };

    $scope.load();

    /* -------- Mixpanel Analytics Start -------- */
    mixpanel.track(
      "Page Viewed", {
        "pageType": "Company",
        "companyid": $routeParams.id,
        "appPlatform": APP_PLATFORM
      }
    );
    /* -------- Mixpanel Analytics End -------- */
  }
]);
