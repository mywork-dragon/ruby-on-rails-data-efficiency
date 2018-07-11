export const getCurrentId = state => state.appPage.rankings.id;

export const getCurrentPlatform = state => state.appPage.rankings.platform;

export const getSelectedCountries = state => state.appPage.rankings.selectedCountries;

export const getSelectedCategories = state => state.appPage.rankings.selectedCategories;

export const getSelectedRankingTypes = state => state.appPage.rankings.selectedRankingTypes;

export const getSelectedDateRange = state => state.appPage.rankings.selectedDateRange;

export const getAllSelectedOptions = state => ({
  countries: state.appPage.rankings.selectedCountries.map(x => x.value),
  categories: state.appPage.rankings.selectedCategories,
  rankingTypes: state.appPage.rankings.selectedRankingTypes,
  dateRange: state.appPage.rankings.selectedDateRange.value,
  platform: state.appPage.rankings.platform,
  appIdentifier: state.appPage.rankings.appIdentifier,
});

export const getCountryOptions = state => state.appPage.rankings.countryOptions;

export const getCategoryOptions = state => state.appPage.rankings.categoryOptions;

export const getRankingTypesOptions = state => state.appPage.rankings.rankingTypesOptions;

export const needOptions = state => !state.appPage.rankings.optionsLoaded;

export const getChartData = state => state.appPage.rankings.chartData;

export const isChartDataLoading = state => state.appPage.rankings.chartLoading;

export const isChartDataLoaded = state => state.appPage.rankings.chartLoaded;
