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
            <button>
              Columns
              <i className="fa fa-caret-down" />
            </button>
            <ul className="dropdown-menu-form">
              {
                Object.keys(this.state.columns).map((column) => {
                  const isActive = this.state.columns[column] === true;
                  const isLocked = this.state.columns[column] === 'Locked';
                  return isLocked ? null : (
                    <li key={column}>
                      <div className="option">
                        <div className="checkbox">
                          <label>
                            <input
                              checked={isActive}
                              className="checkboxInput"
                              onChange={() => this.toggleColumn(column)}
                              type="checkbox"
                            />
                            <span>{column}</span>
                          </label>
                        </div>
                      </div>
                    </li>
                  );
                })
              }
            </ul>
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
