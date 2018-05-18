import React from 'react';
import PropTypes from 'prop-types';
import { Popover, OverlayTrigger } from 'react-bootstrap';
import { capitalize } from 'utils/format.utils';
import { filterRankings } from 'utils/explore/general.utils';

const RankChangeCell = ({
  app: {
    id,
    platform,
    rankings: { charts },
  },
  getCategoryById,
  currentRankingsCountries,
  currentSort,
  changeType,
}) => {
  if (!charts || !charts.length) return <span className="invalid">No rankings data</span>;

  changeType = `${changeType}ly_change`;
  const filtered = filterRankings(charts, currentRankingsCountries, changeType, currentSort);
  if (!filtered.length) return 'No recorded changes';

  const changeIcon = (change) => {
    let color = '';
    if (change > 0) color = '#0c0';
    if (change < 0) color = '#ff4500';
    return (
      <span style={{ color }}>
        {change ? <i className={`fa fa-${change > 0 ? 'arrow-up' : 'arrow-down'}${filtered.length > 1 ? ' dotted' : ''}`} /> : null}
        {' '}
        {Math.abs(change)}
      </span>
    );
  };

  const baseChart = filtered[0];
  const base = (
    <span>
      <img src={`/lib/images/flags/${baseChart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
      <span className={filtered.length > 1 ? 'dotted-link' : ''}>
        {`${baseChart.country} Top ${capitalize(baseChart.ranking_type)} ${getCategoryById(baseChart.category, platform).name}: `}
        {changeIcon(baseChart[changeType])}
      </span>
    </span>
  );

  if (filtered.length === 1) return base;

  const popover = (
    <Popover id="popover-trigger-hover-focus" bsClass="rankings-popover popover">
      <div className="rankings-scroll">
        <ul className="international-data">
          {filtered.map(chart => (
            <li key={`${chart.country}_${chart.category}_${chart.rank}_${id}`} className="rank-change-li">
              <img src={`/lib/images/flags/${chart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
              {`${chart.country} Top ${capitalize(chart.ranking_type)} ${getCategoryById(chart.category, platform).name}: `}
              {changeIcon(chart[changeType])}
            </li>
          ))}
        </ul>
      </div>
    </Popover>
  );

  return (
    <div>
      <OverlayTrigger container={document.querySelector('.explore-page')} overlay={popover} placement="left" rootClose trigger={['click']}>
        {base}
      </OverlayTrigger>
    </div>
  );
};

RankChangeCell.propTypes = {
  app: PropTypes.shape({
    platform: PropTypes.string,
    rankings: PropTypes.shape({
      charts: PropTypes.array,
    }),
  }).isRequired,
  getCategoryById: PropTypes.func.isRequired,
  currentRankingsCountries: PropTypes.string.isRequired,
  currentSort: PropTypes.shape({
    id: PropTypes.string,
    desc: PropTypes.bool,
  }).isRequired,
  changeType: PropTypes.string,
};

RankChangeCell.defaultProps = {
  changeType: 'week',
};

export default RankChangeCell;
