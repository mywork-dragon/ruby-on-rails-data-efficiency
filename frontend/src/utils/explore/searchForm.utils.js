import _ from 'lodash';
import getDisplayText from './displayText.utils';

function updateSearchForm(state, action) {
  const { parameter, value } = action.payload;
  switch (parameter) {
    case 'includeTakenDown':
      return {
        ...state,
        includeTakenDown: !state.includeTakenDown,
      };
    case 'availableCountries':
    case 'fortuneRank':
    case 'mobilePriority':
    case 'headquarters':
    case 'userBase':
    case 'price':
    case 'inAppPurchases':
    case 'iosCategories':
    case 'androidCategories':
    case 'creativeFormats':
    case 'adNetworks':
    case 'adNetworkCount':
    case 'ratingsCount':
    case 'rating':
    case 'releaseDate':
    case 'downloads':
      return {
        ...state,
        filters: updateFilters(state.filters, action.payload),
      };
    case 'platform':
      return {
        ...state,
        platform: value,
      };
    case 'resultType':
      return {
        ...state,
        resultType: value,
      };
    case 'sdks':
      return {
        ...state,
        filters: updateFilters(state.filters, action.payload),
      };
    case 'sdkOperator':
      const newState = { ...state };
      newState.filters.sdks.operator = action.payload.value;
      return newState;
    default:
      return state;
  }
}

function updateFilters (filters, { parameter, value, options }) {
  let filter;

  switch (parameter) {
    case 'headquarters':
    case 'fortuneRank':
    case 'availableCountries':
    case 'price':
    case 'inAppPurchases':
    case 'iosCategories':
    case 'androidCategories':
    case 'adNetworks':
    case 'adNetworkCount':
    case 'ratingsCount':
    case 'rating':
    case 'releaseDate':
    case 'downloads':
      filter = updateSingleValueFilter(filters[parameter], parameter, value, options);
      break;
    case 'userBase':
    case 'mobilePriority':
    case 'creativeFormats':
      filter = updateArrayTypeFilter(filters[parameter], parameter, value, options);
      break;
    case 'sdks':
      filter = updateSdkFilter(filters[parameter].filters[options.index], parameter, value, options);
      break;
    default:
      break;
  }

  const newFilters = addFilter(filters, parameter, filter, options);

  return newFilters;
}

function updateArrayTypeFilter (filter, type, value, { panelKey }) {
  const result = {
    panelKey,
    value: [],
  };

  if (filter === undefined) {
    result.value.push(value);
  } else {
    const values = filter.value;
    if (values.includes(value)) {
      _.remove(values, x => x === value);
    } else {
      values.push(value);
    }
    result.value = _.uniq(values);
  }

  if (result.value.length === 0) {
    return null;
  }

  result.displayText = getDisplayText(type, result.value);

  return result;
}

function updateSingleValueFilter (filter, type, value, { panelKey }) {
  const result = {
    panelKey,
    value: null,
  };

  if (value && (filter === undefined || value !== filter.value)) {
    result.value = value;
    result.displayText = getDisplayText(type, result.value);
  }

  if (!result.value || (Array.isArray(value) && value.length === 0)) {
    return null;
  }

  return result;
}

function updateSdkFilter (filter, type, value) {
  const newFilter = {
    ...value,
  };

  newFilter.displayText = getDisplayText('sdk', newFilter);

  return newFilter;
}

function addFilter (filters, type, filter, options) {
  const result = { ...filters };

  if (filter == null) {
    delete result[type];
  } else if (type === 'sdks') {
    result.sdks.filters[options.index] = filter;
  } else {
    result[type] = filter;
  }

  return result;
}

export default updateSearchForm;
