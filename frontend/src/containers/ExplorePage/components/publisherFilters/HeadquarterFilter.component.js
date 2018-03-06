import React from 'react';
import PropTypes from 'prop-types';
import { capitalize } from 'utils/format.utils';
import { Select, Spin } from 'antd';
import ExploreService from 'services/explore.service';

const Option = Select.Option;

class HeadquarterFilter extends React.Component {
  constructor (props) {
    super(props);
    this.fetchCountryOptions = this.fetchCountryOptions.bind(this);
    this.lastFetchId = 0;

    this.state = {
      countryOptions: [],
      fetching: false,
    };
  }

  fetchCountryOptions (value) {
    if (value === '') {
      return;
    }

    this.lastFetchId += 1;
    const fetchId = this.lastFetchId;
    this.setState({ countryOptions: [], fetching: true });
    ExploreService().getCountryAutocompleteResults(0, value)
      .then((response) => {
        if (fetchId !== this.lastFetchId) {
          return;
        }

        this.setState({ countryOptions: response.data.results, fetching: false });
      });
  }


  render () {
    const {
      filter: {
        value,
      },
      panelKey,
      updateFilter,
    } = this.props;

    const { countryOptions, fetching } = this.state;

    return (
      <li>
        <label className="filter-label">
          Headquartered in any:
        </label>
        <div className="input-group headquarter">
          <div>
            <Select
              allowClear
              filterOption={false}
              labelInValue
              mode="multiple"
              notFoundContent={fetching ? <Spin size="small" /> : null}
              onChange={values => updateFilter('headquarters', values, { panelKey })()}
              onSearch={this.fetchCountryOptions}
              placeholder="Search countries"
              value={value}
            >
              {countryOptions.map(x => (
                <Option key={`${x.name}${x.id}`} value={`${x.id}`}>
                  {x.name}
                </Option>
              ))}
            </Select>
          </div>
        </div>
      </li>
    );
  }
}

HeadquarterFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.array,
  }),
  updateFilter: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
};

HeadquarterFilter.defaultProps = {
  filter: {
    value: [],
  },
};

export default HeadquarterFilter;
