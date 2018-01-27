export { headerNames } from './column.models';

export function table(actionTypes) {
  const initialState = {
    results: [],
    selectedItems: [],
  };

  function reducer(state = initialState, action) {
    switch (action.type) {
      case actionTypes.LOAD_RESULTS:
        return loadResults(state, action);
      case actionTypes.CLEAR_RESULTS:
        return {
          ...initialState,
        };
      case actionTypes.TOGGLE_ALL_ITEMS:
        return toggleAll(state);
      case actionTypes.TOGGLE_ITEM:
        return toggleItemSelect(state, action);
      default:
        return state;
    }
  }

  function loadResults(state, action) {
    return {
      ...state,
      results: action.payload.results,
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
