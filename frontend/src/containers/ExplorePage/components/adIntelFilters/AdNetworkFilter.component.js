import React from 'react';
import PropTypes from 'prop-types';
import { Select, DatePicker } from 'antd';
import moment from 'moment';

const Option = Select.Option;

const AdNetworkFilter = ({
  filter: {
    value,
    value: {
      adNetworks,
      operator,
      firstSeenDateRange,
      lastSeenDateRange,
      firstSeenDate,
      lastSeenDate,
    },
  },
  accountNetworks,
  panelKey,
  updateFilter,
  facebookOnly,
}) => {
  const updateAdNetworkFilter = field => (val) => {
    if (field === 'adNetworks') {
      val = val.map((x) => {
        if (Array.isArray(x.label)) {
          return { ...x, label: `${x.label[2]}` };
        }
        return x;
      });
    }

    const newFilter = {
      ...value,
      [field]: val,
    };

    updateFilter('adNetworks', newFilter, { panelKey })();
  };

  return (
    <li className="li-filter ad-networks">
      <div className="ad-date-options-group">
        Advertising on
        {facebookOnly && ' '}
        {!facebookOnly && (
          <span>
            <Select
              getPopupContainer={() => document.getElementById('ad-network-filter')}
              onChange={updateAdNetworkFilter('operator')}
              size="small"
              value={operator}
            >
              <Option value="any">any</Option>
              <Option value="all">all</Option>
            </Select>
            of
            {' '}
          </span>
        )}
        the following:
      </div>
      <div className="li-select">
        <Select
          allowClear
          getPopupContainer={() => document.getElementById('ad-network-filter')}
          labelInValue
          mode="multiple"
          onChange={updateAdNetworkFilter('adNetworks')}
          placeholder="Add ad networks"
          style={{ width: '100%' }}
          value={adNetworks}
        >
          {
            accountNetworks.map(x => (
              <Option
                key={x.id}
                value={x.id}
              >
                <img src={x.icon} />
                {' '}
                {x.name}
              </Option>
            ))
          }
        </Select>
      </div>
      <div className="ad-date-options-group" id="ad-network-filter">
        First Seen Ads:
        <Select
          getPopupContainer={() => document.getElementById('ad-network-filter')}
          onChange={updateAdNetworkFilter('firstSeenDateRange')}
          size="small"
          style={{ width: 175 }}
          value={firstSeenDateRange}
        >
          <Option value="anytime">Anytime</Option>
          <Option value="week">Last Week</Option>
          <Option value="month">Last Month</Option>
          <Option value="three-months">Last Three Months</Option>
          <Option value="before-date">Before Date</Option>
          <Option value="after-date">After Date</Option>
        </Select>
        {
          ['before-date', 'after-date'].includes(firstSeenDateRange) && (
            <DatePicker
              getCalendarContainer={() => document.getElementById('ad-network-filter')}
              onChange={updateAdNetworkFilter('firstSeenDate')}
              size="small"
              value={firstSeenDate}
            />
          )
        }
      </div>
      <div className="ad-date-options-group">
        Last Seen Ads:
        <Select
          getPopupContainer={() => document.getElementById('ad-network-filter')}
          onChange={updateAdNetworkFilter('lastSeenDateRange')}
          size="small"
          style={{ width: 175 }}
          value={lastSeenDateRange}
        >
          <Option value="anytime">Anytime</Option>
          <Option value="week">Last Week</Option>
          <Option value="month">Last Month</Option>
          <Option value="three-months">Last Three Months</Option>
          <Option value="before-date">Before Date</Option>
          <Option value="after-date">After Date</Option>
        </Select>
        {
          ['before-date', 'after-date'].includes(lastSeenDateRange) && (
            <DatePicker
              getCalendarContainer={() => document.getElementById('ad-network-filter')}
              onChange={updateAdNetworkFilter('lastSeenDate')}
              size="small"
              value={lastSeenDate}
            />
          )
        }
      </div>
    </li>
  );
};

AdNetworkFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.object,
  }),
  updateFilter: PropTypes.func.isRequired,
  panelKey: PropTypes.string.isRequired,
  accountNetworks: PropTypes.arrayOf(PropTypes.object),
  facebookOnly: PropTypes.bool.isRequired,
};

AdNetworkFilter.defaultProps = {
  accountNetworks: [],
  filter: {
    value: {
      adNetworks: [],
      operator: 'any',
      firstSeenDateRange: 'anytime',
      lastSeenDateRange: 'anytime',
      firstSeenDate: moment(),
      lastSeenDate: moment(),
    },
  },
};

export default AdNetworkFilter;
