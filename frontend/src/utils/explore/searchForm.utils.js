import _ from 'lodash';
import { getDisplayText } from './displayText.utils';

function updateSearchForm(state, action) {
  const { parameter, value } = action.payload;
  switch (parameter) {
    case 'app_category':
      return updateFilter(state, action);
    case 'includeTakenDown':
      return {
        ...state,
        includeTakenDown: !state.includeTakenDown,
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

function updateFilter (state, { payload: { parameter, value } }) {
  const result = Object.assign({}, state.filters);
  switch (parameter) {
    case 'app_category':
      result.app_category = updateCategoryFilter(result.app_category, value);
      break;
    default:
      return { ...state };
  }

  return {
    ...state,
    filters: result,
  };
}

function updateCategoryFilter (filter, value) {
  const result = {};
  if (filter === undefined) {
    result.value = [value];
  } else {
    const values = filter.value;
    values.push(value);
    result.value = _.uniq(values);
  }

  result.displayText = getDisplayText('app_category', result.value);
  return result;
}

export default updateSearchForm;
