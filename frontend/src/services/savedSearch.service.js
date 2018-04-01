import { $localStorage } from 'utils/localStorage.utils';
import httpClient from './httpClient';

const SavedSearchService = (client = httpClient) => ({
  getSavedSearches: () => (
    client.get('/api/saved_searches/get')
  ),
  createSavedSearch: (name, params) => (
    client.post('/api/saved_searches/create', { name, queryString: params })
  ),
  updateSavedSearch: (id, params) => (
    client.put('/api/saved_searches/edit', { id, queryString: params })
  ),
  deleteSavedSearch: id => (
    client.put('/api/saved_searches/delete', { id })
  ),
  getSavedSearches2: () => ({
    data: JSON.parse($localStorage.get('savedSearches')) || {},
  }),
  createSavedSearch2: (name, queryId) => {
    const savedSearches = JSON.parse($localStorage.get('savedSearches')) || {};
    let newId = 1;
    while (Object.keys(savedSearches).some(x => x == newId)) {
      newId += 1;
    }

    const newSearch = {
      id: newId,
      name,
      queryId,
    };

    savedSearches[newId] = newSearch;

    $localStorage.set('savedSearches', JSON.stringify(savedSearches));
    return { status: 200, data: newSearch };
  },
  deleteSavedSearch2: (id) => {
    const savedSearches = JSON.parse($localStorage.get('savedSearches')) || {};
    delete savedSearches[id];
    $localStorage.set('savedSearches', JSON.stringify(savedSearches));
    return { status: 200 };
  },
});

export default SavedSearchService;
