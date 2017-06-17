'use strict';

angular.module('appApp').controller("PublisherDetailsCtrl", ["$scope", "$http", "$routeParams", "$window", "pageTitleService", "$rootScope", "apiService", "listApiService", "loggitService", "authService", "searchService", "uniqueStringsFilter", "linkedInService",
  function($scope, $http, $routeParams, $window, pageTitleService, $rootScope, apiService, listApiService, loggitService, authService, searchService, uniqueStringsFilter, linkedInService) {

    var publisherDetailsCtrl = this;
    $scope.appPlatform = $routeParams.platform
    $scope.initialPageLoadComplete = false; // shows page load spinner
    $scope.currentPage = 1;
    $scope.currentContactsPage = 1;
    $scope.contactsPerPage = 10;

    $scope.loadPublisher = function(category, order) {
      publisherDetailsCtrl.queryInProgress = true;

      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_' + $scope.appPlatform + '_developer',
        params: {id: $routeParams.id, sortBy: category, orderBy: order, pageNum: $scope.currentPage}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        $scope.publisherData = data;
        $scope.apps = data.apps;
        $scope.numApps = data.numApps;
        if ($scope.numApps > 0 && $scope.publisherData.websites && $scope.apps[0].supportDesk) {
          $scope.publisherData.websites.push($scope.apps[0].supportDesk)
        }
        $scope.publisherData.websites = uniqueStringsFilter($scope.publisherData.websites)
        $rootScope.numApps = data.numApps;
        publisherDetailsCtrl.queryInProgress = false;

        $scope.initialPageLoadComplete = true; // hides page load spinner

        /* Sets html title attribute */

        mixpanel.track(
          "Publisher Page Viewed", {
            "publisherId": $routeParams.id,
            "appPlatform": $scope.appPlatform,
            "publisherName": $scope.publisherData.name
          }
        );

        if ($routeParams.utm_source == 'salesforce') {
          mixpanel.track(
            "Salesforce Publisher Page Viewed", {
              "publisherId": $routeParams.id,
              "appPlatform": $scope.appPlatform,
              "publisherName": $scope.publisherData.name
            }
          );
        }
      }).error(function() {
        publisherDetailsCtrl.queryInProgress = false;
      });
    };
    $scope.loadPublisher();

    authService.permissions()
      .success(function(data) {
        $scope.canViewSupportDesk = data.can_view_support_desk;
        $scope.canViewExports = data.can_view_exports;
      })
      .error(function() {
        $scope.canViewSupportDesk = false;
      });

    /* LinkedIn Link Button Logic */
    $scope.onLinkedinButtonClick = function(linkedinLinkType) {
      linkedInService.getLink(linkedinLinkType, $scope.publisherData.name);
    };

    $scope.appsDisplayedCount = function() {
      var lastPageMaxApps = 100 * $scope.currentPage;
      var baseAppNum = 100 * ($scope.currentPage - 1) + 1;

      if (lastPageMaxApps > $scope.numApps) {
        return "" + baseAppNum.toLocaleString() + " - " + $scope.numApps.toLocaleString();
      } else {
        return "" + baseAppNum.toLocaleString() + " - " + lastPageMaxApps.toLocaleString();
      }
    };

    $scope.submitPageChange = function(currentPage) {
      $scope.currentPage = currentPage;
      $scope.loadPublisher();
    }

    $scope.onAppTableAppClick = function(app) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "App on Company Page Clicked", {
          "companyName": $scope.publisherData.name,
          "appName": app.name,
          "appId": app.id,
          "appPlatform": app.type
        }
      );
      /* -------- Mixpanel Analytics End -------- */
    };

    $scope.addMixedSelectedTo = function(list, selectedApps) {
      listApiService.addMixedSelectedTo(list, selectedApps).success(function() {
        $scope.notify('add-selected-success');
        $scope.selectedAppsForList = [];
      }).error(function() {
        $scope.notify('add-selected-error');
      });
      $scope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    $scope.notify = function(type) {
      switch (type) {
        case "add-selected-success":
          return loggitService.logSuccess("Items were added successfully.");
        case "add-selected-error":
          return loggitService.logError("Error! Something went wrong while adding to list.");
        case 'major publisher tagged':
          return loggitService.logSuccess("Publisher tagged successfully.")
        case 'major publisher untagged':
          return loggitService.logSuccess("Publisher untagged successfully.")
      }
    };

    $scope.handleTagButtonClick = function() {
      const id = $scope.publisherData.id;
      if ($scope.publisherData.isMajorPublisher) {
        apiService.untagAsMajorPublisher(id, $routeParams.platform).success(function(data) {
          $scope.notify('major publisher untagged')
          $scope.publisherData.isMajorPublisher = data.isMajorPublisher
        })
      } else {
        apiService.tagAsMajorPublisher(id, $routeParams.platform).success(function(data) {
          $scope.notify('major publisher tagged')
          $scope.publisherData.isMajorPublisher = data.isMajorPublisher
        })
      }
    }

    $scope.exportContactsToCsv = function(filter) {
      apiService.exportContactsToCsv($scope.appPlatform, $scope.publisherData.id, filter, $scope.publisherData.name)
        .success(function (content) {
          var hiddenElement = document.createElement('a');
          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'contacts.csv';
          hiddenElement.click();
        });
    };

    $scope.getLastUpdatedDaysClass = function(lastUpdatedDays) {
      return searchService.getLastUpdatedDaysClass(lastUpdatedDays);
    };

    // When orderby/sort arrows on dashboard table are clicked
    $scope.sortApps = function(category, order) {
      $scope.loadPublisher(category, order);
      var sign = order == 'desc' ? '-' : ''
      $scope.rowSort = sign + category;
    };

    $scope.contactsLoading = false;
    $scope.contactsLoaded = false;

    $scope.getContactEmail = function(contact) {
      contact.isLoading = true
      var clearbitId = contact.clearbitId
      apiService.getContactEmail(clearbitId)
        .success(function(data) {
          mixpanel.track(
            "Contact Email Requested", {
              'email': data.email,
              'clearbitId': clearbitId
            }
          );
          contact.email = data.email
          contact.isLoading = false
        }).error(function(data) {
          alert(data.error)
          contact.isLoading = false
        })
    }

    $scope.contactsDisplayedCount = function() {
      var offset = (($scope.currentContactsPage - 1) * $scope.contactsPerPage) + 1
      return offset + ' - ' + (offset + $scope.contactsPerPage - 1)
    }

    $scope.getCompanyContacts = function(filter, page) {
      if (!page) {
        page = 1
      }
      $scope.contactsLoading = true;
      apiService.getCompanyContacts($scope.appPlatform, $scope.publisherData.id, filter, page, $scope.contactsPerPage).success(function(data) {
        $scope.companyContacts = data.contacts;
        $scope.contactsCount = data.contactsCount;
        $scope.contactsLoading = false;
        $scope.contactsLoaded = true;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested", {
            'companyName': $scope.publisherData.name,
            'requestResults': data.contacts,
            'requestResultsCount': data.contacts.length,
            'titleFilter': filter || ''
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      }).error(function() {
        $scope.contactsLoading = false;
        $scope.contactsLoaded = false;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested", {
            'companyName': $scope.publisherData.name,
            'requestResultsCount': 0,
            'titleFilter': filter || ''
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      });
    };

  }
]);
