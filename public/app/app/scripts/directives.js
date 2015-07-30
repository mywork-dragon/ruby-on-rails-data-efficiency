
/*
 App custom Directives
 Custom directives for the app like custom background, minNavigation etc
 */

angular.module("app.directives", []).directive("imgHolder", [
        function() {
            return {
                link: function(scope, ele) {
                    return Holder.run({
                        images: ele[0]
                    });
                }
            };
        }
    ]).directive("customBackground", function() {
        return {
            controller: ["$scope", "$element", "$location",
                function($scope, $element, $location) {
                    var addBg, path;
                    return path = function() {
                        return $location.path();
                    }, addBg = function(path) {
                        switch ($element.removeClass("body-home body-special body-tasks body-lock"), path) {
                            case "/":
                                return $element.addClass("body-home");
                            case "/404":
                            case "/app.ui.ctrlses/500":
                            case "/pages/signin":
                            case "/pages/signup":
                            case "/pages/forgot":
                                return $element.addClass("body-special");
                            case "/pages/lock-screen":
                                return $element.addClass("body-special body-lock");
                            case "/tasks":
                                return $element.addClass("body-tasks");
                        }
                    }, addBg($location.path()), $scope.$watch(path, function(newVal, oldVal) {
                        return newVal !== oldVal ? addBg($location.path()) : void 0;
                    });
                }
            ]
        };
    }).directive("uiColorSwitch", [
        function() {
            return {
                restrict: "A",
                link: function(scope, ele) {
                    return ele.find(".color-option").on("click", function(event) {
                        var $this, hrefUrl, style;
                        if ($this = $(this), hrefUrl = void 0, style = $this.data("style"), "loulou" === style){
                            hrefUrl = "styles/main.css";
                            $('link[href^="styles/main"]').attr("href", hrefUrl);
                        }
                        else {
                            if (!style) return !1;
                            style = "-" + style;
                            hrefUrl = "styles/main" + style + ".css";
                            $('link[href^="styles/main"]').attr("href", hrefUrl);
                        }
                        return event.preventDefault();
                    });
                }
            };
        }
    ]).directive("toggleMinNav", ["$rootScope",
        function($rootScope) {
            return {
                link: function(scope, ele) {
                    var $content, $nav, $window, Timer, app, updateClass;

                    return app = $("#app"), $window = $(window), $nav = $("#nav-container"), $content = $("#content"), ele.on("click", function(e) {

                        if(app.hasClass("nav-min")){
                            app.removeClass("nav-min");
                        }
                        else{
                            app.addClass("nav-min");
                            $rootScope.$broadcast("minNav:enabled");
                            e.preventDefault();
                        }

                    }), Timer = void 0, updateClass = function() {
                        var width;
                        return width = $window.width(), 980 > width ? app.addClass("nav-min") : void 0;
                    },initResize = function() {
                        var width;
                        return width = $window.width(), 980 > width ? app.addClass("nav-min") : app.removeClass("nav-min");
                    }, $window.resize(function() {
                        var t;
                        return clearTimeout(t), t = setTimeout(updateClass, 300);
                    }),initResize();

                }
            };
        }
    ]).directive("collapseNav", [
        function() {
            return {
                link: function(scope, ele) {
                    var $a, $aRest, $lists, $listsRest, app;
                    return $lists = ele.find("ul").parent("li"),
                        $lists.append('<i class="fa fa-arrow-circle-o-right icon-has-ul"></i>'),
                        $a = $lists.children("a"),
                        $listsRest = ele.children("li").not($lists),
                        $aRest = $listsRest.children("a"),
                        app = $("#app"),
                        $a.on("click", function(event) {
                            var $parent, $this;
                            return app.hasClass("nav-min") ? !1 : ($this = $(this),
                                $parent = $this.parent("li"),
                                $lists.not($parent).removeClass("open").find("ul").slideUp(),
                                $parent.toggleClass("open").find("ul").stop().slideToggle(), event.preventDefault());
                        }), $aRest.on("click", function() {
                        return $lists.removeClass("open").find("ul").slideUp();
                    }), scope.$on("minNav:enabled", function() {
                        return $lists.removeClass("open").find("ul").slideUp();
                    });
                }
            };
        }
    ]).directive("highlightActive", [
        function() {
            return {
                controller: ["$scope", "$element", "$attrs", "$location",
                    function($scope, $element, $attrs, $location) {
                        var highlightActive, links, path;
                        return links = $element.find("a"), path = function() {
                            return $location.path();
                        }, highlightActive = function(links, path) {
                            return path = "#" + path, angular.forEach(links, function(link) {
                                var $li, $link, href;
                                return $link = angular.element(link), $li = $link.parent("li"), href = $link.attr("href"), $li.hasClass("active") && $li.removeClass("active"), 0 === path.indexOf(href) ? $li.addClass("active") : void 0;
                            });
                        }, highlightActive(links, $location.path()), $scope.$watch(path, function(newVal, oldVal) {
                            return newVal !== oldVal ? highlightActive(links, $location.path()) : void 0;
                        });
                    }
                ]
            };
        }
    ]).directive("toggleOffCanvas", [
        function() {
            return {
                link: function(scope, ele) {
                    return ele.on("click", function() {
                        return $("#app").toggleClass("on-canvas").toggleClass("nav-min");
                    });
                }
            };
        }
    ]).directive("slimScroll", [
        function() {
            return {
                link: function(scope, ele, attrs) {
                    return ele.slimScroll({
                        height: attrs.scrollHeight || "100%"
                    });
                }
            };
        }
    ]).directive("goBack", [
        function() {
            return {
                restrict: "A",
                controller: ["$scope", "$element", "$window",
                    function($scope, $element, $window) {
                        return $element.on("click", function() {
                            return $window.history.back();
                        });
                    }
                ]
            };
        }
    ]).directive('ngEnter', function () {
        return function (scope, element, attrs) {
            element.bind("keydown keypress", function (event) {
                if(event.which === 13) {
                    scope.$apply(function (){
                        scope.$eval(attrs.ngEnter);
                    });

                    event.preventDefault();
                }
            });
          };
      })
    .filter('filesize', function () {
      return function (size) {
        if (isNaN(size))
          size = 0;

        if (size < 1024)
          return size + ' B';

        size /= 1024;

        if (size < 1024)
          return size.toFixed(0) + ' KB';

        size /= 1024;

        if (size < 1024)
          return size.toFixed(0) + ' MB';

        size /= 1024;

        if (size < 1024)
          return size.toFixed(0) + ' GB';

        size /= 1024;

        return size.toFixed(0) + ' TB';
      };
    })
    .filter('thousandSuffix', function () {
      return function (input, decimals) {
        var exp, rounded,
          suffixes = ['K', 'M', 'G', 'T', 'P', 'E'];

        if(window.isNaN(input)) {
          return null;
        }

        if(input < 1000) {
          return input;
        }

        exp = Math.floor(Math.log(input) / Math.log(1000));

        return (input / Math.pow(1000, exp)).toFixed(decimals) + suffixes[exp - 1];
      };
    })
    .filter('supportDeskName', function () {
      return function (url) {
        if(!url) return "";

        var result = "";
        var supportDeskNames = [
          'Zendesk',
          'Helpshift',
          'UserVoice',
          'Freshdesk',
          'Desk'
        ];

        var domain = url.toLowerCase().split('.');

        supportDeskNames.forEach(function(name) {
          if (domain.length > 1 && domain[domain.length - 2] == name.toLowerCase()) {
            result = name;
          }
        });
        return result;
      };
    })
    .directive('selectAllCheckbox', ["$rootScope", function ($rootScope) {
          return {
            replace: true,
            restrict: 'E',
            scope: {
              apps: '@apps'
            },
            template: '<input type="checkbox" ng-model="checkboxMaster" ng-click="checkboxMasterChange()">',
            controller: function ($scope, $element) {

              $scope.checkboxMasterChange = function () {
                if ($scope.checkboxMaster) {
                  $rootScope.selectedAppsForList = [];
                  angular.forEach($scope.apps, function (app, index) {
                    $rootScope.selectedAppsForList.push({id: app.id, type: app.type});
                  });
                } else {
                  $rootScope.selectedAppsForList = [];
                }
              };

              $scope.$watch('$root.selectedAppsForList', function () {

                /* Controls 'checked' status of master checkbox (top checkbox). Three states: [ ], [X] and [-] */
                if($rootScope.selectedAppsForList.length == $scope.apps.length) {
                  $element.prop('checked', true);
                } else {
                  $element.prop('checked', false);
                }

              }, true);
            }
          };
        }])
    .directive('checkableCheckbox', ["$rootScope", "listApiService", function ($rootScope, listApiService) {
          return {
            replace: true,
            restrict: 'E',
            scope: {
              app: '=app',
              apps: '@apps'
            },
            template: '<input type="checkbox" ng-model="appCheckbox" ng-click="addAppToList()">',
            controller: function ($scope, $element) {

              $scope.addAppToList = function() {
                listApiService.modifyCheckbox($scope.app.id, $scope.app.type, $rootScope.selectedAppsForList);
              };

              $scope.$watch('$root.selectedAppsForList', function () {

                if($rootScope.selectedAppsForList.length == $scope.apps.length) {
                  $element.prop('checked', true);
                } else {
                  $element.prop('checked', false);
                }

              });

            }
          };
        }])
    .directive('selectAllCheckboxTwo', [function () {
      return {
        replace: true,
        restrict: 'E',
        scope: {
          apps: '=apps',
          selectedAppsForList: '=selectedAppsForList'
        },
        template: '<input type="checkbox" ng-model="checkboxMaster" ng-click="checkboxMasterChange()">',
        controller: function ($scope, $element) {

          $scope.checkboxMasterChange = function () {
            if ($scope.checkboxMaster) {
              $scope.selectedAppsForList = [];
              angular.forEach($scope.apps, function (app, index) {
                $scope.selectedAppsForList.push({id: app.id, type: app.type});
              });
            } else {
              $scope.selectedAppsForList = [];
            }
          };

          $scope.$watch('selectedAppsForList', function () {

            /* Controls 'checked' status of master checkbox (top checkbox). Three states: [ ], [X] and [-] */
            if($scope.selectedAppsForList.length == $scope.apps.length) {
              $element.prop('checked', true);
            } else {
              $element.prop('checked', false);
            }

          }, true);
        }
      };
    }])
    .directive('checkableCheckboxTwo', ["listApiService", function (listApiService) {
      return {
        replace: true,
        restrict: 'E',
        scope: {
          app: '=app',
          selectedAppsForList: '=selectedAppsForList',
          apps: '=apps'
        },
        template: '<input type="checkbox" ng-model="appCheckbox" ng-click="addAppToList()">',
        controller: function ($scope, $element) {

          $scope.addAppToList = function() {
            listApiService.modifyCheckbox($scope.app.id, $scope.app.type, $scope.selectedAppsForList);
          };

          $scope.$watch('selectedAppsForList', function () {

            if($scope.selectedAppsForList.length == $scope.apps.length) {
              $element.prop('checked', true);
            } else {
              $element.prop('checked', false);
            }

          });

        }
      };
    }])
    .directive('appPlatformToggle', ["apiService", "$rootScope", "AppPlatform", function (apiService, $rootScope, AppPlatform) {
      return {
        replace: true,
        restrict: 'E',
        scope: {},
        template: '<span class="btn-group" id="dashboardPlatformSwitch"><button type="button" ng-class="appPlatform.platform == \'ios\' ? \'btn-primary\' : \'btn-default\'" class="btn" ng-click="changeAppPlatform(\'ios\')">iOS</button> <button type="button" ng-class="appPlatform.platform == \'android\' ? \'btn-primary\' : \'btn-default\'" class="btn" ng-click="changeAppPlatform(\'android\')">Android</button> </span>',
        controller: function ($scope) {

          $scope.appPlatform = AppPlatform;

          $scope.changeAppPlatform = function (platform) {
            $scope.appPlatform.platform = platform;
            APP_PLATFORM = platform;
            apiService.getCategories().success(function (data) {
              $rootScope.categoryFilterOptions = data;
            });

            // Stops 'supportDesk' filter from being added
            if ($scope.appPlatform == 'android') {
              for (var index = 0; index < $rootScope.tags.length; index++) {
                if ($rootScope.tags[index].parameter == 'supportDesk') {
                  $rootScope.tags.splice(index, 1);
                  index -= 1;
                }
              }
            }
          };
        },
        controllerAs: 'appPlatformCtrl'
      }
    }])
    .directive('ddTextCollapse', ['$compile', function($compile) {
      return {
        restrict: 'A',
        scope: true,
        link: function(scope, element, attrs) {
          // start collapsed
          scope.collapsed = false;
          // create the function to toggle the collapse
          scope.toggle = function() {
            scope.collapsed = !scope.collapsed;
          };
          // wait for changes on the text
          attrs.$observe('ddTextCollapseText', function(text) {
            // get the length from the attributes
            var maxLength = scope.$eval(attrs.ddTextCollapseMaxLength);
            if (text.length > maxLength) {
              // split the text in two parts, the first always showing
              var firstPart = String(text).substring(0, maxLength);
              var secondPart = String(text).substring(maxLength, text.length);
              // create some new html elements to hold the separate info
              var firstSpan = $compile('<span>' + firstPart + '</span>')(scope);
              var secondSpan = $compile('<span ng-if="collapsed">' + secondPart + '</span>')(scope);
              var moreIndicatorSpan = $compile('<span ng-if="!collapsed">... </span>')(scope);
              var lineBreak = $compile('<br ng-if="collapsed">')(scope);
              var toggleButton = $compile('<span class="collapse-text-toggle" ng-click="toggle()">{{collapsed ? "less" : "more"}}</span>')(scope);
              // remove the current contents of the element
              // and add the new ones we created
              element.empty();
              element.append(firstSpan);
              element.append(secondSpan);
              element.append(moreIndicatorSpan);
              element.append(lineBreak);
              element.append(toggleButton);
            }
            else {
              element.empty();
              element.append(text);
            }
          });
        }
      };
    }]);
