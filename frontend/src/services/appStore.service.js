import httpClient from './httpClient';

const AppStoreService = (client = httpClient) => ({
  getIosCategories: () => (
    client.get('/api/ios_category_objects')
  ),
  getAndroidCategories: () => (
    client.get('/api/android_category_objects')
  ),
  getCountryAutocompleteResults: (status, query) => (
    client.get(`/api/location/autocomplete?status=${status}&query=${query}`)
  ),
  getIosSdkCategories: () => (
    client.get('/api/get_ios_sdk_categories')
  ),
  getAndroidSdkCategories: () => (
    client.get('/api/get_android_sdk_categories')
  ),
  getRankingsCountries: () => (
    client.get('/api/ranking_countries')
  ),
  getSdkAutocompleteResults: (platform, query) => (
    client.get(`/api/sdks/autocomplete/v2?platform=${platform}&query=${query}`)
  ),
});

export default AppStoreService;
