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
});

export default AppStoreService;
