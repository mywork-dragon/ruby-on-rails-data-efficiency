export const getAvailableCountries = state => state.appStoreInfo.availableCountries.availableCountries;

export const getIosCategories = state => Object.values(state.appStoreInfo.categories.iosCategoriesById);

export const getAndroidCategories = state => Object.values(state.appStoreInfo.categories.androidCategoriesById);
