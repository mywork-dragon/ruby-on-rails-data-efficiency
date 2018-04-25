import jwt from 'jsonwebtoken';
import moment from 'moment';
import { $localStorage } from './localStorage.utils';

export const isValidToken = (token) => {
  if (token) {
    const { exp } = jwt.decode(token);

    return moment() < moment.unix(exp);
  }

  return false;
};

export const getUserIdFromToken = () => {
  const token = localStorage.getItem('ms_jwt_auth_token');

  return token ? jwt.decode(token).user_id : null;
};

export const tokenExpired = () => {
  const fetchTime = $localStorage.get('queryTokenFetchTime');
  if (!fetchTime) return true;
  const diff = moment().diff(fetchTime, 'minutes');
  return diff > 60;
};
