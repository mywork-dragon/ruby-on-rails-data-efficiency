export const getAvailableCountries = state => state.appStoreInfo.availableCountries.availableCountries;

export const getIosCategories = state => Object.values(state.appStoreInfo.categories.iosCategoriesById);

export const getAndroidCategories = state => Object.values(state.appStoreInfo.categories.androidCategoriesById);

export const needAppCategories = state => !state.appStoreInfo.categories.loaded && !state.appStoreInfo.categories.fetching;

export const needAvailableCountries = state => !state.appStoreInfo.availableCountries.loaded && !state.appStoreInfo.availableCountries.fetching;

export const needSdkCategories = state => !state.appStoreInfo.sdkCategories.loaded && !state.appStoreInfo.sdkCategories.fetching;

export const getIosSdkCategories = state => state.appStoreInfo.sdkCategories.iosCategoriesById;

export const getAndroidSdkCategories = state => state.appStoreInfo.sdkCategories.androidCategoriesById;

export const needRankingsCountries = state => !state.appStoreInfo.rankingsCountries.loaded && !state.appStoreInfo.rankingsCountries.fetching;

export const getRankingsCountries = state => state.appStoreInfo.rankingsCountries.rankingsCountries;
