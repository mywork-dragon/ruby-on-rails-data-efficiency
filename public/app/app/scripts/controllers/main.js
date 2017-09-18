'use strict';

/**
 * @ngdoc function
 * @name appApp.controller:MainCtrl
 * @description
 * # MainCtrl
 * Controller of the appApp
 */
angular.module('appApp')
  .controller('MainCtrl', ["$scope", "$location", "authService", "authToken", "$rootScope", "$route", "pageTitleService", "apiService", "$window", 'dropdownCategoryFilter', 'filterService', 'slacktivity',
    function ($scope, $location, authService, authToken, $rootScope, $route, pageTitleService, apiService, $window, dropdownCategoryFilter, filterService, slacktivity) {

      $scope.$route = $route; // for use in determining active tab (for CSS styling)

      $scope.pageTitleService = pageTitleService;

      $scope.checkIfOwnPage = function() {
        return ["/404", "/login", "/pages/signin", "/admin/"].some(el => $location.path().indexOf(el) > -1)
      };

      $rootScope.isAuthenticated = authToken.isAuthenticated();

      // If user not authenticated (and user not already on login page) redirect to login
      if(!$rootScope.isAuthenticated && !_.contains(["/login"], $location.path())) {
        authService.referrer($location.path());
        $window.location.href = "#/login";
      }

      // Delete JWT Auth token if unauthorized (401) response
      $scope.$on('STRING_REPRESENTS_AUTHORIZATION_REVOKED', function(event) {
        $rootScope.isAuthenticated = false;
        authToken.deleteToken("Your MightySignal access has been revoked. Please contact us or your account admin for details.");
      });

      $scope.$on('STRING_REPRESENTS_EVENT_FAILURE_TIMEOUT', function(event) {
        $rootScope.isAuthenticated = false;
        authToken.deleteToken("Your MightySignal login session has expired. Please login again.");
      });

      $scope.$on('STRING_REPRESENTS_AUTHENTICATION_SHARED', function(event) {
        $rootScope.isAuthenticated = false;
        authToken.deleteToken("Your MightySignal account was logged in from somewhere else. Please login again.");
      });

      $scope.clickedNavLink = function(link) {
        if (link == "Blog") {
          const slacktivityData = {
            "title": "Blog Link Clicked",
            "fallback": "Blog Link Clicked",
            "color": "#FFD94D"
          }
          slacktivity.notifySlack(slacktivityData);
        }
        mixpanel.track("Clicked Navigation Link", {
          link: link
        });
      }

      $scope.logUserOut = authToken.deleteToken;

      if($rootScope.isAuthenticated) {
        authService.userInfo().success(function(data) {
          mixpanel.identify(data.email);
          mixpanel.people.set({
            "$email": data.email,
            "jwtToken": authToken.get(),
            "Account Name": data.account_name,
            "Account ID": data.account_id
          });
          mixpanel.unregister("Account Name")
          mixpanel.unregister("Account ID")
          mixpanel.unregister("Company Name")
          mixpanel.unregister("Company ID")
          const affiliateNetworks = [107, 136, 133, 131, 43, 123, 106, 79, 154]
          if (affiliateNetworks.includes(data.account_id)) {
            mixpanel.people.set({
              "Account Type": "Affiliate Network"
            })
          }
        });

        // Sets user permissions
        authService.permissions()
          .success(function(data) {
            $scope.canViewSupportDesk = data.can_view_support_desk;
            $scope.canViewAdSpend = data.can_view_ad_spend;
            $scope.canViewSdks = data.can_view_sdks;
            $rootScope.canViewStorewideSdks = data.can_view_storewide_sdks;
            $scope.canViewAdAttribution = data.can_view_ad_attribution;
            $rootScope.isAdmin = data.is_admin;
            $rootScope.isAdminAccount = data.is_admin_account;
            $rootScope.connectedOauth = data.connected_oauth;
            $rootScope.canViewExports = data.can_view_exports;

            if (!$rootScope.connectedOauth) {
              $window.location.href = "#/login?token=" + authToken.get();
            }
          })
          .error(function() {
            $scope.canViewSupportDesk = false;
            $scope.canViewAdSpend = true;
            $scope.canViewSdks = false;
            $rootScope.isAdmin = false;
            $rootScope.isAdminAccount = false;
            $rootScope.connectedOauth = true;
          });


        var routeParams = $location.search();
        if (routeParams.platform) {
          try {
            APP_PLATFORM = JSON.parse(routeParams.platform).appPlatform
          } catch(e) {
            APP_PLATFORM = routeParams.platform
          }
        }

        /* Populates "Categories" dropdown with list of categories */
        apiService.getCategories().success(function(data) {
          $rootScope.categoryFilterOptions = dropdownCategoryFilter(data);
        });

        $rootScope.downloadsFilterOptions = [
          { id: 0, label: '0 - 50K'},
          { id: 1, label: '50K - 500K'},
          { id: 2, label: '500K - 10M'},
          { id: 3, label: '10M - 100M'},
          { id: 4, label: '100M - 1B'},
          { id: 5, label: '1B - 5B'}
        ]

        $rootScope.mobilePriorityFilterOptions = [
          { id: 'low', label: 'Low' },
          { id: 'medium', label: 'Medium' },
          { id: 'high', label: 'High' }
        ]

        $rootScope.userbaseFilterOptions = [
          { id: 'weak', label: 'Weak'},
          { id: 'moderate', label: 'Moderate'},
          { id: 'strong', label: 'Strong'},
          { id: 'elite', label: 'Elite'},
        ]

        apiService.getSdkCategories().success(data => {
          $rootScope.sdkCategories = data;
        })

        apiService.checkAppStatus().success(data => {
          $rootScope.appStatus = data.error;
        });

        $rootScope.appIsNew = function(app) {
          app.releasedDays && 0 <= app.releasedDays && app.releasedDays <= 15
        }

        $rootScope.complexFilters = {
          sdk: {or: [{status: "0", date: "0"}], and: [{status: "0", date: "0"}]},
          sdkCategory: {or: [{status: "0", date: "0"}], and: [{status: "0", date: "0"}]},
          location: {or: [{status: "0", state: '0'}], and: [{status: "0", state: '0'}]},
          userbase: {or: [{status: "0"}], and: [{status: "0"}]}
        }

        $rootScope.categoryModel = [];
        $rootScope.downloadsModel = []
        $rootScope.mobilePriorityModel = []
        $rootScope.userbaseModel = []
      }
  }])
  .controller("TableCtrl", ["$scope", "apiService", "listApiService", "$filter", "$rootScope", "loggitService", "AppPlatform",
    function($scope, apiService, listApiService, $filter, $rootScope, loggitService, AppPlatform) {
      return $rootScope.apps = [],
        $scope.searchKeywords = "",
        $scope.filteredApps = [],
        $scope.row = "",
        $scope.appPlatform = AppPlatform,
        $scope.appsDisplayedCount = function() {
          var lastPageMaxApps = $rootScope.numPerPage * $rootScope.currentPage;
          var baseAppNum = $rootScope.numPerPage * ($rootScope.currentPage - 1) + 1;
          if (lastPageMaxApps > $rootScope.numApps) {
            return "" + baseAppNum + " - " + $rootScope.numApps;
          } else {
            return "" + baseAppNum + " - " + lastPageMaxApps;
          }
        },
        listApiService.getLists().success(function(data) {
          $rootScope.usersLists = data;
        }),
        $rootScope.selectedAppsForList = [],
        $scope.addSelectedTo = function(list, selectedApps) {
          listApiService.addSelectedTo(list, selectedApps, $scope.appPlatform.platform).success(function() {
            $scope.notify('add-selected-success');
            $rootScope.selectedAppsForList = [];
          }).error(function() {
            $scope.notify('add-selected-error');
          });
          $rootScope['addSelectedToDropdown'] = ""; // Resets HTML select on view to default option
        },
        $scope.notify = function(type) {
          listApiService.listAddNotify(type);
        },
        $scope.onFilterChange = function() {
          return $scope.select(1), $rootScope.currentPage = 1, $scope.row = "";
        },
        $scope.onNumPerPageChange = function() {
          return $scope.select(1), $rootScope.currentPage = 1;
        },
        $scope.onOrderChange = function() {
          return $scope.select(1), $rootScope.currentPage = 1;
        },
        $scope.search = function() {
          return $scope.filteredApps = $filter("filter")($scope.apps, $scope.searchKeywords), $scope.onFilterChange();
        },
        $scope.numPerPageOpt = [100, 200, 350, 1000],
        $rootScope.numPerPage = $scope.numPerPageOpt[0],
        $rootScope.currentPage = 1,
        $scope.currentPageApps = []
    }
  ])
  .controller("BlogCtrl", ["$scope", "rssService", "slacktivity",
    function($scope, rssService, slacktivity) {
      $scope.isOpen = false;
      $scope.toggleTooltip = function(bool) {
        $scope.isOpen = bool;
      }

      rssService.fetchRssFeed().success(function(data) {
        if (!data.message) {
          $scope.title = data.title;
          $scope.author = data.author;
          $scope.link = data.link;
          $scope.pubDate = data.pubDate;
          $scope.newPost = true;
        }
      });

      $scope.clickedBlogNotification = function() {
        const slacktivityData = {
          "title": "Blog Post Notification Clicked",
          "fallback": "Blog Post Notification Clicked",
          "color": "#FFD94D",
          "Blog Title": $scope.title
        }
        slacktivity.notifySlack(slacktivityData);
        mixpanel.track("Clicked Navigation Link", {
          link: "New Blog Post"
        });
      }
    }
  ]);
