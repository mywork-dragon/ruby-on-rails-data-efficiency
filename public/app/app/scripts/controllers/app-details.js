'use strict';

angular.module('appApp').controller("AppDetailsCtrl", ["$scope", '$auth', 'authToken', "$http", "$routeParams", "$window", "$timeout", "$route", "pageTitleService", "listApiService", "loggitService", "$rootScope", "apiService", "authService", "appDataService", 'newsfeedService', 'sdkLiveScanService', 'contactService', 'slacktivity', '$sce',
  function($scope, $auth, authToken, $http, $routeParams, $window, $timeout, $route, pageTitleService, listApiService, loggitService, $rootScope, apiService, authService, appDataService, newsfeedService, sdkLiveScanService, contactService, slacktivity, $sce) {

    $scope.appPlatform = $routeParams.platform;

    $scope.initialPageLoadComplete = false; // shows page load spinner
    $scope.calculateDaysAgo = sdkLiveScanService.calculateDaysAgo
    $scope.currentContactsPage = 1;
    $scope.contactsPerPage = 10;

    // Facebook ads slideshow
    $scope.myInterval = 0;
    $scope.noWrapSlides = false;
    $scope.active = 0;

    authService.permissions()
      .success(function(data) {
        $scope.canViewSupportDesk = data.can_view_support_desk;
        $scope.canViewExports = data.can_view_exports;
        $scope.canViewSdks = data.can_view_sdks;
        $scope.canViewAdSpend = data.can_view_ad_spend;
        $scope.canViewIosLiveScan = data.can_view_ios_live_scan;
        $scope.canViewStorewideSdks = data.can_view_storewide_sdks;
        $scope.canViewAdAttribution = data.can_view_ad_attribution;
        $scope.isAdminAccount = data.is_admin_account;
        $scope.canUseSalesforce = data.can_use_salesforce;
        $scope.sfAdminConnected = data.sf_admin_connected;
        $scope.sfUserConnected = data.sf_user_connected;
        $scope.sfInstalled = data.sf_installed;
      })
      .error(function() {
        $scope.canViewSupportDesk = false;
      });

      authService.accountInfo()
      .success(function(data) {
        $scope.salesforceSettings = data.salesforce_settings
      })

    $scope.getSalesforceData = function() {
      authService.userInfo().success(function(data) {
        $scope.userInfo = {}
        $scope.userInfo.email = data.email;
        $scope.userInfo.salesforceName = data.salesforce_name;
        $scope.userInfo.salesforceImageUrl = data.salesforce_image_url;
      });
    }

    $scope.authenticate = function(provider) {
      $auth.authenticate(provider, {token: authToken.get()})
      .then(function(response) {
        $scope.sfUserConnected = true
        $scope.getSalesforceData();
      })
      .catch(function(response) {
        $scope.sfUserConnected = false
        alert(response.data.error)
      });
    };

    $scope.openSalesforceModal = function() {
      mixpanel.track(
        "Opened Salesforce Export Modal", {
          "appId": $routeParams.id,
          "appName": $scope.appData.name,
          "companyName": $scope.appData.publisher.name,
          "appPlatform": $routeParams.platform
        }
      );
    }

    $scope.linkedinTooltip = $sce.trustAsHtml('LinkedIn profile <span class=\"fa fa-external-link\"></span>')

    $scope.emailCopied = function (contact) {
      mixpanel.track("Email Copied", {
        "Email": contact.email,
        "Company": $scope.appData.publisher.name,
        "Name": contact.fullName,
        "Title": contact.title,
        "Source Type": 'app'
      })
    }

    $scope.load = function() {
      return $http({
        method: 'GET',
        url: API_URI_BASE + 'api/get_' + $routeParams.platform + '_app',
        params: {id: $routeParams.id}
      }).success(function(data) {
        $scope.appData = data;
        $scope.prepareRatings(data)
        if ($scope.appData.publisher && $scope.appData.publisher.websites && $scope.appData.supportDesk) {
          $scope.appData.publisher.websites.push($scope.appData.supportDesk)
        }
        $scope.isFollowing = data.following
        $scope.initialPageLoadComplete = true; // hides page load spinner
        if (data.facebookAds) {
          for (var i = 0; i < data.facebookAds.length; i++) {
            var ad = data.facebookAds[i];
            ad.id = i;
          }
        }

        // Updates displayStatus for use in android-live-scan ctrl
        appDataService.displayStatus = {appId: $routeParams.id, status: data.displayStatus};
        $scope.$broadcast('APP_DATA_FOR_APP_DATA_SERVICE_SET');

        /* Sets html title attribute */
        pageTitleService.setTitle(data.name);
        $scope.getCompanyContacts()

        /* -------- Mixpanel Analytics Start -------- */
        if ($routeParams.from == 'ewok') {
          mixpanel.track(
            "Ewok App Page Viewed", {
              "appId": $routeParams.id,
              "appName": $scope.appData.name,
              "companyName": $scope.appData.publisher.name,
              "appPlatform": $routeParams.platform
            }
          );
        } else {
          mixpanel.track(
            "App Page Viewed", {
              "appId": $routeParams.id,
              "appName": $scope.appData.name,
              "companyName": $scope.appData.publisher.name,
              "appPlatform": $routeParams.platform
            }
          );
        }
        /* -------- Mixpanel Analytics End -------- */

        if ($routeParams.utm_source == 'salesforce') {
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Salesforce App Page Viewed", {
              "appId": $routeParams.id,
              "appName": $scope.appData.name,
              "companyName": $scope.appData.publisher.name,
              "appPlatform": $routeParams.platform
            }
          );
          /* -------- Mixpanel Analytics End -------- */
        }
      });
    };

    $scope.load();

    $scope.prepareRatings = function (appData) {
      const rating = $scope.appPlatform == 'ios' ? appData.rating.rating : appData.rating
      $scope.rating = parseFloat(rating, 10)
      $scope.ratingsCount = $scope.appPlatform == 'ios' ? appData.ratingsCount.ratings_count : appData.ratingsCount
    }

    /* LinkedIn Link Button Logic */
    $scope.onLinkedinButtonClick = function(linkedinLinkType) {
      if (linkedinLinkType == 'company' && $scope.appData.publisher.linkedin) {
        contactService.getLink('linkedin', $scope.appData.publisher.linkedin, 'app');
      } else {
        contactService.getLink(linkedinLinkType, $scope.appData.publisher.name, 'app');
      }
    };

    $scope.onLinkedinContactClick = function (contact) {
      contactService.trackLinkedinContactClick(contact, 'app')
    }

    $scope.crunchbaseLinkClicked = function () {
      contactService.trackCrunchbaseClick($scope.appData.publisher.name, 'app')
    }

    $scope.openAppStorePage = function () {
      const page = $routeParams.platform == 'ios' ? $scope.appData.appStoreLink : 'https://play.google.com/store/apps/details?id=' + $scope.appData.appIdentifier
      $window.open(page)
    }

    $scope.linkTo = function(path) {
      $window.location.href = path;
    };

    $scope.isEmpty = function(obj) {
      try { return Object.keys(obj).length === 0; }
      catch(err) {}
    };

    $scope.notify = function(type) {
      switch (type) {
        case "add-selected-success":
          return loggitService.logSuccess("Items were added successfully.");
        case "add-selected-error":
          return loggitService.logError("Error! Something went wrong while adding to list.");
        case "followed":
          return loggitService.logSuccess("You will now see updates for this app on your Timeline");
        case "unfollowed":
          return loggitService.logSuccess("You will stop seeing updates for this app on your Timeline");
        case "reset":
          return loggitService.logSuccess("Resetting app data. The page will refresh shortly.")
        case "major app tagged":
          return loggitService.logSuccess("App successfully tagged.")
        case "major app untagged":
          return loggitService.logSuccess("Tag successfully removed.")
      }
    };

    $scope.addSelectedTo = function(list) {
      var selectedApp = [{
        id: $routeParams.id,
        type: $routeParams.platform
      }];
      listApiService.addSelectedTo(list, selectedApp, $scope.appPlatform).success(function() {
        $scope.notify('add-selected-success');
        $rootScope.selectedAppsForList = [];
      }).error(function() {
        $scope.notify('add-selected-error');
      });
      $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
    };

    $scope.followApp = function(id, action) {
      const follow = {
        id,
        type: $routeParams.platform == 'ios' ? 'IosApp' : 'AndroidApp',
        name: $scope.appData.name,
        action,
        source: 'appDetails'
      }
      newsfeedService.follow(follow).success(function(data) {
        $scope.isFollowing = data.is_following
        if (data.is_following) {
          $scope.notify('followed');
        } else {
          $scope.notify('unfollowed');
        }
      });
    }

    $scope.resetAppData = function(id) {
      $scope.notify('reset');
      apiService.iosResetAppData(id).success(function() {
        $timeout(function() {
          $route.reload();
        }, 5000)
      });
    }

    $scope.handleTagButtonClick = function(id) {
      // if ($scope.appData.isMajorApp) {
      //   apiService.untagAsMajorApp(id, $routeParams.platform).success(function(data) {
      //     $scope.notify('major app untagged')
      //     $scope.appData.isMajorApp = data.isMajorApp
      //   })
      // } else {
        apiService.tagAsMajorApp(id, $routeParams.platform).success(function(data) {
          $scope.notify('major app tagged')
          $scope.appData.isMajorApp = data.isMajorApp
        })
      // }
    }

    $scope.exportContactsToCsv = function(filter) {
      apiService.exportContactsToCsv($scope.appData.platform, $scope.appData.publisher.id, filter, $scope.appData.publisher.name)
        .success(function (content) {
          var hiddenElement = document.createElement('a');

          hiddenElement.href = 'data:attachment/csv,' + encodeURI(content);
          hiddenElement.target = '_blank';
          hiddenElement.download = 'contacts.csv';
          hiddenElement.click();
        });
    };

    /* Company Contacts Logic */
    $scope.contactsLoading = false;
    $scope.contactsLoaded = false;

    $scope.getContactEmail = function(contact) {
      contact.isLoading = true
      var clearbitId = contact.clearbitId
      apiService.getContactEmail(clearbitId)
        .success(function(data) {
          mixpanel.track(
            "Contact Email Requested", {
              'contact': contact,
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

    $scope.trackCompanyContactsRequest = function (data, filter) {
      /* -------- Mixpanel Analytics Start -------- */
      mixpanel.track(
        "Company Contacts Requested", {
          'companyName': $scope.appData.publisher.name,
          'requestResults': data.contacts,
          'requestResultsCount': data.contactsCount,
          'titleFilter': filter || '',
          'Source Type': 'app'
        }
      );
      /* -------- Mixpanel Analytics End -------- */
    }

    $scope.getCompanyContacts = function(filter, page, clicked) {
      if (!page) {
        page = 1
      }
      $scope.contactsLoading = true;
      apiService.getCompanyContacts($scope.appData.platform, $scope.appData.publisher.id, filter, page, $scope.contactsPerPage)
        .success(function(data) {
          $scope.companyContacts = data.contacts;
          $scope.contactsCount = data.contactsCount;
          $scope.contactsLoading = false;
          $scope.contactsLoaded = true;
          if (clicked) {
            $scope.trackCompanyContactsRequest(data, filter)
          }
        }).error(function(err) {
          /* -------- Mixpanel Analytics Start -------- */
          mixpanel.track(
            "Company Contacts Requested Error", {
              'companyName': $scope.appData.publisher.name,
              'requestError': err,
              'titleFilter': filter || '',
              'Source Type': 'app'
            }
          );
          /* -------- Mixpanel Analytics End -------- */
          $scope.contactsLoading = false;
          $scope.contactsLoaded = false;
        });
    };

    $scope.getSalesforceData();
  }

]);
