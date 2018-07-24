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

const Select = (props) => {
  if (props.allowSelectAll) {
    if (props.value.length === props.options.length) {
      return (
        <ReactSelect
          arrowRenderer={SelectArrow}
          {...props}
          onChange={selected => props.onChange(selected.slice(1))}
          removeSelected={false}
        />
      );
    }

    return (
      <ReactSelect
        arrowRenderer={SelectArrow}
        {...props}
        onChange={(selected) => {
          if (
            selected.length > 0 &&
            selected[selected.length - 1].value === props.allOption.value
          ) {
            return props.onChange(props.options);
          }
          return props.onChange(selected);
        }}
        options={[props.allOption, ...props.options]}
        removeSelected={false}
      />
    );
  }

  let newOptions = props.options;
  const atMax = props.value !== null && !props.simpleValue && props.value.length === props.maxItems;
  if (atMax) {
    newOptions = [];
  }

  return (
    <ReactSelect
      arrowRenderer={SelectArrow}
      {...props}
      noResultsText={atMax ? props.maxText : 'No results found'}
      options={newOptions}
    />
  );
};

Select.propTypes = {
  options: PropTypes.array.isRequired,
  value: PropTypes.oneOfType([PropTypes.array, PropTypes.string, PropTypes.object, PropTypes.number]),
  onChange: PropTypes.func.isRequired,
  allowSelectAll: PropTypes.bool,
  allOption: PropTypes.shape({
    label: PropTypes.string,
    value: PropTypes.string,
  }),
  maxItems: PropTypes.number,
  maxText: PropTypes.string,
  simpleValue: PropTypes.bool,
};

Select.defaultProps = {
  allowSelectAll: false,
  allOption: {
    label: 'Select all',
    value: '*',
  },
  value: null,
  maxItems: null,
  maxText: 'Max options selected',
  simpleValue: false,
};

export default Select;
