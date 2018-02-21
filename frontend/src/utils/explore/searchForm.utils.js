import _ from 'lodash';
import { getDisplayText } from './displayText.utils';

function updateSearchForm(state, action) {
  const { parameter, value } = action.payload;
  switch (parameter) {
    case 'includeTakenDown':
      return {
        ...state,
        includeTakenDown: !state.includeTakenDown,
      };
    case 'mobilePriority':
      return {
        ...state,
        filters: updateArrayTypeFilter(state.filters, parameter, value),
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

function updateArrayTypeFilter (filters, type, value) {
  const newFilters = Object.assign({}, filters);
  const filter = filters[type];
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

  if (result.value.length === 0) {
    delete newFilters[type];
  } else {
    newFilters[type] = result;
  }

  return newFilters;
}

export default updateSearchForm;
