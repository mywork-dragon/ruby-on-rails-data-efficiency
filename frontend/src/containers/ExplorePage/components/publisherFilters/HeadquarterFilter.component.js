import React from 'react';
import PropTypes from 'prop-types';
import { Select, Checkbox } from 'antd';
import CustomSelect from 'components/select/CustomSelect.component';

const { Option } = Select;

const HeadquarterFilter = ({
  filter: {
    value: {
      values,
      includeNoHqData,
      operator,
    },
  },
  panelKey,
  updateFilter,
  headquarterOptions,
}) => (
  <li className="li-filter">
    <label className="filter-label">
      Headquartered in:
    </label>
    <div className="input-group headquarter" id="headquarter-filter">
      <Select
        getPopupContainer={() => document.getElementById(('headquarter-filter'))}
        onChange={(val) => {
          const newValue = {
            values,
            includeNoHqData,
            operator: val,
          };

          updateFilter('headquarters', newValue, { panelKey })();
        }}
        size="small"
        value={operator}
      >
        <Option value="any">Any</Option>
        <Option value="none">None</Option>
      </Select>
      <div className="following">
        of the following
      </div>
      <div className="li-select">
        <CustomSelect
          clearable
          multi
          name="headquarter-field"
          onChange={(vals) => {
            const newValue = {
              values: vals,
              operator,
              includeNoHqData,
            };

            updateFilter('headquarters', newValue, { panelKey })();
          }}
          options={headquarterOptions}
          placeholder="Select countries"
          searchable
          value={values}
        />
      </div>
      {/* <div>
        <Checkbox
          checked={includeNoHqData}
          className="explore-checkbox"
          disabled={values.length === 0}
          onChange={() => {
            const newValue = {
              values,
              operator,
              includeNoHqData: !includeNoHqData,
            };

            updateFilter('headquarters', newValue, { panelKey })();
          }}
        >
          Include results with no location data
        </Checkbox>
      </div> */}
    </div>
  </li>
);

HeadquarterFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.shape({
      values: PropTypes.array,
      includeNoHqData: PropTypes.bool,
      operator: PropTypes.oneOf(['any', 'none']),
    }),
  }),
  updateFilter: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
  headquarterOptions: PropTypes.arrayOf(PropTypes.shape({
    value: PropTypes.string,
    label: PropTypes.string,
  })),
};

HeadquarterFilter.defaultProps = {
  filter: {
    value: {
      values: [],
      includeNoHqData: false,
      operator: 'any',
    },
  },
  headquarterOptions: [],
};

export default HeadquarterFilter;
