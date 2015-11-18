'use strict';

angular.module("appApp")
  .factory("filterService", ["$rootScope",
    function($rootScope) {
      return {
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

          $rootScope.tags.forEach(function (tag) {

            // Determine if tag is a duplicate
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

          if(!limitToOneFilter && !duplicateTag || $rootScope.tags.length < 1) {
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
