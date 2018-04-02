/* eslint react/no-find-dom-node: 1 */

import React from 'react';
import PropTypes from 'prop-types';
import { findDOMNode } from 'react-dom';
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

const MAX_MENU_HEIGHT = 200;
const AVG_OPTION_HEIGHT = 36;

class Select extends React.Component {
  constructor(props) {
    super(props);

    this.state = {
      dropUp: false,
    };

    this.determineDropUp = this.determineDropUp.bind(this);
  }

  componentDidMount() {
    this.determineDropUp(this.props);
    window.addEventListener('resize', this.determineDropUp);
    document.querySelector('#content').addEventListener('scroll', this.determineDropUp);
  }

  componentWillReceiveProps(nextProps) {
    this.determineDropUp(nextProps);
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.determineDropUp);
    document.querySelector('#content').removeEventListener('scroll', this.determineDropUp);
  }

  determineDropUp(props = {}) {
    const options = props.options || this.props.options || [];
    const node = findDOMNode(this.selectInst);

    if (!node) return;

    const windowHeight = window.innerHeight;
    const menuHeight = Math.min(MAX_MENU_HEIGHT, (options.length * AVG_OPTION_HEIGHT));
    const instOffsetWithMenu = node.getBoundingClientRect().bottom + menuHeight;

    this.setState({
      dropUp: instOffsetWithMenu >= windowHeight,
    });
  }

  render() {
    const className = this.state.dropUp ? 'drop-up' : '';

    return (
      <ReactSelect
        {...this.props}
        arrowRenderer={SelectArrow}
        className={className}
        ref={inst => (this.selectInst = inst)}
      />
    );
  }
}

Select.propTypes = {
  options: PropTypes.array,
};

Select.defaultProps = {
  options: [],
};

export default Select;
