'use strict'

angular.module('appApp')
  .controller("FilterCtrl", ["$scope", "apiService", "$http", "$rootScope", "filterService",
    function($scope, apiService, $http, $rootScope, filterService) {

      $scope.mixpanelAnalyticsEventTooltip = function(name) {
        /* -------- Mixpanel Analytics Start -------- */
        mixpanel.track(
          "Methodology Modal Viewed",
          { "tooltipName": name }
        );
        /* -------- Mixpanel Analytics End -------- */
      };

      if(!$rootScope.tags) $rootScope.tags = [];

      $scope.categorySelectEvents = {
        onItemSelect: function(item) {
          $scope.onFilterChange('categories', item.label, 'Category', false)
        },
        onItemDeselect: function(item) {
          filterService.removeFilter('categories', item.id)
        },
        onSelectAll: function() {
          $rootScope.categoryFilterOptions.forEach(category => $scope.onFilterChange('categories', category.label, 'Category', false))
        },
        onDeselectAll: function() {
          filterService.removeFilter('categories')
        }
      };

      $scope.chartSelectEvents = {
        onItemSelect: function(item) {
          $scope.onFilterChange('charts', item.id, 'Chart', false)
        },
        onItemDeselect: function(item) {
          filterService.removeFilter('charts', item.id)
        },
        onSelectAll: function() {
          $rootScope.chartFilterOptions.forEach(chart => $scope.onFilterChange('charts', chart.id, 'Chart', false))
        },
        onDeselectAll: function() {
          filterService.removeFilter('charts')
        }
      };

      $scope.downloadsSelectEvents = {
        onItemSelect: function(item) {
          $scope.onFilterChange('downloads', item.id, 'Downloads', false)
        },
        onItemDeselect: function(item) {
          filterService.removeFilter('downloads', item.id)
        },
        onSelectAll: function() {
          $rootScope.downloadsFilterOptions.forEach(download => $scope.onFilterChange('downloads', download.id, 'Downloads', false))
        },
        onDeselectAll: function() {
          filterService.removeFilter('downloads')
        }
      };

      $scope.mobilePrioritySelectEvents = {
        onItemSelect: function(item) {
          $scope.onFilterChange('mobilePriority', item.id, 'Mobile Priority', false)
        },
        onItemDeselect: function(item) {
          filterService.removeFilter('mobilePriority', item.id)
        },
        onSelectAll: function() {
          $rootScope.mobilePriorityFilterOptions.forEach(priority => $scope.onFilterChange('mobilePriority', priority.id, 'Mobile Priority', false))
        },
        onDeselectAll: function() {
          filterService.removeFilter('mobilePriority')
        }
      };

      $scope.userbaseSelectEvents = {
        onItemSelect: function(item) {
          $scope.onFilterChange('userBases', item.id, 'User Base Size', false)
        },
        onItemDeselect: function(item) {
          filterService.removeFilter('userBases', item.id)
        },
        onSelectAll: function() {
          $rootScope.userbaseFilterOptions.forEach(priority => $scope.onFilterChange('userBases', priority.id, 'User Base Size', false))
        },
        onDeselectAll: function() {
          filterService.removeFilter('userBases')
        }
      };

      $scope.onFilterChange = function(parameter, value, displayName, limitToOneFilter, customName) {
        if(parameter == 'downloads') {
          const tagText = $rootScope.downloadsFilterOptions[value].label
          filterService.addFilter(parameter, value, displayName, limitToOneFilter, tagText);
        } else {
          filterService.addFilter(parameter, value, displayName, limitToOneFilter, customName);
        }
        $scope[parameter] = ""; // Resets HTML select on view to default option
      };
    }
  ])
