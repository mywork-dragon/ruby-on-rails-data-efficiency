export const takenDownFilter = state => state.explorePage.searchForm.includeTakenDown;

export const currentQueryId = state => state.explorePage.explore.queryId;

export const csvQueryId = state => state.explorePage.explore.csvQueryId;

export const queryResultId = state => state.explorePage.explore.queryResultId;

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

export const getCurrentColumns = (state, resultType) => state.explorePage.explore[`${resultType || state.explorePage.searchForm.resultType}Columns`];

export const getCurrentResultType = state => state.explorePage.searchForm.resultType;

export const currentExplorePage = state => state.explorePage.resultsTable.pageNum;

export const currentFormVersion = state => state.explorePage.searchForm.version;

export const getCurrentState = state => state.explorePage;
