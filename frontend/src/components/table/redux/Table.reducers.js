import { getPreferredPageSize } from 'utils/table.utils';
import { headerNames } from './column.models';

export { headerNames };
export { initializeColumns } from 'utils/table.utils';

export function table(actionTypes, tableOptions) {
  const initialState = {
    columns: {},
    error: false,
    loading: false,
    message: 'Filter items to see results',
    pageNum: 0,
    pageSize: getPreferredPageSize() || 20,
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
          ...state,
          results: [],
          resultsCount: 0,
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
      case actionTypes.UPDATE_PAGE_SIZE:
        return {
          ...state,
          pageSize: action.payload.pageSize,
        };
      default:
        return state;
    }
  }

  // data format: { results, resultsCount, pageSize, pageNum, sort, columns }
  function loadResults(state, { payload: { data } }) {
    if (data.resultsCount === 0) {
      return {
        ...initialState,
        message: 'No Results',
      };
    }

    return {
      ...state,
      ...data,
      columns: reconcileColumns(state.columns, data.columns),
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

  function reconcileColumns (oldColumns, newColumns) {
    if (newColumns === undefined) {
      return oldColumns;
    }

    const columns = {};

    for (const key in oldColumns) {
      if (oldColumns[key]) {
        columns[key] = newColumns[key] ? newColumns[key] : false;
      }
    }

    return columns;
  }

  return reducer;
}
