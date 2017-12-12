import angular from 'angular';
import mixpanel from 'mixpanel-browser';

angular.module('appApp')
  .controller('FilterCtrl', ['$scope', 'apiService', '$http', '$rootScope', 'filterService',
    function ($scope, apiService, $http, $rootScope, filterService) {
      $scope.mixpanelAnalyticsEventTooltip = function (name) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          'Methodology Modal Viewed',
          { tooltipName: name },
        );
        /* -------- Mixpanel Analytics End -------- */
      };

      if (!$rootScope.tags) $rootScope.tags = [];

      $scope.categorySelectEvents = {
        onItemSelect(item) {
          $scope.onFilterChange('categories', item.label, 'Category', false);
        },
        onItemDeselect(item) {
          filterService.removeFilter('categories', item.id);
        },
        onSelectAll() {
          $rootScope.categoryFilterOptions.forEach(category => $scope.onFilterChange('categories', category.label, 'Category', false));
        },
        onDeselectAll() {
          filterService.removeFilter('categories');
        },
      };

      $scope.chartSelectEvents = {
        onItemSelect(item) {
          $scope.onFilterChange('charts', item.id, 'Chart', false);
        },
        onItemDeselect(item) {
          filterService.removeFilter('charts', item.id);
        },
        onSelectAll() {
          $rootScope.chartFilterOptions.forEach(chart => $scope.onFilterChange('charts', chart.id, 'Chart', false));
        },
        onDeselectAll() {
          filterService.removeFilter('charts');
        },
      };

      $scope.downloadsSelectEvents = {
        onItemSelect(item) {
          $scope.onFilterChange('downloads', item.id, 'Downloads', false);
        },
        onItemDeselect(item) {
          filterService.removeFilter('downloads', item.id);
        },
        onSelectAll() {
          $rootScope.downloadsFilterOptions.forEach(download => $scope.onFilterChange('downloads', download.id, 'Downloads', false));
        },
        onDeselectAll() {
          filterService.removeFilter('downloads');
        },
      };

      $scope.mobilePrioritySelectEvents = {
        onItemSelect(item) {
          $scope.onFilterChange('mobilePriority', item.id, 'Mobile Priority', false);
        },
        onItemDeselect(item) {
          filterService.removeFilter('mobilePriority', item.id);
        },
        onSelectAll() {
          $rootScope.mobilePriorityFilterOptions.forEach(priority => $scope.onFilterChange('mobilePriority', priority.id, 'Mobile Priority', false));
        },
        onDeselectAll() {
          filterService.removeFilter('mobilePriority');
        },
      };

      $scope.userbaseSelectEvents = {
        onItemSelect(item) {
          $scope.onFilterChange('userBases', item.id, 'User Base Size', false);
        },
        onItemDeselect(item) {
          filterService.removeFilter('userBases', item.id);
        },
        onSelectAll() {
          $rootScope.userbaseFilterOptions.forEach(priority => $scope.onFilterChange('userBases', priority.id, 'User Base Size', false));
        },
        onDeselectAll() {
          filterService.removeFilter('userBases');
        },
      };

      $scope.onFilterChange = function (parameter, value, displayName, limitToOneFilter, customName) {
        if (parameter === 'downloads') {
          const tagText = $rootScope.downloadsFilterOptions[value].label;
          filterService.addFilter(parameter, value, displayName, limitToOneFilter, tagText);
        } else {
          filterService.addFilter(parameter, value, displayName, limitToOneFilter, customName);
        }
        $scope[parameter] = ''; // Resets HTML select on view to default option
      };
    },
  ]);
