export const FETCH_LISTS = 'FETCH_LISTS';
export const FETCH_LIST = 'FETCH_LIST';
export const CLEAR_LISTS = 'CLEAR_LISTS';
export const LOAD_LISTS = 'LOAD_LISTS';
export const ADD_SELECTED_APPS_TO_LIST = 'ADD_SELECTED_APPS_TO_LIST';

export function fetchLists() {
  return { type: FETCH_LISTS };
}

export function loadLists(lists) {
  return { type: LOAD_LISTS, payload: { lists } };
}

export function addSelectedToList(id, apps) {
  return { type: ADD_SELECTED_APPS_TO_LIST, payload: { id, apps } };
}
