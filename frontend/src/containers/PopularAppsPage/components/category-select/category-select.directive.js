import angular from 'angular';

angular
  .module('appApp')
  .directive('categorySelect', ['$http', '$rootScope', 'apiService', 'filterService', function ($http, $rootScope, apiService, filterService) {
    return {
      replace: true,
      restrict: 'E',
      scope: {
        categoryModel: '=category',
        categorySelectLoaded: '=loaded',
      },
      template: require('containers/PopularAppsPage/components/category-select/category-select.html'),
      controller: ['$scope', '$element', function ($scope, $element) {
        // load ios/android categories
        $scope.selectedTab = 'popular';
        $scope.searchQuery = '';
        $scope.searchChanged = searchChanged;
        $scope.checkCategory = checkCategory;
        $scope.checkAll = checkAll;
        $scope.uncheckAll = uncheckAll;
        $scope.switchTabs = switchTabs;
        $scope.categorySelectLoaded = false;
        $scope.filterKey = 'categories';
        $scope.popularCategoryIds = ['36', 'OVERALL', '6014', 'GAME', '6008', 'SOCIAL', '6005', '6016', 'SHOPPING', '6024',
          'PHOTOGRAPHY', '6011', 'MUSIC_AND_AUDIO', 'LIFESTYLE', '6012', 'ENTERTAINMENT', '6016'];

        $scope.$watchCollection('$root.tags', () => {
          for (var id in $scope.categoryModel) {
            $scope.categoryModel[id] = $rootScope.tags.some(tag => tag.value == id && tag.parameter == $scope.filterKey);
          }
        });

        activate();

        function activate() {
          $scope.isLoading = true;
          getIosCategories()
            .then(getAndroidCategories)
            .then(() => {
              $scope.categories = $scope.iosCategories.concat($scope.androidCategories);
              $scope.categories.sort((a, b) => a.name.localeCompare(b.name));
              $scope.categoriesFiltered = $scope.categories;

              $scope.popularCategories = $scope.categories.filter(category => $scope.popularCategoryIds.includes(category.id.toString()));
              $scope.popularCategoriesFiltered = $scope.popularCategories;

              setDefaultCategories();
              $scope.isLoading = false;

              // to tell main controller this directive is done loading
              $scope.categorySelectLoaded = true;
            });
        }

        function switchTabs(tab) {
          $scope.selectedTab = tab;
        }

        function getIosCategories() {
          return apiService.getIosCategories()
            .then((data) => {
              $scope.iosCategories = data;
              $scope.iosCategoriesFiltered = data;
            });
        }

        function getAndroidCategories() {
          return apiService.getAndroidCategories()
            .then((data) => {
              $scope.androidCategories = data;
              $scope.androidCategoriesFiltered = data;
            });
        }

        function checkAll() {
          selectedCollection()
            .forEach((category) => {
              $scope.categoryModel[category.id] = true;
              filterService.addFilter($scope.filterKey, category.id, 'Category', false, categoryDisplayName(category));
            });
        }

        function uncheckAll() {
          selectedCollection()
            .forEach((category) => {
              $scope.categoryModel[category.id] = false;
              filterService.removeFilter($scope.filterKey, category.id);
            });
        }

        function selectedCollection() {
          switch ($scope.selectedTab) {
            case 'popular':
              return $scope.popularCategoriesFiltered;
            case 'all':
              return $scope.categoriesFiltered;
            case 'ios':
              return $scope.iosCategoriesFiltered;
            case 'android':
              return $scope.androidCategoriesFiltered;
          }
        }

        function checkCategory(category, trackInMixpanel = true) {
          if (filterService.hasFilter($scope.filterKey, category.id)) {
            $scope.categoryModel[category.id] = false;
            filterService.removeFilter($scope.filterKey, category.id);
          } else {
            $scope.categoryModel[category.id] = true;
            filterService.addFilter($scope.filterKey, category.id, 'Category', false, categoryDisplayName(category), trackInMixpanel);
          }
        }

        function categoryDisplayName(category) {
          return `${category.name} - ${category.platform == 'ios' ? 'iOS' : 'Android'}`;
        }

        function setDefaultCategories() {
          for (const category of $scope.categories.filter(category => category.id == 36 || category.id == 'OVERALL')) {
            checkCategory(category, false);
          }
        }

        function searchChanged(query) {
          $scope.searchQuery = query;
          query = query.toLowerCase();
          $scope.popularCategoriesFiltered = $scope.popularCategories.filter(category => category.name.toLowerCase().includes(query));
          $scope.categoriesFiltered = $scope.categories.filter(category => category.name.toLowerCase().includes(query));
          $scope.iosCategoriesFiltered = $scope.iosCategories.filter(category => category.name.toLowerCase().includes(query));
          $scope.androidCategoriesFiltered = $scope.androidCategories.filter(category => category.name.toLowerCase().includes(query));
        }
      }],
    };
  }]);
