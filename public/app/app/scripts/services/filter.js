'use strict';

angular.module("appApp")
  .factory("filterService", ["$rootScope",
    function($rootScope) {
      return {
        hasFilter: function(parameter) {
          for(var i = $rootScope.tags.length - 1; i >= 0 ; i--){
              if($rootScope.tags[i].parameter == parameter){
                  return true;
              }
          }
          return false
        },
        removeFilter: function(parameter, value) {
          for(var i = $rootScope.tags.length - 1; i >= 0 ; i--){
              // only check for value if value exists
              if($rootScope.tags[i].parameter == parameter && (!value || ($rootScope.tags[i].value == value))){
                  $rootScope.tags.splice(i, 1);
              }
          }
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

          $rootScope.tags.forEach(function (tag) {

            // Determine if tag is a duplicate (for tags with objects for values)
            if(tag.value.id !== undefined && tag.parameter == parameter && tag.value.id == value.id) {
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
