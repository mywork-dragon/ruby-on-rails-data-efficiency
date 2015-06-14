
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
      }).directive('selectAllCheckbox', ["$rootScope", function ($rootScope) {
          return {
            replace: true,
            restrict: 'E',
            scope: {
              checkboxes: '=',
              allselected: '=allSelected',
              allclear: '=allClear'
            },
            template: '<input type="checkbox" ng-model="checkboxMaster" ng-change="checkboxMasterChange()">',
            controller: function ($scope, $element) {

              $scope.checkboxMasterChange = function () {
                if ($scope.checkboxMaster) {
                  $rootScope.selectedAppsForList = [];
                  angular.forEach($scope.checkboxes, function (app, index) {
                    $rootScope.selectedAppsForList.push({id: app.app.id, type: app.app.type});
                  });
                } else {
                  angular.forEach($scope.checkboxes, function (cb, index) {
                    $rootScope.selectedAppsForList = [];
                  });
                }
              };

              $scope.$watch('$root.selectedAppsForList', function () {

                /*
                var allSet = true,
                  allClear = true;
                angular.forEach($scope.checkboxes, function (cb, index) {
                  if (cb.isSelected) {
                    allClear = false;
                  } else {
                    allSet = false;
                  }
                });

                if ($scope.allselected !== undefined) {
                  $scope.allselected = allSet;
                }
                if ($scope.allclear !== undefined) {
                  $scope.allclear = allClear;
                }
                */

                /*

                $('.dashboardTableDataCheckbox > input').each(function(index, checkbox) {
                  $rootScope.selectedAppsForList.forEach(function(app) {
                    console.log(checkbox);
                    if(checkbox.attributes['data-app-id'].value == app.id && checkbox.attributes['data-app-type'].value == app.type) {
                      checkbox.prop('checked', true);
                      console.log('TRUE ', checkbox);
                    } else {
                      checkbox.prop('checked', false);
                      console.log('FALSE ', checkbox);
                    }
                  })
                });

                */

                /* Controls 'checked' status of master checkbox (top checkbox). Three states: [ ], [X] and [-] */
                $element.prop('checked', false);
                if($rootScope.selectedAppsForList.length == $rootScope.numApps) {
                  $element.prop('indeterminate', false);
                  $element.prop('checked', true);
                } else if($rootScope.selectedAppsForList.length > 0 && $rootScope.selectedAppsForList.length < $rootScope.numApps) {
                  $element.prop('indeterminate', true);
                }

                /*

                angular.forEach($rootScope.apps, function(app) {
                  console.log($element, $element.inheritedData(), $element.inheritedData()['$isolateScope']['checkboxes']);
                  $element.prop('checked', true);
                });

                $element.prop('indeterminate', false);
                if (allSet) {
                  $scope.checkboxMaster = true;
                } else if (allClear) {
                  $scope.checkboxMaster = false;
                } else {
                  $scope.checkboxMaster = false;
                  $element.prop('indeterminate', true);
                }
                */


              }, true);
            }
          };
        }]).directive('checkableCheckbox', ["$rootScope", "listApiService", function ($rootScope, listApiService) {
          return {
            replace: true,
            restrict: 'E',
            scope: {
              app: '=app'
            },
            template: '<input type="checkbox" ng-model="appCheckbox" ng-change="addAppToList()">',
            controller: function ($scope, $element) {

              $scope.addAppToList = function() {
                listApiService.modifyCheckbox($scope.app.id, $scope.app.type, $rootScope.selectedAppsForList);
              };

              $scope.$watch('$root.selectedAppsForList', function () {
                $rootScope.selectedAppsForList.forEach(function(app) {
                  if($scope.app.id == app.id && $scope.app.type == app.type) {
                    $element.prop('checked', true);
                  } else {
                    $element.prop('checked', false);
                  }
                });
              });

            }
          };
        }]);
