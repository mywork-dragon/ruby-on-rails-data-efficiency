import React, { Component } from 'react';
import PropTypes from 'prop-types';
import { ButtonDropdown } from 'simple-react-bootstrap';

class ColumnPicker extends Component {
  constructor (props) {
    super();

    this.onClose = this.onClose.bind(this);
    this.toggleColumn = this.toggleColumn.bind(this);

    this.state = {
      open: false,
      columns: props.columns,
    };
  }

  componentWillReceiveProps (nextProps) {
    this.setState({ columns: nextProps.columns });
  }

  onClose () {
    this.setState({ open: false });
    this.props.onColumnChange(this.state.columns);
  }

  toggleColumn (column) {
    const newState = Object.assign({}, this.state.columns);
    newState[column] = !newState[column];
    this.setState({ columns: newState });
  }

  render () {
    return (
      <span className="-columnOptions">
        <span className="column-select">
          <ButtonDropdown
            ignoreContentClick
            onToggle={() => {
              if (this.state.open) {
                this.onClose();
              } else {
                this.setState({ open: true });
              }
            }}
            open={this.state.open}
          >
            <div className={`ant-select-sm ant-select ant-select-enabled ${this.state.open ? 'ant-select-open' : ''}`}>
              <div className="ant-select-selection ant-select-selection--single">
                <div className="ant-select-selection__rendered">
                  <div className="ant-select-selection-selected-value">
                    Columns
                  </div>
                </div>
                <span className="ant-select-arrow" />
              </div>
            </div>
            <div className="column-picker" style={{ position: 'absolute' }}>
              <div>
                <div className="ant-select-dropdown ant-select-dropdown--single ant-select-dropdown-placement-bottomLeft">
                  <div style={{ overflow: 'auto' }}>
                    <ul className="ant-select-dropdown-menu ant-select-dropdown-menu-root ant-select-dropdown-menu-vertical">
                      {
                        Object.keys(this.state.columns).map((column) => {
                          const isActive = this.state.columns[column] === true;
                          const isLocked = this.state.columns[column] === 'LOCKED';
                          return isLocked ? null : (
                            <li
                              key={column}
                              className={`ant-select-dropdown-menu-item ${isActive ? 'ant-select-dropdown-menu-item-selected' : ''}`}
                              onClick={() => this.toggleColumn(column)}
                            >
                              {column}
                            </li>
                          );
                        })
                      }
                    </ul>
                  </div>
                </div>
              </div>
            </div>
          </ButtonDropdown>
        </span>
      </span>
    );
  }
}

ColumnPicker.propTypes = {
  columns: PropTypes.shape({
    App: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
    Publisher: PropTypes.oneOfType([PropTypes.string, PropTypes.bool]),
  }).isRequired,
  onColumnChange: PropTypes.func.isRequired,
};

export default ColumnPicker;
