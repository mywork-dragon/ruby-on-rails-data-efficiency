import _ from 'lodash';

export const getAvailableCountries = state => state.appStoreInfo.availableCountries.availableCountries;

export const getIosCategories = state => Object.values(state.appStoreInfo.categories.iosCategoriesById);

export const getAndroidCategories = state => Object.values(state.appStoreInfo.categories.androidCategoriesById);

export const needAppCategories = state => !state.appStoreInfo.categories.loaded && !state.appStoreInfo.categories.fetching;

export const needAvailableCountries = state => !state.appStoreInfo.availableCountries.loaded && !state.appStoreInfo.availableCountries.fetching;

export const needSdkCategories = state => !state.appStoreInfo.sdkCategories.loaded && !state.appStoreInfo.sdkCategories.fetching;

export const getIosSdkCategories = state => state.appStoreInfo.sdkCategories.iosCategoriesById;

export const getAndroidSdkCategories = state => state.appStoreInfo.sdkCategories.androidCategoriesById;

export const needRankingsCountries = state => !state.appStoreInfo.rankingsCountries.loaded && !state.appStoreInfo.rankingsCountries.fetching;

export const getRankingsCountries = state => _.sortBy(state.appStoreInfo.rankingsCountries.rankingsCountries, x => x.name);

export const getCategoryNameById = (state, id, platform) => state.appStoreInfo.categories[`${platform}CategoriesById`][id] || {};

export const getCountryById = (state, id) => state.appStoreInfo.rankingsCountries.rankingsCountries.find(x => x.id === id);

export const needAppPermissionsOptions = state => !state.appStoreInfo.appPermissionsOptions.loaded && !state.appStoreInfo.appPermissionsOptions.fetching;

export const getAppPermissionsOptions = state => Object.entries(state.appStoreInfo.appPermissionsOptions.options).map(x => ({ key: x[0], ...x[1] }));

export const needGeoOptions = state => !state.appStoreInfo.geoOptions.loaded && !state.appStoreInfo.geoOptions.fetching;

export const getGeoCountries = state => _.sortBy(Object.values(state.appStoreInfo.geoOptions.countries), x => x.name).map(x => ({ value: x.code, label: x.name, country: x.code }));

export const storeHeadquarterOptions = () => {
  let result = null;

  return function ({ appStoreInfo: { headquarters } }) {
    if (!result && headquarters.loaded) {
      result = [];
      Object.values(headquarters.cities).forEach(x => result.push({ value: x.code, label: x.name, city: x.code, state: x.parents.state_code, country: x.parents.country_code }));
      Object.values(headquarters.statesById).forEach(x => result.push({ value: x.code, label: x.name, state: x.code, country: x.parents.country_code }));
      Object.values(headquarters.countriesById).forEach(x => result.push({ value: x.code, label: x.name, country: x.code }));
    }

    return result;
  };
};
