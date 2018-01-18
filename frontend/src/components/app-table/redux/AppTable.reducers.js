function appTable(actionTypes) {
  const initialState = {
    apps: [],
    selectedApps: [],
  };

  function reducer(state = initialState, action) {
    switch (action.type) {
      case actionTypes.LOAD_APPS:
        return loadApps(state, action);
      case actionTypes.CLEAR_APPS:
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

  function loadApps(state, action) {
    return {
      ...state,
      apps: action.payload.apps,
    };
  }

  function toggleItemSelect(state, action) {
    const { item } = action.payload;
    const isSelected = state.selectedApps.some(x => x.id === item.id && x.type === item.type);
    if (isSelected) {
      return {
        ...state,
        selectedApps: state.selectedApps.filter(x => !(x.id === item.id && x.type === item.type)),
      };
    }

    return {
      ...state,
      selectedApps: state.selectedApps.concat([item]),
    };
  }

  function toggleAll(state) {
    if (state.apps.length === state.selectedApps.length) {
      return {
        ...state,
        selectedApps: [],
      };
    }

    return {
      ...state,
      selectedApps: state.apps.map(app => ({ id: app.id, type: app.type })),
    };
  }

  return reducer;
}

export default appTable;
