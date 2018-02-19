import accountSaga from 'sagas/Account.sagas';
import appSaga from 'containers/AppPage/redux/App.sagas';
import exploreSaga from 'containers/ExplorePage/redux/Explore.sagas';
import listSaga from 'sagas/List.sagas';
import publisherSaga from 'containers/PublisherPage/redux/Publisher.sagas';
import tableSaga from 'Table/redux/Table.sagas';

const runSagas = (sagaMiddleware) => {
  sagaMiddleware.run(accountSaga);
  sagaMiddleware.run(appSaga);
  sagaMiddleware.run(exploreSaga);
  sagaMiddleware.run(listSaga);
  sagaMiddleware.run(publisherSaga);
  sagaMiddleware.run(tableSaga);
};

export default runSagas;
