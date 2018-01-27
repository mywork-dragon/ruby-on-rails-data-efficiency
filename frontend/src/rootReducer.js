import { combineReducers } from 'redux';

import account from 'reducers/Account.reducers';
import app from 'containers/AppPage/redux/App.reducers';
import explore from 'containers/ExplorePage/redux/Explore.reducers';
import lists from 'reducers/List.reducers';
import publisher from 'containers/PublisherPage/redux/Publisher.reducers';

const rootReducer = combineReducers({
  account,
  app,
  explore,
  lists,
  publisher,
});

export default rootReducer;
