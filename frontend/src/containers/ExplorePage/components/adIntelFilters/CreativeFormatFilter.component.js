import React from 'react';
import PropTypes from 'prop-types';
import { Checkbox } from 'antd';

const CreativeFormatFilter = ({
  filter: {
    value,
  },
  panelKey,
  updateFilter,
}) => (
  <li className="li-filter">
    <label className="filter-label">
      Creative Formats:
    </label>
    <div className="input-group">
      <Checkbox
        key="html_game"
        checked={value.includes('html_game')}
        onChange={updateFilter('creativeFormats', 'html_game', { panelKey })}
      >
        Playable
      </Checkbox>
      <Checkbox
        key="video"
        checked={value.includes('video')}
        onChange={updateFilter('creativeFormats', 'video', { panelKey })}
      >
        Video
      </Checkbox>
    </div>
  </li>
);

CreativeFormatFilter.propTypes = {
  filter: PropTypes.shape({
    value: PropTypes.array,
  }),
  panelKey: PropTypes.string.isRequired,
  updateFilter: PropTypes.func.isRequired,
};

CreativeFormatFilter.defaultProps = {
  filter: {
    value: [],
  },
};

export default CreativeFormatFilter;
