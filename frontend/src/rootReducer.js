import { combineReducers } from 'redux';

import account from 'reducers/Account.reducers';
import appPage from 'containers/AppPage/redux/App.reducers';
import appStoreInfo from 'reducers/AppStore.reducers';
import explorePage from 'containers/ExplorePage/redux/Explore.reducers';
import lists from 'reducers/List.reducers';
import publisherPage from 'containers/PublisherPage/redux/Publisher.reducers';

const rootReducer = combineReducers({
  account,
  appPage,
  appStoreInfo,
  explorePage,
  lists,
  publisherPage,
});

export default rootReducer;
