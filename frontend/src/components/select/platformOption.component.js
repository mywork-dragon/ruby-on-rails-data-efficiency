import React from 'react';
import PropTypes from 'prop-types';
import { getNestedValue } from 'utils/format.utils';

class PlatformOption extends React.Component {
  constructor () {
    super();

    this.handleMouseDown = this.handleMouseDown.bind(this);
    this.handleMouseEnter = this.handleMouseEnter.bind(this);
    this.handleMouseMove = this.handleMouseMove.bind(this);
  }

  handleMouseDown (event) {
    event.preventDefault();
    event.stopPropagation();
    this.props.onSelect(this.props.option, event);
  }

  handleMouseEnter (event) {
    this.props.onFocus(this.props.option, event);
  }

  handleMouseMove (event) {
    if (this.props.isFocused) return;
    this.props.onFocus(this.props.option, event);
  }

  render () {
    return (
      <div
        className={this.props.className}
        onMouseDown={this.handleMouseDown}
        onMouseEnter={this.handleMouseEnter}
        onMouseMove={this.handleMouseMove}
        title={this.props.option.title}
      >
        {this.props.children}
        <div className="select-option-platforms">
          {this.props.option.ios && <i className="fa fa-apple" />}
          {this.props.option.android && <i className="fa fa-android" />}
        </div>
      </div>
    );
  }
}

PlatformOption.propTypes = {
  children: PropTypes.node,
  className: PropTypes.string,
  isFocused: PropTypes.bool,
  onFocus: PropTypes.func,
  onSelect: PropTypes.func,
  option: PropTypes.object.isRequired,
};

PlatformOption.defaultProps = {
  children: null,
  className: '',
  isFocused: false,
  onFocus: null,
  onSelect: null,
};

export default PlatformOption;
