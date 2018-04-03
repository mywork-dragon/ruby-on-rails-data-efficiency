export const formatSavedSearches = (searches, queries) => {
  const result = {};

  searches.forEach((search) => {
    search.queryId = search.search_params;
    delete search.search_params;
    const query = queries.find(x => x.config.url.substr(x.config.url.lastIndexOf('/') + 1) === search.queryId);
    search.formState = query.data.formState;
    result[search.id] = search;
  });

  return result;
};
