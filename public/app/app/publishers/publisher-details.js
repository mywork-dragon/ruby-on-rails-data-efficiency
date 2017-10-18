'use strict';

angular.module('appApp').controller("PublisherDetailsCtrl", ["$scope", "$http", "$stateParams", "$window", "pageTitleService", "$rootScope", "apiService", "listApiService", "loggitService", "authService", "searchService", "uniqueStringsFilter", "contactService", "$sce",
  function($scope, $http, $stateParams, $window, pageTitleService, $rootScope, apiService, listApiService, loggitService, authService, searchService, uniqueStringsFilter, contactService, $sce) {

    var publisherDetailsCtrl = this;
    $scope.appPlatform = $stateParams.platform
    $scope.initialPageLoadComplete = false; // shows page load spinner
    $scope.currentPage = 1;
    $scope.currentContactsPage = 1;
    $scope.contactsPerPage = 10;
    $scope.linkedinTooltip = $sce.trustAsHtml('LinkedIn profile <span class=\"fa fa-external-link\"></span>')

    $scope.loadPublisher = function(category, order) {
      publisherDetailsCtrl.queryInProgress = true;
        return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_' + $scope.appPlatform + '_developer',
        params: {id: $stateParams.id}
      }).success(function(data) {
        pageTitleService.setTitle(data.name);
        $scope.publisherData = data;
        $scope.numApps = data.numApps;
        $rootScope.numApps = data.numApps;

        $scope.initialPageLoadComplete = true; // hides page load spinner
        $scope.getCompanyContacts()
        $scope.getSdkSummary()
        $scope.getPublisherApps()
        /* Sets html title attribute */

        mixpanel.track(
          "Publisher Page Viewed", {
            "publisherId": $stateParams.id,
            "appPlatform": $scope.appPlatform,
            "publisherName": $scope.publisherData.name
          }
        );

        if ($stateParams.utm_source == 'salesforce') {
          mixpanel.track(
            "Salesforce Publisher Page Viewed", {
              "publisherId": $stateParams.id,
              "appPlatform": $scope.appPlatform,
              "publisherName": $scope.publisherData.name
            }
          );
        }
      }).error(function() {
        publisherDetailsCtrl.queryInProgress = false;
      });
    };

    $scope.getPublisherApps = function (category, order) {
      publisherDetailsCtrl.queryInProgress = true;
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_developer_apps',
        params: { id: $stateParams.id, platform: $stateParams.platform, sortBy: category, orderBy: order, pageNum: $scope.currentPage }
      }).success(function(data) {
        $scope.apps = data.apps
        publisherDetailsCtrl.queryInProgress = false;
        if ($scope.numApps > 0 && $scope.publisherData.websites && $scope.apps[0].supportDesk) {
          $scope.publisherData.websites.push($scope.apps[0].supportDesk)
        }
        $scope.publisherData.websites = uniqueStringsFilter($scope.publisherData.websites)
      })
    }

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
    // $scope.onLinkedinButtonClick = function(linkedinLinkType) {
    //   if (linkedinLinkType == 'company' && $scope.publisherData.linkedin) {
    //     contactService.getLink('linkedin', $scope.publisherData.linkedin, 'publisher');
    //   } else {
    //     contactService.getLink(linkedinLinkType, $scope.publisherData.name, 'publisher');
    //   }
    // };

    $scope.onLinkedinContactClick = function (contact) {
      contactService.trackLinkedinContactClick(contact, 'publisher')
    }

    $scope.crunchbaseLinkClicked = function () {
      contactService.trackCrunchbaseClick($scope.publisherData.name, 'publisher')
    }

    $scope.emailCopied = function (contact) {
      mixpanel.track("Email Copied", {
        "Email": contact.email,
        "Company": $scope.appData.publisher.name,
        "Name": contact.fullName,
        "Title": contact.title,
        "Source Type": 'publisher'
      })
    }

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
      $scope.getPublisherApps();
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

    // $scope.handleTagButtonClick = function() {
    //   const id = $scope.publisherData.id;
    //   if ($scope.publisherData.isMajorPublisher) {
    //     apiService.untagAsMajorPublisher(id, $stateParams.platform).success(function(data) {
    //       $scope.notify('major publisher untagged')
    //       $scope.publisherData.isMajorPublisher = data.isMajorPublisher
    //     })
    //   } else {
    //     apiService.tagAsMajorPublisher(id, $stateParams.platform).success(function(data) {
    //       $scope.notify('major publisher tagged')
    //       $scope.publisherData.isMajorPublisher = data.isMajorPublisher
    //     })
    //   }
    // }

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
      $scope.getPublisherApps(category, order);
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

    $scope.trackCompanyContactsRequest = function (data, filter) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "Company Contacts Requested", {
          'companyName': $scope.publisherData.name,
          'requestResults': data.contacts,
          'requestResultsCount': data.contactsCount,
          'titleFilter': filter || '',
          'Source Type': 'publisher'
        }
      );
      /* -------- Mixpanel Analytics End -------- */
    }

    $scope.getCompanyContacts = function(filter, page, clicked) {
      if (!page) {
        page = 1
      }
      $scope.contactsLoading = true;
      apiService.getCompanyContacts($scope.appPlatform, $scope.publisherData.id, filter, page, $scope.contactsPerPage).success(function(data) {
        $scope.companyContacts = data.contacts;
        $scope.contactsCount = data.contactsCount;
        $scope.contactsLoading = false;
        $scope.contactsLoaded = true;
        if (clicked) {
          $scope.trackCompanyContactsRequest(data, filter)
        }
      }).error(function(err) {
        $scope.contactsLoading = false;
        $scope.contactsLoaded = false;
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Company Contacts Requested Error", {
            'companyName': $scope.publisherData.name,
            'requestError': err,
            'titleFilter': filter || '',
            'Source Type': 'publisher'
          }
        );
        /* -------- Mixpanel Analytics End -------- */
      });
    };

    $scope.sdksLoading = true

    $scope.getSdkCount = function(sdks) {
      let count = 0
      for (var group in sdks) {
        count += sdks[group].length
      }
      return count
    }

    $scope.getSdkCategories = function(sdks) {
      const categories = {}
      const categoryNames = Object.keys(sdks).sort()
      const others = _.remove(categoryNames, x => x == "Others")
      if (others.length) { categoryNames.push("Others") }
      categoryNames.forEach(name => categories[name] = true)
      return categories
    }

    $scope.getSdkSummary = function () {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/' + $scope.appPlatform + '_sdks_exist',
        params: { publisherId: $stateParams.id }
      }).success(function (data) {
        $scope.installedSdks = data.installed_sdks
        $scope.installedSdkCategories = $scope.getSdkCategories(data.installed_sdks)
        $scope.uninstalledSdks = data.uninstalled_sdks
        $scope.uninstalledSdkCategories = $scope.getSdkCategories(data.uninstalled_sdks)
        $scope.installedSdksCount = $scope.getSdkCount(data.installed_sdks)
        $scope.uninstalledSdksCount = $scope.getSdkCount(data.uninstalled_sdks)
        $scope.sdksLoading = false
      })
    }
}]);
