const initialState = {
  savedSearches: {
    loaded: false,
    searches: [],
  },
  columnOptions: [
    'Publisher',
    'Fortune Rank',
    'Mobile Priority',
    'Ad Networks',
    'Last Updated',
    'First Seen Ads',
    'Last Seens Ads',
    'User Base',
    'Ad Spend',
    'Category',
  ],
  // searchForm: {}
  // tableOptions: {}
  // apps: []
  // appTable: {}
};

function explore(state = initialState, action) {
  switch (action.type) {
    default:
      return state;
  }
}

export default explore;
