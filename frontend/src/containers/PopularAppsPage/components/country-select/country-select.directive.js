import angular from 'angular';

angular
  .module('appApp')
  .directive('countrySelect', ['$http', '$rootScope', 'apiService', 'filterService', function ($http, $rootScope, apiService, filterService) {
    return {
      replace: true,
      restrict: 'E',
      scope: {
        countryModel: '=country',
        countrySelectLoaded: '=loaded',
      },
      template: require('containers/PopularAppsPage/components/country-select/country-select.html'),
      controller: ['$scope', '$element', function ($scope, $element) {
        // load ios/android categories
        $scope.selectedTab = 'popular';
        $scope.searchQuery = '';
        $scope.searchChanged = searchChanged;
        $scope.checkCountry = checkCountry;
        $scope.checkAll = checkAll;
        $scope.uncheckAll = uncheckAll;
        $scope.switchTabs = switchTabs;
        $scope.countrySelectLoaded = false;
        $scope.filterKey = 'countries';
        $scope.popularCountryIds = ['US', 'CA', 'GB', 'FR', 'AU'];

        $scope.$watchCollection('$root.tags', () => {
          for (var id in $scope.countryModel) {
            $scope.countryModel[id] = $rootScope.tags.some(tag => tag.value == id && tag.parameter == $scope.filterKey);
          }
        });

        activate();

        function activate() {
          $scope.isLoading = true;
          getCountries()
            .then(() => {
              $scope.countries.sort((a, b) => a.name.localeCompare(b.name));
              $scope.countriesFiltered = $scope.countries;

              $scope.popularCountries = $scope.countries.filter(country => $scope.popularCountryIds.includes(country.id));
              $scope.popularCountriesFiltered = $scope.popularCountries;

              $scope.iosCountries = $scope.countries.filter(country => country.platforms.includes('ios'));
              $scope.androidCountries = $scope.countries.filter(country => country.platforms.includes('android'));

              $scope.iosCountriesFiltered = $scope.iosCountries;
              $scope.androidCountriesFiltered = $scope.androidCountries;
              setDefaultCountries();
              $scope.isLoading = false;
              // to tell main controller this directive is done loading
              $scope.countrySelectLoaded = true;
            });
        }

        function switchTabs(tab) {
          $scope.selectedTab = tab;
        }

        function getCountries() {
          return apiService.getCountries()
            .then((data) => {
              $scope.countries = data;
            });
        }

        function checkAll() {
          selectedCollection()
            .forEach((country) => {
              $scope.countryModel[country.id] = true;
              filterService.addFilter($scope.filterKey, country.id, 'Country', false, countryDisplayName(country));
            });
        }

        function uncheckAll() {
          selectedCollection()
            .forEach((country) => {
              $scope.countryModel[country.id] = false;
              filterService.removeFilter($scope.filterKey, country.id);
            });
        }

        function selectedCollection() {
          switch ($scope.selectedTab) {
            case 'popular':
              return $scope.popularCountriesFiltered;
            case 'all':
              return $scope.countriesFiltered;
            case 'ios':
              return $scope.iosCountriesFiltered;
            case 'android':
              return $scope.androidCountriesFiltered;
          }
        }

        function checkCountry(country) {
          if (filterService.hasFilter($scope.filterKey, country.id)) {
            $scope.countryModel[country.id] = false;
            filterService.removeFilter($scope.filterKey, country.id);
          } else {
            $scope.countryModel[country.id] = true;
            filterService.addFilter($scope.filterKey, country.id, 'Country', false, countryDisplayName(country));
          }
        }

        function countryDisplayName(country) {
          let display = country.name;
          if (country.platforms.length == 1) {
            display += ` - ${country.platforms[0] == 'ios' ? 'iOS' : 'Android'}`;
          }
          return display;
        }

        function setDefaultCountries() {
          for (const country of $scope.countries.filter(country => country.id == 'US')) {
            checkCountry(country);
          }
        }

        function searchChanged(query) {
          $scope.searchQuery = query;
          query = query.toLowerCase();
          $scope.popularCountriesFiltered = $scope.popularCountries.filter(country => country.name.toLowerCase().includes(query));
          $scope.countriesFiltered = $scope.countries.filter(country => country.name.toLowerCase().includes(query));
          $scope.iosCountriesFiltered = $scope.iosCountries.filter(country => country.name.toLowerCase().includes(query));
          $scope.androidCountriesFiltered = $scope.androidCountries.filter(country => country.name.toLowerCase().includes(query));
        }
      }],
    };
  }]);
