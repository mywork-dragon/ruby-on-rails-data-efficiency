import accountSaga from 'sagas/Account.sagas';
import adIntelSaga from 'components/ad-intel-tab/redux/AdIntelTab.sagas';
import listSaga from 'sagas/List.sagas';

const runSagas = (sagaMiddleware) => {
  sagaMiddleware.run(accountSaga);
  sagaMiddleware.run(adIntelSaga);
  sagaMiddleware.run(listSaga);
};

export default runSagas;
