import { combineReducers } from 'redux';
import appTable from 'components/app-table/redux/AppTable.reducers';

function adIntelTab(actionTypes, tableActionTypes) {
  const initialInfoState = {
    id: '',
    platform: 'ios',
    first_seen_ads_date: new Date(),
    last_seen_ads_date: new Date(),
    ad_networks: [],
    ad_attribution_sdks: [],
    creative_formats: [],
    number_of_creatives: 0,
    total_apps: 0,
    advertising_apps: [],
    loadError: false,
    appTableHeaders: [
      'checkbox',
      'App',
      'Networks',
      'Ad Attribution SDKs',
      'Formats',
      'Total Creatives Seen',
      'First Seen Ads',
      'Last Seen Ads',
    ],
    tableHeader: 'Advertising Apps',
  };

  const initialCreativesState = {
    id: '',
    fetching: false,
    results: [],
    activeIndex: 0,
    pageNum: 1,
    pageSize: 8,
    resultsCount: 0,
    activeFormats: [],
    activeNetworks: [],
  };

  function info(state = initialInfoState, action) {
    switch (action.type) {
      case actionTypes.CLEAR_AD_INTEL_INFO:
        return { ...initialInfoState };
      case actionTypes.AD_INTEL_INFO_SUCCESS:
        return loadAdIntelInfo(action);
      case actionTypes.AD_INTEL_INFO_FAILURE:
        return loadAdFetchError(action);
      default:
        return state;
    }
  }

  function creatives(state = initialCreativesState, action) {
    switch (action.type) {
      case actionTypes.CREATIVES_SUCCESS:
        return loadCreatives(state, action);
      case actionTypes.UPDATE_ACTIVE_CREATIVE_INDEX:
        return updateActiveIndex(state, action);
      case actionTypes.AD_INTEL_INFO_SUCCESS:
        return initializeCreativeFilters(initialCreativesState, action);
      case actionTypes.TOGGLE_CREATIVE_FILTER:
        return toggleFilter(state, action);
      case actionTypes.CREATIVES_REQUEST:
        return {
          ...state,
          fetching: true,
        };
      default:
        return state;
    }
  }

  function loadAdIntelInfo(action) {
    const {
      id,
      platform,
      type,
      data,
    } = action.payload;
    const newState = {
      ...initialInfoState,
      ...data,
      id,
      platform,
      type,
    };
    return newState;
  }

  function loadAdFetchError(action) {
    return {
      ...initialInfoState,
      ...action.payload,
      loadError: true,
    };
  }

  function loadCreatives(state, action) {
    const { id, data } = action.payload;
    return {
      ...state,
      ...data,
      id,
      fetching: false,
      activeIndex: 0,
    };
  }

  function updateActiveIndex(state, action) {
    return {
      ...state,
      activeIndex: action.payload.index,
    };
  }

  function initializeCreativeFilters(state, action) {
    const { id, data } = action.payload;
    const activeFormats = data.creative_formats || [];
    const activeNetworks = data.ad_networks ? data.ad_networks.map(network => network.id) : [];
    const itemId = data.number_of_creatives === 0 ? id : '';
    return {
      ...state,
      activeFormats,
      activeNetworks,
      id: itemId,
    };
  }

  function toggleFilter(state, action) {
    const res = {};
    const { value, type } = action.payload;
    const activeFilters = state[type];
    if (activeFilters.includes(value)) {
      res[type] = activeFilters.filter(x => x !== value);
    } else {
      res[type] = activeFilters.concat([value]);
    }
    return {
      ...state,
      ...res,
    };
  }

  const reducers = {
    info,
    creatives,
  };

  if (tableActionTypes) {
    reducers.appTable = appTable(tableActionTypes);
  }

  const reducer = combineReducers(reducers);

  return reducer;
}

export default adIntelTab;
