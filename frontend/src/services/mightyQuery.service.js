import axios from 'axios';
import moment from 'moment';
import { $localStorage } from 'utils/localStorage.utils';
import { tokenExpired } from 'utils/auth.utils';
import { getQueryToken } from './auth';
import httpClient from './httpClient';

const MightyQueryService = (client = httpClient) => {
  const mightyQueryClient = axios.create({
    headers: { Authorization: null },
  });

  mightyQueryClient.interceptors.request.use((config) => {
    const { headers: { Authorization: token } } = config;
    if (tokenExpired()) {
      return getQueryToken().then((newToken) => {
        mightyQueryClient.defaults.headers.Authorization = `${newToken}`;
        config.headers.Authorization = `${newToken}`;
        $localStorage.set('queryToken', newToken);
        $localStorage.set('queryTokenFetchTime', moment());
        return Promise.resolve(config);
      });
    } else if (!token) {
      const savedToken = $localStorage.get('queryToken');
      if (!savedToken) {
        return getQueryToken().then((newToken) => {
          mightyQueryClient.defaults.headers.Authorization = `${newToken}`;
          config.headers.Authorization = `${newToken}`;
          $localStorage.set('queryToken', newToken);
          $localStorage.set('queryTokenFetchTime', moment());
          return Promise.resolve(config);
        });
      }
      mightyQueryClient.defaults.headers.Authorization = `${savedToken}`;
      config.headers.Authorization = `${savedToken}`;
    }

    return config;
  });

  return {
    getQueryId: params => (
      mightyQueryClient.put(`${window.MQUERY_SERVICE}/query`, params)
    ),
    getQueryParams: id => (
      mightyQueryClient.get(`${window.MQUERY_SERVICE}/query/${id}`)
    ),
    getQueryResultInfo: id => (
      mightyQueryClient.put(`${window.MQUERY_SERVICE}/query_result/${id}`)
    ),
    getResultsByResultId: (id, page) => (
      mightyQueryClient.get(`${window.MQUERY_SERVICE}/query_result/${id}/pages/${page}?formatter=json_list`)
    ),
    getCsvByQueryResultId: id => (
      mightyQueryClient.get(`${window.MQUERY_SERVICE}/query_result/${id}/pages/*?formatter=csv`)
    ),
    getAppPermissionsOptions: () => (
      mightyQueryClient.get(`${window.MQUERY_SERVICE}/app/permissions/options`)
    ),
    getGeoOptions: () => (
      mightyQueryClient.get(`${window.MQUERY_SERVICE}/geo/options`)
    ),
    getAppInfo: (platform, id) => (
      mightyQueryClient.get(`${window.MQUERY_SERVICE}/app/${platform}/${id}`)
    ),
  };
};

export default MightyQueryService();
