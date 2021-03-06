import updateSearchForm from 'utils/explore/searchForm.utils';
import {
  TABLE_TYPES,
  POPULATE_FROM_QUERY_ID,
  ADD_BLANK_SDK_FILTER,
  DUPLICATE_SDK_FILTER,
} from './Explore.actions';

export const sdkFilterModel = {
  dateRange: 'anytime',
  dates: [],
  eventType: 'install',
  operator: 'any',
  sdks: [],
  installState: 'is-installed',
  panelKey: '1',
  displayText: '',
};

const initialFormState = {
  resultType: 'app',
  platform: 'all',
  includeTakenDown: false,
  filters: {
    sdks: {
      filters: [{ ...sdkFilterModel }],
      operator: 'or',
    },
  },
  version: '1.3.2',
};

function searchForm (state = initialFormState, action) {
  switch (action.type) {
    case ADD_BLANK_SDK_FILTER:
      return addBlankSdkFilter(state);
    case TABLE_TYPES.UPDATE_FILTER:
      return updateSearchForm(state, action);
    case TABLE_TYPES.CLEAR_FILTERS:
      return {
        ...initialFormState,
        filters: {
          sdks: {
            filters: [{ ...sdkFilterModel }],
            operator: 'and',
          },
        },
      };
    case TABLE_TYPES.DELETE_FILTER:
      return deleteFilter(state, action.payload);
    case POPULATE_FROM_QUERY_ID.SUCCESS:
      return {
        ...action.payload.formState,
        version: state.version,
      };
    case DUPLICATE_SDK_FILTER:
      return duplicateSdkFilter(state, action.payload);
    default:
      return state;
  }
}

function deleteFilter(state, { filterKey, index }) {
  const newState = { ...state };
  if (typeof index === 'number') {
    newState.filters[filterKey].filters.splice(index, 1);
    if (filterKey === 'sdks' && newState.filters[filterKey].filters.length === 0) {
      newState.filters[filterKey].filters.push(sdkFilterModel);
    }
  } else {
    delete newState.filters[filterKey];
  }

  return newState;
}

function addBlankSdkFilter (state) {
  const newState = { ...state };
  newState.filters.sdks.filters.push({ ...sdkFilterModel });

  return newState;
}

function duplicateSdkFilter (state, { index }) {
  const newState = { ...state };
  const copy = { ...state.filters.sdks.filters[index] };
  newState.filters.sdks.filters.splice(index, 0, copy);
  return newState;
}

export default searchForm;
