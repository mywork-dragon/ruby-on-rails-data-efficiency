import axios from 'axios';
import moment from 'moment';
import { $localStorage } from 'utils/localStorage.utils';
import { tokenExpired } from 'utils/auth.utils';
import { getQueryToken } from './auth';
import httpClient from './httpClient';

const ExploreService = (client = httpClient) => {
  const exploreClient = axios.create({
    headers: { Authorization: null },
  });

  exploreClient.interceptors.request.use((config) => {
    const { headers: { Authorization: token } } = config;
    if (tokenExpired()) {
      return getQueryToken().then((newToken) => {
        exploreClient.defaults.headers.Authorization = `${newToken}`;
        config.headers.Authorization = `${newToken}`;
        $localStorage.set('queryToken', newToken);
        $localStorage.set('queryTokenFetchTime', moment());
        return Promise.resolve(config);
      });
    } else if (!token) {
      const savedToken = $localStorage.get('queryToken');
      exploreClient.defaults.headers.Authorization = `${savedToken}`;
      config.headers.Authorization = `${savedToken}`;
    }

    return config;
  });

  return {
    getQueryId: params => (
      exploreClient.put(`${window.MQUERY_SERVICE}/query`, params)
    ),
    getQueryParams: id => (
      exploreClient.get(`${window.MQUERY_SERVICE}/query/${id}`)
    ),
    getQueryResultInfo: id => (
      exploreClient.put(`${window.MQUERY_SERVICE}/query_result/${id}`)
    ),
    getResultsByResultId: (id, page) => (
      exploreClient.get(`${window.MQUERY_SERVICE}/query_result/${id}/pages/${page}?formatter=json_list`)
    ),
    getSdkAutocompleteResults: (platform, query) => (
      client.get(`/api/sdks/autocomplete/v2?platform=${platform}&query=${query}`)
    ),
    getCsvByQueryResultId: id => (
      exploreClient.get(`${window.MQUERY_SERVICE}/query_result/${id}/pages/*?formatter=csv`)
    ),
    getAppPermissionsOptions: () => (
      exploreClient.get(`${window.MQUERY_SERVICE}/app/permissions/options`)
    ),
    getGeoOptions: () => (
      exploreClient.get(`${window.MQUERY_SERVICE}/geo/options`)
    ),
  };
};

export default ExploreService();
