import Bugsnag from 'bugsnag-js';
import React from 'react';
import PropTypes from 'prop-types';
import jwt from 'jsonwebtoken';

Bugsnag.apiKey = "3cd7afb86ca3972cfde605c1e0a64a73";

class BugsnagWrapper extends React.Component {
  componentDidCatch (error, info) {
    Bugsnag.notifyException(error, {
      react: info,
      user_id: jwt.decode(localStorage.getItem('ms_jwt_auth_token')).user_id,
    })
  }

  render () {
    return this.props.children;
  }
}

BugsnagWrapper.propTypes = {
  children: PropTypes.element.isRequired,
};

export default BugsnagWrapper;
