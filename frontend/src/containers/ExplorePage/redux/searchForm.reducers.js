import updateSearchForm from 'utils/explore/searchForm.utils';
import { TABLE_TYPES, POPULATE_FROM_QUERY_ID } from './Explore.actions';


const initialFormState = {
  resultType: 'app',
  platform: 'all',
  includeTakenDown: false,
  filters: {},
  version: '0.0.0',
};

function searchForm (state = initialFormState, action) {
  switch (action.type) {
    case TABLE_TYPES.UPDATE_FILTER:
      return updateSearchForm(state, action);
    case TABLE_TYPES.CLEAR_FILTERS:
      return {
        ...initialFormState,
      };
    case POPULATE_FROM_QUERY_ID.SUCCESS:
      return {
        ...action.payload.formState,
      };
    default:
      return state;
  }
}

export default searchForm;
