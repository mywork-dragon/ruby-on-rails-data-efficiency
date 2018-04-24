import axios from 'axios';
import { isValidToken } from 'utils/auth.utils';
import { $localStorage } from 'utils/localStorage.utils';
import { getQueryToken } from './auth';
import httpClient from './httpClient';


const ExploreService = (client = httpClient) => {

  const exploreClient = axios.create({
    headers: { Authorization: null },
  });

  exploreClient.interceptors.request.use((config) => {
    const { headers: { Authorization: token } } = config;
    if (token && isValidToken(token)) {
      return config;
    }

    return getQueryToken().then((newToken) => {
      exploreClient.defaults.headers.Authorization = `${newToken}`;
      config.headers.Authorization = `${newToken}`;
      $localStorage.set('queryToken', newToken);
      return Promise.resolve(config);
    });
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
  };
};

export default ExploreService();
