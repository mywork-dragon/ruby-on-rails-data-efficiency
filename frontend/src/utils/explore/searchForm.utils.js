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
    case 'fortuneRank':
    case 'mobilePriority':
    case 'userBase':
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
    default:
      return state;
  }
}

function updateFilters (filters, { parameter, value, options: { panelKey } }) {
  let filter;

  switch (parameter) {
    case 'fortuneRank':
      filter = updateSingleValueFilter(filters[parameter], parameter, value, panelKey);
      break;
    case 'userBase':
    case 'mobilePriority':
      filter = updateArrayTypeFilter(filters[parameter], parameter, value, panelKey);
      break;
    default:
      break;
  }

  const newFilters = addFilter(filters, parameter, filter);

  return newFilters;
}

function updateArrayTypeFilter (filter, type, value, panelKey) {
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

  result.displayText = getDisplayText(type, result.value);

  return result;
}

function updateSingleValueFilter (filter, type, value, panelKey) {
  const result = {
    panelKey,
    value: null,
  };

  if (value && (filter === undefined || value !== filter.value)) {
    result.value = value;
    result.displayText = getDisplayText(type, result.value);
  }

  return result;
}

function addFilter (filters, type, filter) {
  const result = { ...filters };

  if (Array.isArray(filter.value) && filter.value.length !== 0) {
    result[type] = filter;
  } else if (!Array.isArray(filter.value) && filter.value) {
    result[type] = filter;
  } else {
    delete result[type];
  }

  return result;
}

export default updateSearchForm;
