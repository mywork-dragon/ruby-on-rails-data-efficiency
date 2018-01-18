import React from 'react';
import PropTypes from 'prop-types';

import TableHeader from 'Table/TableHeader.component';
import AppTableCell from './components/AppTableCell.component';
import ListDropdownContainer from './containers/ListDropdown.container';

const AppTableComponent = ({
  apps,
  networks,
  platform,
  selectedApps,
  tableHeader,
  toggleAll,
  toggleItem,
  columnHeaders,
}) => {
  if (apps.length === 0) {
    return null;
  }

  return (
    <div className="page-table">
      <section className="panel panel-default table-dynamic">
        <div className="panel-heading" id="listViewTableHeading">
          <strong>
            <i className="fa fa-list panel-icon" />
            {tableHeader}
          </strong>
          {' '}|{' '}
          <span id="dashboardResultsTableHeadingNumDisplayed">{apps.length} apps</span>
          <ListDropdownContainer
            selectedApps={selectedApps}
          />
        </div>
        <div id="results-table-wrapper">
          <table className="table table-bordered table-striped table-responsive" id="companyDetailsTable">
            <TableHeader allSelected={apps.length === selectedApps.length} headers={columnHeaders} toggleAll={toggleAll} />
            <tbody>
              {
                apps.map(app => (
                  <tr key={`${app.id}-row`}>
                    {
                      columnHeaders.map(column => (
                        <AppTableCell
                          key={`${app.id}-${column}`}
                          app={app}
                          allSelected={selectedApps.some(x => x.id === app.id && x.type === app.type)}
                          isAdIntel
                          networks={networks}
                          platform={platform}
                          toggleItem={() => toggleItem(app.id, app.type)}
                          type={column}
                        />
                      ))
                    }
                  </tr>
                ))
              }
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
};

AppTableComponent.propTypes = {
  apps: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
    number_of_creatives: PropTypes.number,
    first_seen_ads_date: PropTypes.string,
    last_seen_ads_date: PropTypes.string,
    ad_attribution_sdks: PropTypes.arrayOf(PropTypes.object),
    ad_networks: PropTypes.arrayOf(PropTypes.object),
    last_scanned: PropTypes.string,
  })).isRequired,
  networks: PropTypes.arrayOf(PropTypes.object).isRequired,
  platform: PropTypes.string.isRequired,
  selectedApps: PropTypes.arrayOf(PropTypes.shape({
    id: PropTypes.string,
    name: PropTypes.string,
    number_of_creatives: PropTypes.number,
    first_seen_ads_date: PropTypes.string,
    last_seen_ads_date: PropTypes.string,
    ad_attribution_sdks: PropTypes.arrayOf(PropTypes.object),
    ad_networks: PropTypes.arrayOf(PropTypes.object),
    last_scanned: PropTypes.string,
  })).isRequired,
  tableHeader: PropTypes.string,
  toggleAll: PropTypes.func.isRequired,
  toggleItem: PropTypes.func.isRequired,
  columnHeaders: PropTypes.arrayOf(PropTypes.string),
};

AppTableComponent.defaultProps = {
  columnHeaders: [],
  tableHeader: 'Apps',
};

export default AppTableComponent;
