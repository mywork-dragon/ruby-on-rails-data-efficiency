/* global window */
import hello from 'hellojs';
import axios from 'axios';

const JWT_TOKEN = 'ms_jwt_auth_token';

export const getToken = (w = window) => (
  w.localStorage.getItem(JWT_TOKEN)
);

// Do not use shared http to prevent circular dependency
const http = axios.create({
  headers: { Authorization: getToken() },
});

const setToken = (payload, w = window) => (
  w.localStorage.setItem(JWT_TOKEN, payload)
);

const cleanupHello = (w = window) => (
  w.localStorage.removeItem('hello')
);

const initializeOauth = () => {
  hello.init({
    google: '341121226980-egcfb2qebu8skkjq63i1cdfpvahrcuak.apps.googleusercontent.com',
    linkedin: '755ulzsox4aboj',
  }, {
    scope: ['email'],
    oauth_proxy: '/auth/oauth_proxy', // TODO: This breaks LinkedIn auth in local development because it doesn't use react-scripts development proxy. Fix is http://localhost:3000/auth/oauth_proxy
  });
};

initializeOauth();

/* Public Methods */

export const isAuthenticated = () => (
  getToken() !== null
);

export const loginProvider = (provider, inviteCode) => {
  const options = {
    state: JSON.stringify({
      token: inviteCode,
    }),
    redirect_uri: '/app/login',
  };

  return hello.login(provider, options).then((auth) => {
    cleanupHello();
    return auth;
  });
};

export const authenticateWithProviderToken = (provider, accessToken, inviteCode) => (
  http.post(
    `/auth/${provider}`,
    {
      access_token: accessToken,
      token: getToken() || inviteCode,
      redirectUri: '/app/login',
    },
  ).then((response) => {
    setToken(response.data.auth_token);
    return response.data.auth_token;
  })
);

  // if (this.permissions) {
  //   return Promise.resolve(this.permissions);
  // }

  // if (!this.isAuthenticated()) {
  //   // TODO: should redirect to login page
  //   // Maybe return a rejected Promise that caller can then redirect?
  //   this.permissions = null;
  //   return Promise.reject(new Error('Not Authenticated'));
  // }

  // return this.http.get('/auth/permissions')
  //   .then((response) => {
  //     this.permissions = response;
  //     return Promise.resolve(this.permissions);
  //   })
  //   .catch((error) => {
  //     throw error;
  //   });
