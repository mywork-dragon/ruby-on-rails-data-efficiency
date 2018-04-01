import httpClient from './httpClient';

const SavedSearchService = (client = httpClient) => ({
  getSavedSearches: () => (
    client.get('/api/saved_searches/get')
  ),
  createSavedSearch: (name, queryId) => (
    client.post('/api/saved_searches/create', { name, queryString: queryId, version: 'v2' })
  ),
  updateSavedSearch: (id, params) => (
    client.put('/api/saved_searches/edit', { id, queryString: params })
  ),
  deleteSavedSearch: id => (
    client.put('/api/saved_searches/delete', { id })
  ),
});

export default SavedSearchService;
