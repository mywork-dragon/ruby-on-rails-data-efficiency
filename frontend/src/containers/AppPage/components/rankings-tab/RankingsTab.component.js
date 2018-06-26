import React from 'react';
import PropTypes from 'prop-types';
import Table from 'components/table/Table.container';
import { headerNames } from 'components/table/redux/column.models';
import NoDataMessage from 'Messaging/NoData.component';

const RankingsTab = ({
  rankings,
  platform,
  newcomers,
}) => {
  const columns = {
    [headerNames.COUNTRY]: true,
    [headerNames.CATEGORY]: true,
    [headerNames.SIMPLE_RANK]: true,
    [headerNames.SIMPLE_WEEK_CHANGE]: true,
    [headerNames.SIMPLE_MONTH_CHANGE]: true,
    [headerNames.SIMPLE_ENTERED_CHART]: true,
  };

  const charts = rankings.map((x) => {
    const newcomerChart = newcomers.find(y => y.category === x.category && y.country === x.country && y.ranking_type === x.ranking_type);
    const date = newcomerChart ? newcomerChart.date : null;

    return {
      ...x,
      date,
      platform,
    };
  });

  return (
    <div id="appPage">
      <div className="col-md-12 info-column">
        { charts.length ? (
          <Table
            columns={columns}
            pageSize={charts.length}
            platform={platform}
            results={charts}
            resultsCount={charts.length}
            showHeader={false}
            showPagination={false}
          />
        ) : (
          <NoDataMessage>
            No Rankings Data
          </NoDataMessage>
        )}
      </div>
    </div>
  );
};

RankingsTab.propTypes = {
  platform: PropTypes.string.isRequired,
  rankings: PropTypes.arrayOf(PropTypes.object),
  newcomers: PropTypes.arrayOf(PropTypes.object),
};

RankingsTab.defaultProps = {
  rankings: [],
  newcomers: [],
};

export default RankingsTab;
