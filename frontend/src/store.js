import { createStore, compose, applyMiddleware } from 'redux';
import createSagaMiddleware from 'redux-saga';

import rootReducer from 'rootReducer';
import runSagas from 'sagas';

const middlewares = [];

if (process.env.NODE_ENV === 'development') {
  const { logger } = require('redux-logger');
  middlewares.push(logger);
}

const sagaMiddleware = createSagaMiddleware();

middlewares.push(sagaMiddleware);

function configureStore(initialState) {
  /* eslint-disable no-underscore-dangle */
  const composeEnhancers = window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__ || compose;
  const store = createStore(rootReducer, initialState, composeEnhancers(applyMiddleware(...middlewares)));
  /* eslint-enable no-underscore-dangle */
  runSagas(sagaMiddleware);
  return store;
}

export const store = configureStore();
