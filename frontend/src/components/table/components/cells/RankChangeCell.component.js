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
  rest: {
    getCategoryById,
    currentRankingsCountries,
  },
  changeType,
}) => {
  if (!charts) return <span className="invalid">No rankings data</span>;

  changeType = `${changeType}ly_change`;
  const chartsWithChange = charts.filter(x => x[changeType]);
  const filtered = filterRankings(chartsWithChange, currentRankingsCountries, changeType);

  if (filtered.length === 0) {
    return <span className="invalid">No recorded change</span>;
  }

  const changeIcon = (change) => {
    let color = '';
    if (change > 0) color = '#0c0';
    if (change < 0) color = '#ff4500';
    return (
      <span style={{ color }}>
        {change !== 0 && <i className={`fa fa-${change > 0 ? 'arrow-up' : 'arrow-down'}${chartsWithChange.length > 1 ? ' dotted' : ''}`} />}
        {' '}
        {Math.abs(change)}
      </span>
    );
  };

  const baseChart = filtered[0];
  const base = (
    <span>
      <img src={`/lib/images/flags/${baseChart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
      <span className={filtered.length > 1 ? 'tooltip-item' : ''}>
        {`Top ${capitalize(baseChart.ranking_type)} ${getCategoryById(baseChart.category, platform).name}: `}
        {changeIcon(baseChart[changeType])}
      </span>
    </span>
  );

  if (filtered.length === 1) return base;

  const remainingCharts = charts.length - filtered.length;

  const popover = (
    <Popover id="popover-trigger-hover-focus" bsClass="rankings-popover popover">
      <ul className="international-data">
        {filtered.map(chart => (
          <li key={`${chart.country}_${chart.category}_${chart.rank}_${id}`} className="rank-change-li">
            <img src={`/lib/images/flags/${chart.country.toLowerCase()}.png`} style={{ marginRight: 5 }} />
            {`Top ${capitalize(chart.ranking_type)} ${getCategoryById(chart.category, platform).name}: `}
            {changeIcon(chart[changeType])}
          </li>
        ))}
        {remainingCharts > 0 && <li>... and {remainingCharts} more charts</li>}
      </ul>
    </Popover>
  );

  return (
    <div>
      <OverlayTrigger overlay={popover} placement="left" trigger={['hover', 'focus']}>
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
  rest: PropTypes.shape({
    getCategoryById: PropTypes.func,
    currentRankingsCountries: PropTypes.string,
  }).isRequired,
  changeType: PropTypes.string,
};

RankChangeCell.defaultProps = {
  changeType: 'week',
};

export default RankChangeCell;
