import jwt from 'jsonwebtoken';
import moment from 'moment';

export const isValidToken = (token) => {
  if (token) {
    const { exp } = jwt.decode(token);

    return moment() < moment.unix(exp);
  }

  return false;
};
