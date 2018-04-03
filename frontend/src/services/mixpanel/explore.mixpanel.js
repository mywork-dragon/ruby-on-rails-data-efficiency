import mixpanel from 'mixpanel-browser';

const ExploreMixpanelService = () => ({
  trackFilterAdded: (parameter, value) => {
    let data;
    if (['string', 'number'].includes(typeof value)) {
      data = { parameter, value };
    } else if (Array.isArray(value)) {
      data = {
        parameter,
        value: value.map((x) => {
          switch (parameter) {
            case 'headquarters':
              return x.key;
            case 'iosCategories':
            case 'androidCategories':
              return x.label;
            default:
              return x;
          }
        }),
      };
    } else if (parameter === 'sdks') {
      data = {
        parameter,
        ...value,
        sdks: value.sdks.map(x => ({ name: x.name, platform: x.platform })),
      };
    } else if (parameter === 'adNetworks') {
      data = {
        parameter,
        ...value,
        networks: value.adNetworks.map(x => x.label),
      };
    } else {
      data = { parameter, ...value };
    }

    mixpanel.track('Explore V2 Filter Added or Updated', data);
  },
  trackQueryPopulation: queryId => mixpanel.track('Explore V2 Populated from Query', { queryId }),
  trackColumnUpdate: columns => mixpanel.track('Explore V2 Columns Updated', {
    columns: Object.keys(columns).filter(x => columns[x]),
  }),
  trackPageThrough: (queryId, page) => mixpanel.track('Explore V2 Results Paged Through', { queryId, page }),
  trackTableSort: sort => mixpanel.track('Explore V2 Results Sorted', {
    parameter: sort[0].id,
    order: sort[0].desc ? 'desc' : 'asc',
  }),
  trackResultsLoad: (queryId, filters, resultsCount) => mixpanel.track('Explore V2 Results Loaded', {
    queryId,
    filters,
    resultsCount,
  }),
  trackQueryFailure: filters => mixpanel.track('Explore V2 Query Failed', { filters }),
  trackCsvExport: queryId => mixpanel.track('Explore V2 CSV Exported', { queryId }),
  trackSavedSearchCreate: (id, name, queryId) => mixpanel.track('Explore V2 Saved Search Created', { name, id, queryId }),
  trackSavedSearchLoad: (id, name, queryId) => mixpanel.track('Explore V2 Saved Search Loaded', { name, id, queryId }),
  trackSavedSearchDelete: (id, name, queryId) => mixpanel.track('Explore V2 Saved Search Deleted', { name, id, queryId }),
});

export default ExploreMixpanelService;
