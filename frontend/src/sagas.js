import accountSaga from 'sagas/Account.sagas';
import appRankingsMixpanelSaga from 'containers/AppPage/redux/Mixpanel.sagas';
import appSaga from 'containers/AppPage/redux/App.sagas';
import appStoreSaga from 'sagas/AppStore.sagas';
import bugsnagSaga from 'sagas/Bugsnag.sagas';
import exploreSaga from 'containers/ExplorePage/redux/Explore.sagas';
import exploreMixpanelSaga from 'containers/ExplorePage/redux/Mixpanel.sagas';
import listSaga from 'sagas/List.sagas';
import publisherSaga from 'containers/PublisherPage/redux/Publisher.sagas';
import tableSaga from 'Table/redux/Table.sagas';

const runSagas = (sagaMiddleware) => {
  sagaMiddleware.run(accountSaga);
  sagaMiddleware.run(appRankingsMixpanelSaga);
  sagaMiddleware.run(appSaga);
  sagaMiddleware.run(appStoreSaga);
  sagaMiddleware.run(bugsnagSaga);
  sagaMiddleware.run(exploreSaga);
  sagaMiddleware.run(exploreMixpanelSaga);
  sagaMiddleware.run(listSaga);
  sagaMiddleware.run(publisherSaga);
  sagaMiddleware.run(tableSaga);
};

export default runSagas;
