import angular from 'angular';
import mixpanel from 'mixpanel-browser';

import 'components/navigation/navigation.directive';

angular.module('appApp')
  .controller('MainCtrl', ['$scope', '$location', 'authService', 'authToken', '$rootScope', 'pageTitleService', 'apiService', '$window', 'dropdownCategoryFilter', 'filterService', 'slacktivity', '$sce',
    function ($scope, $location, authService, authToken, $rootScope, pageTitleService, apiService, $window, dropdownCategoryFilter, filterService, slacktivity, $sce) {
      $scope.pageTitleService = pageTitleService;

      $scope.checkIfOwnPage = function () {
        return ['/404', '/login', '/pages/signin', '/admin/'].some(el => $location.path().indexOf(el) > -1);
      };

      $rootScope.isAuthenticated = authToken.isAuthenticated();

      // If user not authenticated (and user not already on login page) redirect to login
      if (!$rootScope.isAuthenticated && !['/login'].includes($location.path())) {
        authService.referrer($location.path());
        $window.location.href = '#/login';
      }

      // Delete JWT Auth token if unauthorized (401) response
      $scope.$on('STRING_REPRESENTS_AUTHORIZATION_REVOKED', () => {
        $rootScope.isAuthenticated = false;
        authToken.deleteToken('Your MightySignal access has been revoked. Please contact us or your account admin for details.');
      });

      $scope.$on('STRING_REPRESENTS_EVENT_FAILURE_TIMEOUT', () => {
        $rootScope.isAuthenticated = false;
        authToken.deleteToken('Your MightySignal login session has expired. Please login again.');
      });

      $scope.$on('STRING_REPRESENTS_AUTHENTICATION_SHARED', () => {
        $rootScope.isAuthenticated = false;
        authToken.deleteToken('Your MightySignal account was logged in from somewhere else. Please login again.');
      });

      $scope.$on('STRING_REPRESENTS_EVENT_FAILED_AUTH', () => {
        $rootScope.isAuthenticated = false;
        authToken.deleteToken('You are not logged in');
      });

      $scope.clickedNavLink = function (link) {
        if (link === 'Blog') {
          const slacktivityData = {
            title: 'Blog Link Clicked',
            fallback: 'Blog Link Clicked',
            color: '#FFD94D',
          };
          slacktivity.notifySlack(slacktivityData);
        }
        mixpanel.track('Clicked Navigation Link', {
          link,
        });
      };

      $scope.logUserOut = authToken.deleteToken;

      if ($rootScope.isAuthenticated) {
        authService.userInfo().success((data) => {
          mixpanel.identify(data.email);
          mixpanel.people.set({
            $email: data.email,
            jwtToken: authToken.get(),
            'Account Name': data.account_name,
            'Account ID': data.account_id,
          });
          mixpanel.unregister('Account Name');
          mixpanel.unregister('Account ID');
          mixpanel.unregister('Company Name');
          mixpanel.unregister('Company ID');
          const affiliateNetworks = [107, 136, 133, 131, 43, 123, 106, 79, 154];
          if (affiliateNetworks.includes(data.account_id)) {
            mixpanel.people.set({
              'Account Type': 'Affiliate Network',
            });
          }
        });

        // Sets user permissions
        authService.permissions()
          .success((data) => {
            $scope.canViewSupportDesk = data.can_view_support_desk;
            $scope.canViewAdSpend = data.can_view_ad_spend;
            $scope.canViewSdks = data.can_view_sdks;
            $scope.canViewAdAttribution = data.can_view_ad_attribution;
            $scope.canUseSalesforce = data.can_use_salesforce;
            $scope.sfAdminConnected = data.sf_admin_connected;
            $scope.sfUserConnected = data.sf_user_connected;
            $scope.sfInstalled = data.sf_installed;

            $rootScope.canViewSupportDesk = data.can_view_support_desk;
            $rootScope.canViewAdSpend = data.can_view_ad_spend;
            $rootScope.canViewSdks = data.can_view_sdks;
            $rootScope.canViewAdSpend = data.can_view_ad_spend;
            $rootScope.canViewSdks = data.can_view_sdks;
            $rootScope.canViewStorewideSdks = data.can_view_storewide_sdks;
            $rootScope.canViewIosLiveScan = data.can_view_ios_live_scan;
            $rootScope.isAdmin = data.is_admin;
            $rootScope.isAdminAccount = data.is_admin_account;
            $rootScope.connectedOauth = data.connected_oauth;
            $rootScope.canViewExports = data.can_view_exports;
            $rootScope.canUseSalesforce = data.can_use_salesforce;
            $rootScope.sfAdminConnected = data.sf_admin_connected;
            $rootScope.sfUserConnected = data.sf_user_connected;
            $rootScope.sfInstalled = data.sf_installed;

            if (!$rootScope.connectedOauth) {
              $window.location.href = `#/login?token=${authToken.get()}`;
            }
          })
          .error(() => {
            $scope.canViewSupportDesk = false;
            $scope.canViewAdSpend = true;
            $scope.canViewSdks = false;
            $rootScope.isAdmin = false;
            $rootScope.isAdminAccount = false;
            $rootScope.connectedOauth = true;
          });


        const routeParams = $location.search();
        if (routeParams.platform) {
          try {
            window.APP_PLATFORM = JSON.parse(routeParams.platform).appPlatform;
          } catch (e) {
            window.APP_PLATFORM = routeParams.platform;
          }
        }

        /* Populates "Categories" dropdown with list of categories */
        apiService.getCategories().success((data) => {
          $rootScope.categoryFilterOptions = dropdownCategoryFilter(data);
        });

        $rootScope.downloadsFilterOptions = [
          { id: 0, label: '0 - 50K' },
          { id: 1, label: '50K - 500K' },
          { id: 2, label: '500K - 10M' },
          { id: 3, label: '10M - 100M' },
          { id: 4, label: '100M - 1B' },
          { id: 5, label: '1B - 5B' },
        ];

        $rootScope.mobilePriorityFilterOptions = [
          { id: 'low', label: 'Low' },
          { id: 'medium', label: 'Medium' },
          { id: 'high', label: 'High' },
        ];

        $rootScope.chartFilterOptions = [
          { id: 'free', label: 'Top Free Apps' },
          { id: 'paid', label: 'Top Paid Apps' },
          { id: 'grossing', label: 'Top Grossing Apps' },
        ];

        $rootScope.userbaseFilterOptions = [
          { id: 'weak', label: 'Weak' },
          { id: 'moderate', label: 'Moderate' },
          { id: 'strong', label: 'Strong' },
          { id: 'elite', label: 'Elite' },
        ];

        apiService.getSdkCategories().success((data) => {
          $rootScope.sdkCategories = data;
        });

        apiService.checkAppStatus().success((data) => {
          $rootScope.appStatus = data.error;
        });

        $rootScope.appIsNew = function (app) {
          return app.releasedDays && app.releasedDays >= 0 && app.releasedDays <= 15;
        };

        $rootScope.complexFilters = {
          sdk: { or: [{ status: '0', date: '0' }], and: [{ status: '0', date: '0' }] },
          sdkCategory: { or: [{ status: '0', date: '0' }], and: [{ status: '0', date: '0' }] },
          location: { or: [{ status: '0', state: '0' }], and: [{ status: '0', state: '0' }] },
          userbase: { or: [{ status: '0' }], and: [{ status: '0' }] },
        };

        $rootScope.categoryModel = [];
        $rootScope.downloadsModel = [];
        $rootScope.mobilePriorityModel = [];
        $rootScope.userbaseModel = [];

        $rootScope.mobilePriorityExplanation = $sce.trustAsHtml('<p>How actively the app is being developed, based on how recently the app has been updated.</p>' +
                                                            '<p>High: Updated within the past 2 months.</p>' +
                                                            '<p>Medium: 2-4 months.</p>' +
                                                            '<p>Low: More than 4 months ago.</p>');

        $rootScope.userbaseExplanation = $sce.trustAsHtml('<p>An estimate of how many active users an app has, based on ratings for the current release.</p>' +
                                                      '<p>Elite: 50,000 total ratings or average of 7 ratings per day.</p>' +
                                                      '<p>Strong: 10,000 total ratings or average of 1 rating per day.</p>' +
                                                      '<p>Moderate: 100 total ratings or average of 0.1 rating per day.</p>' +
                                                      '<p>Weak: Anything less.</p>');
      }
    }])
  .controller('BlogCtrl', ['$scope', 'rssService', 'slacktivity',
    function ($scope, rssService, slacktivity) {
      $scope.isOpen = false;
      $scope.toggleTooltip = function (bool) {
        $scope.isOpen = bool;
      };

      rssService.fetchRssFeed().success((data) => {
        if (!data.message) {
          $scope.title = data.title;
          $scope.author = data.author;
          $scope.link = data.link;
          $scope.pubDate = data.pubDate;
          $scope.newPost = true;
        }
      });

      $scope.clickedBlogNotification = function () {
        const slacktivityData = {
          title: 'Blog Post Notification Clicked',
          fallback: 'Blog Post Notification Clicked',
          color: '#FFD94D',
          'Blog Title': $scope.title,
        };
        slacktivity.notifySlack(slacktivityData);
        mixpanel.track('Clicked Navigation Link', {
          link: 'New Blog Post',
        });
      };
    },
  ]);
