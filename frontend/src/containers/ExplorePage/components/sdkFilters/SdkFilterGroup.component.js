import React from 'react';
import PropTypes from 'prop-types';
import { Select, DatePicker, Icon, Spin, Tooltip } from 'antd';
import { capitalize } from 'utils/format.utils';
import ExploreService from 'services/explore.service';

import SdkCategoryFilter from './SdkCategoryFilter.component';

const Option = Select.Option;
const RangePicker = DatePicker.RangePicker;

class SdkFilterGroup extends React.Component {
  constructor (props) {
    super(props);
    this.fetchSdkOptions = this.fetchSdkOptions.bind(this);
    this.updateSdkFilter = this.updateSdkFilter.bind(this);
    this.lastFetchId = 0;

    this.state = {
      sdkOptions: [],
      fetching: false,
    };
  }

  fetchSdkOptions (value) {
    if (value === '') {
      return;
    }

    this.lastFetchId += 1;
    const fetchId = this.lastFetchId;
    this.setState({ sdkOptions: [], fetching: true });
    ExploreService.getSdkAutocompleteResults(this.props.platform, value)
      .then((response) => {
        if (fetchId !== this.lastFetchId) {
          return;
        }
        const sdks = response.data.results.map(x => ({ ...x, platform: x.platform.toLowerCase() }));

        this.setState({ sdkOptions: sdks, fetching: false });
      });
  }

  updateSdkFilter (values) {
    const { updateFilter, index, filter } = this.props;
    const options = filter.sdks.concat(this.state.sdkOptions);
    const newSdks = values.map((val) => {
      const [id, platform] = val.key.split('_');
      const sdk = options.find(x => x.id === parseInt(id, 10) && x.platform === platform && !x.sdks);
      return { ...sdk, ...val, label: `${sdk.name} (${capitalize(sdk.platform)})` };
    });
    const newFilter = {
      ...filter,
      sdks: newSdks.concat(filter.sdks.filter(x => x.sdks)),
    };
    updateFilter('sdks', newFilter, { index })();
  }

  render () {
    const {
      canDelete,
      deleteFilter,
      duplicateSdkFilter,
      filter,
      filter: {
        dateRange,
        dates,
        eventType,
        sdks,
        operator,
        installState,
      },
      index,
      updateFilter,
      ...rest
    } = this.props;

    const { sdkOptions, fetching } = this.state;

    const showDateOptions = !['never-seen', 'is-installed', 'is-not-installed'].includes(eventType);
    const showDatePicker = !['never-seen', 'is-installed', 'is-not-installed'].includes(eventType) && dateRange === 'custom';

    return (
      <div className="sdk-filter-group" id={`sdk-filter-${index}`}>
        <div className="options-group">
          <div className="action-items">
            { canDelete && <Icon onClick={() => deleteFilter('sdks', index)} type="delete" /> }
            <Tooltip title="Duplicate filter">
              <Icon onClick={duplicateSdkFilter(index)} type="copy" />
            </Tooltip>
          </div>
          <Select
            getPopupContainer={() => document.getElementById((`sdk-filter-${index}`))}
            onChange={(value) => {
              const newFilter = {
                ...filter,
                eventType: value,
              };
              updateFilter('sdks', newFilter, { index })();
            }}
            size="small"
            style={{
              width: '150px',
            }}
            value={eventType}
          >
            <Option value="install">Installed</Option>
            <Option value="uninstall">Uninstalled</Option>
            <Option value="never-seen">Never Seen</Option>
          </Select>
          {
            showDateOptions && (
              <Select
                getPopupContainer={() => document.getElementById((`sdk-filter-${index}`))}
                onChange={(value) => {
                  const newFilter = {
                    ...filter,
                    dateRange: value,
                  };
                  updateFilter('sdks', newFilter, { index })();
                }}
                size="small"
                style={{
                  width: '160px',
                }}
                value={dateRange}
              >
                <Option value="anytime">Anytime</Option>
                <Option value="week">Last Week</Option>
                <Option value="month">Last Month</Option>
                <Option value="three-months">Last Three Months</Option>
                <Option value="six-months">Last Six Months</Option>
                <Option value="year">Last Year</Option>
                <Option value="custom">Custom Date Range</Option>
              </Select>
            )
          }
          { showDatePicker && (
            <RangePicker
              getCalendarContainer={() => document.getElementById((`sdk-filter-${index}`))}
              onChange={(value) => {
                const newFilter = {
                  ...filter,
                  dates: value,
                };
                updateFilter('sdks', newFilter, { index })();
              }}
              size="small"
              style={{ width: '225px' }}
              value={dates}
            />
          ) }
          {eventType !== 'never-seen' && (
            <div style={{ marginRight: 10, display: 'inline' }}>
              and
            </div>
          )}
          {eventType !== 'never-seen' && (
            <Select
              getPopupContainer={() => document.getElementById((`sdk-filter-${index}`))}
              onChange={(value) => {
                const newFilter = {
                  ...filter,
                  installState: value,
                };
                updateFilter('sdks', newFilter, { index })();
              }}
              size="small"
              style={{ width: 300 }}
              value={installState}
            >
              <Option key="is-installed">Currently Installed</Option>
              <Option key="is-not-installed">Currently Not Installed</Option>
              <Option key="any-installed">Either Currently Installed or Not Installed</Option>
            </Select>
          )}
          <Select
            getPopupContainer={() => document.getElementById((`sdk-filter-${index}`))}
            onChange={(value) => {
              const newFilter = {
                ...filter,
                operator: value,
              };
              updateFilter('sdks', newFilter, { index })();
            }}
            size="small"
            style={{
              width: '80px',
            }}
            value={operator}
          >
            {['any', 'all'].map(x => (
              <Option key={`${index}sdk${x}`} value={x}>{capitalize(x)}</Option>
            ))}
          </Select>
        </div>
        <div className="following">
          of the following SDKs
        </div>
        <Select
          allowClear
          filterOption={false}
          getPopupContainer={() => document.getElementById((`sdk-filter-${index}`))}
          labelInValue
          mode="multiple"
          notFoundContent={fetching ? <Spin size="small" /> : null}
          onChange={this.updateSdkFilter}
          onSearch={this.fetchSdkOptions}
          placeholder="Add SDKs"
          value={sdks.filter(x => !x.sdks)}
        >
          {sdkOptions.map(x => (
            <Option key={`${x.id}_${x.platform}`} value={`${x.id}_${x.platform}`}>
              <div className="sdk-select-option">
                <i alt={x.platform} className={`fa fa-${x.platform === 'ios' ? 'apple' : 'android'}`} />
                {x.name}
                {' '}
                { x.type === 'sdkCategory' && <span style={{ fontSize: '12px' }}>(Category)</span> }
              </div>
            </Option>
          ))}
        </Select>
        <div className="following categories">
          and SDK categories
        </div>
        <SdkCategoryFilter filter={filter} index={index} updateFilter={updateFilter} {...rest} />
      </div>
    );
  }
}

SdkFilterGroup.propTypes = {
  canDelete: PropTypes.bool.isRequired,
  deleteFilter: PropTypes.func.isRequired,
  duplicateSdkFilter: PropTypes.func.isRequired,
  filter: PropTypes.shape({
    dateRange: PropTypes.string,
    dates: PropTypes.array,
    eventType: PropTypes.string,
    sdks: PropTypes.array,
    operator: PropTypes.string,
    installState: PropTypes.string,
  }).isRequired,
  index: PropTypes.number.isRequired,
  platform: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

export default SdkFilterGroup;
