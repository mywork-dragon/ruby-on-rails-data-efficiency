import { combineReducers } from 'redux';

import app from 'containers/AppPage/redux/App.reducers';
import publisher from 'containers/PublisherPage/redux/Publisher.reducers';
import lists from 'reducers/List.reducers';

const rootReducer = combineReducers({
  app,
  publisher,
  lists,
});

export default rootReducer;
