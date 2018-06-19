import React from 'react';
import PropTypes from 'prop-types';

const PlatformValue = ({
  children,
  value,
  onRemove,
}) => (
  <div className="Select-value" title={value.title}>
    {
      onRemove && (
        <span
          aria-hidden="true"
          className="Select-value-icon"
          onClick={() => onRemove(value)}
        >
          ×
        </span>
      )
    }
    <span className="Select-value-label">
      {value.ios && <i className="fa fa-apple" />}
      {value.android && <i className="fa fa-android" />}
      {children}
    </span>
  </div>
);

PlatformValue.propTypes = {
  children: PropTypes.node,
  value: PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
    ios: PropTypes.string,
    android: PropTypes.string,
  }),
  onRemove: PropTypes.func,
};

PlatformValue.defaultProps = {
  children: null,
  onRemove: () => {},
  value: null,
};

export default PlatformValue;
