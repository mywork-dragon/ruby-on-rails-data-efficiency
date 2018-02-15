import { headerNames } from './column.models';

export { headerNames };
export { initializeColumns } from 'utils/table.utils';

export function table(actionTypes, tableOptions) {
  const initialState = {
    columns: {},
    error: false,
    loading: false,
    message: 'No results',
    pageNum: 0,
    pageSize: 20,
    results: [],
    resultType: 'app',
    selectedItems: [],
    sort: [{ id: headerNames.APP, desc: false }],
    resultsCount: 0,
    ...tableOptions,
  };

  function reducer(state = initialState, action) {
    switch (action.type) {
      case actionTypes.ALL_ITEMS.REQUEST:
        return {
          ...state,
          loading: true,
        };
      case actionTypes.ALL_ITEMS.SUCCESS:
        return loadResults(state, action);
      case actionTypes.ALL_ITEMS.FAILURE:
        return {
          ...initialState,
          error: true,
          message: 'Whoops! There was an error fetching the data for this table.',
        };
      case actionTypes.CLEAR_RESULTS:
        return {
          ...initialState,
        };
      case actionTypes.TOGGLE_ALL_ITEMS:
        return toggleAll(state);
      case actionTypes.TOGGLE_ITEM:
        return toggleItemSelect(state, action);
      case actionTypes.UPDATE_COLUMNS:
        return {
          ...state,
          columns: action.payload.columns,
        };
      default:
        return state;
    }
  }

  function loadResults(state, { payload: { data } }) {
    const {
      results,
      resultsCount,
      pageSize,
      pageNum,
      sort,
      order,
    } = data;
    const sortVal = {
      id: sort,
      desc: order === 'desc',
    };
    return {
      ...state,
      pageSize,
      pageNum,
      results,
      resultsCount: resultsCount || results.length,
      sort: [sortVal],
      loading: false,
      error: false,
    };
  }

  function toggleItemSelect(state, action) {
    const { item } = action.payload;
    const isSelected = state.selectedItems.some(x => x.id === item.id && x.type === item.type);
    if (isSelected) {
      return {
        ...state,
        selectedItems: state.selectedItems.filter(x => !(x.id === item.id && x.type === item.type)),
      };
    }

    return {
      ...state,
      selectedItems: state.selectedItems.concat([item]),
    };
  }

  function toggleAll(state) {
    if (state.results.length === state.selectedItems.length) {
      return {
        ...state,
        selectedItems: [],
      };
    }

    return {
      ...state,
      selectedItems: state.results.map(x => ({ id: x.id, type: x.type })),
    };
  }

  return reducer;
}
