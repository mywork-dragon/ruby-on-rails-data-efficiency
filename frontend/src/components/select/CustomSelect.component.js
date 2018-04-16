import React from 'react';
import PropTypes from 'prop-types';
import ReactSelect from 'react-select';
import { Icon } from 'antd';

const SelectArrow = ({ isOpen }) => {
  const style = {
    color: 'rgba(0, 0, 0, 0.25)',
    fontSize: '12px',
    margin: 0,
  };

  if (isOpen) {
    return <Icon style={style} type="up" />;
  }

  return <Icon style={style} type="down" />;
};

SelectArrow.propTypes = {
  isOpen: PropTypes.bool.isRequired,
};

const Select = props => (
  <ReactSelect
    {...props}
    arrowRenderer={SelectArrow}
  />
);

export default Select;
