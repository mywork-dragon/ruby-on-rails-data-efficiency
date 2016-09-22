'use strict';

angular.module("appApp")
  .factory("filterService", ["$rootScope",
    function($rootScope) {
      return {
        sdkDisplayText: function(filter, filterType) {
          var displayName = 'SDK'

          if (filter.status == "0") {
            displayName = 'First Seen ' + displayName
          } else if (filter.status == '1') {
            displayName = 'Last Seen ' + displayName
          } else if (filter.status == '2') {
            displayName = 'Never Seen ' + displayName
          } else {
            displayName = 'Uninstalled or Never Installed ' + displayName
          }

          if (filter.status == "0" || filter.status == "1") { // Only install or uninstall should show date
            if (filter.date == "0") {
              displayName = displayName + ' Anytime'
            } else if (filter.date == '1') {
              displayName = displayName + ' < 1 Week Ago'
            } else if (filter.date == '2') {
             displayName = displayName + ' Between 1 Week and 1 Month Ago'
            } else if (filter.date == '3') {
              displayName = displayName + ' Between 1 Month and 3 Months Ago'
            } else if (filter.date == '4') {
              displayName = displayName + ' Between 3 Months and 6 Months Ago'
            } else if (filter.date == '5') {
              displayName = displayName + ' Between 6 Months and 9 Months Ago'
            } else if (filter.date == '6') {
              displayName = displayName + ' Between 9 Months and 1 Year Ago'
            } else if (filter.date == '7') {
              displayName = displayName + ' > 1 Year Ago'
            }
          }
         
          return filterType + ' ' + displayName;
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
              var possible = ["status", "date", "state"]
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
        removeFilter: function(parameter, value) {
          for(var i = $rootScope.tags.length - 1; i >= 0 ; i--){
            // only check for value if value exists
            if ($rootScope.tags[i].parameter == parameter && (!value || this.tagsAreEqual($rootScope.tags[i], value))) {
              $rootScope.tags.splice(i, 1);
            }
          }
        },
        tagsAreEqual: function(tag1, tag2) {
          return (tag1.value == tag2) || (tag1.value.id && tag2.id && tag1.value.id == tag2.id && tag1.value.status == tag2.status && tag1.value.date == tag2.date && tag1.value.state == tag2.state)
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
          var complexFilters = ['sdkFiltersOr', 'sdkFiltersAnd', 'locationFiltersAnd', 'locationFiltersOr']
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
