import React from 'react';
import PropTypes from 'prop-types';
import classnames from 'classnames';
import { Spin, Icon } from 'antd';

const antIcon = <Icon spin style={{ fontSize: 38 }} type="loading" />;

const LoadingSpinner = ({
  loading,
  loadingText,
  ...rest
}) => (
  <div
    className={classnames('-loading', { '-active': loading })}
    {...rest}
  >
    <div className="-loading-inner">
      <Spin indicator={antIcon} />
    </div>
  </div>
);

LoadingSpinner.propTypes = {
  loading: PropTypes.bool.isRequired,
  loadingText: PropTypes.string,
};

LoadingSpinner.defaultProps = {
  loadingText: 'Loading...',
};

export default LoadingSpinner;
