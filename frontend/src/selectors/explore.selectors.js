export const takenDownFilter = state => state.explorePage.searchForm.includeTakenDown;

export const currentQueryId = state => state.explorePage.explore.queryId;

export const activeFilters = (state) => {
  const currentFilters = state.explorePage.searchForm.filters;

  const filters = Object.keys(currentFilters);

  if (!currentFilters.sdks.filters.some(x => x.sdks.length)) {
    const idx = filters.indexOf('sdks');
    filters.splice(idx, 1);
  }

  if (currentFilters.adNetworks && currentFilters.adNetworks.value.adNetworks.length === 0) {
    const idx = filters.indexOf('adNetworks');
    filters.splice(idx, 1);
  }

  return filters;
};

export const csvQueryId = state => state.explorePage.explore.csvQueryId;

export const queryResultId = state => state.explorePage.explore.queryResultId;

export const currentExplorePage = state => state.explorePage.resultsTable.pageNum;
