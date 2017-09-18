'use strict';

angular.module("appApp")
  .factory("filterService", ["$rootScope",
    function($rootScope) {
      return {
        userbaseDisplayText: function(filter, filterType) {
          var displayName;
          switch(filter.status) {
            case "0":
              displayName = 'User Base'
              break
            case "1":
              displayName = 'Daily Active Users'
              break
            case "2":
              displayName = 'Weekly Active Users'
              break
            case "3":
              displayName = 'Monthly Active Users'
              break
          }
          return filterType + ' ' + displayName
        },
        sdkDisplayText: function(filter, filterOperation, filterType) {
          var displayName = filterType == 'sdk' ? 'SDK' : 'SDK Category'

          if (filter.status == "0") {
            displayName = displayName + ' Installed'
          } else if (filter.status == '1') {
            displayName = displayName + ' Uninstalled'
          } else if (filter.status == '2') {
            displayName = displayName + ' Never Seen'
          } else {
            displayName = displayName + ' Uninstalled or Never Installed'
          }

          if (filter.status == "0" || filter.status == "1") { // Only install or uninstall should show date
            switch (filter.date) {
              case "0":
                displayName = displayName + ' Anytime'
                break
              case "1":
                displayName = displayName + ' Less Than 1 Week Ago'
                break
              case "2":
                displayName = displayName + ' Less Than 1 Month Ago'
                break
              case "3":
                displayName = displayName + ' Less Than 3 Months Ago'
                break
              case "4":
                displayName = displayName + ' Less Than 6 Months Ago'
                break
              case "5":
                displayName = displayName + ' Less Than 9 Months Ago'
                break
              case "6":
                displayName = displayName + ' Less Than 1 Year Ago'
                break
              case "7":
                displayName = displayName + ` Between ${moment(filter.dateRange.from).format('L')} and ${moment(filter.dateRange.until).format('L')}`
                break
              case "8":
                displayName = displayName + ' Between 1 Week and 1 Month Ago'
                break
              case "9":
                displayName = displayName + ' Between 1 Months and 3 Months Ago'
                break
              case "10":
                displayName = displayName + ' Between 3 Months and 6 Months Ago'
                break
              case "11":
                displayName = displayName + ' Between 6 Months and 9 Months Ago'
                break
              case "12":
                displayName = displayName + ' Between 9 Months and 1 Year Ago'
                break
            }
          }

          return filterOperation + ' ' + displayName;
        },
        locationDisplayText: function(filter, filterType) {
          var displayName = ''

          if (filter.status == "0") {
            displayName = 'Headquartered in' + displayName
          } else if (filter.status == '1') {
            displayName = 'Only available in' + displayName
          } else if (filter.status == '2') {
            displayName = 'Available in' + displayName
          } else if (filter.status == '3') {
            displayName = 'Not Available in' + displayName
          }

          return filterType + ' ' + displayName;
        },
        hasFilter: function(parameter) {
          for(var i = $rootScope.tags.length - 1; i >= 0 ; i--){
              if($rootScope.tags[i].parameter == parameter){
                  return true;
              }
          }
          return false
        },
        changeFilter: function(parameter, oldValue, value, newDisplayText) {
          for(var i = $rootScope.tags.length - 1; i >= 0 ; i--){
            // only check for value if value exists
            if ($rootScope.tags[i].parameter == parameter && this.tagsAreEqual($rootScope.tags[i], oldValue)) {
              var possible = ["status", "date", "state", "id", "name", "dateRange"]
              for (var y = 0; y < possible.length; y++) {
                if (value[possible[y]]) {
                  $rootScope.tags[i].value[possible[y]] = value[possible[y]]
                }
              }
              if (value.state && value.state != "0") {
                $rootScope.tags[i].text = newDisplayText + ': ' + value.state + ', ' + $rootScope.tags[i].value.name
              } else {
                $rootScope.tags[i].text = newDisplayText + ': ' + $rootScope.tags[i].value.name
              }
              break
            }
          }
        },
        clearAllSdkCategoryTags: function () {
          _.remove($rootScope.tags, tag => tag.parameter.includes('sdkCategoryFilters'))
        },
        removeFilter: function(parameter, value) {
          for(var i = $rootScope.tags.length - 1; i >= 0 ; i--){
            // only check for value if value exists
            if ($rootScope.tags[i].parameter == parameter && (!value || this.tagsAreEqual($rootScope.tags[i], value))) {
              $rootScope.tags.splice(i, 1);
            }
          }
        },
        tagsAreEqual: function(tag1, tag2) {
          const value = tag1.value
          return (value == tag2) || (typeof value.id !== 'undefined' && typeof tag2.id !== 'undefined' && value.id == tag2.id && value.status == tag2.status && value.date == tag2.date && value.state == tag2.state)
        },
        addFilter: function(parameter, value, displayName, limitToOneFilter, customName) {
          /* -------- Mixpanel Analytics Start -------- */
          var mixpanelProperties = {};
          mixpanelProperties['parameter'] = parameter;
          mixpanelProperties[parameter] = value;
          mixpanel.track(
            "Filter Added",
            mixpanelProperties
          );
          /* -------- Mixpanel Analytics End -------- */

          var duplicateTag = false;
          var oneTagUpdated = false;
          var self = this
          $rootScope.tags.forEach(function (tag) {

            // Determine if tag is a duplicate (for tags with objects for values)
            if(tag.value.id !== undefined && tag.parameter == parameter && self.tagsAreEqual(tag, value)) {
              duplicateTag = true;
            }

            // Determine if tag is a duplicate for normal tags (with non-object values)
            if (tag.parameter == parameter && tag.value == value) {
              duplicateTag = true;
            }

            if(limitToOneFilter && !duplicateTag) {
              // If replacing pre existing tag of limitToOneFilter = true category
              if (tag.parameter == parameter) {
                tag.value = value;
                tag.text = displayName + ': ' + (customName ? customName : value);
                oneTagUpdated = true;
              }
            }
          });

          if(limitToOneFilter && !duplicateTag && !oneTagUpdated) {
            // If first tag of limitToOneFilter = true category
            $rootScope.tags.push({
              parameter: parameter,
              value: value,
              text: displayName + ': ' + (customName ? customName : value)
            });
          }
          var complexFilters = ['sdkFiltersOr', 'sdkFiltersAnd', 'sdkCategoryFiltersOr', 'sdkCategoryFiltersOr', 'locationFiltersAnd', 'locationFiltersOr', 'userbaseFiltersOr', 'userbaseFiltersAnd']
          if(!limitToOneFilter && (!duplicateTag || complexFilters.indexOf(parameter) > -1) || $rootScope.tags.length < 1) {
            $rootScope.tags.push({
              parameter: parameter,
              value: value,
              text: displayName + ': ' + (customName ? customName : value)
            });
          }
        }
      };
    }
  ]);
