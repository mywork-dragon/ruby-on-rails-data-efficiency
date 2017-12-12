/* eslint-disable no-sequences */

import angular from 'angular';
import mixpanel from 'mixpanel-browser';
import $ from 'jquery';
import Holder from 'holderjs';

/*
 App custom Directives
 Custom directives for the app like custom background, minNavigation etc
 */

angular.module('app.directives', []).directive('imgHolder', [
  function() {
    return {
      link(scope, ele) {
        return Holder.run({
          images: ele[0],
        });
      },
    };
  },
]).directive('customBackground', () => ({
  controller: ['$scope', '$element', '$location',
    function($scope, $element, $location) {
      const path = function() {
        return $location.path();
      }
      const addBg = function(path) {
        switch ($element.removeClass('body-home body-special body-tasks body-lock'), path) {
          case '/':
            return $element.addClass('body-home');
          case '/404':
          case '/app.ui.ctrlses/500':
          case '/pages/signin':
          case '/pages/signup':
          case '/pages/forgot':
            return $element.addClass('body-special');
          case '/pages/lock-screen':
            return $element.addClass('body-special body-lock');
          case '/tasks':
            return $element.addClass('body-tasks');
        }
      }
      addBg($location.path())
      return $scope.$watch(path, (newVal, oldVal) => (newVal !== oldVal ? addBg($location.path()) : void 0));
    },
  ],
})).directive('uiColorSwitch', [
  function() {
    return {
      restrict: 'A',
      link(scope, ele) {
        return ele.find('.color-option').on('click', function(event) {
          let $this;
          let hrefUrl;
          let style;
          if ($this = $(this), hrefUrl = void 0, style = $this.data('style'), style === 'loulou') {
            hrefUrl = 'styles/main.css';
            $('link[href^="styles/main"]').attr('href', hrefUrl);
          } else {
            if (!style) return !1;
            style = `-${style}`;
            hrefUrl = `styles/main${style}.css`;
            $('link[href^="styles/main"]').attr('href', hrefUrl);
          }
          return event.preventDefault();
        });
      },
    };
  },
])
  .directive('toggleMinNav', ['$rootScope',
    function($rootScope) {
      return {
        link(scope, ele) {
          let $content;
          let $nav;
          let $window;
          let Timer;
          let app;
          let updateClass;

          return app = $('#app'), $window = $(window), $nav = $('#nav-container'), $content = $('#content'), ele.on('click', (e) => {
            if (app.hasClass('nav-min')) {
              app.removeClass('nav-min');
            } else {
              app.addClass('nav-min');
              $rootScope.$broadcast('minNav:enabled');
              e.preventDefault();
            }
          }), Timer = void 0, updateClass = function() {
            let width;
            return width = $window.width(), width < 980 ? app.addClass('nav-min') : void 0;
          }, window.initResize = function() {
            let width;
            return width = $window.width(), width < 980 ? app.addClass('nav-min') : app.removeClass('nav-min');
          }, $window.resize(() => {
            let t;
            return clearTimeout(t), t = setTimeout(updateClass, 300);
          }), window.initResize(); // not sure if correct but not used
        },
      };
    },
  ])
  .directive('collapseNav', [
    function() {
      return {
        link(scope, ele) {
          let $a;
          let $aRest;
          let $lists;
          let $listsRest;
          let app;
          return $lists = ele.find('ul').parent('li'),
          $lists.append('<i class="fa fa-arrow-circle-o-right icon-has-ul"></i>'),
          $a = $lists.children('a'),
          $listsRest = ele.children('li').not($lists),
          $aRest = $listsRest.children('a'),
          app = $('#app'),
          $a.on('click', function(event) {
            let $parent;
            let $this;
            return app.hasClass('nav-min') ? !1 : ($this = $(this),
              $parent = $this.parent('li'),
              $lists.not($parent).removeClass('open').find('ul').slideUp(),
              $parent.toggleClass('open').find('ul').stop().slideToggle(), event.preventDefault());
          }), $aRest.on('click', () => $lists.removeClass('open').find('ul').slideUp()), scope.$on('minNav:enabled', () => $lists.removeClass('open').find('ul').slideUp());
        },
      };
    },
  ])
  .directive('highlightActive', [
    function() {
      return {
        controller: ['$scope', '$element', '$attrs', '$location',
          function($scope, $element, $attrs, $location) {
            let highlightActive;
            let links;
            let path;
            return links = $element.find('a'), path = function() {
              return $location.path();
            }, highlightActive = function(links, path) {
              return path = `#${path}`, angular.forEach(links, (link) => {
                let $li;
                let $link;
                let href;
                return $link = angular.element(link), $li = $link.parent('li'), href = $link.attr('href'), $li.hasClass('active') && $li.removeClass('active'), path.indexOf(href) === 0 ? $li.addClass('active') : void 0;
              });
            }, highlightActive(links, $location.path()), $scope.$watch(path, (newVal, oldVal) => (newVal !== oldVal ? highlightActive(links, $location.path()) : void 0));
          },
        ],
      };
    },
  ])
  .directive('toggleOffCanvas', [
    function() {
      return {
        link(scope, ele) {
          return ele.on('click', () => $('#app').toggleClass('on-canvas').toggleClass('nav-min'));
        },
      };
    },
  ])
  .directive('slimScroll', [
    function() {
      return {
        link(scope, ele, attrs) {
          return ele.slimScroll({
            height: attrs.scrollHeight || '100%',
          });
        },
      };
    },
  ])
  .directive('goBack', [
    function() {
      return {
        restrict: 'A',
        controller: ['$scope', '$element', '$window',
          function($scope, $element, $window) {
            return $element.on('click', () => $window.history.back());
          },
        ],
      };
    },
  ])
  .directive('ngEnter', () => function (scope, element, attrs) {
    element.bind('keydown keypress', (event) => {
      if (event.which === 13) {
        scope.$apply(() => {
          scope.$eval(attrs.ngEnter);
        });

        event.preventDefault();
      }
    });
  })
  .filter('filesize', () => function (size) {
    if (isNaN(size)) { size = 0; }

    if (size < 1024) { return `${size} B`; }

    size /= 1024;

    if (size < 1024) { return `${size.toFixed(0)} KB`; }

    size /= 1024;

    if (size < 1024) { return `${size.toFixed(0)} MB`; }

    size /= 1024;

    if (size < 1024) { return `${size.toFixed(0)} GB`; }

    size /= 1024;

    return `${size.toFixed(0)} TB`;
  })
  .filter('dropdownCategory', () => function (categories) {
    const newCategories = [];
    for (let i = 0; i < categories.length; i++) {
      const category = categories[i];
      newCategories.push({ id: category, label: category });
    }
    return newCategories;
  })
  .filter('thousandSuffix', () => function (input, decimals) {
    let rounded;
    const suffixes = ['K', 'M', 'G', 'T', 'P', 'E'];

    if (Number.isNaN(input)) {
      return null;
    }

    if (input < 1000) {
      return input;
    }

    const exp = Math.floor(Math.log(input) / Math.log(1000));

    return (input / Math.pow(1000, exp)).toFixed(decimals) + suffixes[exp - 1];
  })
  .filter('supportDeskName', () => function (url) {
    if (!url) return '';

    let result = '';
    const supportDeskNames = [
      'Zendesk',
      'Helpshift',
      'UserVoice',
      'Freshdesk',
      'Desk',
    ];

    const domain = url.toLowerCase().split('.');

    supportDeskNames.forEach((name) => {
      if (domain.length > 1 && domain[domain.length - 2] == name.toLowerCase()) {
        result = name;
      }
    });
    return result;
  })
  .filter('humanizeNum', () => function humanize(number) {
    if (number < 1000) {
      return number;
    }
    const si = ['K', 'M', 'B', 'T', 'Q', 'Quin'];
    const exp = Math.floor(Math.log(number) / Math.log(1000));
    let result = number / Math.pow(1000, exp);
    result = (result % 1 > (1 / Math.pow(1000, exp - 1))) ? result.toFixed(2) : result.toFixed(0);
    return result + si[exp - 1];
  })
  .directive('selectAllCheckbox', ['$rootScope', function ($rootScope) {
    return {
      replace: true,
      restrict: 'E',
      scope: {
        apps: '=apps',
        numApps: '=numApps',
      },
      template: '<input type="checkbox" ng-model="checkboxMaster" ng-click="checkboxMasterChange()">',
      controller: ['$scope', '$element',
        function ($scope, $element) {
          $scope.checkboxMasterChange = function () {
            if ($scope.checkboxMaster) {
              $rootScope.selectedAppsForList = [];

              angular.forEach($scope.apps, (app) => {
                $rootScope.selectedAppsForList.push({ id: app.id, type: app.type });
              });
            } else {
              $rootScope.selectedAppsForList = [];
            }
          };

          $scope.$watch('$root.selectedAppsForList', () => {
            /* Controls 'checked' status of master checkbox (top checkbox). Two states: [ ] and [X] */
            if ($rootScope.selectedAppsForList.length == $rootScope.numPerPage || $rootScope.selectedAppsForList.length == $scope.numApps) {
              $element.prop('checked', true);
            } else {
              $element.prop('checked', false);
            }
          }, true);
        }],
    };
  }])
  .directive('checkableCheckbox', ['$rootScope', 'listApiService', function ($rootScope, listApiService) {
    return {
      replace: true,
      restrict: 'E',
      scope: {
        app: '=app',
        apps: '=apps',
      },
      template: '<input type="checkbox" ng-model="appCheckbox" ng-click="addAppToList()">',
      controller: ['$scope', '$element', function ($scope, $element) {
        $scope.addAppToList = function() {
          listApiService.modifyCheckbox($scope.app.id, $scope.app.type, $rootScope.selectedAppsForList);
        };

        $scope.$watch('$root.selectedAppsForList', () => {
          if ($rootScope.selectedAppsForList.length == $scope.apps.length) {
            $element.prop('checked', true);
          } else {
            $element.prop('checked', false);
          }
        });
      }],
    };
  }])
  .directive('selectAllCheckboxTwo', [function () {
    return {
      replace: true,
      restrict: 'E',
      scope: {
        apps: '=apps',
        selectedAppsForList: '=selectedAppsForList',
      },
      template: '<input type="checkbox" ng-model="checkboxMaster" ng-click="checkboxMasterChange()">',
      controller: ['$scope', '$element', function ($scope, $element) {
        $scope.checkboxMasterChange = function () {
          if ($scope.checkboxMaster) {
            $scope.selectedAppsForList = [];
            angular.forEach($scope.apps, (app) => {
              $scope.selectedAppsForList.push({ id: app.id, type: app.type });
            });
          } else {
            $scope.selectedAppsForList = [];
          }
        };

        $scope.$watch('selectedAppsForList', () => {
          /* Controls 'checked' status of master checkbox (top checkbox). Three states: [ ], [X] and [-] */
          if ($scope.selectedAppsForList.length == $scope.apps.length) {
            $element.prop('checked', true);
          } else {
            $element.prop('checked', false);
          }
        }, true);
      }],
    };
  }])
  .directive('checkableCheckboxTwo', ['listApiService', function (listApiService) {
    return {
      replace: true,
      restrict: 'E',
      scope: {
        app: '=app',
        selectedAppsForList: '=selectedAppsForList',
        apps: '=apps',
      },
      template: '<input type="checkbox" ng-model="appCheckbox" ng-click="addAppToList()">',
      controller: ['$scope', '$element', function ($scope, $element) {
        $scope.addAppToList = function() {
          listApiService.modifyCheckbox($scope.app.id, $scope.app.type, $scope.selectedAppsForList);
        };

        $scope.$watch('selectedAppsForList', () => {
          if ($scope.selectedAppsForList.length == $scope.apps.length) {
            $element.prop('checked', true);
          } else {
            $element.prop('checked', false);
          }
        });
      }],
    };
  }])
  .directive('salesforceExportForm', ['$http', 'authService', 'slacktivity', function ($http, authService, slacktivity) {
    return {
      replace: true,
      restrict: 'E',
      scope: {
        app: '=',
        user: '=',
      },
      template: require('views/forms/salesforce-export.html'),
      controller: ['$scope', '$element', function ($scope, $element) {
        $scope.existingObject;
        $scope.sfMapping = { Lead: {}, Account: {} };
        $scope.sfMappingForm = {
          Lead: [
            {
              platform: 'ios', id: 'MightySignal iOS Publisher ID', name: 'MightySignal iOS Publisher ID', fields: [{ id: 'MightySignal_iOS_Publisher_ID__c', name: 'New Field: MightySignal iOS Publisher Id' }, { id: 'AccountNumber', name: 'Account Number' }],
            },
            {
              platform: 'android', id: 'MightySignal Android Publisher ID', name: 'MightySignal Android Publisher ID', fields: [{ id: 'MightySignal_Android_Publisher_ID__c', name: 'New Field: MightySignal Android Publisher Id' }, { id: 'AccountNumber', name: 'Account Number' }],
            },
            { id: 'Publisher Name', name: 'Publisher Name', fields: [{ id: 'Company', name: 'Company' }, { id: 'MightySignal_Publisher_Name__c', name: 'New Field: MightySignal Publisher Name' }] },
            { id: 'Website', name: 'Website', fields: [{ id: 'Website', name: 'Website' }, { id: 'MightySignal_Publisher_Website__c', name: 'New Field: MightySignal Publisher Website' }] },
            {
              platform: 'ios', id: 'MightySignal iOS SDK Summary', name: 'MightySignal iOS SDK Summary', fields: [{ id: 'MightySignal_iOS_SDK_Summary__c', name: 'New Field: MightySignal iOS SDK Summary' }],
            },
            {
              platform: 'android', id: 'MightySignal Android SDK Summary', name: 'MightySignal Android SDK Summary', fields: [{ id: 'MightySignal_Android_SDK_Summary__c', name: 'New Field: MightySignal Android SDK Summary' }],
            },
            {
              platform: 'ios', id: 'MightySignal iOS Link', name: 'MightySignal iOS Link', fields: [{ id: 'MightySignal_iOS_Link__c', name: 'New Field: MightySignal iOS Link' }],
            },
            {
              platform: 'android', id: 'MightySignal Android Link', name: 'MightySignal Android Link', fields: [{ id: 'MightySignal_Android_Link__c', name: 'New Field: MightySignal Android Link' }],
            },
            { id: 'Email', name: 'Email' },
            { id: 'FirstName', name: 'First Name' },
            { id: 'LastName', name: 'Last Name' },
            { id: 'Title', name: 'Title' },
          ],
          Account: [
            {
              platform: 'ios', id: 'MightySignal iOS Publisher ID', name: 'MightySignal iOS Publisher ID', fields: [{ id: 'MightySignal_iOS_Publisher_ID__c', name: 'New Field: MightySignal iOS Publisher Id' }, { id: 'AccountNumber', name: 'Account Number' }],
            },
            {
              platform: 'android', id: 'MightySignal Android Publisher ID', name: 'MightySignal Android Publisher ID', fields: [{ id: 'MightySignal_Android_Publisher_ID__c', name: 'New Field: MightySignal Android Publisher Id' }, { id: 'AccountNumber', name: 'Account Number' }],
            },
            { id: 'Publisher Name', name: 'Publisher Name', fields: [{ id: 'Name', name: 'Name' }, { id: 'MightySignal_Publisher_Name__c', name: 'New Field: MightySignal Publisher Name' }] },
            { id: 'Website', name: 'Website', fields: [{ id: 'Website', name: 'Website' }, { id: 'MightySignal_Publisher_Website__c', name: 'New Field: MightySignal Publisher Website' }] },
            {
              platform: 'ios', id: 'MightySignal iOS SDK Summary', name: 'MightySignal iOS SDK Summary', fields: [{ id: 'MightySignal_iOS_SDK_Summary__c', name: 'New Field: MightySignal iOS SDK Summary' }],
            },
            {
              platform: 'android', id: 'MightySignal Android SDK Summary', name: 'MightySignal Android SDK Summary', fields: [{ id: 'MightySignal_Android_SDK_Summary__c', name: 'New Field: MightySignal Android SDK Summary' }],
            },
            {
              platform: 'ios', id: 'MightySignal iOS Link', name: 'MightySignal iOS Link', fields: [{ id: 'MightySignal_iOS_Link__c', name: 'New Field: MightySignal iOS Link' }],
            },
            {
              platform: 'android', id: 'MightySignal Android Link', name: 'MightySignal Android Link', fields: [{ id: 'MightySignal_Android_Link__c', name: 'New Field: MightySignal Android Link' }],
            },
          ],
        };

        // load salesforce settings
        authService.accountInfo()
          .success((data) => {
            $scope.salesforceSettings = data.salesforce_settings || { default_mapping: {} };
            $scope.salesforceSettings.salesforceUrl = data.instance_url;
            if ($scope.salesforceSettings.default_object) {
              $scope.sfObject = $scope.salesforceSettings.default_object;
              $scope.selectedExportClass();
            }
          });

        $scope.selectedExportClass = function() {
          $scope.removeSelectedObject();
          const mapping = $scope.salesforceSettings.default_mapping[$scope.sfObject];

          // if there is only one option for mapping, choose it by default
          $scope.sfMappingForm[$scope.sfObject].forEach((field) => {
            if (field.fields && field.fields.length == 1) {
              $scope.sfMapping[$scope.sfObject][field.name] = field.fields[0];
            } else if (!field.fields) {
              $scope.sfMapping[$scope.sfObject][field.name] = { id: field.id };
            }

            // populate mapping from saved salesforce settings
            if (mapping && mapping[field.id] && (!field.platform || field.platform == $scope.app.platform)) {
              $scope.sfMapping[$scope.sfObject][field.name] = mapping[field.id];
              if (!$scope.sfMapping[$scope.sfObject][field.name].id) {
                $scope.sfMapping[$scope.sfObject][field.name].id = field.id;
              }
            }
          });
        };

        $scope.objectAutocompleteUrl = function() {
          return `${window.API_URI_BASE}api/salesforce/search?model=${$scope.sfObject}&query=`;
        };

        $scope.selectedObject = function ($item) {
          $scope.existingObject = $item.originalObject;
          // populate email, name and title when user selects a lead
          if ($scope.sfObject == 'Lead') {
            $scope.sfMapping.Lead.Title.data = $scope.existingObject.title;
            $scope.sfMapping.Lead.Email.data = $scope.existingObject.email;
            $scope.sfMapping.Lead['Last Name'].data = $scope.existingObject.first_name;
            $scope.sfMapping.Lead['First Name'].data = $scope.existingObject.last_name;
          }
        };

        $scope.removeSelectedObject = function() {
          $scope.existingObject = null;
        };

        $scope.placeholderText = function() {
          switch ($scope.sfObject) {
            case 'Account':
              return 'Search on Account Name';
            case 'Lead':
              return 'Search on Lead Company Name';
          }
        };

        $scope.export = function() {
          const params = { mapping: $scope.sfMapping[$scope.sfObject], model: $scope.sfObject };
          if ($scope.existingObject) {
            params.objectId = $scope.existingObject.id;
          }

          params[`${$scope.app.platform}_app_id`] = $scope.app.id;

          const slacktivityData = {
            title: 'Exported App to Salesforce',
            color: '#FFD94D', // yellow
            publisherName: $scope.app.publisher.name,
            appName: $scope.app.name,
            appId: $scope.app.id,
            appPlatform: $scope.app.platform,
          };
          slacktivity.notifySlack(slacktivityData);
          mixpanel.track('Exported App to Salesforce', {
            publisherName: $scope.app.publisher.name,
            appName: $scope.app.name,
            appId: $scope.app.id,
            appPlatform: $scope.app.platform,
            exportObject: $scope.sfObject,
          });

          $scope.isExporting = true;
          return $http({
            method: 'POST',
            url: `${window.API_URI_BASE}api/salesforce/export`,
            params,
          }).success((data) => {
            $scope.isExporting = false;
            $scope.exportId = data.success;
          }).error((data) => {
            $scope.isExporting = false;
            alert(`There was an error exporting your ${$scope.sfObject}. Please try again.`);
            mixpanel.track('Exported App to Salesforce Failed', {
              publisherName: $scope.app.publisher.name,
              appName: $scope.app.name,
              appId: $scope.app.id,
              appPlatform: $scope.app.platform,
              exportObject: $scope.sfObject,
            });
          });
        };
      }],
    };
  }])
  .directive('appPlatformToggle', ['apiService', '$rootScope', '$location', 'AppPlatform', 'dropdownCategoryFilter', function (apiService, $rootScope, $location, AppPlatform, dropdownCategoryFilter) {
    return {
      replace: true,
      restrict: 'E',
      template: '<span class="btn-group" id="dashboardPlatformSwitch"><button type="button" ng-class="appPlatform.platform == \'ios\' ? \'btn-primary\' : \'btn-default\'" class="btn" ng-click="changeAppPlatform(\'ios\')">iOS</button><button type="button" ng-class="appPlatform.platform == \'android\' ? \'btn-primary\' : \'btn-default\'" class="btn" ng-click="changeAppPlatform(\'android\')">Android</button></span>',
      controller: ['$scope', function ($scope) {
        $scope.appPlatform = AppPlatform;

        $scope.emptyDropdownModels = function () {
          $rootScope.categoryModel = [];
          $rootScope.downloadsModel = [];
        };

        $scope.changeAppPlatform = function (platform) {
          $scope.appPlatform.platform = platform;
          window.APP_PLATFORM = platform;

          if ($location.path() == '/search') {
            apiService.getCategories().success((data) => {
              $rootScope.categoryFilterOptions = dropdownCategoryFilter(data);
            });

            $scope.emptyDropdownModels();

            $rootScope.sdkCategoryFilterOptions = apiService.getSdkCategories().success((data) => {
              $rootScope.sdkCategories = data;
            });

            // Removes all sdk & download filters upon platform switch to iOS
            if ($scope.appPlatform != 'android') {
              for (let index = 0; index < $rootScope.tags.length; index++) {
                const platformSpecificParameters = ['sdkFiltersAnd', 'sdkFiltersOr', 'sdkCategoryFiltersAnd', 'sdkCategoryFiltersOr', 'locationFiltersAnd', 'locationFiltersOr', 'downloads', 'categories', 'supportDesk'];
                if ($rootScope.tags[index] && platformSpecificParameters.indexOf($rootScope.tags[index].parameter) > -1) {
                  if (($rootScope.tags[index].parameter == 'locationFiltersOr' || $rootScope.tags[index].parameter == 'locationFiltersAnd') && $rootScope.tags[index].value.status == '0') continue;
                  $rootScope.tags.splice(index, 1);
                  index -= 1;
                }
              }
            }
          }
        };
      }],
      controllerAs: 'appPlatformCtrl',
    };
  }])
  .directive('customPlatformSelect', ['apiService', 'authToken', '$rootScope', 'AppPlatform', 'authService', function (apiService, authToken, $rootScope, AppPlatform, authService) {
    return {
      replace: true,
      restrict: 'E',
      scope: {
        customSearchPlatform: '=customSearchPlatform',
      },
      template: '<span class="ui-select"> <select ng-model="searchPlatform" ng-init="searchPlatform = \'ios\'" ng-change="changeAppPlatform(searchPlatform)"><option value="ios">iOS Apps</option><option value="android" selected="selected">Android Apps</option><option ng-if="canViewStorewideSdks" value="iosSdks">iOS SDKs</option><option ng-if="canViewStorewideSdks" value="androidSdks">Android SDKs</option></select></span>',
      controller: ['$scope', function ($scope) {
        $scope.appPlatform = AppPlatform;

        if (authToken.isAuthenticated()) {
          authService.permissions()
            .success((data) => {
              $scope.canViewStorewideSdks = data.can_view_storewide_sdks;
            });
        }

        $scope.changeAppPlatform = function (platform) {
          $scope.customSearchPlatform = platform;
        };
      }],
      controllerAs: 'appPlatformCtrl',
    };
  }])
  .directive('ddTextCollapse', ['$compile', function($compile) {
    return {
      restrict: 'A',
      scope: true,
      link(scope, element, attrs) {
        // start collapsed
        scope.collapsed = false;
        // create the function to toggle the collapse
        scope.toggle = function() {
          scope.collapsed = !scope.collapsed;
        };
        // wait for changes on the text
        attrs.$observe('ddTextCollapseText', (text) => {
          // get the length from the attributes
          const maxLength = scope.$eval(attrs.ddTextCollapseMaxLength);
          if (text.length > maxLength) {
            // split the text in two parts, the first always showing
            const firstPart = String(text).substring(0, maxLength);
            const secondPart = String(text).substring(maxLength, text.length);
            // create some new html elements to hold the separate info
            const firstSpan = $compile(`<span>${firstPart}</span>`)(scope);
            const secondSpan = $compile(`<span ng-if="collapsed">${secondPart}</span>`)(scope);
            const moreIndicatorSpan = $compile('<span ng-if="!collapsed">... </span>')(scope);
            const lineBreak = $compile('<br ng-if="collapsed">')(scope);
            const toggleButton = $compile('<span class="collapse-text-toggle" ng-click="toggle()">{{collapsed ? "READ LESS" : "READ MORE"}}</span>')(scope);
            // remove the current contents of the element
            // and add the new ones we created
            element.empty();
            element.append(firstSpan);
            element.append(secondSpan);
            element.append(moreIndicatorSpan);
            element.append(lineBreak);
            element.append(toggleButton);
          } else {
            element.empty();
            element.append(text);
          }
        });
      },
    };
  }])
  .directive('focusMe', ['$timeout', function($timeout) {
    return {
      link(scope, element, attrs) {
        scope.$watch(attrs.focusMe, (value) => {
          if (value === true) {
            $timeout(() => {
              element[0].focus();
              scope[attrs.focusMe] = false;
            }, 550);
          }
        });
      },
    };
  }])
  .directive('clickOutside', ['$document', function ($document) {
    return {
      restrict: 'A',
      scope: {
        clickOutside: '&',
      },
      link (scope, el, attr) {
        $document.on('click', (e) => {
          if (el !== e.target && !el[0].contains(e.target)) {
            scope.$apply(() => {
              scope.$eval(scope.clickOutside);
            });
          }
        });
      },
    };
  }])
  .directive('starRating', () => ({
    restrict: 'EA',
    template: '<span>' +
						 "  <span ng-repeat='star in stars' ng-class='star'>" +
						 "    <i class='fa fa-star'></i>" + // &#9733
						 '  </span>' +
						 "  <span ng-repeat='half in halfStars' ng-class='star'>" +
						 "    <i class='fa fa-star-half-o'></i>" + // &#9733
						 '  </span>' +
						 "  <span ng-repeat='empty in emptyStars' ng-class='star'>" +
						 "    <i class='fa fa-star-o'></i>" + // &#9733
						 '  </span>' +
						 '</span>',
    scope: {
      ratingValue: '=ngModel',
      max: '=?', // optional: default is 5
    },
    link(scope, elem, attrs) {
      if (scope.max === undefined) { scope.max = 5; }
      function updateStars() {
        scope.stars = [];
        scope.halfStars = [];
        scope.emptyStars = [];
        scope.starCount = parseFloat(scope.ratingValue, 10);
    					if (scope.starCount % 1 === 0) {
    						for (var i = 0; i < scope.starCount; i++) {
    							scope.stars.push({
    								filled: i,
    							});
    						}
    					}

    					if (scope.starCount % 1 !== 0) {
    						for (var j = 0; j < scope.starCount - 1; j++) {
    							scope.stars.push({
    								filled: j < scope.starCount - 1,
    							});
    						}
    						scope.halfStars.push({
    							filled: j < 1,
    						});
    					}

        const remainingStars = scope.max - scope.stars.length - scope.halfStars.length;
        for (var i = 0; i < remainingStars; i++) {
          scope.emptyStars.push({ filled: i });
        }
    				}

      scope.$watch('ratingValue', (oldVal, newVal) => {
				  if (newVal) { updateStars(); }
      });
    },
  }))
  .directive('smartSrc', ['$http', function($http) {
    return {
      restrict: 'A',
      scope: {
        smartSrc: '@',
        smartSrcId: '@',
        smartSrcWatch: '&',
        smartSrcLast: '@',
      },
      link(scope, element) {
        var unwatcher = scope.$watch(scope.smartSrcWatch, (newId) => {
          const idx = parseInt(scope.smartSrcId, 10);
          const loadIndices = [
            idx, idx + 1, idx - 1,
          ];

          if ((loadIndices.includes(newId) || idx == scope.smartSrcLast) && scope.smartSrc) {
            element.attr('src', scope.smartSrc);
            unwatcher();
          }
        });
      },
    };
  }]);
