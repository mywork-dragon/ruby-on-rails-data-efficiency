export const getAvailableCountries = state => state.appStoreInfo.availableCountries.availableCountries;

export const getIosCategories = state => Object.values(state.appStoreInfo.categories.iosCategoriesById);

export const getAndroidCategories = state => Object.values(state.appStoreInfo.categories.androidCategoriesById);

export const getIosSdkCategories = state => state.appStoreInfo.sdkCategories.iosCategoriesById;

export const getAndroidSdkCategories = state => state.appStoreInfo.sdkCategories.androidCategoriesById;
