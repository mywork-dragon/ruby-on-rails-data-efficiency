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

function updateFilters (filters, { parameter, value }) {
  let filter;

  switch (parameter) {
    case 'userBase':
    case 'mobilePriority':
      filter = updateArrayTypeFilter(filters[parameter], parameter, value);
      break;
    default:
      break;
  }

  const newFilters = addFilter(filters, parameter, filter);

  return newFilters;
}

function updateArrayTypeFilter (filter, type, value) {
  const result = {
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

function addFilter (filters, type, filter) {
  const result = { ...filters };

  if (Array.isArray(filter.value) && filter.value.length !== 0) {
    result[type] = filter;
  } else {
    delete result[type];
  }

  return result;
}

export default updateSearchForm;
